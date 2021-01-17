//
//  ExercisesTableViewCell.h
//  TXLiteAVDemo
//
//  Created by 赵佟越 on 2020/10/27.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTTestTopicModel.h"
#import "ExercisesTableViewController.h"

@interface ExercisesTableViewCell : UITableViewCell
@property (nonatomic, strong) UIView *backColorView;
@property (nonatomic, strong) UILabel *myTitleLabel;
@property (nonatomic, strong) UILabel *myDetailabel;
@property (nonatomic, strong) UILabel *titleTiplabel;
@property (nonatomic, strong) UILabel *doneTipLabel;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) PTTestTopicModel *model;
@end


