//
//  NowTestViewController.m
//  TXLiteAVDemo_TRTC
//
//  Created by 赵佟越 on 2020/11/15.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "NowTestViewController.h"
#import "ExercisesTableViewCell.h"
#import "PTQuestionViewController.h"
#import "HPNetManager.h"
 #import <liveSDK/liveSDK-Swift.h>
#import "PTTestTopicModel.h"
#import "MJRefresh.h"
#import "HUDHelper.h"
@interface NowTestViewController ()
@property(nonatomic, strong)UITableView *myTableView;
@property(nonatomic, strong)PTQuestionViewController *questionViewController;
@property(nonatomic, strong)NSMutableArray *dataArr;
@property (nonatomic, strong) UIButton *rightCloseBtn;

@end

@implementation NowTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIView *backVIew = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    backVIew.backgroundColor = [UIColor whiteColor];
    backVIew.alpha = 1;
    [self.view addSubview:backVIew];
    [self.view addSubview:self.myTableView];
    [self.view addSubview:self.rightCloseBtn];
    [self.rightCloseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.top.mas_equalTo(10);
    }];
    UILabel *tipLabel = [[UILabel alloc]init];
    [self.view addSubview:tipLabel];
    tipLabel.text = @"随堂测";
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.rightCloseBtn.mas_right).offset(14);
        make.size.mas_equalTo(CGSizeMake(100, 40));
        make.top.mas_equalTo(10);
    }];
    
    
//    let header = MJRefreshStateHeader(refreshingTarget: self, refreshingAction: #selector(loadRoomsInfo))
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self.myTableView.mj_header endRefreshing];//结束刷新
        [self getDate];
    }];
    [header setTitle:@"下拉刷新" forState: MJRefreshStateIdle];
    [header setTitle:@"释放更新数据" forState:MJRefreshStatePulling];
    [header setTitle:@"Loading..." forState:MJRefreshStateRefreshing];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.myTableView.mj_header =  header;
    [self getDate];
}

- (void)getDate{
    
    NSDictionary *tempDic = @{
        @"tlRoomNumber":[NSString stringWithFormat:@"%@",[[ProfileManager shared]roomID]],//
           @"tlQuestionType":@"0",//随堂测
        @"studentId":[NSString stringWithFormat:@"%@",[[[ProfileManager shared] loginUserModel]userId]]};
        [[HUDHelper sharedInstance] syncLoading];
       [HPNetManager POSTWithUrlString:@"http://39.106.88.75:9999/TeacherLive/pages/room/getTopicOrQuestion" isNeedCache:NO parameters:tempDic successBlock:^(id response) {
           [[HUDHelper sharedInstance] syncStopLoading];
            if ([response[@"code"] intValue] == 200) {
                self.dataArr = [[NSMutableArray alloc]init];
                self.dataArr = [PTTestTopicModel mj_objectArrayWithKeyValuesArray:response[@"dataList"]];
                
                [self.myTableView reloadData];
            }else{
                
            }
       } failureBlock:^(NSError *error) {
           
       } progressBlock:^(int64_t bytesProgress, int64_t totalBytesProgress) {
           
       }];
}

#pragma mark - tableview delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return  [[UIView alloc]init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 10;
    }else{
        return CGFLOAT_MIN;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 95;//[PetKnowMoreTableViewCell cellheight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ExercisesTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[ExercisesTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
    }
    cell.model = self.dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.questionViewController = [[PTQuestionViewController alloc] init];
    self.questionViewController.tempVC = self;
    if ([[self.dataArr[indexPath.row] topicList] count] == 0) {
        return;
    }
    self.questionViewController.tempArr = [self.dataArr[indexPath.row] topicList];
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,HPScreenWidth , HPScreenHeight)];
    UIView *tempView = self.questionViewController.view;
    tempView.frame = CGRectMake(0, 264 - 80 + (HPScreenHeight - 64 - 200 + 80) ,HPScreenWidth  , HPScreenHeight - 64 - 200 + 80);
    tempView.alpha = 1;
     
    UIView *backColorView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, HPScreenWidth, HPScreenHeight)];
    backColorView.alpha = 0;
    backColorView.backgroundColor = UIColor.blackColor;
    [backView addSubview:backColorView];
    [backView addSubview:tempView];
    backView.tag = 1000001;
    [UIView animateWithDuration:0.3 animations:^{
        //动画设置
        tempView.frame = CGRectMake(0, 264 - 80,HPScreenWidth , HPScreenHeight - 64 - 200 + 80);

        tempView.alpha = 1;
        backColorView.alpha = 0.7;
        
    } completion:^(BOOL finished) {
        //动画结束后执行的操作
        [[[UIApplication sharedApplication].keyWindow viewWithTag:1000002] removeFromSuperview];
    }];
    [[[UIApplication sharedApplication] keyWindow] addSubview:backView];
    
    
//    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)closeAction{
    [[[UIApplication sharedApplication].keyWindow viewWithTag:1000002] removeFromSuperview];
}

#pragma mark - Private Methods

- (UIButton *)rightCloseBtn {
    if (!_rightCloseBtn){
        _rightCloseBtn = [[UIButton alloc]init];
        [_rightCloseBtn setImage:[UIImage imageNamed:@"cha"] forState:normal];
    }
    _rightCloseBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_rightCloseBtn addTarget:self action:@selector(closeAction)];
    return _rightCloseBtn;
}


- (UITableView *)myTableView{
    if (_myTableView == nil) {
        _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, HPScreenHeight - 64 - 200 + 80 -30) style:UITableViewStyleGrouped];
        _myTableView.dataSource = self;
        _myTableView.backgroundColor = [UIColor clearColor];
        _myTableView.delegate = self;
        _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _myTableView;
}


#pragma mark - JXCategoryListContentViewDelegate

- (UIView *)listView {
    return self.view;
}

@end

