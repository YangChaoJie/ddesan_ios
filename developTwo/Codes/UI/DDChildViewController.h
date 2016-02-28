#import <UIKit/UIKit.h>

@interface DDChildViewController : UIViewController

- (instancetype)initWithCoder: (NSCoder*)decoder __unavailable;
- (instancetype)initWithNibName: (NSString*)nibName bundle: (NSBundle*)bundle __unavailable;

// 前进，由左划手势触发，默认为没有操作，可由子类覆盖改写。
- (void)goForward;
// 后退，由右划手势触发，默认为弹出当前页，可由子类覆盖改写。
- (void)goBack;

- (void)push: (DDChildViewController*)viewController animated: (BOOL)animated;
- (void)switchTo: (DDChildViewController*)viewController animated: (BOOL)animated;
- (void)popAnimated: (BOOL)animated;
- (void)popToRootAnimated: (BOOL)animated;

- (DDChildViewController*)previousViewController;

// 登录超时处理（提示超时，跳回首页并打开登录页面）。
- (void)loginTimedOut;

@end
