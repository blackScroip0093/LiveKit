//
//  PTQuestionViewController.h
//  ProblemTest
//
//  Created by Celia on 2017/10/24.
//  Copyright © 2017年 Hopex. All rights reserved.
//

#import "PTBaseViewController.h"
#import "NowTestViewController.h"
#import "ExercisesTableViewController.h"
@interface PTQuestionViewController : PTBaseViewController

@property (nonatomic, strong) NSString *length_time;
@property (nonatomic, strong) NSString *total_topic;
@property (nonatomic, strong) NSArray *tempArr;
@property (nonatomic, strong) NowTestViewController *tempVC;
@property (nonatomic, strong) ExercisesTableViewController *exTempVC;


@end
