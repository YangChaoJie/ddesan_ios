#import <UIKit/UIKit.h>

@class DDCampaigningStation;

@interface DDCampaigningStationCell : UITableViewCell
    

@property(nonatomic, strong) DDCampaigningStation* campaigningStation;
- (void)setCampaigningStation: (DDCampaigningStation*)campaigningStation Dictionary:(NSDictionary*)dict;
@end
