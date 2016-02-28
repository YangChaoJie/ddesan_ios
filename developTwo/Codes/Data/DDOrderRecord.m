#import "DDOrderRecord.h"

#import "DDCampaign.h"
#import "DDStation.h"
#import "NSObject+JsonParsing.h"

static NSDate* parseDate(NSString* string) {
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
	[dateFormatter setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: 28800]];
	
	NSDate* date = [dateFormatter dateFromString: string];
	
	return date;
}

#pragma mark -

@implementation DDOrderRecord

@end

#pragma mark -

DDOrderRecord* DDOrderRecordFromJsonObject(NSDictionary* jsonObject) {
	if(jsonObject == nil) {
		return nil;
	}
	
	DDOrderRecord* orderRecord = [[DDOrderRecord alloc] init];
	
	{
		NSDictionary* jsonOrder = [jsonObject[@"CampaignOrder"] asDictionary];
		
		NSString* code = [jsonOrder[@"order_code"] asString];
		[orderRecord setCode: code];
		
		NSNumber* state = [jsonOrder[@"status"] asNumber];
		[orderRecord setState: state];
		
		NSString* fuelType = [jsonOrder[@"oil_type"] asString];
		[orderRecord setFuelType: fuelType];
		
		NSNumber* fuelPrice = [jsonOrder[@"unit_price"] asNumber];
		[orderRecord setFuelPrice: fuelPrice];
		
		NSNumber* fuelPriceCut = [jsonOrder[@"subtract_price"] asNumber];
		[orderRecord setFuelPriceCut: fuelPriceCut];
		
		NSNumber* fuelAmount = [jsonOrder[@"quantity"] asNumber];
		[orderRecord setFuelAmount: fuelAmount];
		
		NSNumber* originalPrice = [jsonOrder[@"org_price"] asNumber];
		[orderRecord setOriginalPrice: originalPrice];
		
		NSNumber* discountedPrice = [jsonOrder[@"price"] asNumber];
		[orderRecord setDiscountedPrice: discountedPrice];
		
		NSNumber* score = [jsonOrder[@"score"] asNumber];
		[orderRecord setScore: score];
		
		NSString* complaint = [jsonOrder[@"complaint"] asString];
		[orderRecord setComplaint: complaint];
		
		NSNumber* tubeNumber = [jsonOrder[@"eqt"] asNumber];
		[orderRecord setTubeNumber: tubeNumber];
		
		NSString* paymentType = [jsonOrder[@"pay_type"] asString];
		[orderRecord setPaymentType: paymentType];
		
		NSDate* paymentDate = parseDate([jsonOrder[@"pay_time"] asString]);
		[orderRecord setPaymentDate: paymentDate];
	}
	
	DDStation* station = DDStationFromJsonObject([jsonObject[@"MerchantShop"] asDictionary]);
	[orderRecord setStation: station];
	
	DDCampaign* campaign = DDCampaignFromJsonObject([jsonObject[@"Campaign"] asDictionary]);
	[orderRecord setCampaign: campaign];
	
	{
		NSDictionary* jsonOperator = [jsonObject[@"MerchantAppuser"] asDictionary];
		
		NSString* operatorName = [jsonOperator[@"app_name"] asString];
		[orderRecord setOperatorName: operatorName];
	}
	
	return orderRecord;
}
