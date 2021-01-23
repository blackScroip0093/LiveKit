/**
 * Module: TCAudienceViewController
 *
 * Function: 观众播放模块主控制器，里面承载了渲染view，逻辑view，以及播放相关逻辑，同时也是SDK层事件通知的接收者
 */

#import "TCAudienceViewController.h"
#import "HPProgressHUD.h"
#import "TCAnchorViewController.h"
#import <mach/mach.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>
#import "TCMsgModel.h"
#import "NSString+Common.h"
#import "TCStatusInfoView.h"
#import "UIView+Additions.h"
#import "HUDHelper.h"
 #import <liveSDK/liveSDK-Swift.h>
#import <TEduBoard/TEduBoard.h>
#import "JXCategoryView.h"
#import "ListViewController.h"
#import "NoticeListViewController.h"
#import "ExercisesTableViewController.h"
#import "NowTestViewController.h"
#import "IQKeyboardManager.h"
#import "HPNetManager.h"
#import "Macro.h"
#import "ChatViewController.h"
#import "TRTCLiveRoomIMAction.h"
#import "JZVideoPlayerView.h"
#import "TRTCCallingUtils.h"
#import "JBCountdownLabel.h"
#import "TCAnchorToolbarView.h"
#import "UIColor+HPCategory.h"
#import "TXLivePlayer.h"
#import "SDWebImage.h"
#import "MJRefresh.h"
#import "GenerateTestUserSig.h"
#import "UIImageView+WebCache.h"


#define VIDEO_VIEW_WIDTH            100
#define VIDEO_VIEW_HEIGHT           150
#define VIDEO_VIEW_MARGIN_BOTTOM    56
#define VIDEO_VIEW_MARGIN_RIGHT     8
#define VIDEO_VIEW_MARGIN_SPACE     5
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]


@interface TCAudienceViewController() <UIImagePickerControllerDelegate,UINavigationControllerDelegate,
UITextFieldDelegate,JZPlayerViewDelegate,
TCAudienceToolbarDelegate,
TXLiveRecordListener,
TRTCLiveRoomDelegate,TEduBoardDelegate,JXCategoryListContainerViewDelegate,JXCategoryViewDelegate,CountdownDelegate>
@property (nonatomic, strong) TEduBoardController *boardController;
@property (nonatomic, strong) JXCategoryTitleView *categoryView;
@property (nonatomic, strong) JXCategoryListContainerView *listContainerView;
    @property (nonatomic, strong) UILabel *gongGaoLabel;
@property (nonatomic, strong) UILabel *guangboLabel;
@property (nonatomic, strong) UITextView *jianjieLabel;
@property (nonatomic, strong) UIView *myvideoView;
@property (nonatomic, strong) UILabel *centerLabel;
@property (nonatomic, strong) UIButton *changeBtn;
@property (nonatomic, strong) UIButton *changeVideoBtn;
@property (nonatomic, strong) UIButton *nowTestBtn;
@property (nonatomic, strong) UIButton *muteBtn;
@property (nonatomic, strong) TCStatusInfoView* statusInfoView;
@property (nonatomic, strong) TCStatusInfoView* smallStatusInfoView;
@property (nonatomic, strong) TCStatusInfoView* smallOnlineStatusInfoView;
@property (nonatomic, strong) UIView *boardView;/// 白板VIew
@property (nonatomic, strong) JZVideoPlayerView *jzPlayer;
@property (nonatomic, strong) UIImageView *backImgView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) JBCountdownLabel *countdownLabel;
@property (nonatomic, strong) UILabel *peopleCount;
@property (nonatomic, strong) UIButton *danMuBtn;
@property (nonatomic, strong) UIButton *danMuTypeBtn;
@property (nonatomic, assign) BOOL isHiddenOpenVideo;
@property (nonatomic, strong) ChatViewController *bottomVC;
@property (nonatomic, strong) UIImageView *myimageView;
@property (nonatomic, assign) BOOL isCanShow;
@end

@implementation TCAudienceViewController
{
    NSInteger            _audienceCount;     // 在线观众数
    TX_Enum_PlayType     _playType;
    long long            _trackingTouchTS;
    BOOL                 _startSeek;
    BOOL                 _videoPause;
    BOOL                 _videoFinished;
    float                _sliderValue;
    BOOL                 _isLivePlay;
    BOOL                 _isInVC;
    NSString             *_rtmpUrl;
    
    BOOL                  _rotate;
    BOOL                 _isErrorAlert; //是否已经弹出了错误提示框，用于保证在同时收到多个错误通知时，只弹一个错误提示框
    
    //link mic
    BOOL                    _isBeingLinkMic;
    BOOL                    _isWaitingResponse;
    
    UITextView *            _waitingNotice;
    UIButton *              _closeBtn;
    UIButton*               _btnCamera;
    UIButton*               _btnLinkMic;
    BOOL                    _isStop;
    
    NSMutableArray*         _statusInfoViewArray;         //小画面播放列表
    UILabel                *_noOwnerTip;
    
    int                     _errorCode;
    NSString *              _errorMsg;
    
    uint64_t                _beginTime;
    uint64_t                _endTime;
}
-(void)initJZPlayer:(NSString *)urlString{
    NSURL *url = [NSURL URLWithString:urlString];
    [self hiddenTip];
    _jzPlayer = [[JZVideoPlayerView sharedInstance] initWithFrame:CGRectMake(0, 20, self.view.width , self.view.width/375*200 + 20) contentURL:url];
//    _jzPlayer = [[JZVideoPlayerView alloc] initWithFrame:CGRectMake(0, 20, self.view.width , self.view.width/375*200 + 20) contentURL:url];
    _jzPlayer.delegate = self;
    [self.view addSubview:_jzPlayer];
    [_jzPlayer play];
}


- (void)initBackImageView{
    self.backImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, StatusBarHeight, HPScreenWidth, self.view.width/375*200 + 20)];
    [self.view addSubview:self.backImgView];
    [self.backImgView sd_setImageWithURL:[NSURL URLWithString:self.needDict.roomBackgroundImg]];
    
}
- (void)initCountDown{
    if (self.isHiddenOpenVideo == YES) {
        return;
    }
    NSString *time = self.needDict.startTime;
    //                 time = @"2020-11-29 21:23";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"]; //设定时间的格式
    NSDate *tempDate = [dateFormatter dateFromString:time];//将字符串转换为时间对象
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"ss"];
    NSDate* date = [NSDate date];
    NSTimeInterval Comtime = [tempDate timeIntervalSinceDate:date];
    
    self.countdownLabel = [[JBCountdownLabel alloc] initWithFrame:CGRectMake(0, 0, 84, 84) format:@"%@" time:Comtime delegate:self];
    self.countdownLabel.layer.cornerRadius = 42;
    self.countdownLabel.backgroundColor = UIColorFromRGB(0x408FF7);
    self.countdownLabel.textColor = UIColor.whiteColor;
    self.view.layer.cornerRadius = 5;
    [[UIApplication sharedApplication].keyWindow addSubview:self.countdownLabel];
    self.countdownLabel.frame = CGRectMake((HPScreenWidth - 100)/2, StatusBarHeight + 40, 100, 100);
    self.countdownLabel.alpha = 0.7;
    self.countdownLabel.layer.cornerRadius = 50;
    self.countdownLabel.clipsToBounds = YES;
}
- (void)countdownFinnishIn:(JBCountdownLabel *)countdown{
    self.countdownLabel.hidden = YES;
}
- (void)initTipLabel{
    if (self.isHiddenOpenVideo == YES) {
        return;
    }
    self.tipLabel = [[UILabel alloc] init];
    self.tipLabel.textColor = UIColor.blackColor;
    self.tipLabel.frame = CGRectMake(14, StatusBarHeight + 140 + 10, HPScreenWidth - 28, 20);
    [self.tipLabel adjustsFontSizeToFitWidth];
    [[UIApplication sharedApplication].keyWindow addSubview:self.tipLabel];
    self.tipLabel.text = self.needDict.roomPrompt;
}



- (void)hiddenTip{
    
    if (self.tipLabel != nil) {
        [self.tipLabel removeFromSuperview];
    }
    if (self.countdownLabel != nil) {
        [self.countdownLabel removeFromSuperview];
    }
    if (self.backImgView != nil){
        [self.backImgView removeFromSuperview];
    }
    
}

- (void)dissmissVideo{
    if (_jzPlayer != nil) {
        [_jzPlayer pause];
        [_jzPlayer removeFromSuperview];
        _jzPlayer = nil;
    }
}


- (id)initWithPlayInfo:(TRTCLiveRoomInfo *)info videoIsReady:(videoIsReadyBlock)videoIsReady {
    if (self = [super init]) {
        _liveInfo = info;
        _videoIsReady = videoIsReady;
        _videoPause   = NO;
        _videoFinished = YES;
        _isInVC       = NO;
        _log_switch   = NO;
        _errorCode    = 0;
        _errorMsg     = @"";
        
        _isLivePlay = YES;
        
        if ([_rtmpUrl hasPrefix:@"http:"]) {
            _rtmpUrl = [_rtmpUrl stringByReplacingOccurrencesOfString:@"http:" withString:@"https:"];
        }
        _rotate       = NO;
        _isErrorAlert = NO;
        _isOwnerEnter = NO;
        _isStop = NO;
        
        //link mic
        _isBeingLinkMic = false;
        _isWaitingResponse = false;
        self.liveRoom.delegate = self;
        _roomStatus = TRTCLiveRoomLiveStatusNone;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receveImage:) name:@"receveImage" object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peopleCountAdd:) name:@"peopleCount++" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peopleCountRemove:) name:@"peopleCount--" object:nil];
    }
    return self;
}
//    _audienceCount ++;
//    _totalViewerCount ++;
//    [_audienceLabel setText:[NSString stringWithFormat:@"%ld", _audienceCount]];
//
//    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
//    [center postNotificationName:@"peopleCount++" object:self userInfo:nil];
//
//
//}
//
//- (void)onUserExitLiveRoom {
//    if (_audienceCount > 0) {
//        _audienceCount --;
//    }
//    [_audienceLabel setText:[NSString stringWithFormat:@"%ld", _audienceCount]];

- (void)peopleCountAdd:(NSNotification *)notification {
    _audienceCount ++;
    if ([self.needDict.roomOpennumber  intValue] == 1) {
        self.peopleCount.text = [NSString stringWithFormat:@"在线人数: %ld",(long)_audienceCount + [self.needDict.roomOnlinenumber  intValue] ];
    }else{
        self.peopleCount.text = [NSString stringWithFormat:@"在线人数: %ld",(long)_audienceCount];
    }
    
    
        
}

- (void)peopleCountRemove:(NSNotification *)notification {
    if (_audienceCount > 0) {
          _audienceCount --;
    }
    if ([self.needDict.roomOpennumber  intValue] == 1) {
        self.peopleCount.text = [NSString stringWithFormat:@"在线人数: %ld",(long)_audienceCount + [self.needDict.roomOnlinenumber  intValue]];
    }else{
        self.peopleCount.text = [NSString stringWithFormat:@"在线人数: %ld",(long)_audienceCount];
    }
}


- (void)receveImage:(NSNotification *)notification {
    
}

- (void)onAppWillResignActive:(NSNotification *)notification {
    if (_isBeingLinkMic) {
    }
}

- (void)onAppDidBecomeActive:(NSNotification *)notification {
    if (_isBeingLinkMic) {
    }
}

- (void)onAppDidEnterBackGround:(UIApplication *)app {
    if (_isBeingLinkMic) {
    }
}

- (void)onAppWillEnterForeground:(UIApplication *)app {
    if (_isBeingLinkMic) {
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self startRtmp];
    _isInVC = YES;
    [[IQKeyboardManager sharedManager] setEnable:NO];
    if (_errorCode != 0) {
        [self onError:_errorCode errMsg:_errorMsg extraInfo:nil];
        _errorCode = 0;
        _errorMsg  = @"";
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [self stopRtmp];
    _isInVC = NO;
}

- (void)getData{
    NSDictionary *tempDic = @{@"userId":[NSString stringWithFormat:@"%@",[[[ProfileManager shared] loginUserModel]userId]],
                                                @"userNickName":[[ProfileManager shared] roomNickName],
                                                @"password":[[ProfileManager shared] roomPassWord],
                                                @"identity":@"2",
                                                @"roomNumber":[[ProfileManager shared] roomID],
                                                @"roomVerification":@"0",
                                                @"userTerminal":@"3",
                      };
    [HPNetManager POSTWithUrlString:@"http://39.106.88.75:9999/TeacherLive/pages/room/getRoomDetails" isNeedCache:NO parameters:tempDic successBlock:^(id response) {
        [[HUDHelper sharedInstance] syncStopLoading];
        if ([response[@"code"] intValue] == 400) {
            // 禁封
            [self closeVCAction];
        }
         if ([response[@"code"] intValue] == 200) {
              self.needDict = [loginModel mj_objectWithKeyValues:response[@"cre"]];
             self.needDict.peopleNumber = response[@"userEntity"][@"peopleNumber"];
             self.centerLabel.text = self.needDict.roomName;
             self.jianjieLabel.text = self.needDict.roomDescribe;
             [[ProfileManager shared] setTeacherId:self.needDict.roomTeacherId];
             
             if([self.needDict.roomOpenBackground  intValue] == 1){
                 //是否开启背景图
                 [self initBackImageView];
             }
             if([self.needDict.roomOpenHint  intValue] == 1){
                 //是否开启提示语
                 [self initTipLabel];
             }
             if([self.needDict.roomOpenCountdown  intValue] == 1){
                 //是否开启倒计时
                 [self initCountDown];
             }
             
             NSString *time = self.needDict.startTime;
             NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
             [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"]; //设定时间的格式
             NSDate *tempDate = [dateFormatter dateFromString:time];//将字符串转换为时间对象
             NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
             [formatter setDateStyle:NSDateFormatterMediumStyle];
             [formatter setTimeStyle:NSDateFormatterShortStyle];
             [formatter setDateFormat:@"ss"];
             NSDate* date = [NSDate date];
             NSTimeInterval Comtime = [tempDate timeIntervalSinceDate:date];
             NSLog(@"%f秒",Comtime);
             [self performSelector:@selector(hiddenTip) withObject:self afterDelay:Comtime];
             [self joinRoom];
             if ([self.needDict.roomOpenVideo intValue] == 1){
                 // 是否开启暖场视频
                 [HPNetManager POSTWithUrlString:@"http://39.106.88.75:9999/TeacherLive/pages/room/getCloudDemandDetails" isNeedCache:NO parameters:@{@"videoId":self.needDict.roomWarmVideo} successBlock:^(id response) {
                     if ([response[@"code"] intValue] == 200) {
                        //开启暖场视频
                                         NSString *time = self.needDict.startTime;
                        //                 time = @"2020-11-29 21:23";
                                         NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
                                         [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"]; //设定时间的格式
                                         NSDate *tempDate = [dateFormatter dateFromString:time];//将字符串转换为时间对象
                                         NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                                         [formatter setDateStyle:NSDateFormatterMediumStyle];
                                         [formatter setTimeStyle:NSDateFormatterShortStyle];
                                         [formatter setDateFormat:@"ss"];
                                         NSDate* date = [NSDate date];
                                         NSTimeInterval Comtime = [tempDate timeIntervalSinceDate:date];
                                         NSLog(@"%f秒",Comtime);
//                                         if (self.needDict.startTime > 0) {
                         
                         if (!self.isHiddenOpenVideo) {
                              [self initJZPlayer:response[@"searchMediaEntity"][@"mediaUrl"]];
                         }
                                            
//                                             [self performSelector:@selector(dissmissVideo) withObject:self afterDelay:Comtime];
//                                         }
                     }else{
                         
                     }
                 } failureBlock:^(NSError *error) {
                     
                 } progressBlock:^(int64_t bytesProgress, int64_t totalBytesProgress) {
                     
                 }];
                 
                 
             }
         }else{
             
         }
        
        
                         
        
        
        
    } failureBlock:^(NSError *error) {
        
    } progressBlock:^(int64_t bytesProgress, int64_t totalBytesProgress) {
        
    }];
                
    
    
}





- (void)joinRoom{
    
      NSDictionary *tempDic1 = @{@"userId":[[[ProfileManager shared] loginUserModel]userId],
                                @"userNickName":[[ProfileManager shared] roomNickName],
                                @"password":[[ProfileManager shared] roomPassWord],
                                @"identity":@"2",
                                @"roomNumber":[[ProfileManager shared] roomID],
                                @"roomVerification":@"0",
                                @"userTerminal":@"3",
      };
      
      [HPNetManager POSTWithUrlString:@"http://39.106.88.75:9999/TeacherLive/pages/room/joinRoom" isNeedCache:NO parameters:tempDic1 successBlock:^(id response) {
          [[HUDHelper sharedInstance] syncStopLoading];
           if ([response[@"code"] intValue] == 200) {
              
           }else{
               
           }
      } failureBlock:^(NSError *error) {
          
      } progressBlock:^(int64_t bytesProgress, int64_t totalBytesProgress) {
          
      }];
}


- (void)closeVCAction{
    
    [[(UIButton *)[UIApplication sharedApplication].keyWindow viewWithTag:1000004] removeFromSuperview];
    [[(UIView *)[UIApplication sharedApplication].keyWindow viewWithTag:10000099] removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
    if (self.tipLabel != nil) {
        [self.tipLabel removeFromSuperview];
    }
    if (self.countdownLabel != nil) {
        [self.countdownLabel removeFromSuperview];
    }
    if (self.backImgView != nil){
        [self.backImgView removeFromSuperview];
    }
        [self stopLocalPreview];
       [self stopLinkMic];
       [self hideWaitingNotice];
       [self hiddenTip];
       [self dissmissVideo];
    [HPProgressHUD showMessage:@"您已退出直播间"];
    [self stopRtmp];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.onPlayError) {
                self.onPlayError();
            }
        });
    }
}

- (void)viewDidLoad {
    self.myimageView = [[UIImageView alloc]init];
    self.bottomVC =[[ChatViewController alloc]init];
    self.danMuBtn = [[UIButton alloc]init];
    self.danMuBtn.hidden = YES;
    self.danMuTypeBtn = [[UIButton alloc]init];
    self.peopleCount = [[UILabel alloc]init];
    UILabel *tipLabel = [[UILabel alloc]init];
    [self.danMuTypeBtn setHidden:YES];
//    ProfileManager.shared.loginUserModel
    UIButton *backBtn = [[UIButton alloc]init];
    [backBtn setImage:[UIImage imageNamed:@"chevron-left"] forState:normal];
    backBtn.tag = 1000004;
    [[UIApplication sharedApplication].keyWindow addSubview:backBtn];
    [backBtn addTarget:self action:@selector(closeVCAction)];
    
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.top.mas_equalTo(StatusBarHeight + 10);
        make.size.mas_equalTo(CGSizeMake(18, 18));
    }];
    
    
    
    [self getData];
    [super viewDidLoad];
    [self setupToast];
    //(1)白板
    NSString *userID = [[ProfileManager shared] curUserID];
    NSString *userSig = [[ProfileManager shared] curUserSig];
    TEduBoardAuthParam *authParam = [[TEduBoardAuthParam alloc] init];
    authParam.sdkAppId = SDKAPPID;
    authParam.userId = userID;
    authParam.userSig = userSig;
    //（2）白板默认配置
    TEduBoardInitParam *initParam = [[TEduBoardInitParam alloc] init];
    _boardController = [[TEduBoardController alloc] initWithAuthParam:authParam roomId:[_liveInfo.roomId intValue] initParam:initParam];
    //（3）添加白板事件回调
    [_boardController addDelegate:self];
    
    //加载背景图
    UIImage *backImage = [UIImage imageNamed:@""];
    UIImage *clipImage = nil;
    if (backImage) {
        CGFloat backImageNewHeight = self.view.height;
        CGFloat backImageNewWidth = backImageNewHeight * backImage.size.width / backImage.size.height;
        UIImage *gsImage = [TCUtil gsImage:backImage withGsNumber:10];
        UIImage *scaleImage = [TCUtil scaleImage:gsImage scaleToSize:CGSizeMake(backImageNewWidth, backImageNewHeight)];
        clipImage = [TCUtil clipImage:scaleImage inRect:CGRectMake((backImageNewWidth - self.view.width)/2, (backImageNewHeight - self.view.height)/2, self.view.width, self.view.height)];
    }
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    backgroundImageView.image = clipImage;
    backgroundImageView.backgroundColor = [UIColor whiteColor];
    backgroundImageView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:backgroundImageView];
    
    
    
    self.centerImageView  = [[UIImageView alloc]initWithFrame:CGRectMake(14, self.view.width/375 *260 + 7, 100, 70)];
    self.centerImageView.backgroundColor = [UIColor whiteColor];
    self.centerImageView.image = [UIImage imageNamed:@"图片 Copy 2"];
    self.centerLabel = [[UILabel alloc]init];
    self.centerLabel.numberOfLines = 2;
    self.centerLabel.font = [UIFont boldSystemFontOfSize:15];
    
    self.centerLabel.textColor = [UIColor blackColor];
    [self.view addSubview:self.centerImageView];
    [self.view addSubview:self.centerLabel];
    self.centerLabel.frame = CGRectMake(119, self.view.width/375 *260 + 7, SCREEN_WIDTH - 128, 70);
    //    [self.centerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.left.mas_equalTo(124);
    //        make.right.equalTo(self.view.mas_right).offset(-14);
    //        make.top.bottom.equalTo(self.centerImageView);
    //    }];
    
    _noOwnerTip = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height / 2 - 40, self.view.bounds.size.width, 30)];
    _noOwnerTip.backgroundColor = [UIColor clearColor];
    [_noOwnerTip setTextColor:[UIColor whiteColor]];
    [_noOwnerTip setTextAlignment:NSTextAlignmentCenter];
    [_noOwnerTip setText:@""];
    
    [self.view addSubview:_noOwnerTip];
    [_noOwnerTip setHidden:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self.isOwnerEnter) {
            [self->_noOwnerTip setHidden:NO];
        }
    });
    
    
    self.categoryView = [[JXCategoryTitleView alloc] init];
    self.listContainerView = [[JXCategoryListContainerView alloc] initWithType:JXCategoryListContainerType_ScrollView delegate:self];
//    self.listContainerView.frame = CGRectMake(0, self.view.frame.size.width/375*260 + 50 + 70, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.view addSubview:self.listContainerView];
    
    //关联到categoryView
    self.categoryView.listContainer = self.listContainerView;
    
    //视频画面父view
    _videoParentView = [[UIView alloc] initWithFrame:self.view.frame];
    _videoParentView.tag = FULL_SCREEN_PLAY_VIDEO_VIEW;
    [self.view addSubview:_videoParentView];
    [_videoParentView setHidden:YES];
    
    [self initLogicView];
    _beginTime = [[NSDate date] timeIntervalSince1970];
    ///Segment
    
    self.categoryView.backgroundColor = [UIColor clearColor];
    self.categoryView.titleColor = [UIColor grayColor];
    self.categoryView.titleSelectedColor = UIColorFromRGB(0x408FF7);
    self.categoryView.alpha = 0.85;
    self.categoryView.delegate = self;
    [self.view addSubview:self.categoryView];
    self.categoryView.frame = CGRectMake(0, self.view.frame.size.width/375*260 + 70, kScreenWith, 50);
    
    [self.listContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.categoryView.mas_bottom);
        make.bottom.equalTo(self.view);
        make.left.mas_equalTo(0);
        make.width.equalTo(self.view);
    }];
    // 功能栏
    self.categoryView.titles = @[@"简介", @"聊天", @"问卷",@"公告"];
    self.categoryView.titleColorGradientEnabled = YES;
    JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
    lineView.indicatorColor = UIColorFromRGB(0x408FF7);
    lineView.indicatorWidth = JXCategoryViewAutomaticDimension;
    self.categoryView.indicators = @[lineView];
    
    
    UIView *lineViewGray = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.width/375*260, self.view.width, 1)];
    lineViewGray.backgroundColor = UIColorFromRGB(0xF2F0F0);
    [self.view addSubview:lineViewGray];
    UIView *lineViewGray1 = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.width/375*260 + 120, self.view.width, 1)];
    lineViewGray1.backgroundColor = UIColorFromRGB(0xF2F0F0);
    [self.view addSubview:lineViewGray1];
    
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(receiveBroadcast:) name:@"通知" object:nil];
    [center addObserver:self selector:@selector(receiveBroadcastPingMu:) name:@"屏幕共享" object:nil];
    [center addObserver:self selector:@selector(receiveLink:) name:@"连麦" object:nil];
    
//    [self onTEBHistroyDataSyncCompleted];
}

- (void)receiveLink: (NSNotification *)notification{
    //连麦
    
    NSNumber* cmd = notification.userInfo[@"cmd"] ?: @(0);
    if (cmd.intValue == 1){
        //连麦开启
        _btnLinkMic.hidden = NO;
    }else if(cmd.intValue == 5){
        //关闭连麦
        _btnLinkMic.hidden = YES;
        [self hideWaitingNotice];
        [self stopLocalPreview];
    }else if(cmd.intValue == 3){
        //老师接收通话
        self->_isWaitingResponse = NO;
        [self->_btnLinkMic setEnabled:YES];
        [self hideWaitingNotice];
        self->_isBeingLinkMic = YES;
        //            [self->_btnLinkMic setImage:[UIImage imageNamed:@"linkmic_off"] forState:UIControlStateNormal];
        [TCUtil toastTip:@"老师接受了您的连麦请求，开始连麦" parentView:self.view];
        //推流允许前后切换摄像头
        self->_btnCamera.hidden = NO;
        [[AppUtils shared] alertUserTips:self];
//        [self hideWaitingNotice];
        
        [self showWaitingNotice:@"语言通话中"];
        
        self->_smallStatusInfoView.userID = [[[ProfileManager shared] loginUserModel] userId];
        [_smallStatusInfoView startLoading];
        [self.liveRoom startCameraPreviewWithFrontCamera:YES view:self->_smallStatusInfoView.videoView callback:^(int code, NSString * error) {
            [self->_smallStatusInfoView stopLoading];
        }];
        NSString *streamID = [NSString stringWithFormat:@"%@_stream",[[[ProfileManager shared] loginUserModel] userId]];
        
        [self.liveRoom startPublishWithStreamID:streamID callback:^(int code, NSString * error) {
            
        }];
    }else if(cmd.intValue == 4){
        // 挂断
        [self hideWaitingNotice];
        [self onKickoutJoinAnchor];
    }
    
}

-(void)receiveBroadcastPingMu: (NSNotification *)notification{
    NSString * name = notification.name;
    NSString* pushType = notification.userInfo[@"available"];
    NSString* userId = notification.userInfo[@"userId"];
    if ([pushType isEqualToString:@"stop"]) {
        [self.myvideoView setHidden: YES];
        [TRTCCloud.sharedInstance stopRemoteSubStreamView :userId];
    }else if([pushType isEqualToString:@"star"]) {
        [self.myvideoView setHidden: NO];
        [TRTCCloud.sharedInstance startRemoteSubStreamView :userId view:self.myvideoView];
    }
    NSLog(@"广播名称：%@", name);
}

- (void)muteAllRemoteAudio:(UIButton *)sender {
    [sender setSelected:!sender.isSelected];
    
//    self.view.makeToast(sender.isSelected ? "开启静音" : "关闭静音");
    [[TRTCCloud sharedInstance] muteAllRemoteAudio:sender.isSelected];
}

-(void)receiveBroadcast: (NSNotification *)notification{
    NSString * name = notification.name;
    
    NSNumber* pushType = notification.userInfo[@"pushType"] ?: @(0);
    if (pushType.intValue == 1) {
        self.gongGaoLabel.text = notification.userInfo[@"content"] ?: @(0);
        [self.gongGaoLabel sizeToFit];
    }else if (pushType.intValue == 2) {
        self.guangboLabel.text = notification.userInfo[@"content"] ?: @(0);
        [self.guangboLabel sizeToFit];
    }else if (pushType.intValue == 6){
        [HUDHelper alert:notification.userInfo[@"content"] ];
    }else if (pushType.intValue == 10){
        [self hiddenTip];
        [self dissmissVideo];
        [self getData];
    }
    NSLog(@"广播名称：%@", name);
}
//

- (void)viewDidDisappear:(BOOL)animated {
    _endTime = [[NSDate date] timeIntervalSince1970];
}

- (void)dealloc {
    [self stopRtmp];
    NSLog(@"dealloc audienceVC");
}

- (void)initReBack{
//    _logicView.frame = CGRectMake(0, 0, kScreenWith, self.view.height - (self.view.frame.size.width/375*260 + 50 + 70));
    _logicView.msgTableView.hidden = NO;
    _logicView.userInteractionEnabled = YES;
    _logicView.msgTableView.frame = CGRectMake(15, 0, MSG_TABLEVIEW_WIDTH, _logicView.height - 40);
    _logicView.msgTableView.isBig = NO;
    [_logicView addSubview:_logicView.msgTableView];
    [_logicView sendSubviewToBack:_logicView.msgTableView];
    [self.bottomVC.view addSubview:self.logicView];
    _logicView.msgInputView.hidden = NO;
    _logicView.msgInputView.frame = CGRectMake(0, SCREEN_HEIGHT - 45 - TabbarSafeBottomMargin, _logicView.width, MSG_TEXT_SEND_VIEW_HEIGHT );
    
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    [tempArr addObjectsFromArray:_logicView.msgTableView.msgallArray];
    _logicView.msgTableView.msgArray = tempArr;
    [_logicView.msgTableView reloadData];
    
    [_logicView.msgInputView becomeFirstResponder];
    
}

- (void)initlogicBigView{
    _logicView.userInteractionEnabled = NO;
    CGFloat bottom = 0;
                if (@available(iOS 11, *)) {
                    bottom = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
                }
    CGRect frame = CGRectMake(14, 0, kScreenWith, 300);
    _logicView.frame = frame;
    CGRect frame1 = CGRectMake(14, 40, [UIScreen mainScreen].bounds.size.width, 260);
    _logicView.msgTableView.frame = frame1;
    _logicView.msgTableView.isBig = YES;
//                _logicView.liveRoom = _liveRoom;
    [self.view addSubview:_logicView];
    [self.view bringSubviewToFront:_logicView];
    
    
    
    NSMutableArray *msgleastArray = [[NSMutableArray alloc]init];
    for (TCMsgModel *msgModel in _logicView.msgTableView.msgallArray) {
//        if (msgModel.msgType == TCMsgModelType_DanmaMsg) {
            [msgleastArray addObject:msgModel];
//        }
    }
    _logicView.msgTableView.msgArray = msgleastArray;
    [_logicView.msgTableView reloadData];
//    [_logicView.msgTableView scrollToBottom];
}

- (void)initLogicView {
    
    if (!_logicView) {
        CGFloat bottom = 0;
        if (@available(iOS 11, *)) {
            bottom = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
        }
        CGRect frame = CGRectMake(0, 0, kScreenWith, self.view.height - (self.view.frame.size.width/375*260 + 50 + 70));
        frame.size.height -= bottom;
        _logicView = [[TCAudienceToolbarView alloc] initWithFrame:frame liveInfo:self.liveInfo withLinkMic: YES];
        _logicView.delegate = self;
        _logicView.liveRoom = _liveRoom;
        [self.view addSubview:_logicView];
        
        if (_btnLinkMic == nil) {
            int   icon_size = BOTTOM_BTN_ICON_WIDTH;
            float startSpace = 15;
            
            float icon_count = 7;
            float icon_center_interval = (_logicView.width - 2*startSpace - icon_size)/(icon_count - 1);
            float icon_center_y = _logicView.height - icon_size/2 - startSpace;
            
            //Button: 发起连麦
            _btnLinkMic = [UIButton buttonWithType:UIButtonTypeCustom];
//            _btnLinkMic.center = CGPointMake(self.view.width - 50, icon_center_y - 40);
            [_logicView addSubview:_btnLinkMic];
            [_btnLinkMic mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(_logicView.mas_right);
                make.bottom.mas_equalTo(-TabbarSafeBottomMargin - 45 - 30);
                make.size.mas_equalTo(CGSizeMake(168/3, 108/3));
            }];
            
            _btnLinkMic.hidden = YES;
            [_btnLinkMic setImage:[UIImage imageNamed:@"视频"] forState:UIControlStateNormal];
            [_btnLinkMic addTarget:self action:@selector(clickBtnLinkMic:) forControlEvents:UIControlEventTouchUpInside];
            
//            [_btnLinkMic mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.centerX.equalTo(self->_logicView.closeBtn).offset(-icon_center_interval*2.5);
//                make.centerY.equalTo(self->_logicView.closeBtn);
//                make.width.height.equalTo(@(icon_size));
//            }];
            
            //Button: 前置后置摄像头切换
            CGRect rectBtnLinkMic = _btnLinkMic.frame;
            _btnCamera = [UIButton buttonWithType:UIButtonTypeCustom];
            _btnCamera.center = CGPointMake(_btnLinkMic.center.x - icon_center_interval, icon_center_y);
            _btnCamera.bounds = CGRectMake(0, 0, CGRectGetWidth(rectBtnLinkMic), CGRectGetHeight(rectBtnLinkMic));
            [_btnCamera setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
            [_btnCamera addTarget:self action:@selector(clickBtnCamera:) forControlEvents:UIControlEventTouchUpInside];
            _btnCamera.hidden = YES;
            [_logicView addSubview:_btnCamera];
        }
        
        //初始化连麦播放小窗口
        if (_statusInfoViewArray == nil) {
            _statusInfoViewArray = [NSMutableArray new];
            [self initStatusInfoView:1];
            //            [self initStatusInfoView:2];
            //            [self initStatusInfoView:3];
        }
        
        //logicView不能被连麦小窗口挡住
        [self.logicView removeFromSuperview];
        
    }
}

- (void)initRoomLogic {
    _liveRoom.delegate = self;
    __weak __typeof(self) wself = self;
    [_liveRoom enterRoomWithRoomID:[_liveInfo.roomId intValue] callback:^(int code, NSString * error) {
        __strong __typeof(wself) self = wself;
        if (self == nil) {
            return ;
        }
        if (code == 0) {
            __block BOOL isGetList = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //获取成员列表
                [self.liveRoom getAudienceList:^(int code, NSString * error, NSArray<TRTCLiveUserInfo *> * users) {
                    isGetList = (code == 0);
                    [self->_logicView initAudienceList:users];
                }];
            });
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (isGetList) {
                    return;
                }
                //获取成员列表
                [self.liveRoom getAudienceList:^(int code, NSString * error, NSArray<TRTCLiveUserInfo *> * users) {
                    [self->_logicView initAudienceList:users];
                }];
            });
            
        } else {
            __strong __typeof(wself) self = wself;
            if (self == nil) {
                return ;
            }
            [self makeToastWithMessage:error.length > 0 ? error : @"进入房间失败"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //退房
                [self closeVCWithRefresh:YES popViewController:YES];
            });
        }
    }];
}

- (void)startLinkMic {
    ///TODO
//    NSInteger cmdID = [[[ProfileManager shared] curUserID] intValue];
//    NSData *data = [@"{\"cmd\":2}" dataUsingEncoding:NSUTF8StringEncoding];
//    // reliable 和 ordered 目前需要一致，这里以需要保证消息按发送顺序到达为例
//    [[TRTCCloud sharedInstance] sendCustomCmdMsg:cmdID data:data reliable:YES ordered:YES];
//
//    [[V2TIMManager sharedInstance] createCustomMessage:[TRTCCallingUtils dictionary2JsonData:@{@"cmd" : @2}]];
    
//    V2TIMMessage *msg = [[V2TIMManager sharedInstance] createCustomMessage:[TRTCCallingUtils dictionary2JsonData:@{@"version" : @2}]];
//    [[V2TIMManager sharedInstance] sendC2CCustomMessage:<#(NSData *)#> to:<#(NSString *)#> succ:<#^(void)succ#> fail:<#^(int code, NSString *desc)fail#>
    
    [self showWaitingNotice:@"等待老师接受"];
    [[V2TIMManager sharedInstance] sendC2CCustomMessage:[TRTCCallingUtils dictionary2JsonData:@{@"cmd" : @2}] to:[[ProfileManager shared] teacherId] succ:^{
        
    } fail:^(int code, NSString *desc) {
        
    }];
    
//
//    if (_isBeingLinkMic || _isWaitingResponse) {
//        return;
//    }
//    __weak __typeof(self) wself = self;
//    _isWaitingResponse = YES;
//
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onWaitLinkMicResponseTimeOut) object:nil];
//    [self performSelector:@selector(onWaitLinkMicResponseTimeOut) withObject:nil afterDelay:20];
//
////    [_btnLinkMic setImage:[UIImage imageNamed:@"linkmic_off"] forState:UIControlStateNormal];
//    [_btnLinkMic setEnabled:NO];
//
//    [self showWaitingNotice:@"等待主播接受"];
//
////    [TRTCLiveRoomIMAction sendRoomTextMsgWithRoomID:@"" message:@"{\"cmd\":2}" callback:callback];
////    { "cmd":  2 }
//
//
//    [self.liveRoom requestJoinAnchor:@"" responseCallback:^(BOOL agreed, NSString * reason) {
//        __strong __typeof(wself) self = wself;
//        if (self == nil) {
//            return ;
//        }
//        if (self->_isWaitingResponse == NO || !self->_isInVC) {
//            return;
//        }
//        self->_isWaitingResponse = NO;
//        [self->_btnLinkMic setEnabled:YES];
//        [self hideWaitingNotice];
//        if (agreed) {
//            self->_isBeingLinkMic = YES;
////            [self->_btnLinkMic setImage:[UIImage imageNamed:@"linkmic_off"] forState:UIControlStateNormal];
//            [TCUtil toastTip:@"主播接受了您的连麦请求，开始连麦" parentView:self.view];
//
//            //推流允许前后切换摄像头
//            self->_btnCamera.hidden = NO;
//
//            //查找空闲的TCSmallPlayer, 开始loading
////            for (TCStatusInfoView * statusInfoView in self->_statusInfoViewArray) {
////                if (statusInfoView.userID == nil || statusInfoView.userID.length == 0) {
//                    [[AppUtils shared] alertUserTips:self];
//
//            self->_smallStatusInfoView.userID = [[[ProfileManager shared] loginUserModel] userId];
//            [self.liveRoom startCameraPreviewWithFrontCamera:YES view:self->_smallStatusInfoView.videoView callback:^(int code, NSString * error) {
//
//                    }];
//                    NSString *streamID = [NSString stringWithFormat:@"%@_stream",[[[ProfileManager shared] loginUserModel] userId]];
//                    [self.liveRoom startPublishWithStreamID:streamID callback:^(int code, NSString * error) {
//
//                    }];
////                    break;
////                }
//
//
//
////            }
//        } else {
//            self->_isBeingLinkMic = NO;
//            self->_isWaitingResponse = NO;
////            [self->_btnLinkMic setImage:[UIImage imageNamed:@"linkmic_on"] forState:UIControlStateNormal];
//            if ([reason length] > 0) {
//                [TCUtil toastTip:reason parentView:self.view];
//            } else {
//                [TCUtil toastTip:@"主播拒绝了您的连麦请求" parentView:self.view];
//            }
//        }
//    }];
}

- (void)stopLinkMic {
    // 关闭所有的播放器
    [_smallOnlineStatusInfoView stopLoading];
    [_smallOnlineStatusInfoView stopPlay];
    if (_smallOnlineStatusInfoView.userID.length) {
        [self.liveRoom stopPlayWithUserID:_smallOnlineStatusInfoView.userID callback:^(int code, NSString * error) {
            
        }];
    }
    [_smallOnlineStatusInfoView emptyPlayInfo];
    
    [_smallStatusInfoView stopLoading];
    [_smallStatusInfoView stopPlay];
    if (_smallStatusInfoView.userID.length) {
        [self.liveRoom stopPlayWithUserID:_smallStatusInfoView.userID callback:^(int code, NSString * error) {
            
        }];
    }
    [_smallStatusInfoView emptyPlayInfo];
    
    for (TCStatusInfoView* statusInfoView in _statusInfoViewArray) {
        [statusInfoView stopLoading];
        [statusInfoView stopPlay];
        if (statusInfoView.userID.length) {
            [self.liveRoom stopPlayWithUserID:statusInfoView.userID callback:^(int code, NSString * error) {
                
            }];
        }
        [statusInfoView emptyPlayInfo];
    }
}

- (void)stopLocalPreview {
    if (_isBeingLinkMic == YES) {
        [self.liveRoom stopPublish:^(int code, NSString * error) {
            
        }];
        
        //关闭本地摄像头，停止推流
        for (TCStatusInfoView* statusInfoView in _statusInfoViewArray) {
            if ([statusInfoView.userID isEqualToString:[[ProfileManager shared] curUserID]]) {
                [self.liveRoom stopCameraPreview];
                [statusInfoView stopLoading];
                [statusInfoView stopPlay];
                [statusInfoView emptyPlayInfo];
                break;
            }
        }
        //UI重置
//        [_btnLinkMic setImage:[UIImage imageNamed:@"linkmic_on"] forState:UIControlStateNormal];
        [_btnLinkMic setEnabled:YES];
        _btnCamera.hidden = YES;
        
        _isBeingLinkMic = NO;
        _isWaitingResponse = NO;
    }
}

- (void)initStatusInfoView: (int)index {
    
    self.statusInfoView = [[TCStatusInfoView alloc] init];
    self.statusInfoView.videoView = [[UIView alloc] initWithFrame:self.centerImageView.frame];
    self.statusInfoView.linkFrame = self.centerImageView.frame;
    [self.view addSubview:self.statusInfoView.videoView];
    [_statusInfoViewArray addObject:self.statusInfoView];
    
    
    
    self.smallOnlineStatusInfoView = [[TCStatusInfoView alloc] init];
       self.smallOnlineStatusInfoView.videoView = [[UIView alloc] initWithFrame:CGRectMake(self.centerImageView.width/2, self.centerImageView.height/2, self.centerImageView.width/2, self.centerImageView.height/2)];
       [self.view addSubview:self.smallOnlineStatusInfoView.videoView];
       [self.smallOnlineStatusInfoView.videoView mas_makeConstraints:^(MASConstraintMaker *make) {
           make.right.equalTo(self.centerImageView);
           make.bottom.equalTo(self.centerImageView);
           make.size.mas_equalTo(CGSizeMake(100/2, 70/2));
       }];
       
       self.smallOnlineStatusInfoView.linkFrame = self.centerImageView.frame;
    
    self.smallStatusInfoView = [[TCStatusInfoView alloc] init];
    self.smallStatusInfoView.videoView = [[UIView alloc] initWithFrame:CGRectMake(self.centerImageView.width/2, self.centerImageView.height/2, self.centerImageView.width/2, self.centerImageView.height/2)];
    [self.view addSubview:self.smallStatusInfoView.videoView];
    [self.smallStatusInfoView.videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.centerImageView);
        make.bottom.equalTo(self.centerImageView);
        make.size.mas_equalTo(CGSizeMake(100/2, 70/2));
    }];
    
    self.smallStatusInfoView.linkFrame = self.centerImageView.frame;
    
    
}

- (void)onWaitLinkMicResponseTimeOut {
    if (_isWaitingResponse == YES) {
        _isWaitingResponse = NO;
//        [_btnLinkMic setImage:[UIImage imageNamed:@"linkmic_on"] forState:UIControlStateNormal];
        [_btnLinkMic setEnabled:YES];
        [self hideWaitingNotice];
        [TCUtil toastTip:@"连麦请求超时，主播没有做出回应" parentView:self.view];
    }
}

- (void)showWaitingNotice:(NSString*)notice {
    CGRect frameRC = [[UIScreen mainScreen] bounds];
    frameRC.origin.y = frameRC.size.height - (IPHONE_X ? 114 : 80);
    frameRC.size.height -= 110;
    if (_waitingNotice == nil) {
        _waitingNotice = [[UITextView alloc] init];
        _waitingNotice.editable = NO;
        _waitingNotice.selectable = NO;
        
        frameRC.size.height = [TCUtil heightForString:_waitingNotice andWidth:frameRC.size.width];
        _waitingNotice.frame = frameRC;
        _waitingNotice.textColor = [UIColor whiteColor];
        _waitingNotice.backgroundColor = [UIColor hex:@"#CEE6FC"];
        _waitingNotice.alpha = 0.9;
        _closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(HPScreenWidth - 40, 3, 24, 24)];
        [_closeBtn setImage:[UIImage imageNamed:@"cha-2"] forState:normal];
        
        [_closeBtn addTarget:self action:@selector(closeAction)forControlEvents:UIControlEventTouchUpInside];
        [_waitingNotice addSubview:_closeBtn];
        [self.view addSubview:_waitingNotice];
        
    }
    
    _waitingNotice.text = notice;
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 500 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^(){
//        [self freshWaitingNotice:notice withIndex: [NSNumber numberWithLong:0]];
//    });
}

- (void)closeAction{
    // 取消连麦
    
    if ([_waitingNotice.text hasPrefix:@"等待老师接受"]) {
        //取消
        [[V2TIMManager sharedInstance] sendC2CCustomMessage:[TRTCCallingUtils dictionary2JsonData:@{@"cmd" : @6}] to:[[ProfileManager shared] teacherId] succ:^{
               
           } fail:^(int code, NSString *desc) {
               
           }];
           
    }else{
        //挂断
        [[V2TIMManager sharedInstance] sendC2CCustomMessage:[TRTCCallingUtils dictionary2JsonData:@{@"cmd" : @4}] to:[[ProfileManager shared] teacherId] succ:^{
            
        } fail:^(int code, NSString *desc) {
            
        }];
        [self stopLocalPreview];
    }
    [self hideWaitingNotice];
    
}

- (void)freshWaitingNotice:(NSString *)notice withIndex:(NSNumber *)numIndex {
    if (_waitingNotice) {
        long index = [numIndex longValue];
        ++index;
        index = index % 4;
        
        NSString * text = notice;
        for (long i = 0; i < index; ++i) {
            text = [NSString stringWithFormat:@"%@.....", text];
        }
        [_waitingNotice setText:text];
        
        numIndex = [NSNumber numberWithLong:index];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 500 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^(){
            [self freshWaitingNotice:notice withIndex: numIndex];
        });
    }
}

- (void)hideWaitingNotice {
    if (_waitingNotice) {
        [_waitingNotice removeFromSuperview];
        _waitingNotice = nil;
    }
}

- (void)showAlertWithTitle:(NSString *)title sureAction:(void(^)(void))callback {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (callback) {
            callback();
        }
    }];
    [alertController addAction:sureAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - liveroom listener
- (void)onDebugLog:(NSString *)msg {
    NSLog(@"onDebugMsg:%@", msg);
}

- (void)onRoomDestroy:(NSString *)roomID {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"onRoomDestroy, roomID:%@", roomID);
        __weak __typeof(self) weakSelf = self;
        [self showAlertWithTitle:@"大主播关闭直播间" sureAction:^{
            [weakSelf closeVCWithRefresh:YES popViewController:YES];
        }];
    });
}

- (void)onError:(int)errCode errMsg:(NSString *)errMsg extraInfo:(NSDictionary *)extraInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"onError:%d, %@", errCode, errMsg);
        if(errCode != 0){
            if (self->_isInVC) {
                __weak __typeof(self) weakSelf = self;
                [self showAlertWithTitle:@"大主播关闭直播间" sureAction:^{
                    [weakSelf closeVCWithRefresh:YES popViewController:YES];
                }];
            }else{
                self->_errorCode = errCode;
                self->_errorMsg = errMsg;
            }
        }
    });
}



- (void)onKickoutJoinAnchor {
    [TCUtil toastTip:@"老师断开连麦" parentView:self.view];
    [self stopLocalPreview];
}


#pragma mark- MiscFunc
- (TCStatusInfoView *)getStatusInfoViewFrom:(NSString *)userID {
    if (userID) {
        for (TCStatusInfoView* statusInfoView in _statusInfoViewArray) {
            if ([userID isEqualToString:statusInfoView.userID]) {
                return statusInfoView;
            }
        }
    }
    return nil;
}

- (BOOL)isNoAnchorINStatusInfoView {
    for (TCStatusInfoView* statusInfoView in _statusInfoViewArray) {
        if ([statusInfoView.userID length] > 0) {
            return NO;
        }
    }
    return YES;
}

- (void)onLiveEnd {
    [self onRecvGroupDeleteMsg];
}

- (void)onAnchorEnter:(NSString *)userID {
    BOOL noAnchor = [self isNoAnchorINStatusInfoView];
    if ([userID isEqualToString:[[ProfileManager shared] curUserID]]) {
        return;
    }
    self.isHiddenOpenVideo = YES;
    [self dissmissVideo];
    [self hiddenTip];
//    NSLog([NSString stringWithFormat:@"%@----%@----%@--%@",userID,[[ProfileManager shared] curUserID]],[[ProfileManager shared] teacherId],[[ProfileManager shared] roomID]);
    ///TODO ZZZ
    if (userID == nil || userID.length == 0) {
        return;
    }
    
    BOOL bExist = NO;
    for (TCStatusInfoView * statusInfoView in _statusInfoViewArray) {
        if ([userID isEqualToString:statusInfoView.userID]) {
            bExist = YES;
            break;
        }
    }
    if (bExist == YES) {
        return;
    }
    if (userID != [[ProfileManager shared] teacherId] ) {
        self->_smallOnlineStatusInfoView.userID = userID;
//        [_smallOnlineStatusInfoView startLoading];
        __weak __typeof(self) weakSelf = self;
        [self.liveRoom startPlayWithUserID:userID view:self->_smallOnlineStatusInfoView.videoView callback:^(int code, NSString * error) {
            if (code == 0) {
//                [self->_smallOnlineStatusInfoView stopLoading];
            } else {
                [weakSelf onAnchorExit:userID];
            }
        }];
    }else{
        for (TCStatusInfoView * statusInfoView in _statusInfoViewArray) {
        if (statusInfoView.userID == nil || statusInfoView.userID.length == 0) {
            statusInfoView.userID = userID;
            [statusInfoView startLoading];
            __weak __typeof(self) weakSelf = self;
            [self.liveRoom startPlayWithUserID:userID view:statusInfoView.videoView callback:^(int code, NSString * error) {
                if (code == 0) {
                    [statusInfoView stopLoading];
                } else {
                    [weakSelf onAnchorExit:userID];
                }
            }];
            break;
        }
    }
    
//    [self.liveRoom startPlayWithUserID:userID view:_smallStatusInfoView.videoView callback:^(int code, NSString * error) {
//        if (code == 0) {
////            [statusInfoView stopLoading];
//        } else {
////            [weakSelf onAnchorExit:userID];
//        }
//    }];
    }
    
    if(noAnchor && self.roomStatus == TRTCLiveRoomLiveStatusRoomPK) {
        [self switchPKMode];
    }
    
}

- (void)onAnchorExit:(NSString *)userID {
    if ([userID isEqualToString:_liveInfo.ownerId]) {
        [self.liveRoom stopPlayWithUserID:userID callback:^(int code, NSString * error) {
            
        }];
        self.isOwnerEnter = NO;
        return;
    }
    
    TCStatusInfoView * statusInfoView = [self getStatusInfoViewFrom:userID];
    if (![statusInfoView.userID isEqualToString:[[ProfileManager shared] curUserID]]) {
        [statusInfoView stopLoading];
        [statusInfoView stopPlay];
        [self.liveRoom stopPlayWithUserID:statusInfoView.userID callback:^(int code, NSString * error) {
            
        }];
        [statusInfoView emptyPlayInfo];
    } else {
        [self stopLocalPreview];
    }
    
    if ([self isNoAnchorINStatusInfoView]) {
        [self linkFrameRestore];
    }
}

- (UIView *)findFullScreenVideoView {
    for (id view in self.view.subviews) {
        if ([view isKindOfClass:[UIView class]] && ((UIView*)view).tag == FULL_SCREEN_PLAY_VIDEO_VIEW) {
            return (UIView*)view;
        }
    }
    return nil;
}


- (void)clickBtnCamera:(UIButton *)button {
    if (_isBeingLinkMic) {
        [self.liveRoom switchCamera];
    }
}

-(void)setIsOwnerEnter:(BOOL)isOwnerEnter {
    _isOwnerEnter = isOwnerEnter;
    [_videoParentView setHidden:!isOwnerEnter];
    [_noOwnerTip setHidden:_isOwnerEnter];
}

#pragma mark RTMP LOGIC

- (BOOL)checkPlayUrl:(NSString *)playUrl {
    if (!([playUrl hasPrefix:@"http:"] || [playUrl hasPrefix:@"https:"] || [playUrl hasPrefix:@"rtmp:"] )) {
        [TCUtil toastTip:@"播放地址不合法，目前仅支持rtmp,flv,hls,mp4播放方式!" parentView:self.view];
        return NO;
    }
    if (_isLivePlay) {
        if ([playUrl hasPrefix:@"rtmp:"]) {
            _playType = PLAY_TYPE_LIVE_RTMP;
        } else if (([playUrl hasPrefix:@"https:"] || [playUrl hasPrefix:@"http:"]) && [playUrl rangeOfString:@".flv"].length > 0) {
            _playType = PLAY_TYPE_LIVE_FLV;
        } else{
            [TCUtil toastTip:@"播放地址不合法，直播目前仅支持rtmp,flv播放方式!" parentView:self.view];
            return NO;
        }
    } else {
        if ([playUrl hasPrefix:@"https:"] || [playUrl hasPrefix:@"http:"]) {
            if ([playUrl rangeOfString:@".flv"].length > 0) {
                _playType = PLAY_TYPE_VOD_FLV;
            } else if ([playUrl rangeOfString:@".m3u8"].length > 0){
                _playType= PLAY_TYPE_VOD_HLS;
            } else if ([playUrl rangeOfString:@".mp4"].length > 0){
                _playType= PLAY_TYPE_VOD_MP4;
            } else {
                [TCUtil toastTip:@"播放地址不合法，点播目前仅支持flv,hls,mp4播放方式!" parentView:self.view];
                return NO;
            }
            
        } else {
            [TCUtil toastTip:@"播放地址不合法，点播目前仅支持flv,hls,mp4播放方式!" parentView:self.view];
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)startPlay {
    [self initRoomLogic];
    return YES;
}

- (BOOL)startRtmp {
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    return [self startPlay];
}

- (void)stopRtmp {
    if (!_isStop) {
        _isStop = YES;
    } else {
        return;
    }
    [self.liveRoom showVideoDebugLog:NO];
    if (self.liveRoom) {
        [self.liveRoom exitRoom:^(int code, NSString * error) {
            NSLog(@"exitRoom: errCode[%ld] errMsg[%@]", (long)code, error);
        }];
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

#pragma mark - TCAudienceToolbarDelegate
- (void)closeVC:(BOOL)popViewController {
    [self stopLocalPreview];
    [self stopLinkMic];
    [self closeVCWithRefresh:NO popViewController:popViewController];
    [self hideWaitingNotice];
    [self hiddenTip];
    [self dissmissVideo];
}

- (void)clickScreen:(CGPoint)position {
    
}

- (void)clickPlayVod {
    if (!_videoFinished) {
        if (_playType == PLAY_TYPE_VOD_FLV || _playType == PLAY_TYPE_VOD_HLS || _playType == PLAY_TYPE_VOD_MP4) {
            if (_videoPause) {
                NSAssert(NO, @"");
                //                [self.liveRoom resume];
                [_logicView.playBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
                [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            } else {
                NSAssert(NO, @"");
                //                [self.liveRoom pause];
                [_logicView.playBtn setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
                [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            }
            _videoPause = !_videoPause;
        }
    }
    else {
        [self startRtmp];
        [_logicView.playBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
}

- (void)onSeek:(UISlider *)slider {
    //    [self.liveRoom seek:_sliderValue];
    _trackingTouchTS = [[NSDate date]timeIntervalSince1970]*1000;
    _startSeek = NO;
}

- (void)onSeekBegin:(UISlider *)slider {
    _startSeek = YES;
}

- (void)onDrag:(UISlider *)slider {
    float progress = slider.value;
    int intProgress = progress + 0.5;
    _logicView.playLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",(int)intProgress / 3600,(int)(intProgress / 60), (int)(intProgress % 60)];
    _sliderValue = slider.value;
}

- (void)clickLog {
    _log_switch = !_log_switch;
    [self.liveRoom showVideoDebugLog:_log_switch];
}

- (void)onRecvGroupDeleteMsg {
    [self closeVC:NO];
    if (!_isErrorAlert) {
        _isErrorAlert = YES;
        __weak __typeof(self) weakSelf = self;
        [self showAlertWithTitle:@"直播已结束" sureAction:^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    }
}

- (void)closeVCWithRefresh:(BOOL)refresh popViewController: (BOOL)popViewController {
    [self stopRtmp];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (refresh) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.onPlayError) {
                self.onPlayError();
            }
        });
    }
    if (popViewController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)clickBtnLinkMic:(UIButton *)button {
    if (_isBeingLinkMic == NO) {
        //检查麦克风权限
        AVAuthorizationStatus statusAudio = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if (statusAudio == AVAuthorizationStatusDenied) {
            [TCUtil toastTip:@"获取麦克风权限失败，请前往隐私-麦克风设置里面打开应用权限" parentView:self.view];
            return;
        }
        
        //是否有摄像头权限
        AVAuthorizationStatus statusVideo = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (statusVideo == AVAuthorizationStatusDenied) {
            [TCUtil toastTip:@"获取摄像头权限失败，请前往隐私-相机设置里面打开应用权限" parentView:self.view];
            return;
        }
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
            [TCUtil toastTip:@"系统不支持硬编码， 启动连麦失败" parentView:self.view];
            return;
        }
        
        [self startLinkMic];
    }
    else {
        [self stopLocalPreview];
    }
}

#pragma mark PK
- (void)switchPKMode {
    //查找存在的视频流
    for (TCStatusInfoView * statusInfoView in _statusInfoViewArray) {
        if ([statusInfoView.userID length] > 0) {
            [statusInfoView.videoView setFrame:CGRectMake(self.view.frame.size.width / 2, 0, self.view.frame.size.width / 2, self.view.frame.size.height / 2)];
            break;
        }
    }
}

- (void)linkFrameRestore {
    for (TCStatusInfoView * statusInfoView in _statusInfoViewArray) {
        if ([statusInfoView.userID length] > 0) {
            [statusInfoView.videoView setFrame:statusInfoView.linkFrame];
        }
    }
}
- (void)onTEBHistroyDataSyncCompleted
{
    //（1）获取白板 UIView
    self.boardView = [_boardController getBoardRenderView];
    [_boardController setDrawEnable:NO];
    //（2）设置显示位置和大小
    //    CGRect(x: 0, y: 100, width: self.view.frame.size.width / 2, height: self.view.frame.size.height / 2)
    self.boardView.frame = CGRectMake(0, StatusBarHeight, self.view.frame.size.width, self.view.frame.size.width / 2 + 40);
    //（3）添加到父视图中 375/2 227
    [self.view addSubview:self.boardView];
    
    self.myvideoView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.width / 2 + 40)];
    [self.myvideoView setHidden: YES];
    [self.view addSubview:self.myvideoView];
    if (_jzPlayer != nil) {
        [self.view bringSubviewToFront:_jzPlayer];
    }
    if (self.backImgView != nil) {
        [self.view addSubview:self.backImgView];
    }
    self.changeBtn = [[UIButton alloc]init];
    [self.view addSubview:self.changeBtn];
    self.changeBtn.frame = CGRectMake(SCREEN_WIDTH - 50, StatusBarHeight + SCREEN_WIDTH / 2 , 25, 25);
    [self.changeBtn setSelected:NO];
    [self.changeBtn setImage:[UIImage imageNamed:@"全屏"] forState:UIControlStateNormal];
    [self.changeBtn setImage:[UIImage imageNamed:@"全屏"] forState:UIControlStateSelected];
    [self.changeBtn addTarget:self action:@selector(changeAction:) forControlEvents:UIControlEventTouchUpInside];

    self.changeVideoBtn = [[UIButton alloc]init];
    [self.view addSubview:self.changeVideoBtn];
    self.changeVideoBtn.frame = CGRectMake(SCREEN_WIDTH - 94 - 50.51, StatusBarHeight + 5, 60, 25);
    [self.changeVideoBtn setSelected:NO];
    [self.changeVideoBtn setImage:[UIImage imageNamed:@"change_screen"] forState:UIControlStateNormal];
    [self.changeVideoBtn setImage:[UIImage imageNamed:@"change_screen"] forState:UIControlStateSelected];
    [self.changeVideoBtn setTitle:@" 切屏" forState:normal];
    [self.changeVideoBtn addTarget:self action:@selector(changeVideoBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.changeVideoBtn.backgroundColor = [UIColor hex:@"909090"];
    self.changeVideoBtn.layer.cornerRadius = 25/2;
    
    self.nowTestBtn = [[UIButton alloc]init];
    [self.view addSubview:self.nowTestBtn];
    self.nowTestBtn.frame = CGRectMake(SCREEN_WIDTH - 14 - 50.51, StatusBarHeight + 5, 25, 25);
    [self.nowTestBtn setSelected:NO];
    self.nowTestBtn.layer.cornerRadius = 12.5;
    [self.nowTestBtn setImage:[UIImage imageNamed:@"ceshi"] forState:UIControlStateNormal];
    [self.nowTestBtn setImage:[UIImage imageNamed:@"ceshi"] forState:UIControlStateSelected];
    self.nowTestBtn.backgroundColor = [UIColor grayColor];
    [self.nowTestBtn addTarget:self action:@selector(nowTestBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.muteBtn = [[UIButton alloc]init];
    [self.view addSubview:self.muteBtn];
    self.muteBtn.frame = CGRectMake(SCREEN_WIDTH - 100, StatusBarHeight + SCREEN_WIDTH / 2 , 25, 25);
    [self.muteBtn setSelected:NO];
    [self.muteBtn setImage:[UIImage imageNamed:@"音量"] forState:UIControlStateNormal];
    [self.muteBtn setImage:[UIImage imageNamed:@"静音"] forState:UIControlStateSelected];
    [self.muteBtn addTarget:self action:@selector(muteAllRemoteAudio:) forControlEvents:UIControlEventTouchUpInside];
    
    self.danMuBtn.backgroundColor = [UIColor hex:@"909090"];
    [self.view addSubview:self.danMuBtn];
    [self.danMuBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(130);
        make.bottom.equalTo(self.muteBtn);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    [self.danMuBtn sizeToFit];
    [self.danMuBtn setTitle:@"说点什么" forState:normal];
    [self.danMuBtn addTarget:self action:@selector(danMuAction)];
    //    self.peopleCount.text = @"在线人数: 100";
    self.danMuBtn.font = [UIFont systemFontOfSize:15];
    self.danMuBtn.layer.cornerRadius = 10;
    self.danMuBtn.clipsToBounds = YES;
    
    
    
    [self.view addSubview:self.danMuTypeBtn];
    [self.danMuTypeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.muteBtn.mas_left).offset(-10);
        make.bottom.equalTo(self.muteBtn);
        make.size.mas_equalTo(CGSizeMake(25, 25));
    }];
    [self.danMuTypeBtn addTarget:self action:@selector(danMuTypeAction:)];
    [self.danMuTypeBtn setSelected:NO];
    [self.danMuTypeBtn setImage:[UIImage imageNamed:@"禁用弹幕"] forState:UIControlStateNormal];
    [self.danMuTypeBtn setImage:[UIImage imageNamed:@"弹幕"] forState:UIControlStateSelected];
    self.danMuTypeBtn.layer.cornerRadius = 12.5;
    self.danMuTypeBtn.clipsToBounds = YES;
        
    
    
    self.peopleCount.backgroundColor = [UIColor hex:@"909090"];
    self.peopleCount.textColor = [UIColor whiteColor];
       [self.view addSubview:self.peopleCount];
       [self.peopleCount mas_makeConstraints:^(MASConstraintMaker *make) {
           make.left.mas_equalTo(14);
           make.bottom.equalTo(self.muteBtn);
           make.size.mas_equalTo(CGSizeMake(100, 20));
       }];
    [self.peopleCount sizeToFit];
//    self.peopleCount.text = @"在线人数: 100";
    self.peopleCount.font = [UIFont systemFontOfSize:15];
    self.peopleCount.layer.cornerRadius = 10;
    self.peopleCount.clipsToBounds = YES;
    self.peopleCount.textAlignment = NSTextAlignmentCenter;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         self->_audienceCount = [self.needDict.peopleNumber  intValue];
        self.peopleCount.text = [NSString stringWithFormat:@"在线人数: %ld",(long)self->_audienceCount + [self.needDict.roomOnlinenumber  intValue]];
    });
    
}

- (void)danMuTypeAction:(UIButton *)sender{
    [self.danMuTypeBtn setSelected:!self.danMuTypeBtn.isSelected];
    if (self.isCanShow == NO) {
        
            _logicView.msgTableView.hidden = NO;
        
      
//        _logicView.bulletBtnIsOn = YES;
    }else{
        
         if (self.danMuTypeBtn.isSelected == YES) {
             //弹幕开
                  self.logicView.msgTableView.hidden = NO;
              }else{
             //弹幕关
                  self.logicView.msgTableView.hidden = YES;
              }
              
        
//        _logicView.bulletBtnIsOn = NO;
    }
    
}

- (void)danMuAction{
     [_logicView.msgInputFeild becomeFirstResponder];;
}

- (void)nowTestBtnAction:(UIButton *)sender{
    // 随堂测
    NowTestViewController *tempVC = [[NowTestViewController alloc] init];
    
//    if ([[self.dataArr[indexPath.row] topicList] count] == 0) {
//        return;
//    }
//    self.questionViewController.tempArr = [self.dataArr[indexPath.row] topicList];
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,HPScreenWidth , HPScreenHeight)];
    UIView *tempView = tempVC.view;
    tempView.frame = CGRectMake(0, 264 - 80 + (HPScreenHeight - 64 - 200 + 80) ,HPScreenWidth  , HPScreenHeight - 64 - 200 + 80);
    tempView.alpha = 1;
     
    UIView *backColorView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, HPScreenWidth, HPScreenHeight)];
    backColorView.alpha = 0;
    backColorView.backgroundColor = UIColor.blackColor;
    [backView addSubview:backColorView];
    [backView addSubview:tempView];
    backView.tag = 1000002;
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

- (void)changeVideoBtnAction:(UIButton *)sender{
    if (sender != nil) {
        [sender setSelected: !sender.isSelected];
    }else{
        if (self.changeVideoBtn.isSelected){
            CGRect temp = self.statusInfoView.videoView.frame;
            self.statusInfoView.videoView.frame = self.boardView.frame;
            self.boardView.frame = temp;
            //    self.centerImageView.frame = temp;
            self.centerImageView.frame = self.statusInfoView.videoView.frame;
            [self.view bringSubviewToFront:self.centerImageView];
            [self.view bringSubviewToFront:self.statusInfoView.videoView];
            self.centerImageView.userInteractionEnabled = YES;
            [self.view bringSubviewToFront:self.boardView];
            self.myvideoView.frame = self.boardView.frame;
            [self.view bringSubviewToFront:self.myvideoView];
            if (_jzPlayer != nil) {
                [self.view bringSubviewToFront:_jzPlayer];
            }
            
            if (self.backImgView != nil) {
                [self.view addSubview:self.backImgView];
            }
            
            [self.view bringSubviewToFront:self.changeVideoBtn];
            [self.view bringSubviewToFront:self.changeBtn];
            [self.view bringSubviewToFront:self.muteBtn];
            [self.view bringSubviewToFront:_logicView];
            [self.view bringSubviewToFront:self.nowTestBtn];
            [self.view bringSubviewToFront:self.peopleCount];
            [self.view bringSubviewToFront:self.smallStatusInfoView.videoView];
            [self.view bringSubviewToFront:self.smallOnlineStatusInfoView.videoView];
            [self.view bringSubviewToFront:self.danMuBtn];
            [self.view bringSubviewToFront:self.danMuTypeBtn];
            [self.view bringSubviewToFront:self.myimageView];
            
//            self.nowTestBtn.frame = CGRectMake(SCREEN_WIDTH - 14 - 50.51, StatusBarHeight + 5, 25, 25);
            return;
        }else{
            
            [self.view bringSubviewToFront:self.boardView];
            self.myvideoView.frame = self.boardView.frame;
            [self.view bringSubviewToFront:self.myvideoView];
            [self.view bringSubviewToFront:self.centerImageView];
            [self.view bringSubviewToFront:self.statusInfoView.videoView];
            if (_jzPlayer != nil) {
                [self.view bringSubviewToFront:_jzPlayer];
            }
            if (self.backImgView != nil) {
                [self.view addSubview:self.backImgView];
            }
            [self.view bringSubviewToFront:self.changeVideoBtn];
            [self.view bringSubviewToFront:self.changeBtn];
            [self.view bringSubviewToFront:self.muteBtn];
            [self.view bringSubviewToFront:_logicView];
            [self.view bringSubviewToFront:self.nowTestBtn];
            [self.view bringSubviewToFront:self.peopleCount];
            [self.view bringSubviewToFront:self.smallStatusInfoView.videoView];
            [self.view bringSubviewToFront:self.smallOnlineStatusInfoView.videoView];
            [self.view bringSubviewToFront:self.danMuBtn];
            [self.view bringSubviewToFront:self.danMuTypeBtn];
            [self.view bringSubviewToFront:self.myimageView];
            return;
        }
    }
    if (sender.isSelected) {
        // 直播视频大屏
//        [self.view addSubview:_logicView];
//        [_logicView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.size.mas_equalTo(CGSizeMake(100, 200));
//            make.bottom.equalTo(self.view);;
//            make.left.mas_equalTo(14);
//        }];
        
        
        CGRect temp = self.statusInfoView.videoView.frame;
        self.statusInfoView.videoView.frame = self.boardView.frame;
        self.boardView.frame = temp;
        //    self.centerImageView.frame = temp;
        self.centerImageView.frame = self.statusInfoView.videoView.frame;
        [self.view bringSubviewToFront:self.centerImageView];
        [self.view bringSubviewToFront:self.statusInfoView.videoView];
        self.centerImageView.userInteractionEnabled = YES;
        [self.view bringSubviewToFront:self.boardView];
        self.myvideoView.frame = self.boardView.frame;
        [self.view bringSubviewToFront:self.myvideoView];
        if (_jzPlayer != nil) {
            [self.view bringSubviewToFront:_jzPlayer];
        }
        if (self.backImgView != nil) {
            [self.view addSubview:self.backImgView];
        }
        [self.view bringSubviewToFront:self.changeVideoBtn];
        [self.view bringSubviewToFront:self.changeBtn];
        [self.view bringSubviewToFront:self.muteBtn];
        [self.view bringSubviewToFront:_logicView];
        [self.view bringSubviewToFront:self.nowTestBtn];
        [self.view bringSubviewToFront:self.peopleCount];
        [self.view bringSubviewToFront:self.smallStatusInfoView.videoView];
        [self.view bringSubviewToFront:self.smallOnlineStatusInfoView.videoView];
        [self.view bringSubviewToFront:self.danMuBtn];
        [self.view bringSubviewToFront:self.danMuTypeBtn];
        [self.view bringSubviewToFront:self.myimageView];
//        [self.view bringSubviewToFront:self.smallOnlineStatusInfoView.videoView];

        [self.smallOnlineStatusInfoView.videoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.boardView);
            make.bottom.equalTo(self.boardView);
            make.size.mas_equalTo(CGSizeMake(100/2, 70/2));
        }];
        [self.smallStatusInfoView.videoView mas_remakeConstraints:^(MASConstraintMaker *make) {
               make.right.equalTo(self.boardView);
               make.bottom.equalTo(self.boardView);
               make.size.mas_equalTo(CGSizeMake(100/2, 70/2));
           }];
           
    }else{
        
        // 投影 白板视频大屏
        CGRect temp = self.statusInfoView.videoView.frame;
        self.statusInfoView.videoView.frame = self.boardView.frame;
        self.boardView.frame = temp;
        self.centerImageView.frame = self.statusInfoView.videoView.frame;
        self.centerImageView.userInteractionEnabled = YES;
        [self.view bringSubviewToFront:self.boardView];
        self.myvideoView.frame = self.boardView.frame;
        [self.view bringSubviewToFront:self.myvideoView];
        [self.view bringSubviewToFront:self.centerImageView];
        [self.view bringSubviewToFront:self.statusInfoView.videoView];
        if (_jzPlayer != nil) {
            [self.view bringSubviewToFront:_jzPlayer];
        }
        if (self.backImgView != nil) {
            [self.view addSubview:self.backImgView];
        }
        [self.view bringSubviewToFront:self.changeVideoBtn];
        [self.view bringSubviewToFront:self.changeBtn];
        [self.view bringSubviewToFront:self.muteBtn];
        [self.view bringSubviewToFront:_logicView];
        [self.view bringSubviewToFront:self.nowTestBtn];
        [self.view bringSubviewToFront:self.peopleCount];
        [self.view bringSubviewToFront:self.smallStatusInfoView.videoView];
        [self.view bringSubviewToFront:self.smallOnlineStatusInfoView.videoView];
        [self.view bringSubviewToFront:self.danMuBtn];
        [self.view bringSubviewToFront:self.danMuTypeBtn];
        [self.view bringSubviewToFront:self.myimageView];
        [self.smallOnlineStatusInfoView.videoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.centerImageView);
            make.bottom.equalTo(self.centerImageView);
            make.size.mas_equalTo(CGSizeMake(100/2, 70/2));
        }];
        [self.smallStatusInfoView.videoView mas_remakeConstraints:^(MASConstraintMaker *make) {
               make.right.equalTo(self.centerImageView);
               make.bottom.equalTo(self.centerImageView);
               make.size.mas_equalTo(CGSizeMake(100/2, 70/2));
           }];
           
    }
}

- (void)changeAction:(UIButton *)sender{
    if (sender != nil) {
        [sender setSelected: !sender.isSelected];
    }
    if (sender.selected) {
        //全屏
        [self.danMuTypeBtn setHidden:NO];
        self.isCanShow = YES;
        if (self.danMuTypeBtn.isSelected == YES) {
            self.logicView.msgTableView.hidden = NO;
        }else{
            self.logicView.msgTableView.hidden = YES;
        }
        self.danMuBtn.hidden = NO;
        [self initlogicBigView];
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
        self.nowTestBtn.hidden = YES;
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformRotate(transform, M_PI_2);
//        self.boardView.transform = transform;
        self.boardView.frame = self.view.frame;
        
        [self.view bringSubviewToFront:self.centerImageView];
        [self.view bringSubviewToFront:self.statusInfoView.videoView];
//        self.statusInfoView.videoView.transform = transform;
//        self.centerImageView.transform = transform;
        self.centerImageView.frame = CGRectMake(SCREEN_WIDTH - 114, SCREEN_HEIGHT - 150, 100, 70);
        self.statusInfoView.videoView.frame = CGRectMake(SCREEN_WIDTH - 114, SCREEN_HEIGHT - 150, 100, 70);
        self.changeVideoBtn.frame = CGRectMake(SCREEN_WIDTH - 94 - 50.51, StatusBarHeight + 5, 60, 25);
        self.changeBtn.frame = CGRectMake(SCREEN_WIDTH - 50, SCREEN_HEIGHT - 60 , 25, 25);
        self.muteBtn.frame = CGRectMake(SCREEN_WIDTH - 100, SCREEN_HEIGHT - 60 , 25, 25);
        
        _jzPlayer.frame = self.view.frame;
        
        self.myimageView.hidden = NO;
        self.myimageView.frame = CGRectMake(250, StatusBarHeight + 5 + 50, 1000, self.view.height - 150);
        [self.view addSubview:self.myimageView];
        self.myimageView.userInteractionEnabled = NO;
        self.myimageView.backgroundColor = UIColor.clearColor;
        
    }else{
        //竖屏
        [self.danMuTypeBtn setHidden:YES];
        self.myimageView.hidden = YES;
        self.isCanShow = NO;
        self.danMuBtn.hidden = YES;
        self.nowTestBtn.hidden = NO;
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
        
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformRotate(transform, M_PI_2);
//        self.boardView.transform = transform;
        self.boardView.frame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.width / 2 + 40);
        [self.view bringSubviewToFront:self.centerImageView];
        [self.view bringSubviewToFront:self.statusInfoView.videoView];
//        self.statusInfoView.videoView.transform = transform;
//        self.centerImageView.transform = transform;
        self.centerImageView.frame = CGRectMake(14, self.view.width/375 *260 + 7, 100, 70);
        self.statusInfoView.videoView.frame = CGRectMake(14, self.view.width/375 *260 + 7, 100, 70);
        
        self.changeBtn.frame = CGRectMake(SCREEN_WIDTH - 50, StatusBarHeight + SCREEN_WIDTH / 2 , 25, 25);
        self.changeVideoBtn.frame = CGRectMake(SCREEN_WIDTH - 94 - 50.51, StatusBarHeight + 5, 60, 25);
        self.muteBtn.frame = CGRectMake(SCREEN_WIDTH - 100, StatusBarHeight + SCREEN_WIDTH / 2 , 25, 25);
        
        
        _jzPlayer.frame = CGRectMake(0, 20, self.view.width , self.view.width/375*200 + 20);
        _jzPlayer.playerLayer.frame = CGRectMake(0, 0, HPScreenWidth, HPScreenWidth/375*200);
//        _jzPlayer.playerLayer.frame = CGRectMake(0, StatusBarHeight, HPScreenWidth - 80, HPScreenWidth/375*200 - StatusBarHeight );
        
        CGFloat bottom = 0;
        if (@available(iOS 11, *)) {
            bottom = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
        }
        CGRect frame = CGRectMake(0, 0, kScreenWith, self.view.height - (self.view.frame.size.width/375*260 + 50 + 70));
        frame.size.height -= bottom;
        self.logicView.frame = frame;
        [self initReBack];
    }
    [self changeVideoBtnAction:nil];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationMaskLandscapeLeft;
}
- (BOOL)shouldAutomaticallyForwardRotationMethods{
    return  YES;
}
//
//override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
//    return .landscapeRight
//}
//
//override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
//    return .landscapeRight
//}
//override var shouldAutorotate: Bool{
//    return true
//}
//override func shouldAutomaticallyForwardRotationMethods() -> Bool {
//    return true
//}

//- (void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available{


//    [TRTCCloud.sharedInstance startRemoteSubStreamView:userId view:self.view];
//    self.videoView = [[UIView alloc]initWithFrame:CGRectMake(0, kStatusBarAndNavigationBarHeight - 44, self.view.frame.size.width, self.view.frame.size.width/2)];
//    [self.view addSubview:self.videoView];
//    TRTCCloud.sharedInstance()?.startRemoteSubStreamView(userId, view: self.videoView)

//}
//- (void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available{
//    self.videoView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.width/3))
//          self.view.addSubview(self.videoView)
//
//          TRTCCloud.sharedInstance()?.startRemoteSubStreamView(userId, view: self.videoView)
//
//}
// 监听屏幕分享

//列表内容
- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return self.categoryView.titles.count;
}
//根据下标index返回对应遵从`JXCategoryListContentViewDelegate`协议的列表实例
- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    if (index == 0) {
        ListViewController*VC = [[ListViewController alloc] init];
        self.jianjieLabel = [[UITextView alloc]initWithFrame:CGRectMake(14, 30, kScreenWith - 28, 180)];
        self.jianjieLabel.backgroundColor = UIColorFromRGB(0xF7F7F7);
        self.jianjieLabel.textColor = [UIColor blackColor];
        self.jianjieLabel.font = [UIFont systemFontOfSize:14];
//        self.jianjieLabel.userInteractionEnabled = false;
        self.jianjieLabel.layer.cornerRadius = 5;
//        self.jianjieLabel.text = @"暂无简介";
        self.jianjieLabel.textContainerInset = UIEdgeInsetsMake(14, 14, 0, 14);
        [VC.view addSubview:self.jianjieLabel];
        return VC;
    }else if (index == 1){
        
        self.logicView.tag = 10000088;
        [self.bottomVC.view addSubview:self.logicView];
//        [[UIApplication sharedApplication].keyWindow addSubview:self.logicView];
//        VC.logicView = self.logicView;
        return self.bottomVC;
    }else if (index == 2){
        ExercisesTableViewController*VC = [[ExercisesTableViewController alloc] init];
        VC.roomId = [_liveInfo.roomId intValue];
        return VC;
    }else if (index == 3){
        NoticeListViewController*VC = [[NoticeListViewController alloc] init];
        VC.roomId = [_liveInfo.roomId intValue];
        return VC;
    }
    return [[ListViewController alloc] init];
}




@end

#pragma mark- TableView

