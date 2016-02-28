#import "DDCampaigningStation.h"

#import "DDCampaign.h"
#import "DDStation.h"
#import "NSObject+JsonParsing.h"

@implementation DDCampaigningStation

@end

#pragma mark -

DDCampaigningStation* DDCampaigningStationFromJsonObject(NSDictionary* jsonObject) {
	if(jsonObject == nil) {
		return nil;
	}
	
	DDCampaigningStation* campaigningStation = [[DDCampaigningStation alloc] init];
	
	DDCampaign* campaign = DDCampaignFromJsonObject([jsonObject[@"Campaign"] asDictionary]);
	[campaigningStation setCampaign: campaign];
	
	DDStation* station = DDStationFromJsonObject([jsonObject[@"Shop"] asDictionary]);
	[campaigningStation setStation: station];
	
	return campaigningStation;
}
