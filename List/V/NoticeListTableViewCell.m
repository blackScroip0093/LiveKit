//
//  NoticeListTableViewCell.m
//  TXLiteAVDemo
//
//  Created by 赵佟越 on 2020/10/27.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "NoticeListTableViewCell.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
 blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]

@implementation NoticeListTableViewCell

- (void)setFrame:(CGRect)frame
{
    //修改cell的左右边距为10;
    //修改cell的Y值下移10;
    //修改cell的高度减少10;
    static CGFloat margin = 15;
    frame.origin.x = margin;
    frame.size.width -= 2 * frame.origin.x;
    frame.origin.y += 5;
    frame.size.height -= 10;
    [super setFrame:frame];
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.lineView = [[UIImageView alloc]init];
        [self addSubview:self.lineView];
        
        self.myimageView = [[UIImageView alloc]init];
        [self addSubview:self.myimageView];
        
        self.myDetailabel = [[UILabel alloc]init];
        [self addSubview:self.myDetailabel];
        
        self.myTitleLabel = [[UILabel alloc]init];
        [self addSubview:self.myTitleLabel];
        
        self.myTimelabel = [[UILabel alloc]init];
        [self addSubview:self.myTimelabel];
        
    }
    return self;
}


- (void)layoutSubviews{
    [super layoutSubviews];
    self.layer.cornerRadius = 10;
    self.backgroundColor = UIColorFromRGB(0xF7F7F7);
    
    self.myimageView.image = [UIImage imageNamed:@"学员"];
    self.myimageView.frame = CGRectMake(14, 20, 30, 30);
    self.myimageView.layer.cornerRadius = 15;
    self.myimageView.clipsToBounds = YES;
    
    
    self.lineView.frame = CGRectMake(0, 70, self.frame.size.width, 1);
    self.lineView.backgroundColor = UIColorFromRGB(0xF0F0F0);
    
    self.myTitleLabel.frame = CGRectMake(14 + 30 + 10, 18.5, 200, 14);
    self.myTitleLabel.font = [UIFont systemFontOfSize:14];
//    self.myTitleLabel.text = @"莎莎助教";
    
    self.myTimelabel.frame = CGRectMake(14 + 30 + 10, 18.5 + 14 + 5, 200, 14);
    self.myTimelabel.font = [UIFont systemFontOfSize:14];
//    self.myTimelabel.text = @"2020-09-01 20:32";
    
    self.myDetailabel.frame = CGRectMake(14 , 70 + 14 , self.frame.size.width - 28, 14);
    self.myDetailabel.font = [UIFont systemFontOfSize:14];
    self.myDetailabel.numberOfLines = 0;
//    self.myDetailabel.text = @"1/ndlasjdoiskdlask;dljsakldjsal;kdjas;kldjas;ldjlasdjlkas;dsajd;askdjakl;sjdkl;asdj;kasjdl;aj";
    [self.myDetailabel sizeToFit];
}

//- (void)setMyModel:(PetCirleAndKnowMoreModel *)myModel{
//    if (_myModel != myModel) {
//        _myModel = myModel;
//    }
//    self.myTitleLabel.text = myModel.encyTitle;
//    self.myDetailabel.text = myModel.content;
//    self.seeCountLabel.text =[NSString stringWithFormat:@"%ld",(long)myModel.encyCount];
//    //
//    [self.myimageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGE_HOST,myModel.encyImg]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
//}
//
//+ (CGFloat)cellheight{
//    return 110;
//}
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

- (void)setModel:(gongGaoModel *)model{
        self.myDetailabel.text = model.noticeContent;
        self.myTitleLabel.text = model.noticeUserId;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:model.noticeCreateTime.doubleValue];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSString *formatDate = [formatter stringFromDate:date];
        self.myTimelabel.text = formatDate;
}

@end
