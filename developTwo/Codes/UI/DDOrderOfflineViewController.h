#import "DDChildViewController.h"

@class DDOrderRecord;

@interface DDOrderOfflineViewController : DDChildViewController


@property(nonatomic,copy)NSDictionary*dict;
- (instancetype)init __unavailable;
//- (instancetype)initWithOrderRecord: (DDOrderRecord*)orderRecord;
- (instancetype)initWithOrderRecord: (DDOrderRecord*)orderRecord Dictary:(NSDictionary*)dict;
- (void)setModifyButtonEnabled: (BOOL)enabled;

@end
