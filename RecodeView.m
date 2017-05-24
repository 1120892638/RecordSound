//
//  RecodeSoundView.m
//  FriendBlood
//
//  Created by 豆子 on 17/5/23.
//  Copyright © 2017年 豆子. All rights reserved.
//

#import "RecodeView.h"

@implementation RecodeView

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        
        //设置layer属性
        [GlobalModel setUpLayerrPropertyWithView:self withCornerRadius:10.0f withBorderWidth:0 withBoderColor:nil];
        
        [self contentOfRecordSoundView];
        
    }
    
    return self;
    
}

- (void)contentOfRecordSoundView{
    
    UILabel *decLabel = [[UILabel alloc] initWithFrame:SetFrame(10, self.height-40, self.width-20, 30)];
    
    [self addSubview:decLabel];
    
    self.descrip = decLabel;
    
    decLabel.font = SystemFont(14);
    
    decLabel.textAlignment = NSTextAlignmentCenter;
    
    [GlobalModel setUpLayerrPropertyWithView:decLabel withCornerRadius:5.0 withBorderWidth:0 withBoderColor:nil];
    
    
    UIImageView *leftImage = [[UIImageView alloc] init];
    
    [self addSubview:leftImage];
    
    self.statusImageView = leftImage;
    
    
    UIImageView *rightImageView = [[UIImageView alloc] init];
    
    [self addSubview:rightImageView];
    
    self.rateImageView = rightImageView;
    
}

- (void)setRecordStatus:(UIRecordSoundStatus)recordStatus{
    
    _recordStatus = recordStatus;
    
    switch (self.recordStatus) {
        case UIRecordSoundStatusRecoding:{
            
            [self showViewWithRecording];
            
        }
            break;
        case UIRecordSoundStatusCancleSending:{
            
            [self showViewWithCancle];
            
        }
            break;
        case UIRecordSoundStatusRecordingShort:{
            
            [self showVieWithTimeShort];
            
        }
            break;
        default:
            break;
    }
    
}

- (void)setRateInteger:(NSInteger)rateInteger{
    
    _rateInteger = rateInteger;
    
    if (self.recordStatus == UIRecordSoundStatusRecoding) {
        
        
        
        self.rateImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"v%ld",self.rateInteger]];
        
    }
    
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    
}

#pragma mark RecodeStatus

//正在录音

- (void)showViewWithRecording{
    
    self.descrip.text = @"手指上滑，取消录音";
    
    self.descrip.textColor = [UIColor whiteColor];
    
    self.descrip.backgroundColor = [UIColor clearColor];
    
    
    self.statusImageView.frame = SetFrame(self.width/2-60, 20, 60, 90);
    
    self.statusImageView.image = [UIImage imageNamed:@"recorder"];
    
    
    self.rateImageView.frame = SetFrame(self.width/2, 20, 60, 90);
    
    self.rateImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"v%ld",self.rateInteger]];
    
    self.rateImageView.hidden = NO;
    
}

//取消发送
- (void)showViewWithCancle{
    
    self.descrip.text = @"松开手指，取消录音";
    
    self.descrip.textColor = [UIColor whiteColor];
    
    self.descrip.backgroundColor = BaseColor;
    
    
    self.statusImageView.frame = SetFrame(self.width/2-60, 20, 120, 90);
    
    self.statusImageView.image = [UIImage imageNamed:@"cancel"];
    
    
    self.rateImageView.hidden = YES;
    
}

//时间过短
- (void)showVieWithTimeShort{
    
    self.descrip.text = @"录音太短";
    
    self.descrip.backgroundColor = [UIColor clearColor];
    
    
    self.statusImageView.frame = SetFrame(self.width/2-60, 20, 120, 90);
    
    self.statusImageView.image = [UIImage imageNamed:@"voice_to_short"];
    
    
    self.rateImageView.hidden = YES;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
