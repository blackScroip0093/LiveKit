//
//  PTTestTopicModel.m
//  ProblemTest
//
//  Created by Celia on 2017/10/24.
//  Copyright © 2017年 Hopex. All rights reserved.
//

#import "PTTestTopicModel.h"

@implementation PTTestTopicModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"test_id":@"tlQuestionsId",
             @"title":@"topicContent",
             @"type":@"topicType",
             @"option_xuan":@"aelist",
             
             @"answer":@"rightConstants",
             
             @"number":@"tlQuestionsId",
             @"topic_id":@"topicId"
    };
}

//"":"c472e0bd-59db-4b00-b687-6d94ec625a33",
//           "":"标题",
//           "":0,
//           "":"485226",
//           "":0,
//           "":1604576789,
//           "":Array[2]

//@property (nonatomic, strong) NSString *test_id;
//@property (nonatomic, strong) NSString *number;
//@property (nonatomic, strong) NSString *title;  //题目
//@property (nonatomic, strong) NSString *type;   // 0单选
//@property (nonatomic, strong) NSArray *option_xuan; //选项
//@property (nonatomic, strong) NSString *answer; //正确答案
//@property (nonatomic, strong) NSString *score;
//@property (nonatomic, strong) NSString *topic_id;

@end
