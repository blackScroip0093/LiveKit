//
//  PTTestTopicModel.h
//  ProblemTest
//
//  Created by Celia on 2017/10/24.
//  Copyright © 2017年 Hopex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTTestTopicModel : NSObject
@property (nonatomic, strong) NSString *tlRoomNumber;
@property (nonatomic, strong) NSString *tlQuestionsScbs;
@property (nonatomic, strong) NSString *createTime;

@property (nonatomic, strong) NSString *test_id;
@property (nonatomic, strong) NSString *number;
@property (nonatomic, strong) NSString *title;  //题目
@property (nonatomic, strong) NSString *type;   // 0单选
@property (nonatomic, strong) NSArray *option_xuan; //选项
@property (nonatomic, strong) NSString *answer; //正确答案
@property (nonatomic, strong) NSString *score;
@property (nonatomic, strong) NSString *topic_id;
@property (nonatomic, strong) NSString *answerId;
@property (nonatomic, strong) NSString *answerSelect; // 选项 A B C D


//List
@property (nonatomic, strong) NSString *tlQuestionsId;
@property (nonatomic, strong) NSString *tlQuestionsContent;
@property (nonatomic, strong) NSString *tlQuestionType;
@property (nonatomic, strong) NSArray *topicList;
@property (nonatomic, strong) NSString *questionsUrl;

@end
