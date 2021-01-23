//
//  PTQuestionBottomView.h
//  ProblemTest
//
//  Created by Celia on 2017/10/24.
//  Copyright © 2017年 Hopex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTTestTopicModel.h"

@interface PTQuestionBottomView : UIView

/** 点击交卷block */
@property (nonatomic, copy) void (^PTQuestionBottomViewSubmitBlock)();

/** 设置倒计时时间 */
- (void)setTimeString:(NSString *)timeString;

/** 设置计题数量 */
- (void)setCountString:(NSString *)countString;

- (void)setCountString:(NSString *)countString setModel:(PTTestTopicModel*)model;
@end
