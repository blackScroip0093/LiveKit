//
//  loginModel.h
//  TXLiteAVDemo_TRTC
//
//  Created by 赵佟越 on 2020/11/25.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface loginModel : NSObject
@property (nonatomic, strong) NSString *roomName;
@property (nonatomic, strong) NSString *roomOpenVideo; // 是否开启暖场视频
@property (nonatomic, strong) NSString *roomWarmVideo; // 暖场视频id
@property (nonatomic, strong) NSString *roomShowBack;
@property (nonatomic, strong) NSString *roomDescribe;
@property (nonatomic, strong) NSString *noticeCreateTime;
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *roomTeacherId;
@property (nonatomic, strong) NSString *roomOpenBackground; // 是否开启背景图
@property (nonatomic, strong) NSString *roomOpenHint; // 是否开启提示语
@property (nonatomic, strong) NSString *roomOpenCountdown; // 是否开启倒计时
@property (nonatomic, strong) NSString *roomPrompt; // 是否开启倒计时
@property (nonatomic, strong) NSString *roomBackgroundImg; // 是否开启倒计时
@property (nonatomic, strong) NSString *roomOnlinenumber; // 添加人数
@property (nonatomic, strong) NSString *roomOpennumber; // 添加人数
@property (nonatomic, strong) NSString *peopleNumber; // 添加人数



@end

NS_ASSUME_NONNULL_END
