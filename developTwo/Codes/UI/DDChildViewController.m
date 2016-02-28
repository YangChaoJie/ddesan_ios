#import "DDChildViewController.h"

#import "DDHomeViewController.h"
#import "DDLoginViewController.h"
#import "DDRootViewController.h"
#import "DDUtilities.h"

@implementation DDChildViewController

- (void)goForward {
	// Do nothing.
}

- (void)goBack {
	[self popAnimated: TRUE];
}

- (void)push: (DDChildViewController*)viewController animated:(BOOL)animated {
	DDRootViewController* rootViewController = [DDRootViewController sharedInstance];
	assert([rootViewController topViewController] == self);
	
	[rootViewController pushViewController: viewController animated: animated];
}

- (void)switchTo: (DDChildViewController*)viewController animated: (BOOL)animated {
	DDRootViewController* rootViewController = [DDRootViewController sharedInstance];
	assert([rootViewController topViewController] == self);
	
	NSMutableArray* viewControllers = [[NSMutableArray alloc] initWithArray: [rootViewController viewControllers]];
	[viewControllers removeLastObject];
	[viewControllers addObject: viewController];
	[rootViewController setViewControllers: viewControllers animated: animated];
}

- (void)popAnimated: (BOOL)animated {
	DDRootViewController* rootViewController = [DDRootViewController sharedInstance];
	assert([rootViewController topViewController] == self);
	
	[rootViewController popViewControllerAnimated: animated];
}

- (void)popToRootAnimated: (BOOL)animated {
	DDRootViewController* rootViewController = [DDRootViewController sharedInstance];
	assert([rootViewController topViewController] == self);
	
	[rootViewController popToRootViewControllerAnimated: animated];
}

- (DDChildViewController*)previousViewController {
	DDRootViewController* rootViewController = [DDRootViewController sharedInstance];
	NSArray* childViewControllers = [rootViewController childViewControllers];
	
	NSInteger index = [childViewControllers indexOfObject: self];
	if(index != NSNotFound && index != 0) {
		DDChildViewController* previousViewController = [childViewControllers objectAtIndex: index - 1];
		
		return previousViewController;
	}
	else {
		return nil;
	}
}

- (void)loginTimedOut {
	DDRootViewController* rootViewController = [DDRootViewController sharedInstance];
	if([rootViewController topViewController] == self) {
		alert(@"登录超时，请重新登录。");
		
		DDHomeViewController* homeViewController = [[DDHomeViewController alloc] init];
		DDLoginViewController* loginViewController = [[DDLoginViewController alloc] init];
		[rootViewController setViewControllers: @[ homeViewController, loginViewController ] animated: FALSE];
	}
}

- (void)handleSwipe: (UISwipeGestureRecognizer*)swiper {
	UIView* target = [swiper view];
	UISwipeGestureRecognizerDirection direction = [swiper direction];
	
	if(target == [super view]) {
		if(direction == UISwipeGestureRecognizerDirectionLeft) {
			[self goForward];
			
			return;
		}
		
		if(direction == UISwipeGestureRecognizerDirectionRight) {
			[self goBack];
			
			return;
		}
		
		return;
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	UISwipeGestureRecognizer* leftSwiper = [[UISwipeGestureRecognizer alloc] initWithTarget: self action: @selector(handleSwipe:)];
	[leftSwiper setDirection: UISwipeGestureRecognizerDirectionLeft];
	[[super view] addGestureRecognizer: leftSwiper];
	
	UISwipeGestureRecognizer* rightSwiper = [[UISwipeGestureRecognizer alloc] initWithTarget: self action: @selector(handleSwipe:)];
	[rightSwiper setDirection: UISwipeGestureRecognizerDirectionRight];
	[[super view] addGestureRecognizer: rightSwiper];
}

- (void)viewWillDisappear: (BOOL)animated {
	[super viewWillDisappear: animated];
	
	[[super view] endEditing: TRUE];
}

- (void)touchesBegan: (NSSet*)touches withEvent: (UIEvent*)event {
	[super touchesBegan: touches withEvent: event];
	
	[[super view] endEditing: FALSE];
}

@end
