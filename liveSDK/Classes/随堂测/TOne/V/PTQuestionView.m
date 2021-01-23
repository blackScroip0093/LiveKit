//
//  PTQuestionView.m
//  ProblemTest
//
//  Created by Celia on 2017/10/24.
//  Copyright © 2017年 Hopex. All rights reserved.
//

#import "PTQuestionView.h"
#import "PTQuestionBottomView.h"
#import "PTQuestionCell.h"
#import "UIColor+HPCategory.h"

static NSString *const cellIDTestQuestion = @"testQuestionCellID";

@interface PTQuestionView () <UICollectionViewDataSource, UICollectionViewDelegate, PTQuestionCellDelegate>
@property (nonatomic, strong) PTQuestionBottomView *bottomView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) PTQuestionCell *temp;

@end

@implementation PTQuestionView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor hex:@"f5f5f5"];
        _dataArray = [NSArray array];
        [self createInterface];
        self.recordAnswer = [NSMutableArray array];
    }
    return self;
}

#pragma mark - 内部逻辑实现

#pragma mark - 代理协议
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PTQuestionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIDTestQuestion forIndexPath:indexPath];
    cell.bottomView = self.bottomView;
    cell.model = self.dataArray[indexPath.row];
    if (indexPath.row == 0) {
        cell.isFirst = true;
    }else {
        cell.isFirst = false;
    }
    cell.delegate = self;
    
    if (self.recordAnswer.count <= indexPath.item) {
        // 做新题
        
    }else {
        // 重做的题
        cell.haveSelectChoices = [self.recordAnswer safeObjectAtIndex:indexPath.item];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    PTTestTopicModel *model = self.dataArray[indexPath.row];
    for(UIView *view in [self.bottomView subviews])
    {
        if (view.tag == 100011) {
            [view removeFromSuperview];
        }
    }
    [self.bottomView setCountString:[NSString stringWithFormat:@"%ld/%ld",indexPath.row + 1, self.dataArray.count] setModel:model];
    ;
    
//    self.temp = cell;
    
    
    [self.bottomView addSubview:((PTQuestionCell *)cell).lastBtn];
    [self.bottomView addSubview:((PTQuestionCell *)cell).nextBtn];
    if (indexPath.row == nil || indexPath.row == 0) {
        [((PTQuestionCell *)cell).lastBtn setHidden:YES];
    }else{
        [((PTQuestionCell *)cell).lastBtn setHidden:NO];
    }
    
    [((PTQuestionCell *)cell).lastBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(((PTQuestionCell *)cell).nextBtn.mas_left);
        make.bottom.equalTo(self.bottomView).offset(-2);
        make.size.mas_equalTo(CGSizeMake(HP_SCALE_W(60), HP_SCALE_H(28)));
    }];
    [((PTQuestionCell *)cell).nextBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView);
        make.bottom.equalTo(self.bottomView).offset(-2);
        make.size.mas_equalTo(CGSizeMake(HP_SCALE_W(60), HP_SCALE_H(28)));
    }];
    
}


#pragma mark - 代理协议 - DJTestQuestionCellDelegate
/** 上一题 */
- (void)PTQuestionCellTapLastQuestion:(PTQuestionCell *)cell {
    
    NSIndexPath *currentP = [self.collectionView indexPathForCell:cell];
    NSIndexPath *lastP = [NSIndexPath indexPathForItem:currentP.item-1 inSection:currentP.section];
    [self.collectionView scrollToItemAtIndexPath:lastP atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    
}

/** 下一题 */
- (void)PTQuestionCellTapNextQuestion:(PTQuestionCell *)cell {
    
    NSIndexPath *currentP = [self.collectionView indexPathForCell:cell];
    
    // 作答到最后一题
    if (currentP.item+1 >= self.dataArray.count) {
        self.SubmitAnswerBlock();
        return;
    }
    
    NSIndexPath *nextP = [NSIndexPath indexPathForItem:currentP.item+1 inSection:currentP.section];
    [self.collectionView scrollToItemAtIndexPath:nextP atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

/** 更新选中的选项数据 */
- (void)PTQuestionCellUpdateSelectChoices:(NSArray *)choiceArray cell:(PTQuestionCell *)cell {
    NSArray *temArr = [PTTestTopicModel mj_objectArrayWithKeyValuesArray:self.tempArr];
    
    NSIndexPath *currentP = [self.collectionView indexPathForCell:cell];
    // 记录做题的答案
    if (self.recordAnswer.count <= currentP.item) {
        // 做新题
        [self.recordAnswer addObject:choiceArray];
    }else {
        // 重做的题
        [self.recordAnswer replaceObjectAtIndex:currentP.item withObject:choiceArray];
    }
}

#pragma mark - 数据请求 / 数据处理
- (void)setTimeCounting:(NSString *)timeCounting {
    
    _timeCounting = timeCounting;
    [self.bottomView setTimeString:timeCounting];
}

- (void)setDataArray:(NSArray *)dataArray {
    
    _dataArray = dataArray;
    [_collectionView reloadData];
}

#pragma mark - 视图布局
- (void)createInterface {
    
    [self addSubview:self.bottomView];
    [self addSubview:self.collectionView];
    
    HPWeakSelf(self)
    self.bottomView.PTQuestionBottomViewSubmitBlock = ^{
        DEBUGLog(@"点击 交卷");
        weakself.SubmitAnswerBlock();
    };
}

#pragma mark - 懒加载
- (PTQuestionBottomView *)bottomView {
    
    if (!_bottomView) {
        _bottomView = [[PTQuestionBottomView alloc] initWithFrame:CGRectMake(0, 0, self.width, 100)];
    }
    return _bottomView;
}

- (UICollectionView *)collectionView {
    
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.sectionInset = UIEdgeInsetsZero;
        layout.itemSize = CGSizeMake(self.width, self.height - 100);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 100, self.width, self.height - 100) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor hex:@"f5f5f5"];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.pagingEnabled = true;
        _collectionView.scrollEnabled = false;
        [_collectionView registerClass:[PTQuestionCell class] forCellWithReuseIdentifier:cellIDTestQuestion];
    }
    return _collectionView;
}

@end
