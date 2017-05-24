//
//  RecordSoundInstance.m
//  FriendBlood
//
//  Created by 豆子 on 17/5/23.
//  Copyright © 2017年 豆子. All rights reserved.
//  录制音频文件

#import "RecordSoundInstance.h"

#define kRecordAudioFile @"myRecord.caf"

static NSString *_filePath;

@implementation RecordSoundInstance

- (instancetype)init{
    
    if (self = [super init]) {
        
        [self setAudioSession];
        
    }
    
    return self;
    
}

#pragma mark - 私有方法
/**
 *  设置音频会话
 */
-(void)setAudioSession{
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
    
    //设置后台播放
    NSError *sessionError;
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    //判断后台有没有播放
    if (audioSession == nil) {
        
        NSLog(@"Error creating sessing:%@", [sessionError description]);
        
    } else {
        
        [audioSession setActive:YES error:nil];
        
    }
    UInt32 audioRoute = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRoute), &audioRoute);
    
}


///var/mobile/Applications/F0CCA9DC-FFBE-4701-8396-2E6EB9509292/Documents/myRecord.caf
///var/mobile/Applications/F0CCA9DC-FFBE-4701-8396-2E6EB9509292/Documents/myRecord.caf
/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
-(NSDictionary *)getAudioSetting{
    //    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    //    //设置录音格式
    //    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    //    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    //    //设置通道,这里采用单声道
    //    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //    //每个采样点位数,分为8、16、24、32
    //    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    //    //是否使用浮点数采样
    //    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //    //....其他设置等
    //    return dicM;
    //录音设置
    NSMutableDictionary * recordSetting = [NSMutableDictionary dictionary];
    
    
    
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];//
    
    [recordSetting setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];//采样率
    
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];//声音通道，这里必须为双通道
    
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityLow] forKey:AVEncoderAudioQualityKey];//音频质量
    return recordSetting;
}

/**
 *  获得录音机对象
 *
 *  @return 录音机对象
 */
-(AVAudioRecorder *)audioRecorder{
    if (!_audioRecorder) {
        //创建录音文件保存路径
        NSURL *url=[self getSavePath];
        //创建录音格式设置
        NSDictionary *setting=[self getAudioSetting];
        //创建录音机
        NSError *error=nil;
        _audioRecorder=[[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate=self;
        _audioRecorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
        if (error) {
            
            return nil;
        }
    }
    return _audioRecorder;
}

/**
 *  创建播放器
 *
 *  @return 播放器
 */
-(AVAudioPlayer *)audioPlayer{
    NSURL *url;
    if (_filePath) {
        url= [NSURL fileURLWithPath:_filePath];
    }else{
        url = [self getSavePath];
    }
    NSError *error=nil;
    _audioPlayer = nil;
    _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
    _audioPlayer.numberOfLoops=0;
    [_audioPlayer prepareToPlay];
    if (error) {
        
        return nil;
    }
    return _audioPlayer;
}

/**
 *  录音声波监控定制器
 *
 *  @return 定时器
 */
-(NSTimer *)timer{
    if (!_timer) {
        dispatch_queue_t queue = dispatch_queue_create("kk", DISPATCH_QUEUE_SERIAL);
        // 串行队列中执行异步任务
        dispatch_async(queue, ^{
            _timer=[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
            // 将定时器添加到runloop中
            [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
            // 在线程中使用定时器，如果不启动run loop，timer的事件是不会响应的，而子线程中runloop默认没有启动
            // 让线程执行一个周期性的任务，如果不启动run loop， 线程跑完就可能被系统释放了
            [[NSRunLoop currentRunLoop] run];// 如果没有这句，doAnything将不会执行！！！
        });
    }
    return _timer;
}

/**
 *  录音时声波频率显示控件
 *
 *  @return 录音分贝图
 */

- (RecodeView *)recodeView{
    
    if (!_recodeView) {
        
        _recodeView = [[RecodeView alloc] initWithFrame:SetFrame(KWidth/2-80, KHeight/2-80, 160, 160)];
        
    }
    
    _recodeView.recordStatus = UIRecordSoundStatusRecoding;
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    if (![keyWindow.subviews containsObject:_recodeView]) {
        
        [keyWindow addSubview:_recodeView];
        
    }
    
    return _recodeView;
    
}

/**
 *  录音声波状态设置
 */
-(void)audioPowerChange{
    [self.audioRecorder updateMeters];//更新测量值
    float power= [self.audioRecorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0
    
    //比如把-60作为最低分贝
    
    float minValue = -60;
    
    //把60作为获取分配的范围
    
    float range = 60;
    
    //把100作为输出分贝范围
    
    float outRange = 70;
    
    //确保在最小值范围内
    
    if (power < minValue)
        
    {
        
        power = minValue;
        
    }
    
    //计算显示分贝
    
    float decibels = (power + range) / range * outRange;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.recodeView.rateInteger = ((int)decibels)/10;
        
    });
    
}


/**
 *  取得录音文件保存路径
 *
 *  @return 录音文件路径
 */
-(NSURL *)getSavePath{
    NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *url;
    
    if(![fileManager fileExistsAtPath:_filePath]) //如果不存在
        
    {
        NSLog(@"xxx.txt is not exist");
        
    }else{
        [fileManager removeItemAtPath:_filePath error:nil];
        NSLog(@"xxx.txt is  exist");
    }
    NSDateFormatter *dateForm = [[NSDateFormatter alloc] init];
    dateForm.dateFormat = @"yyyy-MM-dd-HH-mm-ss";
    urlStr=[urlStr stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",[dateForm stringFromDate:[NSDate date]],kRecordAudioFile]];
    
    _filePath = urlStr;
    
    url=[NSURL fileURLWithPath:urlStr];
    NSLog(@"%@",_filePath);
    
    
    
    
    return url;
}

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    NSLog(@"%f",self.audioPlayer.duration);
    
    _recodeDuration = self.audioPlayer.duration;
    
    if (_recodeDuration < 1 && _recodeDuration > 0) {
        
        _recodeView.recordStatus = UIRecordSoundStatusRecordingShort;
        
        [self performSelector:@selector(hiddenRecordView) withObject:nil afterDelay:1.0f];
        
    }else{
        
        [self hiddenRecordView];
        
        if ([self.delegate respondsToSelector:@selector(audioRecorderFinishRecordWithRecordDuration:withFilePath:)]) {
            
            [self.delegate audioRecorderFinishRecordWithRecordDuration:_recodeDuration withFilePath:_filePath];
            
        }
        
    }
    
}


#pragma mark RecordSoundAction

//开始录音
- (void)startRecordSound{
    
    //显示分贝图
    
    if (![self.audioRecorder isRecording]) {
        [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
        self.timer.fireDate=[NSDate distantPast];
    }
    
}

//暂停录音
- (void)pauseRecodeSound{
    
    if ([self.audioRecorder isRecording]) {
        
        [self.audioRecorder pause];
        
        self.timer.fireDate=[NSDate distantFuture];
        
    }
    
}

//结束录音
- (void)endRecordSound{
    
    [self.audioRecorder stop];
    self.timer.fireDate=[NSDate distantFuture];

}

//播放录音
- (void)playRecordSound{
    
    if (![self.audioPlayer isPlaying]) {
        [self.audioPlayer play];
    }
    
}

//清除录音
- (void)clearRecordSound{
    
    
    
}

- (void)hiddenRecordView{
    
    [_recodeView removeFromSuperview];
    
}

- (void)dealloc{
    
    _delegate = nil;
    
    _audioPlayer.delegate = nil;
    
    _audioRecorder.delegate = nil;
    
    [_recodeView removeFromSuperview];
    
    _recodeView = nil;
    
}

@end
