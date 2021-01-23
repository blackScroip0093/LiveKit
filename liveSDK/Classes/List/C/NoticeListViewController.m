//
//  NoticeListViewController.m
//  TXReplaykitUpload_TRTC
//
//  Created by 赵佟越 on 2020/10/27.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "NoticeListViewController.h"
#import "NoticeListTableViewCell.h"
#import "BIZPopupViewController.h"
#import "CountdownViewController.h"
#import "HPNetManager.h"
 #import <liveSDK/liveSDK-Swift.h>
#import "gongGaoModel.h"

@interface NoticeListViewController ()<UITableViewDelegate ,UITableViewDataSource>
@property(nonatomic, strong)UITableView *myTableView;
@property(nonatomic, strong)NSMutableArray *dataArr;
@property(nonatomic, strong)UILabel *gongGaoLabel;
@end

@implementation NoticeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIView *backVIew = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    backVIew.backgroundColor = [UIColor whiteColor];
    backVIew.alpha = 1;
    [self.view addSubview:backVIew];
    [self.view addSubview:self.myTableView];
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self.myTableView.mj_header endRefreshing];//结束刷新
        [self getData];
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
    self.gongGaoLabel.text = @"暂无公告";
    self.gongGaoLabel.textAlignment = NSTextAlignmentCenter;
    self.gongGaoLabel.hidden = YES;
    [_myTableView addSubview:self.gongGaoLabel];
    
//    [self getData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
//    [self.myTableView.mj_header beginRefreshing];
    [self getData];
}
- (void)getData{
    
    NSDictionary *tempDic = @{@"noticeRoomNumber":[[ProfileManager shared] roomID],
                              };
    [HPNetManager POSTWithUrlString:@"http://39.106.88.75:9999/TeacherLive/pages/room/getNotice" isNeedCache:NO parameters:tempDic successBlock:^(id response) {
         if ([response[@"code"] intValue] == 200) {
             self.dataArr = [[NSMutableArray alloc]init];
             self.dataArr = [gongGaoModel mj_objectArrayWithKeyValuesArray:response[@"notices"]];
             if (self.dataArr.count > 0) {
                 self.gongGaoLabel.hidden = YES;
             }else{
                 self.gongGaoLabel.hidden = NO;
             }
             [self.myTableView reloadData];
         }else{
             self.gongGaoLabel.hidden = NO;
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
    return 50;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    gongGaoModel *tempModel = self.dataArr[indexPath.row];
    
    return [self getHeightLineWithString:tempModel.noticeContent withWidth:HPScreenWidth - 29 withFont:[UIFont systemFontOfSize:14]] + 130;//[PetKnowMoreTableViewCell cellheight];
}


- (CGFloat)getHeightLineWithString:(NSString *)string withWidth:(CGFloat)width withFont:(UIFont *)font {

    

    //1.1最大允许绘制的文本范围

    CGSize size = CGSizeMake(width, 2000);

    //1.2配置计算时的行截取方法,和contentLabel对应

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];

    [style setLineSpacing:0];

    //1.3配置计算时的字体的大小

    //1.4配置属性字典

    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style};

    //2.计算

    //如果想保留多个枚举值,则枚举值中间加按位或|即可,并不是所有的枚举类型都可以按位或,只有枚举值的赋值中有左移运算符时才可以

    CGFloat height = [string boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size.height;

    

    return height;

}

 

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NoticeListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[NoticeListTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
    }
    cell.model = self.dataArr[indexPath.row];
//    cell.myModel = self.petknowMoreArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    petKnowMoreDetailViewController *petknowVC = [[petKnowMoreDetailViewController alloc]init];
//    petknowVC.myModel = self.petknowMoreArr[indexPath.row];
//    [self.navigationController pushViewController:petknowVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    CountdownViewController *smallViewController = [[CountdownViewController alloc] init];
//    
//    BIZPopupViewController *popupViewController = [[BIZPopupViewController alloc] initWithContentViewController:smallViewController contentSize:CGSizeMake(300, 270)];
//    popupViewController.showDismissButton = false;
//    
//    smallViewController.popView = popupViewController;
//    [self presentViewController:popupViewController animated:NO completion:nil];
}

#pragma mark - Private Methods
- (UITableView *)myTableView{
    if (_myTableView == nil) {
        _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.view.frame.size.width/375*260 - 70) style:UITableViewStyleGrouped];
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
