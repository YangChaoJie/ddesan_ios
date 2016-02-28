#import "DDChildViewController.h"
#import <CoreLocation/CoreLocation.h>
@class DDCampaigningStation;
@class DDOrderRecord;

@interface DDOrderViewController : DDChildViewController

- (instancetype)init __unavailable;
- (instancetype)initWithCampaigningStation: (DDCampaigningStation*)campaigningStation Dictary:(NSDictionary*)dic;
- (instancetype)initWithCampaigningStation: (DDCampaigningStation*)campaigningStation;
- (instancetype)initWithCampaigningStation: (DDCampaigningStation*)campaigningStation andOrderCode: (NSString*)orderCode Dictary:(NSDictionary*)dic;
- (instancetype)initWithOrderRecord: (DDOrderRecord*)orderRecord Dictary:(NSDictionary*)dic;

@property(nonatomic, copy) NSNumber* discountedPrice;
@property(nonatomic,strong)NSDictionary* dic;


@property(nonatomic, copy) CLLocation* location;
@end
