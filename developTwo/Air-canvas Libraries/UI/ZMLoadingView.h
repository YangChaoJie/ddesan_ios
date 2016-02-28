//
//  ZMLoadingView.h
//  Tencent
//
//  Created by Leo on 15/6/5.
//  Copyright (c) 2015年 Leo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZMLoadingView : UIView

+ (instancetype)sharedInstance;

- (void)loadingViewShowTips:(NSString*)tips;

- (void)loadingViewShowTips:(NSString*)tips andWithEnable:(BOOL)enable;

- (void)stopLoading;

@end
