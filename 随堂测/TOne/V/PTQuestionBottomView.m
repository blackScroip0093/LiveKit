//
//  PTQuestionBottomView.m
//  ProblemTest
//
//  Created by Celia on 2017/10/24.
//  Copyright © 2017年 Hopex. All rights reserved.
//

#import "PTQuestionBottomView.h"
#import "PTTestTopicModel.h"

@interface PTQuestionBottomView ()
@property (nonatomic, strong) UIView *lineView;         // 灰线条
@property (nonatomic, strong) UIButton *submitBtn;      // 交卷
@property (nonatomic, strong) UIButton *timeBtn;        // 计时
@property (nonatomic, strong) UIButton *countBtn;       // 计题
@property (nonatomic, assign) NSInteger suitFont;       //
@property (nonatomic, strong) UIButton *rightCloseBtn;
@property (nonatomic, assign) UIButton *leftCloseBtn;
@property (nonatomic, assign) BOOL isFromPop;

@property (nonatomic, strong) PTTestTopicModel *model;
@end

@implementation PTQuestionBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self createInterface];
    }
    return self;
}


#pragma mark - 内部逻辑实现
- (void)submitBtnAction:(UIButton *)btn {
    
    if (self.PTQuestionBottomViewSubmitBlock) {
        self.PTQuestionBottomViewSubmitBlock();
    }
}

#pragma mark - 代理协议
#pragma mark - 数据处理
- (void)setTimeString:(NSString *)timeString {
    
    [self.timeBtn setTitle:timeString forState:UIControlStateNormal];
}

- (void)setCountString:(NSString *)countString setModel:(PTTestTopicModel*)model{
    self.model = model;
    NSString *typeString = @"单选";
    if ([model.type integerValue] == 0) {
        typeString = @"单选";
    }else if ([model.type integerValue] == 1) {
        typeString = @"多选";
    }else{
        typeString = @"简答";
    }
    NSString * tempStr  = [NSString stringWithFormat:@"%@ %@",countString,typeString];
    [self.countBtn setTitle:tempStr forState:UIControlStateNormal];
    NSString *str = [[tempStr componentsSeparatedByString:@"/"] firstObject];
    NSString *changeStr = [NSString stringWithFormat:@"%@",str];
    [_countBtn.titleLabel changeTextColor:UIColor.orangeColor toText:changeStr];
    [_countBtn.titleLabel changeTextFontSize:20 toText:changeStr];
}


#pragma mark - 视图布局
- (void)createInterface {
    
    CGFloat btnW = self.width / 3;
    CGFloat btnH = self.height;
    
    self.suitFont = 14;
    if (IS_IPHONE_4 || IS_IPHONE_5) {
        self.suitFont = 14;
    }
    
    [self addSubview:self.lineView];
    [self addSubview:self.submitBtn];
    [self addSubview:self.timeBtn];
    [self addSubview:self.countBtn];
    [self addSubview:self.leftCloseBtn];
    [self addSubview:self.rightCloseBtn];
    
    self.lineView.frame = CGRectMake(0, 99, self.width, 0.8);
//    self.submitBtn.frame = CGRectMake(0, 0, btnW, btnH);
    self.timeBtn.frame = CGRectMake(self.width - btnW - 14, 10, btnW, 40);
    self.countBtn.frame = CGRectMake(0, 59, btnW, 40);
    
    [self.submitBtn addTarget:self action:@selector(submitBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.timeBtn.userInteractionEnabled = false;
    self.countBtn.userInteractionEnabled = false;
    
    
    [self.rightCloseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.top.mas_equalTo(10);
    }];
}

- (void)closeAction{
     [[[UIApplication sharedApplication].keyWindow viewWithTag:1000001] removeFromSuperview];
}


#pragma mark - 懒加载
- (UIButton *)submitBtn {
    
    if (!_submitBtn) {
        _submitBtn = [UIButton initButtonTitleFont:_suitFont titleColor:[UIColor hex:@"121212"] backgroundColor:nil imageName:@"study_test_a" titleName:@"交卷"];
        [_submitBtn layoutButtonWithEdgeInsetsStyle:HPButtonEdgeInsetsStyleLeft imageTitleSpace:6];
    }
    return _submitBtn;
}

- (UIButton *)timeBtn {
    
    if (!_timeBtn) {
        _timeBtn = [UIButton initButtonTitleFont:_suitFont titleColor:UIColor.redColor backgroundColor:nil imageName:@"" titleName:@"00:00"];
        _timeBtn.titleLabel.font = [UIFont systemFontOfSize:_suitFont];
        _timeBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        _timeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//        [_timeBtn layoutButtonWithEdgeInsetsStyle:HPButtonEdgeInsetsStyleLeft imageTitleSpace:6];
    }
    return _timeBtn;
}

- (UIButton *)countBtn {
    
    if (!_countBtn) {
        _countBtn = [UIButton initButtonTitleFont:_suitFont titleColor:[UIColor hex:@"262626"] titleName:@"0/0"];
        _countBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _countBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 14, 0, 0);
        [_countBtn.titleLabel changeTextColor:[UIColor hex:@"858585"] toText:@"/0"];
    }
    return _countBtn;
}

- (UIView *)lineView {
    
    if (!_lineView) {
        _lineView = [UIView initViewBackColor:[UIColor hex:@"e3e3e3"]];
    }
    return _lineView;
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

@end
