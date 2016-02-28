#import "DDCampaign.h"

#import "DDHotCampaign.h"
#import "DDRegularCampaign.h"

@implementation DDCampaign

+ (instancetype)alloc {
	assert([self class] != [DDCampaign class]);
	
	return [super alloc];
}

@end

#pragma mark -

DDCampaign* DDCampaignFromJsonObject(NSDictionary* jsonObject) {
	NSString* type = jsonObject[@"campaign_type"];
	
	if([type isEqualToString: @"1"]) {
		return DDHotCampaignFromJsonObject(jsonObject);
	}
	
	if([type isEqualToString: @"2"]) {
		return DDRegularCampaignFromJsonObject(jsonObject);
	}
	
	return nil;
}
