#import "DDChildViewController.h"

@interface DDDiscountedPriceViewController : DDChildViewController

- (instancetype)init __unavailable;
- (instancetype)initWithFloor: (NSInteger)floor andCeiling: (NSInteger)ceiling;

@end
