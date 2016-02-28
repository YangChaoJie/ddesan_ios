#import "DDChildViewController.h"

@class DDCampaigningStation;

@interface DDHotCampaignViewController : DDChildViewController

- (instancetype)init __unavailable;
- (instancetype)initWithCampaigningStation: (DDCampaigningStation*)campaigningStation;
- (instancetype)initWithCampaigningStation: (DDCampaigningStation*)campaigningStation andOrderCode: (NSString*)orderCode Dictary:(NSDictionary*)dic;
- (instancetype)initWithCampaigningStation: (DDCampaigningStation*)campaigningStation Dictary:(NSDictionary*)dic;
//add by YCj
@property(nonatomic,strong)NSDictionary*dict;
@end
