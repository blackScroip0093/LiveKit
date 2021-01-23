//
//  PTTestChoiceButtonView.m
//  ProblemTest
//
//  Created by Celia on 2017/10/24.
//  Copyright © 2017年 Hopex. All rights reserved.
//

#import "PTQuestionChoiceView.h"
#import "PTQuestionChoiceButtonView.h"
#import <liveSDK/liveSDK-Swift.h>
#import "UIColor+HPCategory.h"

@interface PTQuestionChoiceView () <ChoiceButtonViewDelegate,UITextViewDelegate>
@property (nonatomic, assign) NSInteger itemIndex;
/** 选项数据 */
@property (nonatomic, strong) NSArray *choiceData;
@end

@implementation PTQuestionChoiceView

#pragma mark - 代理协议
- (void)touchChoiceButton:(PTQuestionChoiceButtonView *)btnView {
    
    // 多选
    if (self.type == 1) {
       
        NSMutableArray *selectChoiceArr = [NSMutableArray array];
        NSMutableArray *tempArr = [NSMutableArray array];
        for (int i = 0; i < self.choiceData.count; i++) {
            PTQuestionChoiceButtonView *tempBtnV = [self viewWithTag:1000*self.itemIndex + i];
            if (tempBtnV.status == ChoiceButtonStatusSelected) {
               NSString *choiceS = [NSString stringWithFormat:@"%C",(unichar)(tempBtnV.tag - 1000*self.itemIndex + 65)];
                
                NSArray *dataArr = [PTTestTopicModel mj_objectArrayWithKeyValuesArray:self.model.option_xuan];
                
                for (PTTestTopicModel *tempModel in dataArr) {
                    if ([tempModel.answerSelect isEqualToString:choiceS]) {
                        [tempArr addObject:tempModel.answerId];
                    }
                }
            }
            NSString *tempString = @"";
            for (NSString *tempStr in tempArr) {
                if ([tempString isEqualToString: @""]) {
                    tempString = [NSString stringWithFormat:@"%@%@",tempString ,tempStr];
                }else{
                    tempString = [NSString stringWithFormat:@"%@,%@",tempString ,tempStr];
                }   
            }
            NSDictionary *tempDic = @{
                @"resultTopicid":self.model.topic_id,
                @"resultAnswerId":tempString,
                @"resultStudentid":ProfileManager.shared.loginUserModel.userId,
                @"resultRoomNumber":ProfileManager.shared.roomID
            };
            selectChoiceArr = @[tempDic].mutableCopy;
        }
        if ([self.delegate respondsToSelector:@selector(updateTheSelectChoice:)]) {
            [self.delegate updateTheSelectChoice:selectChoiceArr];
        }
        return;
    }
    
    // 单选： 点中一个选项，将其他选项取消选中
    if (btnView.status == ChoiceButtonStatusSelected) {
        NSMutableArray *selectChoiceArr = [NSMutableArray array];
        NSString *tempStr;
        for (int i = 0; i<self.choiceData.count; i++) {
            
            PTQuestionChoiceButtonView *tempBtnV = [self viewWithTag:1000*self.itemIndex + i];
            if (tempBtnV != btnView) {
                tempBtnV.status = ChoiceButtonStatusNormal;
            }
        }
        NSString *choiceS = [NSString stringWithFormat:@"%C",(unichar)(btnView.tag - 1000*self.itemIndex + 65)];
        
        NSArray *dataArr = [PTTestTopicModel mj_objectArrayWithKeyValuesArray:self.model.option_xuan];
        
        for (PTTestTopicModel *tempModel in dataArr) {
            if ([tempModel.answerSelect isEqualToString:choiceS]) {
                tempStr = tempModel.answerId;
//                [tempArr addObject:tempModel.answerId];
            }
        }
        NSDictionary *tempDic = @{
            @"resultTopicid":self.model.topic_id,
            @"resultAnswerId":tempStr,
            @"resultStudentid":ProfileManager.shared.loginUserModel.userId,
            @"resultRoomNumber":ProfileManager.shared.roomID
        };
        selectChoiceArr = @[tempDic].mutableCopy;
        
        if ([self.delegate respondsToSelector:@selector(updateTheSelectChoice:)]) {
            [self.delegate updateTheSelectChoice:selectChoiceArr];
        }
        
    }else {
        if ([self.delegate respondsToSelector:@selector(updateTheSelectChoice:)]) {
            [self.delegate updateTheSelectChoice:@[]];
        }
    }
    
}
//文字
- (void)textViewDidChange:(UITextView *)textView { // 在该代理方法中实现实时监听uitextview的输入
    NSDictionary *tempDic = @{
            @"resultTopicid":self.model.topic_id,
            @"resultAnswerId":textView.text,
            @"resultStudentid":ProfileManager.shared.loginUserModel.userId,
            @"resultRoomNumber":ProfileManager.shared.roomID
        };
    
    if ([self.delegate respondsToSelector:@selector(updateTheSelectChoice:)]) {
        [self.delegate updateTheSelectChoice: @[tempDic]];
    }
}
#pragma mark - 数据处理
- (void)setChoiceData:(NSArray *)array index:(NSInteger)index {
    
    if (array.count == 0) {
        UITextView *tempField = [[UITextView alloc]init];
        [self addSubview:tempField];
        
        [tempField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(14);
            make.right.equalTo(self).offset(-14);
            make.top.mas_equalTo(15);
            make.bottom.equalTo(self).offset(-50);
        }];
        tempField.backgroundColor = [UIColor hex:@"e6e6e6"];
        tempField.layer.cornerRadius = 5;
        tempField.delegate = self;
        
    }
    
    
    self.itemIndex = index;
    DEBUGLog(@"index -- %ld",index);
    self.choiceData = array;
    // 创建答案选项
    for (int i = 0; i<array.count; i++) {
        
        PTQuestionChoiceButtonView *btnView = [self viewWithTag:1000*index + i];
        if (!btnView) {
            PTQuestionChoiceButtonView *btnView = [[PTQuestionChoiceButtonView alloc] initWithFrame:CGRectMake(0, HP_SCALE_H(60)*i, HPScreenWidth, HP_SCALE_H(60))];
            NSArray *dataArr = [PTTestTopicModel mj_objectArrayWithKeyValuesArray:self.model.option_xuan];
            btnView.ChoiceType = [dataArr[i] answerSelect];
            
            btnView.tag = 1000*index + i;
            btnView.delegate = self;
            DEBUGLog(@"ceate -- %ld",index);
            // 选项如果 前两个包含A: B: 要移除
            NSString *choiceString = array[i];
            if ([choiceString containsString:@":"]) {
                choiceString = [choiceString substringFromIndex:2];
            }else if ([choiceString containsString:@"："]) {
                choiceString = [choiceString substringFromIndex:2];
            }
            
            btnView.choiceDesc = choiceString;
            [self addSubview:btnView];
        }else {
            NSArray *dataArr = [PTTestTopicModel mj_objectArrayWithKeyValuesArray:self.model.option_xuan];
            btnView.ChoiceType = [dataArr[i] answerSelect];
            
            // 选项如果 前两个包含A: B: 要移除
            NSString *choiceString = array[i];
            if ([choiceString containsString:@":"]) {
                choiceString = [choiceString substringFromIndex:2];
            }else if ([choiceString containsString:@"："]) {
                choiceString = [choiceString substringFromIndex:2];
            }
            
            btnView.choiceDesc = choiceString;
        }
    }
}

- (void)setHaveSelectChoice:(NSArray *)haveSelectChoice {
    NSArray *dataArr = [PTTestTopicModel mj_objectArrayWithKeyValuesArray:self.model.option_xuan];
    for (int i = 0; i<dataArr.count; i++) {
        
        
        NSArray *array = [haveSelectChoice[0][@"resultAnswerId"] componentsSeparatedByString:@","];
        if ([array containsObject:[dataArr[i] answerId]]) {
            PTQuestionChoiceButtonView *btnView = [self viewWithTag:1000*self.itemIndex + i];
            DEBUGLog(@"select item ==== %ld",self.itemIndex);
            DEBUGLog(@"select btn ==== %@",btnView);
            if (btnView) {
                btnView.status = ChoiceButtonStatusSelected;
            }
        }
//        if ([[dataArr[i] answerId]isEqualToString:haveSelectChoice[0][@"resultAnswerId"]]) {
//            PTQuestionChoiceButtonView *btnView = [self viewWithTag:1000*self.itemIndex + i];
//            DEBUGLog(@"select item ==== %ld",self.itemIndex);
//            DEBUGLog(@"select btn ==== %@",btnView);
//            if (btnView) {
//                btnView.status = ChoiceButtonStatusSelected;
//            }
//            
//        }
    }
    
//    1000*self.itemIndex + i
//    for (NSString *Charac in haveSelectChoice) {
//        if (Charac.length > 0 && [Charac characterAtIndex:0] >=65) {
//            NSInteger charInte = [Charac characterAtIndex:0];
//            PTQuestionChoiceButtonView *btnView = [self viewWithTag:1000*self.itemIndex + (charInte - 65)];
//            DEBUGLog(@"select item ==== %ld",self.itemIndex);
//            DEBUGLog(@"select btn ==== %@",btnView);
//            if (btnView) {
//                btnView.status = ChoiceButtonStatusSelected;
//            }
//        }
//
//    }
    
}

- (void)setCorrectChoice:(NSArray *)correctChoice {
    
    for (NSString *Charac in correctChoice) {
        if (Charac.length > 0 && [Charac characterAtIndex:0] >=65) {
            NSInteger charInte = [Charac characterAtIndex:0];
            PTQuestionChoiceButtonView *btnView = [self viewWithTag:1000*self.itemIndex + (charInte - 65)];
            if (btnView) {
                DEBUGLog(@"correct item -- %ld",self.itemIndex);
                DEBUGLog(@"correct btn -- %@",btnView);
                btnView.status = ChoiceButtonStatusCorrect;
            }
        }
    }
}


@end
