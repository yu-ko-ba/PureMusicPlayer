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
    
    if (currentMusicNumber >= playlistLength) {
        [self pause];
        self.currentMusicNumber = 0;
        [self prepareToPlay:playlist[currentMusicNumber]];
    } else {
        currentMusicNumber++;
        [self prepareToPlay:playlist[currentMusicNumber]];
    }
}


// AudioOutputUnitStartすると繰り返し呼ばれる関数
static OSStatus thisIsCallbackFunction(void* inRefCon, AudioUnitRenderActionFlags* ioActionFlags, const AudioTimeStamp* inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList* ioData) {
    
    PureMusicPlayer *player = (__bridge PureMusicPlayer *)(inRefCon);
    
    UInt32 ioNumberFrames = inNumberFrames;
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


- (void)reInitAudioUnit {
    AudioOutputUnitStop(audioUnit);
    AudioUnitUninitialize(audioUnit);
    AudioComponentInstanceDispose(audioUnit);
    
    [self initAudioUnit];
    
    AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &clientDataFormat, sizeof(clientDataFormat));
    
    if (playingNow) {
        AudioOutputUnitStart(audioUnit);
    }
}


- (void)setPlaylist:(MPMediaItemCollection *)mediaItemCollection {
    playlist = mediaItemCollection.items;
    playlistLength = mediaItemCollection.count - 1;
    currentMusicNumber = 0;
    
    [self prepareToPlay:playlist[currentMusicNumber]];
}



- (void)play {
    if (canPlay) {
        printf("再生を開始します\n");
        playingNow = YES;
        
        AudioOutputUnitStart(audioUnit);
        
        if ([self.delegate respondsToSelector:@selector(thisFunctionCallWhenPlayingStart)]) {
            [self.delegate thisFunctionCallWhenPlayingStart];
        }
    }
}


- (void)pause {
    if (playingNow) {
        printf("再生を一時停止します\n");
        playingNow = NO;
        AudioOutputUnitStop(audioUnit);
        
        if ([self.delegate respondsToSelector:@selector(thisFunctionCallWhenMusicPaused)]) {
            [self.delegate thisFunctionCallWhenMusicPaused];
        }
    }
}


- (void)togglePlayPause {
    if (playingNow) {
        [self pause];
    } else if (canPlay) {
        [self play];
    }
}


- (void)stop {
    if (canPlay) {
        printf("再生を終了します\n");
    }
    playingNow = NO;
    canPlay = NO;
    pauseWhenCurrentMusicFinishedIsEnable = NO;
    
    AudioOutputUnitStop(audioUnit);
    
    if ([self.delegate respondsToSelector:@selector(thisFunctionCallWhenMusicStopped)]) {
        [self.delegate thisFunctionCallWhenMusicStopped];
    }
}


- (void)skipToPrevious {
    if (canPlay) {
        if (playingNow) {
            SInt64 currentSeek;
            ExtAudioFileTell(extAudioFile, &currentSeek);
            
            if (currentSeek > 30000) {
                ExtAudioFileSeek(extAudioFile, 0);
            } else if (currentMusicNumber >= 1){
                AudioOutputUnitStop(audioUnit);
                currentMusicNumber--;
                [self prepareToPlay:playlist[currentMusicNumber]];
                [self play];
            } else {
                [self pause];
                ExtAudioFileSeek(extAudioFile, 0);
            }
            
            printf("%lld\n", currentSeek);
        } else if (currentMusicNumber >= 1) {
            currentMusicNumber--;
            [self prepareToPlay:playlist[currentMusicNumber]];
        } else {
            ExtAudioFileSeek(extAudioFile, 0);
        }

    }
}


// 連打しても大丈夫。
- (void)skipToNext {
    if (canPlay) {
        if ((playingNow) && !(currentMusicNumber >= playlistLength)) {
            AudioOutputUnitStop(audioUnit);
            [self skipToNextForCallback];
            [self play];
        } else {
            [self skipToNextForCallback];
        }
    }
}


- (instancetype)init {
    self = [super init];
    if (self) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:NULL];
        [audioSession setActive:YES error:NULL];
        
        canPlay = NO;
        playingNow = NO;
        pauseWhenCurrentMusicFinishedIsEnable = NO;
        
        [self initAudioUnit];
    }
    return self;
}


- (void)dealloc {
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
