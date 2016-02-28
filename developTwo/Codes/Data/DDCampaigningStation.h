#import <Foundation/Foundation.h>

@class DDCampaign;
@class DDStation;

// 活动站点。
@interface DDCampaigningStation : NSObject

@property(nonatomic, strong) DDCampaign* campaign;
@property(nonatomic, strong) DDStation* station;

@end

#pragma mark -

DDCampaigningStation* DDCampaigningStationFromJsonObject(NSDictionary* jsonObject);
