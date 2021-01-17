//
//  ExercisesTableViewController.m
//  TXLiteAVDemo
//
//  Created by 赵佟越 on 2020/10/27.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "ExercisesTableViewController.h"
#import "ExercisesTableViewCell.h"
#import "PTQuestionViewController.h"
#import "HPNetManager.h"
#import "TXLiteAVDemo-Swift.h"
#import "PTTestTopicModel.h"
#import "HPWKWebView.h"
#import "RxWebViewController.h"


@interface ExercisesTableViewController ()<UITableViewDelegate ,UITableViewDataSource>
@property(nonatomic, strong)UITableView *myTableView;
@property(nonatomic, strong)PTQuestionViewController *questionViewController;
@property(nonatomic, strong)NSMutableArray *dataArr;
@property(nonatomic, strong)UILabel *gongGaoLabel;
@end

@implementation ExercisesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIView *backVIew = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    backVIew.backgroundColor = [UIColor whiteColor];
    backVIew.alpha = 1;
    [self.view addSubview:backVIew];
    [self.view addSubview:self.myTableView];
//    let header = MJRefreshStateHeader(refreshingTarget: self, refreshingAction: #selector(loadRoomsInfo))
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self.myTableView.mj_header endRefreshing];//结束刷新
        [self getDate];
    }];
    [header setTitle:@"下拉刷新" forState: MJRefreshStateIdle];
    [header setTitle:@"释放更新数据" forState:MJRefreshStatePulling];
    [header setTitle:@"Loading..." forState:MJRefreshStateRefreshing];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.myTableView.mj_header =  nil;
    
    
    self.gongGaoLabel = [[UILabel alloc]initWithFrame:CGRectMake(14, 50, self.view.width - 28, 200)];
    self.gongGaoLabel.numberOfLines = 0;
    self.gongGaoLabel.textColor = [UIColor blackColor];
    self.gongGaoLabel.font = [UIFont systemFontOfSize:15];
    self.gongGaoLabel.text = @"暂无问卷";
    self.gongGaoLabel.textAlignment = NSTextAlignmentCenter;
    self.gongGaoLabel.hidden = YES;
    [_myTableView addSubview:self.gongGaoLabel];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
//    [self.myTableView.mj_header beginRefreshing];
    [self getDate];
}

- (void)getDate{
    
    NSDictionary *tempDic = @{
        @"tlRoomNumber":[NSString stringWithFormat:@"%ld",self.roomId],//
           @"tlQuestionType":@"1",//问卷
        @"studentId":[NSString stringWithFormat:@"%@",[[[ProfileManager shared] loginUserModel]userId]]};
       [HPNetManager POSTWithUrlString:@"http://39.106.88.75:9999/TeacherLive/pages/room/getTopicOrQuestion" isNeedCache:NO parameters:tempDic successBlock:^(id response) {
            if ([response[@"code"] intValue] == 200) {
                self.dataArr = [[NSMutableArray alloc]init];
                self.dataArr = [PTTestTopicModel mj_objectArrayWithKeyValuesArray:response[@"dataList"]];
                if (self.dataArr.count > 0) {
                    self.gongGaoLabel.hidden = YES;
                }else{
                    self.gongGaoLabel.hidden = NO;
                }
                [self.myTableView reloadData];
            }else{
                self.gongGaoLabel.hidden = NO;
                [self.myTableView reloadData];
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
    // tlQuestionType
    if ([[self.dataArr[indexPath.row] tlQuestionType] intValue]== 2){
        //第三芳问卷
        RxWebViewController *rxVC = [[RxWebViewController alloc]initWithUrl:[NSURL URLWithString:[self.dataArr[indexPath.row] questionsUrl] ]];
        [self presentViewController:rxVC animated:YES completion:^{
            
        }];
        return;
    }
    if ([[self.dataArr[indexPath.row] topicList] count] == 0) {
        return;
    }
    
    self.questionViewController.tempArr = [self.dataArr[indexPath.row] topicList];
    self.questionViewController.exTempVC = self;
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
    }];
    [[[UIApplication sharedApplication] keyWindow] addSubview:backView];
    
    
    
}

#pragma mark - Private Methods
- (UITableView *)myTableView{
    if (_myTableView == nil) {
        _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.view.frame.size.width/375*260 - 90) style:UITableViewStyleGrouped];
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

