//
//  ExercisesTableViewCell.m
//  TXLiteAVDemo
//
//  Created by 赵佟越 on 2020/10/27.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "ExercisesTableViewCell.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]

@implementation ExercisesTableViewCell

//- (void)setFrame:(CGRect)frame
//{
//    //修改cell的左右边距为10;
//    //修改cell的Y值下移10;
//    //修改cell的高度减少10;
//    static CGFloat margin = 15;
//    frame.origin.x = margin;
//    frame.size.width -= 2 * frame.origin.x;
//    frame.origin.y += 5;
//    frame.size.height -= 10;
//    [super setFrame:frame];
//    
//}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backColorView = [[UIImageView alloc]init];
        self.backColorView.backgroundColor = [UIColor hex:@"F7FAFF"];
        [self addSubview:self.backColorView];
        
        self.myDetailabel = [[UILabel alloc]init];
        [self addSubview:self.myDetailabel];
        
        self.myTitleLabel = [[UILabel alloc]init];
        self.myTitleLabel.font  = [UIFont systemFontOfSize:17];
        [self addSubview:self.myTitleLabel];
        
        self.titleTiplabel = [[UILabel alloc]init];
        self.titleTiplabel.font  = [UIFont systemFontOfSize:14];
        self.titleTiplabel.textColor = [UIColor hex:@"333333"];
        [self.backColorView addSubview:self.titleTiplabel];
        
        self.doneTipLabel = [[UILabel alloc]init];
        self.doneTipLabel.font  = [UIFont systemFontOfSize:14];
        self.doneTipLabel.textColor = [UIColor hex:@"408FF7"];
        self.doneTipLabel.textAlignment = NSTextAlignmentRight;
        self.doneTipLabel.text = @"开始做题 >>";
        [self.backColorView addSubview:self.doneTipLabel];
        
        
    }
    return self;
}


- (void)layoutSubviews{
    [super layoutSubviews];
    self.layer.cornerRadius = 10;
    
    
    
    self.myTitleLabel.frame = CGRectMake(35, 10, 200, 14);
    self.myTitleLabel.font = [UIFont systemFontOfSize:14];
    self.myTitleLabel.text = @"10月11日 周日";
    
    self.backColorView.frame = CGRectMake(35, self.myTitleLabel.bottom + 15, self.frame.size.width, 52);
    self.backColorView.backgroundColor = UIColorFromRGB(0xF0F0F0);
    
    
    self.titleTiplabel.font = [UIFont systemFontOfSize:14];
    //    self.titleTiplabel.text = @"2020-09-01 20:32";
    [self.titleTiplabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_backColorView).offset(14);
        make.size.mas_equalTo(CGSizeMake(HPScreenWidth, 17));
        make.top.equalTo(_backColorView).offset(5);
    }];
    
    self.myDetailabel.font = [UIFont systemFontOfSize:14];
    self.myDetailabel.numberOfLines = 0;
    
    [self.myDetailabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_backColorView).offset(14);
        make.size.mas_equalTo(CGSizeMake(HPScreenWidth, 17));
        make.bottom.equalTo(_backColorView).offset(-5);
    }];
    
    [self.doneTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-14);
        make.size.mas_equalTo(CGSizeMake(200, 17));
        make.centerY.equalTo(self.backColorView);
    }];
    
}

- (void)makeui{
    
    
}

+ (CGFloat)cellheight{
    return 110;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setModel:(PTTestTopicModel *)model{
    if (_model != model) {
        _model = model;
        
        self.myDetailabel.text = model.tlQuestionsContent;
        
        self.myDetailabel.text = [NSString stringWithFormat:@"%@ %ld道题",model.tlQuestionsContent,model.topicList.count];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:model.createTime.doubleValue];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSString *formatDate = [formatter stringFromDate:date];
        self.titleTiplabel.text = formatDate;
        if ([model.tlQuestionType intValue]== 2){
            self.myDetailabel.text = [NSString stringWithFormat:@"第三方问卷"];
        }
    }
    
}

@end
