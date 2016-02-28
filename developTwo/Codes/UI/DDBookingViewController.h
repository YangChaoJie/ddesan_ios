#import "DDChildViewController.h"

@class DDCampaigningStation;

@interface DDBookingViewController : DDChildViewController

- (instancetype)init __unavailable;
- (instancetype)initWithCampaigningStation: (DDCampaigningStation*)campaigningStation Dictary:(NSDictionary*)dict;
@property(nonatomic,strong)NSDictionary* dict;
@end
