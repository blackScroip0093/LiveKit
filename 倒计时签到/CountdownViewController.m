//
//  CountdownViewController.m
//  Example
//
//  Created by developer on 2020/10/27.
//  Copyright © 2020 IgorBizi@mail.ru. All rights reserved.
//

#import "CountdownViewController.h"
#import "JBCountdownLabel.h"
#import "Masonry.h"
#import "TXLiteAVDemo-Swift.h"
#import "HPNetManager.h"
#import "HUDHelper.h"
#import "HPProgressHUD.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
 blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]

@interface CountdownViewController ()<CountdownDelegate>

@property (strong, nonatomic) JBCountdownLabel *countdownLabel;


@end

@implementation CountdownViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *backView = [[UIView alloc]init];
    [self.view addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(68);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    backView.backgroundColor = UIColorFromRGB(0x408FF7);
    backView.layer.cornerRadius = 50;
    backView.alpha = 0.6;
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.font = [UIFont systemFontOfSize:14];
    [backView addSubview:titleLabel];
    titleLabel.text = @"签到倒计时";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(200, 20));
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(26);
    }];
    
    UIButton *doneBtn = [[UIButton alloc]init];
    [self.view addSubview:doneBtn];
    [doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(200, 40));
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-29);
    }];
    doneBtn.layer.cornerRadius = 20;
    [doneBtn setTitle:@"立即签到" forState:normal];
    doneBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [doneBtn addTarget:self action:@selector(doneBtnAction) forControlEvents:UIControlEventTouchUpInside];
    doneBtn.backgroundColor = UIColorFromRGB(0x408FF7);
    
    self.countdownLabel = [[JBCountdownLabel alloc] initWithFrame:CGRectMake(0, 0, 84, 84) format:@"%@" time:_timeCount delegate:self];
    self.countdownLabel.layer.cornerRadius = 42;
    self.countdownLabel.backgroundColor = UIColorFromRGB(0x408FF7);
    self.countdownLabel.textColor = UIColor.whiteColor;
    self.view.layer.cornerRadius = 5;
    [self.view addSubview:self.countdownLabel];
    [self.countdownLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(backView);
        make.size.mas_equalTo(CGSizeMake(84, 84));
    }];
    self.countdownLabel.layer.cornerRadius = 42;
    self.countdownLabel.clipsToBounds = YES;
    
}
- (void)countdownFinnishIn:(JBCountdownLabel *)countdown{
    [self.popView dismissPopupViewControllerAnimated:YES];
}
- (void)restartCountdown:(id)sender
{
    [self.countdownLabel restartCountdown];
}

- (void)cancelCountdown:(id)sender
{
    [self.countdownLabel cancelCountdown];
}

- (void)doneBtnAction{
    //button action:
    NSDictionary *tempDic = @{@"studentId":[[[ProfileManager shared] loginUserModel] userId],
                              @"roomNumber":[[ProfileManager shared] roomID],
        
    };

    [HPNetManager POSTWithUrlString:@"http://39.106.88.75:9999/TeacherLive/pages/room/studentSignin" isNeedCache:NO parameters:tempDic successBlock:^(id response) {
         if ([response[@"code"] intValue] == 200) {
             [HPProgressHUD showMessage:@"签到成功"];
             [self.popView dismissPopupViewControllerAnimated:YES];
         }else{
             
         }
    } failureBlock:^(NSError *error) {
        
    } progressBlock:^(int64_t bytesProgress, int64_t totalBytesProgress) {
        
    }];
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
