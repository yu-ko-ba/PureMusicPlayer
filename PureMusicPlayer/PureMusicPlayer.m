//
//  PureMusicPlayer.m
//  PureMusicPlayer
//
//  Created by Yu Kobayashi on 2019/02/09.
//  Copyright © 2019 Yu Kobayashi. All rights reserved.
//

#import "PureMusicPlayer.h"

@implementation PureMusicPlayer

@synthesize extAudioFile;
@synthesize audioUnit;

@synthesize currentArtwork;
@synthesize currentArtist;
@synthesize currentAlbumTitle;
@synthesize currentTitle;

@synthesize canPlay;
@synthesize playingNow;

@synthesize currentMusicNumber;

@synthesize pauseWhenCurrentMusicFinishedIsEnable;

AudioStreamBasicDescription clientDataFormat;

NSArray<MPMediaItem *> *playlist;

NSUInteger playlistLength;


// プレイリストの最後だったら再生を停止する、そうじゃなかったら次の曲にスキップする ※連打するとバグる(*´∀｀*)
- (void)skipToNextForCallback {
  if (pauseWhenCurrentMusicFinishedIsEnable) {
    self.pauseWhenCurrentMusicFinishedIsEnable = NO;
    [self pause];
  }
  
  if (currentMusicNumber >= playlistLength) { // プレイリストの最後だったら、
    // 再生を停止してプレイリストの先頭に戻る。
    [self pause];
    self.currentMusicNumber = 0;
    [self prepareToPlay:playlist[currentMusicNumber]];
  } else { // そうでなかったら、
    // 次の曲を準備する(と、次の曲が再生される)。
    currentMusicNumber++;
    [self prepareToPlay:playlist[currentMusicNumber]];
  }
}


// AudioOutputUnitStartすると繰り返し呼ばれる関数
static OSStatus thisIsCallbackFunction(void* inRefCon, AudioUnitRenderActionFlags* ioActionFlags, const AudioTimeStamp* inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList* ioData) {
  // inRefConをPureMusicPlayer型に変換する。
  PureMusicPlayer *player = (__bridge PureMusicPlayer *)(inRefCon);
  
  // inNumberFramesの値をコピーしておく。
  UInt32 ioNumberFrames = inNumberFrames;
  // extAudioFileのデータをioDataに読み込む(と、それが再生される)。
  ExtAudioFileRead(player.extAudioFile, &ioNumberFrames, ioData);
  
  if (ioNumberFrames != inNumberFrames) {
    // 最後のフレームを読み込んだときの処理
    [player skipToNextForCallback]; // 停止を挟みたくないからこっち使う
  }
  
  return noErr;
}


// Audio Unitを準備する
- (void)initAudioUnit {
  AudioComponentDescription componentDescription;
  componentDescription.componentType = kAudioUnitType_Output;
  componentDescription.componentSubType = kAudioUnitSubType_RemoteIO;
  componentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
  
  AudioComponent component = AudioComponentFindNext(NULL, &componentDescription);
  
  AudioComponentInstanceNew(component, &audioUnit);
  
  AudioUnitInitialize(audioUnit);
  
  AURenderCallbackStruct callbackStruct;
  callbackStruct.inputProc = thisIsCallbackFunction;
  callbackStruct.inputProcRefCon = (__bridge void * _Nullable)(self);
  
  AudioUnitSetProperty(audioUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &callbackStruct, sizeof(AURenderCallbackStruct));
  
  // オーディオセッションを"Playback"に設定して、バックグラウンド再生できるようにする
  AVAudioSession *audioSession = [AVAudioSession sharedInstance];
  [audioSession setCategory:AVAudioSessionCategoryPlayback error:NULL];
  [audioSession setActive:YES error:NULL];
}


// 再生の準備をする
- (void)prepareToPlay:(MPMediaItem*)inItem {
  OSStatus resultOfOpenURL = ExtAudioFileOpenURL((__bridge CFURLRef _Nonnull)(inItem.assetURL), &extAudioFile);
  
  if (resultOfOpenURL != noErr) {
    fprintf(stderr, "\"ExtAudioFileOpenURL\"でエラーが起こりました。");
    canPlay = NO;
    return;
  }
  
  AudioStreamBasicDescription inFileDataFormat;
  UInt32 sizeOfAudioStreamBasicDescription = sizeof(AudioStreamBasicDescription);
  
  ExtAudioFileGetProperty(extAudioFile, kExtAudioFileProperty_FileDataFormat, &sizeOfAudioStreamBasicDescription, &inFileDataFormat);
  
  clientDataFormat.mSampleRate = inFileDataFormat.mSampleRate;
  clientDataFormat.mChannelsPerFrame = inFileDataFormat.mChannelsPerFrame;
  clientDataFormat.mFormatID = kAudioFormatLinearPCM;
  clientDataFormat.mFormatFlags = kAudioFormatFlagIsFloat | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved;
  clientDataFormat.mBitsPerChannel = 8 * sizeof(Float32);
  clientDataFormat.mBytesPerPacket = sizeof(Float32);
  clientDataFormat.mBytesPerFrame = sizeof(Float32);
  clientDataFormat.mFramesPerPacket = 1;
  clientDataFormat.mReserved = 0;
  
  ExtAudioFileSetProperty(extAudioFile, kExtAudioFileProperty_ClientDataFormat, sizeOfAudioStreamBasicDescription, &clientDataFormat);
  
  AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &clientDataFormat, sizeOfAudioStreamBasicDescription);
  
  ExtAudioFileSeek(extAudioFile, 0);
  
  canPlay = YES;
  
  currentArtwork = inItem.artwork;
  currentArtist = inItem.artist;
  currentAlbumTitle = inItem.albumTitle;
  currentTitle = inItem.title;
  
  if ([self.delegate respondsToSelector:@selector(thisFunctionIsCalledAtBeginningOfMusic)]) {
    [self.delegate thisFunctionIsCalledAtBeginningOfMusic];
  }
}


// Audio Unitを準備し直す。(雑音が混ざりだしたとき用。※本当に効果があるかはわからない)
- (void)reInitAudioUnit {
  // 一度Audio Unitを解放する。
  AudioOutputUnitStop(audioUnit);
  AudioUnitUninitialize(audioUnit);
  AudioComponentInstanceDispose(audioUnit);
  
  // Audio Unitをinitする。
  [self initAudioUnit];
  
  // Stream Formatを設定し直す。
  AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &clientDataFormat, sizeof(clientDataFormat));
  
  // もし曲の再生中に呼び出されていたら再生を再開する。
  if (playingNow) {
    AudioOutputUnitStart(audioUnit);
  }
}


// プレイリストをセットする。
- (void)setPlaylist:(MPMediaItemCollection *)mediaItemCollection {
  playlist = mediaItemCollection.items;
  playlistLength = mediaItemCollection.count - 1;
  currentMusicNumber = 0;
  
  // 再生中の曲をもう一度選んで再生しようとしたときもバグらないように連打してもバグらないように一旦停止する。
  AudioOutputUnitStop(audioUnit);
  
  [self prepareToPlay:playlist[currentMusicNumber]];
}


// 再生する。
- (void)play {
  if (canPlay) {
    printf("再生を開始します。\n");
    playingNow = YES;
    
    AudioOutputUnitStart(audioUnit);
    
    if ([self.delegate respondsToSelector:@selector(thisFunctionCallWhenPlayingStart)]) {
      [self.delegate thisFunctionCallWhenPlayingStart];
    }
  }
}


// 一時停止する。
- (void)pause {
  if (playingNow) {
    printf("再生を一時停止します。\n");
    playingNow = NO;
    AudioOutputUnitStop(audioUnit);
    
    if ([self.delegate respondsToSelector:@selector(thisFunctionCallWhenMusicPaused)]) {
      [self.delegate thisFunctionCallWhenMusicPaused];
    }
  }
}


// 再生中だったらpause()を呼ぶ、そうで無かったらplay()を呼ぶ。
- (void)togglePlayPause {
  if (playingNow) {
    [self pause];
  } else {
    [self play];
  }
}


// 再生を停止する。
- (void)stop {
  if (canPlay) {
    printf("再生を終了します。\n");
  }
  playingNow = NO;
  canPlay = NO;
  pauseWhenCurrentMusicFinishedIsEnable = NO;
  
  AudioOutputUnitStop(audioUnit);
  
  if ([self.delegate respondsToSelector:@selector(thisFunctionCallWhenMusicStopped)]) {
    [self.delegate thisFunctionCallWhenMusicStopped];
  }
}


// ◀︎◀︎ ←コレ
- (void)skipToPrevious {
  if (canPlay) { // 停止されていないときだけ実行する。
    if (playingNow) { // 再生中なら
      // 今の何フレーム目かを取得する。
      SInt64 currentSeek;
      ExtAudioFileTell(extAudioFile, &currentSeek);
      
      if (currentSeek >= 30000) { // 30000フレーム以上再生されていたら、
        // 曲の先頭に戻る。
        ExtAudioFileSeek(extAudioFile, 0);
      } else if (currentMusicNumber >= 1){ // そうでなくて、プレイリストの先頭でなかったら、
        // 連打してもバグらないように一旦停止する。
        AudioOutputUnitStop(audioUnit);
        
        // 一つ前の曲を再生する。
        currentMusicNumber--;
        [self prepareToPlay:playlist[currentMusicNumber]];
        [self play];
      } else { // プレイリストの先頭でかつ、再生したのが30000フレーム未満だったら
        // 一時停止して、曲の先頭に戻る。
        [self pause];
        ExtAudioFileSeek(extAudioFile, 0);
      }
      
      // 前の曲に戻るのか曲の先頭に戻るのかの分かれ目を見極める用。
      printf("%lldフレーム目のときにスキップしました。\n", currentSeek);
    } else if (currentMusicNumber >= 1) { // 再生中でなくてプレイリストの先頭でなかったら、
      // 一つ前の曲に戻る。
      currentMusicNumber--;
      [self prepareToPlay:playlist[currentMusicNumber]];
    } else { // プレイリストの先頭の曲で一時停止していたら、
      // 曲の先頭に戻る。
      ExtAudioFileSeek(extAudioFile, 0);
    }
    
  }
}


// 連打しても大丈夫。
- (void)skipToNext {
  if (canPlay) { // 停止されていないときだけ実行する。
    if ((playingNow) && !(currentMusicNumber >= playlistLength)) { // 再生中かつプレイリストの最後でないなら、
      // 連打してもバグらないように一旦停止する。
      AudioOutputUnitStop(audioUnit);
      
      // 次の曲にスキップする。
      [self skipToNextForCallback];
      // 再生を再開する。
      AudioOutputUnitStart(audioUnit);
    } else { // 再生中でない、またはプレイリストの先頭だったら、
      // skipToNextForCallback()を呼ぶ。
      [self skipToNextForCallback];
    }
  }
}


- (instancetype)init {
  self = [super init];
  if (self) {
    // 初期値を設定しておく。
    currentArtist = @"Artist";
    currentAlbumTitle = @"Album";
    currentTitle = @"Title";
    
    canPlay = NO;
    playingNow = NO;
    pauseWhenCurrentMusicFinishedIsEnable = NO;
    
    // Audio Unitを準備する。
    [self initAudioUnit];
  }
  return self;
}


static PureMusicPlayer *sharedInstance;

+ (PureMusicPlayer *)sharedManager {
  @synchronized (self) {
    if (!sharedInstance) {
      sharedInstance = [[self alloc] init];
    }
  }
  
  return sharedInstance;
}


- (void)dealloc {
  // Audio Unitを解放する。
  AudioOutputUnitStop(audioUnit);
  AudioUnitUninitialize(audioUnit);
  AudioComponentInstanceDispose(audioUnit);
}


// MultiChannel MixerっていうAudio unitを繋がないと動かないっぽい
//- (void)setVolumeAtOne {
//    AudioUnitSetParameter(audioUnit, kHALOutputParam_Volume, kAudioUnitScope_Input, 0, 0, 0);
//}
//- (void)setVolumeAtZero {
//    AudioUnitSetParameter(audioUnit, kHALOutputParam_Volume, kAudioUnitScope_Output, 0, 0, 0);
//}

@end
