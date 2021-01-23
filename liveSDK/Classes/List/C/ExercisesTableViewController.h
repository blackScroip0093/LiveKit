//
//  ExercisesTableViewController.h
//  TXLiteAVDemo
//
//  Created by 赵佟越 on 2020/10/27.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JXCategoryListContainerView.h"
@interface ExercisesTableViewController : UIViewController<JXCategoryListContentViewDelegate>
@property(nonatomic, assign)NSInteger roomId;
- (void)getDate;
@end
