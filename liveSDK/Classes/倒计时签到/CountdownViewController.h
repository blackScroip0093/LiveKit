//
//  CountdownViewController.h
//  Example
//
//  Created by developer on 2020/10/27.
//  Copyright © 2020 IgorBizi@mail.ru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIZPopupViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CountdownViewController : UIViewController

@property(nonatomic,strong)BIZPopupViewController *popView;

@property(nonatomic, assign) int timeCount;

@end

NS_ASSUME_NONNULL_END
