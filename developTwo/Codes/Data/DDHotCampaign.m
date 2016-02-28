#import "DDHotCampaign.h"

#import "NSObject+JsonParsing.h"

@implementation DDHotCampaign

@end

#pragma mark -

DDHotCampaign* DDHotCampaignFromJsonObject(NSDictionary* jsonObject) {
	if(jsonObject == nil) {
		return nil;
	}
	
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat: @"yyyy-MM-dd"];
	
	NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
	[timeFormatter setDateFormat: @"HH:mm:ss"];
	
	DDHotCampaign* campaign = [[DDHotCampaign alloc] init];
	
	NSString* id = [jsonObject[@"campaign_id"] asString];
	[campaign setId: id];
	
	NSDate* sinceDate = [dateFormatter dateFromString: [jsonObject[@"date_from"] asString]];
	[campaign setSinceDate: sinceDate];
	
	NSDate* tillDate = [dateFormatter dateFromString: [jsonObject[@"date_to"] asString]];
	[campaign setTillDate: tillDate];
	
	NSDate* excludingPeriodStart = [timeFormatter dateFromString: [jsonObject[@"without_time1_from"] asString]];
	[campaign setExcludingPeriodStart: excludingPeriodStart];
	
	NSDate* excludingPeriodEnd = [timeFormatter dateFromString: [jsonObject[@"without_time1_to"] asString]];
	[campaign setExcludingPeriodEnd: excludingPeriodEnd];
	
	NSDictionary* jsonFuelPriceCuts = [jsonObject[@"subtract_price"] asDictionary];
	if(jsonFuelPriceCuts != nil) {
		NSMutableDictionary* fuelPriceCuts = [[NSMutableDictionary alloc] init];
		
		for(NSObject* jsonFuelType in [jsonFuelPriceCuts allKeys]) {
			NSObject* jsonPriceCut = jsonFuelPriceCuts[jsonFuelType];
			//
			NSString* fuelType = [jsonFuelType asString];
			NSNumber* priceCut = [jsonPriceCut asNumber];
			
			if(fuelType != nil && priceCut != nil) {
				fuelPriceCuts[fuelType] = priceCut;
			}
		}
		
		[campaign setFuelPriceCuts: fuelPriceCuts];
	}
	
	NSNumber* totalQuota = [jsonObject[@"person_limit"] asNumber];
	[campaign setTotalQuota: totalQuota];
	
	NSNumber* remainingQuota = [jsonObject[@"person_surplus"] asNumber];
	[campaign setRemainingQuota: remainingQuota];
	
	NSNumber* fuelMinimum = [jsonObject[@"oil_min"] asNumber];
	[campaign setFuelMinimum: fuelMinimum];
	
	NSNumber* fuelLimit = [jsonObject[@"oil_limit"] asNumber];
	[campaign setFuelLimit: fuelLimit];
	
	return campaign;
}
