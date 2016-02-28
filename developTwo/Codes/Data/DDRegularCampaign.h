#import "DDCampaign.h"

// 常规活动。
@interface DDRegularCampaign : DDCampaign

@end

#pragma mark -

DDRegularCampaign* DDRegularCampaignFromJsonObject(NSDictionary* jsonObject);
