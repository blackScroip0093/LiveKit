//
//  ListViewController.m
//  JXCategoryView
//
//  Created by jiaxin on 2018/8/8.
//  Copyright © 2018年 jiaxin. All rights reserved.
//

#import "ListViewController.h"

#define COLOR_WITH_RGB(R,G,B,A) [UIColor colorWithRed:R green:G blue:B alpha:A]

@interface ListViewController ()

@end

@implementation ListViewController
- (void)listWillAppear{
    // 列表展示
    [[[[UIApplication sharedApplication] keyWindow]  viewWithTag:10000099] setHidden:YES];
}

- (void)listDidAppear{
    // 列表消失
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIView *backVIew = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    backVIew.backgroundColor = [UIColor whiteColor];
    backVIew.alpha = 0.7;
    [self.view addSubview:backVIew];
    
//    self.view.backgroundColor = COLOR_WITH_RGB(arc4random()%255/255.0, arc4random()%255/255.0, arc4random()%255/255.0, 1);
}

#pragma mark - JXCategoryListContentViewDelegate

- (UIView *)listView {
    return self.view;
}

@end
