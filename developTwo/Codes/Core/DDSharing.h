#import <UIKit/UIKit.h>

@interface DDSharing : NSObject

+ (instancetype)alloc __unavailable;
+ (instancetype)sharedInstance;

- (void)share;

@end
