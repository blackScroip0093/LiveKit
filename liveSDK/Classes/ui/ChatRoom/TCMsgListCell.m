/**
 * Module: TCMsgListCell
 *
 * Function: 消息Cell
 */

#import "TCMsgListCell.h"
#import "TCUtil.h"
#import "ColorMacro.h"
#import "UIView+Additions.h"
#import <liveSDK/liveSDK-Swift.h>
#import "Masonry.h"
#import "UIColor+HPCategory.h"
#import "SDWebImage.h"

static NSMutableArray      *_arryColor;
static NSInteger           _index = 0;

@implementation TCMsgListCell
{
    UIView  *_msgView;
    UILabel *_msgLabel;
    UIImageView *_msgBkView;
    UIImageView *_photoImageView;
    UILabel *_nameLabel;
    UILabel *_tipLabel;
    TCMsgModel *_msgModel;
    UIImageView *_centerImage;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _msgView  = [[UIView alloc] initWithFrame:CGRectZero];
        [_msgView setBackgroundColor:[UIColor hex:@"CEE6FC"]];
        _msgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _msgLabel.numberOfLines = 0;
        _msgLabel.font = [UIFont systemFontOfSize:MSG_TABLEVIEW_LABEL_FONT];
        _centerImage = [[UIImageView alloc]init];
        _photoImageView = [[UIImageView alloc]init];
        _centerImage.contentMode = UIViewContentModeScaleAspectFit;
        _nameLabel = [[UILabel alloc]init];
        _tipLabel = [[UILabel alloc]init];
        
        [_msgView addSubview:_msgLabel];
        
        [self.contentView addSubview:_centerImage];
        [self.contentView addSubview:_msgView];
        [self.contentView addSubview:_photoImageView];
        [self.contentView addSubview:_nameLabel];
        [self.contentView addSubview:_tipLabel];
    }
    return self;
}
 
- (void)layoutSubviews {
    _msgView.frame  = CGRectMake(0, 40, _msgLabel.width + 20, _msgLabel.height + 16);
    if (_msgModel.msgType == TCMsgModelType_NormalMsg || _msgModel.msgType == TCMsgModelType_DanmaMsg||_msgModel.msgType == TCMsgModelType_Image || _msgModel.msgType == TCMsgModelType_NormalImage ||_isBig == YES) {
        _photoImageView.hidden = NO;
        _nameLabel.hidden = NO;
        _tipLabel.hidden = NO;
        _msgView.frame  = CGRectMake(0, 40, _msgLabel.width + 20, _msgLabel.height + 16);
    }else if (_msgModel.msgType == TCMsgModelType_MemberEnterRoom || _msgModel.msgType == TCMsgModelType_MemberQuitRoom){
        _photoImageView.hidden = YES;
        _nameLabel.hidden = YES;
        _tipLabel.hidden = YES;
        _msgView.hidden = YES;
    }else{
        _photoImageView.hidden = YES;
        _nameLabel.hidden = YES;
        _tipLabel.hidden = YES;
        _msgView.frame  = CGRectMake(0, 0, _msgLabel.width + 20, _msgLabel.height + 16);
    }
    _msgLabel.frame = CGRectMake(14, 8, _msgLabel.width, _msgLabel.height);

    _msgBkView.frame = _msgView.frame;
    _photoImageView.image =[UIImage imageNamed:@"学员"];
    
    NSLog(@"%@",[[ProfileManager shared]curUserID]);
    
    if ([_msgModel.userId isEqualToString:[[[ProfileManager shared] loginUserModel] userId]] && self.isBig == NO) {
            _msgView.frame  = CGRectMake(kScreenWith - 28 - 20 - _msgLabel.width - 14, 40, _msgLabel.width + 20, _msgLabel.height + 16);
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_msgView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight |UIRectCornerTopLeft cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = _msgView.bounds;
        maskLayer.path = maskPath.CGPath;
        _msgView.layer.mask = maskLayer;
        [_photoImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_msgView);
            make.size.mas_equalTo(CGSizeMake(25, 25));
            make.top.mas_equalTo(5);
        }];
        
        [_nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_photoImageView.mas_left).offset(-5);
            make.centerY.equalTo(_photoImageView);
        }];
        [_nameLabel sizeToFit];
        
        [_tipLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_nameLabel.mas_left).offset(-5);
            make.centerY.equalTo(_photoImageView);
            make.size.mas_equalTo(CGSizeMake(40, 20));
        }];
        _tipLabel.clipsToBounds = YES;
        _tipLabel.layer.cornerRadius = 10;
        _tipLabel.backgroundColor = [UIColor hex:@"#D6D7D6"];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.textColor = [UIColor hex:@"6c6c6c"];
        NSLog(@"%@", [NSString stringWithFormat:@"%@",[[ProfileManager shared] teacherId]]);
        if (_msgModel.userId == [[ProfileManager shared]teacherId]) {
            _tipLabel.text = @"老师";
        }else{
            _tipLabel.text = @"学员";
            _photoImageView.image =[UIImage imageNamed:@"老师"];
        }
        if ([_msgModel.userHeadImageUrl isEqualToString:@"公告"]){
            _photoImageView.image =[UIImage imageNamed:@"gonggao"];
            _tipLabel.text = @"";
            _tipLabel.backgroundColor = [UIColor whiteColor];
        }else{
            _tipLabel.backgroundColor = [UIColor hex:@"#D6D7D6"];
        }
        if (_msgModel.msgType == TCMsgModelType_Image) {
            _msgBkView.frame = _msgView.frame;
            _centerImage.frame = CGRectMake(kScreenWith - 200, 40, 150, 150);
            _centerImage.image = _msgModel.tempImage;
            _centerImage.hidden = NO;
            _msgView.hidden = YES;
        }else if (_msgModel.msgType == TCMsgModelType_NormalImage){
            _msgBkView.frame = _msgView.frame;
            _centerImage.frame = CGRectMake( 14, 40, 150, 150);
            [_centerImage sd_setImageWithURL:[NSURL URLWithString:_msgModel.imageUrl]];
            _msgLabel.hidden = YES;
            _centerImage.hidden = NO;
            _msgView.hidden = YES;
        }
        else{
            _msgView.hidden = NO;
            _centerImage.hidden = YES;
        }

    }else{
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_msgView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight |UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = _msgView.bounds;
        maskLayer.path = maskPath.CGPath;
        _msgView.layer.mask = maskLayer;
        
        [_photoImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_msgView);
            make.size.mas_equalTo(CGSizeMake(25, 25));
            make.top.mas_equalTo(5);
        }];
        
        
        [_nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_photoImageView.mas_right).offset(5);
            make.centerY.equalTo(_photoImageView);
        }];
        
        [_nameLabel sizeToFit];
        
        [_tipLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_nameLabel.mas_right).offset(5);
            make.centerY.equalTo(_photoImageView);
            make.size.mas_equalTo(CGSizeMake(40, 20));
        }];
        _tipLabel.clipsToBounds = YES;
        _tipLabel.layer.cornerRadius = 10;
        _tipLabel.backgroundColor = [UIColor hex:@"#D6D7D6"];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.textColor = [UIColor hex:@"6c6c6c"];
        
//        [_photoImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.right.equalTo(_msgView);
//            make.size.mas_equalTo(CGSizeMake(25, 25));
//            make.top.mas_equalTo(5);
//        }];
        _photoImageView.image =[UIImage imageNamed:@"学员"];
        if (_msgModel.userId == [[ProfileManager shared]teacherId]) {
            _tipLabel.text = @"老师";
        }else{
            _tipLabel.text = @"学员";
            _photoImageView.image =[UIImage imageNamed:@"老师"];
        }
        if ([_msgModel.userHeadImageUrl isEqualToString:@"公告"]){
            _photoImageView.image =[UIImage imageNamed:@"gonggao"];
            _tipLabel.text = @"";
            _tipLabel.backgroundColor = [UIColor whiteColor];
        }else{
            _tipLabel.backgroundColor = [UIColor hex:@"#D6D7D6"];
        }
    }
    
    if (_msgModel.msgType == TCMsgModelType_MemberEnterRoom ||_msgModel.msgType == TCMsgModelType_MemberQuitRoom){
           _photoImageView.hidden = YES;
           _nameLabel.hidden = YES;
           _tipLabel.hidden = YES;
           _msgView.hidden = YES;
       }
//    if ([[ProfileManager shared] teacherId] isEqualToString:@"") {
//
//    }
    if (self.isBig) {
        _photoImageView.hidden = YES;
        _nameLabel.hidden = YES;
        _tipLabel.hidden = YES;
        _msgLabel.textColor = UIColor.whiteColor;
        [_msgView setBackgroundColor:[UIColor blackColor]];
        _msgView.alpha = 0.5;
        _msgView.frame  = CGRectMake(0, 0, _msgLabel.width + 20, _msgLabel.height + 4);
         UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_msgView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight |UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(4, 4)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = _msgView.bounds;
        maskLayer.path = maskPath.CGPath;
        _msgView.layer.mask = maskLayer;
        _msgLabel.frame = CGRectMake(14, 2, _msgLabel.width, _msgLabel.height);
//
//        NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] init];
//        NSMutableAttributedString *userName;
//        userName = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ", _nameLabel.text]];
//        [attribute appendAttributedString:userName];
//        [attribute appendAttributedString:_msgLabel.attributedText];
//        _msgLabel.attributedText = attribute;
//
        //_nameLabel.text = _msgModel.userName;
    }else{
        [_msgView setBackgroundColor:[UIColor hex:@"CEE6FC"]];
        _msgView.alpha = 1;
        _msgLabel.frame = CGRectMake(14, 8, _msgLabel.width, _msgLabel.height);
    }
    
}

- (void)refreshWithModel:(TCMsgModel *)msgModel {
    _msgModel = msgModel;
    _msgLabel.attributedText = msgModel.msgAttribText;
    if (_isBig) {
        NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] init];
        NSMutableAttributedString *userName;
        userName = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ", msgModel.userName]];
        [attribute appendAttributedString:userName];
        [attribute appendAttributedString:msgModel.msgAttribText];
        _msgLabel.attributedText = attribute;
    }

    
    
    
    _nameLabel.text = _msgModel.userName;
    if (_isBig) {
        _msgLabel.width = HPScreenHeight - 28;
    }else{
        _msgLabel.width = kScreenWith - 28 - 28;
    }
    
    
    [_msgLabel sizeToFit];
    if (_msgModel.msgType == TCMsgModelType_Image) {
        _msgBkView.frame = _msgView.frame;
        _centerImage.frame = CGRectMake(kScreenWith - 200, 40, 150, 150);
        _centerImage.image = _msgModel.tempImage;
        _centerImage.hidden = NO;
        _msgView.hidden = YES;
    }else if(_msgModel.msgType == TCMsgModelType_NormalImage){
        _msgBkView.frame = _msgView.frame;
        _centerImage.frame = CGRectMake( 14, 40, 150, 150);
        [_centerImage sd_setImageWithURL:[NSURL URLWithString:_msgModel.imageUrl]];
        _msgLabel.hidden = YES;
        _centerImage.hidden = NO;
        _msgView.hidden = YES;
    }else{
        _msgLabel.hidden = NO;
        _msgView.hidden = NO;
        _centerImage.hidden = YES;
    }
//    _tipLabel
    
}

+ (NSAttributedString *)getAttributedStringFromModel:(TCMsgModel *)msgModel isBig:(BOOL)isBig{
     _arryColor = [[NSMutableArray alloc] initWithObjects:UIColorFromRGB(0x1fbcb6),UIColorFromRGB(0x2b7de2),UIColorFromRGB(0xff7906),nil];

    NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] init];
    if (msgModel.msgType == TCMsgModelType_NormalMsg || msgModel.msgType == TCMsgModelType_DanmaMsg) {
        NSMutableAttributedString *userName;
//        if (isBig) {
//             userName = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", msgModel.userName]];
//            [attribute appendAttributedString:userName];
//        }else{
        userName = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", @""]];
                   [attribute appendAttributedString:userName];
//        }
        
       
        
        NSMutableAttributedString *userMsg = [[NSMutableAttributedString alloc] initWithString:msgModel.userMsg];
        [attribute appendAttributedString:userMsg];
        
        [attribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:MSG_TABLEVIEW_LABEL_FONT] range:NSMakeRange(0,attribute.length)];
        
        _index = _index % [_arryColor count];
        [attribute addAttribute:NSForegroundColorAttributeName value:[_arryColor objectAtIndex:_index] range:NSMakeRange(0,userName.length)];
        [attribute addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(userName.length, userMsg.length)];
        _index++;
    }else if (msgModel.msgType == TCMsgModelType_Image){
        
    }else {
        NSMutableAttributedString *msgShow = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"通知 %@%@", msgModel.userName, msgModel.userMsg]];
        
        [attribute appendAttributedString:msgShow];
        [attribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:MSG_TABLEVIEW_LABEL_FONT] range:NSMakeRange(0, attribute.length)];
        [attribute addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:241/255.0 green:43/255.0 blue:91/255.0 alpha:1] range:NSMakeRange(0, msgShow.length)];
    }
    return attribute;
}
@end


#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImage+Additions.h"
#import "UIView+CustomAutoLayout.h"

@implementation TCShowLiveTopView
{
    UIImageView          *_hostImage;        // 主播头像
    UIImageView          *_durationImage;    // 直播时长
    UILabel              *_durationLabel;
    UILabel              *_audienceLabel;    // 在线观众数
    
    NSTimer              *_timer;
    NSInteger            _startTime;
    NSInteger            _liveDuration;      // 直播时长
    NSInteger            _audienceCount;     // 在线观众数
    NSInteger            _likeCount;         // 点赞数
    NSInteger            _totalViewerCount;  // 总共观看人数
    
    BOOL                 _isHost;            // 是否是主播
    NSString             *_hostNickName;     // 主播昵称
    NSString             *_hostFaceUrl;      // 头像地址
}

- (instancetype)initWithFrame:(CGRect)frame isHost:(BOOL)isHost hostNickName:(NSString *)hostNickName audienceCount:(NSInteger)audienceCount likeCount:(NSInteger)likeCount hostFaceUrl:(NSString *)hostFaceUrl {
    if (self = [super initWithFrame: frame]) {
        _audienceCount = audienceCount;
        _totalViewerCount = audienceCount;
        _likeCount = likeCount;
        _liveDuration = 0;

        _isHost = isHost;
        _hostNickName = hostNickName;
        _hostFaceUrl = hostFaceUrl;
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.layer.cornerRadius = frame.size.height / 2;
        self.layer.masksToBounds = YES;
        [self initUI];
    }
    return self;
}

- (void)setViewerCount:(int)viewerCount likeCount:(int)likeCount {
    _audienceCount = viewerCount;
    _totalViewerCount = viewerCount;
    _likeCount = likeCount;
    [_audienceLabel setText:[NSString stringWithFormat:@"%ld", _audienceCount]];
}

- (void)initUI {
    _hostImage = [[UIImageView alloc] init];
    _hostImage.layer.cornerRadius = (self.frame.size.height - 2) / 2;
    _hostImage.layer.masksToBounds = YES;
    [_hostImage sd_setImageWithURL:[NSURL URLWithString:[TCUtil transImageURL2HttpsURL:_hostFaceUrl]] placeholderImage:[UIImage imageNamed:@"default_user"]];
    [_hostImage setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(headTap:)];
    [self addSubview:_hostImage];
    [_hostImage addGestureRecognizer:tapGesture];
    
    _durationLabel = [[UILabel alloc] init];
    if (_isHost) {
        _durationImage = [[UIImageView alloc] init];
        _durationImage.image = [UIImage imageNamed:@"dot"];
        [self addSubview:_durationImage];
        
        [_durationLabel setText:@"00:00:00"];
    }
    else {
        [_durationLabel setText:_hostNickName];
    }
    _durationLabel.font = [UIFont boldSystemFontOfSize:10];
    _durationLabel.textColor = [UIColor whiteColor];
    [self addSubview:_durationLabel];
    
    
    _audienceLabel = [[UILabel alloc] init];
    [_audienceLabel setText:[NSString stringWithFormat:@"%ld", _audienceCount]];
    _audienceLabel.font = [UIFont boldSystemFontOfSize:10];
    _audienceLabel.textColor = [UIColor whiteColor];
    [self addSubview:_audienceLabel];
    
    
    // relayout
    [_hostImage sizeWith:CGSizeMake(33, 33)];
    [_hostImage layoutParentVerticalCenter];
    [_hostImage alignParentLeftWithMargin:1];
    
    if (_isHost) {
        [_durationImage sizeWith:CGSizeMake(5, 5)];
        [_durationImage alignParentTopWithMargin:7.5];
        [_durationImage layoutToRightOf:_hostImage margin:5];
        
        [_durationLabel sizeWith:CGSizeMake(48, 10)];
        [_durationLabel alignParentTopWithMargin:5];
        [_durationLabel layoutToRightOf:_durationImage margin:2.5];
    }
    else {
        [_durationLabel sizeWith:CGSizeMake(48, 10)];
        [_durationLabel alignParentTopWithMargin:5];
        [_durationLabel layoutToRightOf:_hostImage margin:10];
    }

    [_audienceLabel sameWith:_durationLabel];
    [_audienceLabel alignParentBottomWithMargin:5];
}

- (void)headTap:(UITapGestureRecognizer*)tap {
    if (self.clickHead != nil) {
        self.clickHead();
    }
}

- (void)startLive {
    if (_isHost) {
        _startTime = (NSInteger)[[NSDate date] timeIntervalSince1970];
        
        if (_timer) {
            [_timer invalidate];
        }
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onLiveTimer) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

- (void)pauseLive {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)resumeLive {
    [self startLive];
}

- (NSInteger)getViewerCount {
    return _audienceCount;
}

- (NSInteger)getLikeCount {
    return _likeCount;
}

- (NSInteger)getTotalViewerCount {
    return _totalViewerCount;
}

- (NSInteger)getLiveDuration {
    return _liveDuration;
}

- (void)onLiveTimer {
    NSInteger curTime = (NSInteger)[[NSDate date] timeIntervalSince1970];
    NSInteger dur = curTime - _startTime;
    
    NSString *durStr = nil;
    int h = (int)dur/3600;
    int m = (int)(dur - h *3600)/60;
    int s = (int)dur%60;
    durStr = [NSString stringWithFormat:@"%02d:%02d:%02d", h, m, s];
    
    _liveDuration = dur;
    [_durationLabel setText:durStr];
}

- (void)onUserEnterLiveRoom {
    _audienceCount ++;
    _totalViewerCount ++;
    [_audienceLabel setText:[NSString stringWithFormat:@"%ld", _audienceCount]];
}

- (void)onUserExitLiveRoom {
    if (_audienceCount > 0) {
        _audienceCount --;
    }
    [_audienceLabel setText:[NSString stringWithFormat:@"%ld", _audienceCount]];
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"peopleCount--" object:self userInfo:nil];
}

- (void)onUserSendLikeMessage {
    _likeCount ++;
}

@end


#pragma mark 观众列表

@implementation TCAudienceListCell
{
    UIImageView *_imageView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.transform = CGAffineTransformMakeRotation(M_PI / 2);
        [self.contentView addSubview:_imageView];
    }
    return self;
}

- (void)layoutSubviews {
    _imageView.frame = CGRectMake(0, 0, IMAGE_SIZE, IMAGE_SIZE);
    _imageView.layer.cornerRadius = _imageView.size.width/2;
    _imageView.clipsToBounds = YES;
}

- (void)refreshWithModel:(TRTCLiveUserInfo *)msgModel {
    [_imageView sd_setImageWithURL:[NSURL URLWithString:[TCUtil transImageURL2HttpsURL:msgModel.avatarURL]] placeholderImage:[UIImage imageNamed:@"face"]];
    _imageView.hidden = YES;
}
@end
