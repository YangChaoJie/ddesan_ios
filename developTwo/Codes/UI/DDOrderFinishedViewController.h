#import "DDChildViewController.h"

@class DDOrderRecord;

@interface DDOrderFinishedViewController : DDChildViewController

- (instancetype)init __unavailable;
- (instancetype)initWithOrderRecord: (DDOrderRecord*)orderRecord Dictray:(NSDictionary*)dict;
@property(nonatomic,copy)NSDictionary*dict;
@end
