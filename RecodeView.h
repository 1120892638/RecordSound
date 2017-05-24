//
//  RecodeSoundView.h
//  FriendBlood
//
//  Created by 豆子 on 17/5/23.
//  Copyright © 2017年 豆子. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UIRecordSoundStatus) {
    UIRecordSoundStatusRecoding = 0,//正在录音
    
    UIRecordSoundStatusCancleSending,//取消发送
    
    UIRecordSoundStatusRecordingShort,//录音时间过短
};

@interface RecodeView : UIView

@property (nonatomic,strong) UILabel *descrip;

@property (nonatomic,strong) UIImageView *statusImageView;

@property (nonatomic,strong) UIImageView *rateImageView;

@property (nonatomic,assign) NSInteger rateInteger;

@property (nonatomic,assign) UIRecordSoundStatus recordStatus;

@end
