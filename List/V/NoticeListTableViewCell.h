//
//  NoticeListTableViewCell.h
//  TXLiteAVDemo
//
//  Created by 赵佟越 on 2020/10/27.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "gongGaoModel.h"


@interface NoticeListTableViewCell : UITableViewCell
@property (nonatomic, strong) UIImageView *myimageView;
@property (nonatomic, strong) UIView *myView;
@property (nonatomic, strong) UILabel *myTitleLabel;
@property (nonatomic, strong) UILabel *myDetailabel;
@property (nonatomic, strong) UILabel *myTimelabel;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) gongGaoModel *model;
@end

