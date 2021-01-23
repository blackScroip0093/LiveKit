//
//  ResultViewController.m
//  TXLiteAVDemo_TRTC
//
//  Created by 赵佟越 on 2020/11/18.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "ResultViewController.h"
 #import <liveSDK/liveSDK-Swift.h>
#import "UIColor+HPCategory.h"

@interface ResultViewController ()
@property (nonatomic, strong) UIButton *rightCloseBtn;
@property (nonatomic, strong) NSMutableArray *tempArr;
@end

@implementation ResultViewController
{
    UILabel *allScoreLabel;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.rightCloseBtn];
    // Do any additional setup after loading the view.
    [self.rightCloseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-14);
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.top.mas_equalTo(10);
    }];
    [self makeBaseUI];
    
}

- (void)makeBaseUI{
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.text = @"恭喜你完成测试";
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.mas_equalTo(15);
    }];
    
    UIImageView *imgImageView = [[UIImageView alloc]init];
    [self.view addSubview:imgImageView];
    [imgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(titleLabel.mas_bottom).offset(20);
        make.size.mas_equalTo(CGSizeMake(249, 210));
    }];
    imgImageView.image = [UIImage imageNamed:@"手机竖屏分数"];

    
    UILabel *scoreLabel = [[UILabel alloc]init];
//    scoreLabel.text = @"获得50分 用时30秒";
    [self.view addSubview:scoreLabel];
    [scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(imgImageView.mas_bottom).offset(10);
    }];
    
    allScoreLabel = [[UILabel alloc]init];
    [self.view addSubview:allScoreLabel];
    
    [allScoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(scoreLabel.mas_bottom).offset(10);
    }];
    
    UILabel *seeScoreLabel = [[UILabel alloc]init];
    seeScoreLabel.text = [NSString stringWithFormat:@"  总分%@\n查看成绩",_tempDic[@"allGrade"]];
    [self.view addSubview:seeScoreLabel];
    [seeScoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(allScoreLabel.mas_bottom).offset(15);
    }];
    seeScoreLabel.numberOfLines = 0;
    [seeScoreLabel sizeToFit ];
    UILabel *sureScoreLabel = [[UILabel alloc]init];
    sureScoreLabel.text =[NSString stringWithFormat:@"正确%@错误%@",_tempDic[@"correctNumber"],_tempDic[@"mistakeNumber"]] ;
    [self.view addSubview:sureScoreLabel];
    [sureScoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(seeScoreLabel.mas_bottom).offset(15);
    }];
    _tempArr = [[NSMutableArray alloc] init];
    _tempArr = _tempDic[@"amlist"];//@[@"",@"",@"",@"",@"",@"",@"",@""].mutableCopy;
    
    for (int i = 0; i<_tempArr.count; i++) {
        UILabel *tempLabel = [[UILabel alloc]init];
        tempLabel.text = [NSString stringWithFormat:@"%@",_tempArr[i][@"answerNumber"]];
        [self.view addSubview:tempLabel];
        int tempHeight = i/5;
        int leftWight = i%5;
        tempLabel.layer.cornerRadius = 30/2;
        NSString *tempStr = [NSString stringWithFormat:@"%@",_tempArr[i][@"isCorrect"]];
        if ([tempStr isEqualToString: @"1"]) {
            tempLabel.backgroundColor = [UIColor hex:@"b71a06"];
        }else{
            tempLabel.backgroundColor = [UIColor hex:@"2aa515"];
        }
        
        tempLabel.clipsToBounds = YES;
        tempLabel.textColor = [UIColor whiteColor];
        tempLabel.textAlignment = NSTextAlignmentCenter;
        
        [tempLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(sureScoreLabel.mas_bottom).offset(15 + tempHeight * 40);
            make.size.mas_equalTo(CGSizeMake(30, 30));
            if (leftWight == 0) {
                make.left.mas_equalTo(50);
            }else if (leftWight == 2){
                make.centerX.equalTo(self.view);
            }else if (leftWight == 4){
                make.right.equalTo(self.view).offset(-50);
            }else if (leftWight == 1){
                make.centerX.equalTo(self.view).offset(-(self.view.width - 100)/4);
            }else if (leftWight == 3){
                make.centerX.equalTo(self.view).offset((self.view.width - 100)/4);
            }
        }];
    }
}

- (void)closeAction{
    [[[UIApplication sharedApplication].keyWindow viewWithTag:1000003] removeFromSuperview];
}


- (UIButton *)rightCloseBtn {
    if (!_rightCloseBtn){
        _rightCloseBtn = [[UIButton alloc]init];
        [_rightCloseBtn setImage:[UIImage imageNamed:@"cha"] forState:normal];
    }
    _rightCloseBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_rightCloseBtn addTarget:self action:@selector(closeAction)];
    return _rightCloseBtn;
}
- (void)setTempDic:(NSDictionary *)tempDic{
    if (_tempDic != tempDic) {
        _tempDic = tempDic;
    }
}

- (void)setUse_time:(NSString *)use_time{
    if (_use_time != use_time) {
        _use_time = use_time;
    }
    allScoreLabel.text = [NSString stringWithFormat:@"获得%@分 用时%@ ",_tempDic[@"correctGrade"],use_time];

}

@end
