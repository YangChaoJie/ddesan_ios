#import "DDChildViewController.h"

@class DDOrderRecord;

@interface DDOrderConfirmationViewController : DDChildViewController

- (instancetype)init __unavailable;
//- (instancetype)initWithOrderDictary:(NSDictionary*)dict;
- (instancetype)initWithOrderRecord: (DDOrderRecord*)orderRecord Dictary:(NSDictionary *)dict;
@property(nonatomic,copy)NSDictionary*dict;
@end
