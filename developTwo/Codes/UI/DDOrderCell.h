#import <UIKit/UIKit.h>

@class DDOrderRecord;

@interface DDOrderCell : UITableViewCell
//add
- (void)setOrderRecord: (DDOrderRecord*)orderRecord Dictary:(NSDictionary*)dict;
@property(nonatomic, strong) DDOrderRecord* orderRecord;
//add
@property(nonatomic,strong) NSDictionary*dict;
@end
