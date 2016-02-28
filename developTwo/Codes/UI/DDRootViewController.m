#import "DDRootViewController.h"

@implementation DDRootViewController

+ (instancetype)sharedInstance {
	static DDRootViewController* instance = nil;
	
	if(instance == nil) {
		@synchronized([DDRootViewController class]) {
			if(instance == nil) {
				instance = [[super alloc] init];
			}
		}
	}
	
	return instance;
}

- (instancetype)init {
	self = [super init];
	if(self != nil) {
		[super setNavigationBarHidden: TRUE];
	}
	
	return self;
}

@end
