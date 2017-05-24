//
//  RecordSoundInstance.h
//  FriendBlood
//
//  Created by 豆子 on 17/5/23.
//  Copyright © 2017年 豆子. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

#import "RecodeView.h"

@protocol RecorderDeleagte <NSObject>

- (void)audioRecorderFinishRecordWithRecordDuration:(float)recordDuration withFilePath:(NSString *)filePath;

@end

@interface RecordSoundInstance : NSObject<AVAudioRecorderDelegate>

@property (nonatomic,strong) AVAudioRecorder *audioRecorder;//音频录音机
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;//音频播放器，用于播放录音文件
@property (nonatomic,strong) NSTimer *timer;//录音声波监控（注意这里暂时不对播放进行监控）

@property (nonatomic,strong) RecodeView *recodeView;

@property (nonatomic,assign) float recodeDuration;

//设置代理
@property (nonatomic,assign) id<RecorderDeleagte> delegate;

//开始录音
- (void)startRecordSound;

//暂停录音
- (void)pauseRecodeSound;

//结束录音
- (void)endRecordSound;

//播放录音
- (void)playRecordSound;

//清除录音
- (void)clearRecordSound;

@end
