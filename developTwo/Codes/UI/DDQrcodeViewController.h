#import "DDChildViewController.h"

@interface DDQrcodeViewController : DDChildViewController

- (instancetype)init __unavailable;
- (instancetype)initWithTitle: (NSString*)title andQrcodeFile: (NSString*)qrcodeFile;

@end
