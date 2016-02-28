#import "DDCampaign.h"

// 热度活动。
@interface DDHotCampaign : DDCampaign

@property(nonatomic, copy) NSNumber* totalQuota;
@property(nonatomic, copy) NSNumber* remainingQuota;

@end

#pragma mark -

DDHotCampaign* DDHotCampaignFromJsonObject(NSDictionary* jsonObject);
