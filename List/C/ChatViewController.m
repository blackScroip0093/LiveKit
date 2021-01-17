//
//  ChatViewController.m
//  TXLiteAVDemo_TRTC
//
//  Created by 赵佟越 on 2020/11/21.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - JXCategoryListContentViewDelegate

- (void)listWillAppear{
    // 列表展示
    [[self.view viewWithTag:10000088] setHidden:NO];
    [[[[UIApplication sharedApplication] keyWindow]  viewWithTag:10000099] setHidden:NO];
}

- (void)listWillDisappear{
    // 列表消失
    [[self.view viewWithTag:10000088] setHidden:YES];
    [[[[UIApplication sharedApplication] keyWindow]  viewWithTag:10000099] setHidden:YES];
//    10000088
}

- (UIView *)listView {
    return self.view;
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
