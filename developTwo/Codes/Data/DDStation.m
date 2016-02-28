#import "DDStation.h"

#import <CoreLocation/CoreLocation.h>
#import "DDUtilities.h"
#import "NSObject+JsonParsing.h"

@implementation DDStation

@end

#pragma mark -

DDStation* DDStationFromJsonObject(NSDictionary* jsonObject) {
	if(jsonObject == nil) {
		return nil;
	}
	
	DDStation* station = [[DDStation alloc] init];
	
	NSString* id = [jsonObject[@"shop_id"] asString];
	[station setId: id];
	
	NSString* name = [jsonObject[@"shop_name"] asString];
	[station setName: name];
	
	NSString* address = [jsonObject[@"addr"] asString];
	[station setAddress: address];
	
	NSNumber* longitude = [jsonObject[@"shop_lng"] asNumber];
	NSNumber* latitude = [jsonObject[@"shop_lat"] asNumber];
    NSLog(@"long=%@%@",longitude,latitude);
	if(longitude != nil && latitude != nil) {
		// 接口提供的坐标是BD-09格式，须转为WGS-84格式。
		CLLocationCoordinate2D coordinate = translateCoordinateFromGcj02ToWgs84(translateCoordinateFromBd09ToGcj02(CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue])));
		CLLocation* location = [[CLLocation alloc] initWithCoordinate: coordinate altitude: 0 horizontalAccuracy: 0 verticalAccuracy: -1 timestamp: [[NSDate alloc] init]];
		[station setLocation: location];
	}
	
	[station setPhotoImageFile: [jsonObject[@"shop_icon"] asString]];
	
	NSArray* jsonFuelTypes = [jsonObject[@"oil_type"] asArray];
    
	if(jsonFuelTypes != nil) {
		NSMutableArray* fuelTypes = [[NSMutableArray alloc] init];
		
		for(NSObject* jsonFuelType in jsonFuelTypes) {
			NSNumber* fuelType = [jsonFuelType asNumber];
			if(fuelType != nil) {
				[fuelTypes addObject: fuelType];
			}
		}
		
		//[station setFuelTypes: fuelTypes];
        [station setFuelTypes: jsonFuelTypes];
	}
	
	NSDictionary* jsonFuelPrices = [jsonObject[@"oil_price"] asDictionary];
	if(jsonFuelPrices != nil) {
		NSMutableDictionary* fuelPrices = [[NSMutableDictionary alloc] init];
		
		for(NSObject* jsonFuelType in [jsonFuelPrices allKeys]) {
			NSObject* jsonPrice = jsonFuelPrices[jsonFuelType];
			
			NSString* fuelType = [jsonFuelType asString];
			NSNumber* price = [jsonPrice asNumber];
			
			if(fuelType != nil && price != nil) {
				fuelPrices[fuelType] = price;
			}
		}
		
		[station setFuelPrices: fuelPrices];
	}
	
	[station setScore: [jsonObject[@"avg_score"] asNumber]];
	
	return station;
}
