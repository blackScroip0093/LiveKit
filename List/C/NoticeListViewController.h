//
//  NoticeListViewController.h
//  TXReplaykitUpload_TRTC
//
//  Created by 赵佟越 on 2020/10/27.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXCategoryListContainerView.h"

@interface NoticeListViewController : UIViewController <JXCategoryListContentViewDelegate>
@property(nonatomic, assign)NSInteger roomId;
@end

