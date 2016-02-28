//
//  ZMLoadingView.m
//  Tencent
//
//  Created by Leo on 15/6/5.
//  Copyright (c) 2015年 Leo. All rights reserved.
//

#import "ZMLoadingView.h"

@interface ZMLoadingView() {
    
    UIActivityIndicatorView* _activityView;
    UILabel* _messageLabel;
}

@end

@implementation ZMLoadingView

static ZMLoadingView* loadingView = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loadingView = [ZMLoadingView new];
    });
    return loadingView;
}

- (id)init {
    self = [super initWithFrame: CGRectMake(0, 0, 100, 100)];
    if (self) {
        
        self.layer.cornerRadius = 10.0f;
        self.backgroundColor = [UIColor colorWithWhite: 0.0 alpha: 0.6];
        
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
        _activityView.center = CGPointMake(50, 40);
        [self addSubview: _activityView];
        
        _messageLabel = [[UILabel alloc] initWithFrame: CGRectMake(3, 70, CGRectGetWidth(self.bounds) - 6, 20)];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.font = [UIFont systemFontOfSize: 14];
        [self addSubview: _messageLabel];
    }
    return self;
}

- (void)loadingViewShowTips:(NSString*)tips {
    [self loadingViewShowTips: tips andWithEnable: NO];
}

- (void)loadingViewShowTips:(NSString*)tips andWithEnable:(BOOL)enable {
    
    if (tips.length == 0) {
        return;
    }
    
    _messageLabel.text = tips;
    [_activityView startAnimating];
    UIWindow* keyWindow = [[UIApplication sharedApplication] keyWindow];
    self.center = CGPointMake(CGRectGetWidth(keyWindow.bounds)/2, CGRectGetHeight(keyWindow.bounds)/2);
    self.hidden = NO;
    [keyWindow addSubview: self];
    
    if (enable) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    }
}

- (void)stopLoading {
    
    self.hidden = YES;
    [self removeFromSuperview];
    
    if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
}

@end
