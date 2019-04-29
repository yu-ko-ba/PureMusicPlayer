//
//  PureMusicPlayer.h
//  PureMusicPlayer
//
//  Created by Yu Kobayashi on 2019/02/09.
//  Copyright © 2019 Yu Kobayashi. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

NS_ASSUME_NONNULL_BEGIN

@class PureMusicPlayer;

@protocol PureMusicPlayerDelegate <NSObject>

@optional -(void)thisFunctionIsCalledAtBeginningOfMusic;
@optional -(void)thisFunctionCallWhenPlayingStart;
@optional -(void)thisFunctionCallWhenMusicPaused;
@optional -(void)thisFunctionCallWhenMusicStopped;

@end

@interface PureMusicPlayer : NSObject

@property (nonatomic, weak) id<PureMusicPlayerDelegate> delegate;

@property ExtAudioFileRef extAudioFile;
@property AudioUnit audioUnit;

@property (readonly) MPMediaItemArtwork* currentArtwork;
@property (readonly) NSString *currentArtist;
@property (readonly) NSString *currentAlbumTitle;
@property (readonly) NSString *currentTitle;

@property (readonly) BOOL canPlay;
@property (readonly) BOOL playingNow;

@property int currentMusicNumber;

@property BOOL pauseWhenCurrentMusicFinishedIsEnable;

-(void)skipToNextForCallback;

-(void)initAudioUnit;

-(void)showMusicDataForInfoCenter;

-(void)prepareToPlay:(MPMediaItem*)inURL;

-(void)reInitAudioUnit;

-(void)setPlaylist:(MPMediaItemCollection*)mediaItemCollection;

-(void)play;
-(void)pause;
-(void)togglePlayPause;
-(void)stop;
-(void)skipToPrevious;
-(void)skipToNext;


//-(void)setVolumeAtOne;
//-(void)setVolumeAtZero;

+ (PureMusicPlayer *)sharedManager;
@end

NS_ASSUME_NONNULL_END
