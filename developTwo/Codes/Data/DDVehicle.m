#import "DDVehicle.h"

#import "DDVehicleBrand.h"
#import "DDVehicleSeries.h"
#import "NSObject+JsonParsing.h"

@implementation DDVehicle

@end

#pragma mark -

DDVehicle* DDVehicleFromJsonObject(NSDictionary* jsonObject) {
	if(jsonObject == nil) {
		return nil;
	}
	
	DDVehicle* vehicle = [[DDVehicle alloc] init];
	
	DDVehicleBrand* brand = ^DDVehicleBrand* {
		DDVehicleBrand* brand = [[DDVehicleBrand alloc] init];
		
		NSString* code = [jsonObject[@"brand1_code"] asString];
		[brand setCode: code];
		
		NSString* name = [jsonObject[@"brand1_name"] asString];
		[brand setName: name];
		
		return brand;
	} ();
	[vehicle setBrand: brand];
	
	DDVehicleSeries* series = ^DDVehicleSeries* {
		DDVehicleSeries* series = [[DDVehicleSeries alloc] init];
		
		NSString* code = [jsonObject[@"brand2_code"] asString];
		[series setCode: code];
		
		NSString* name = [jsonObject[@"brand2_name"] asString];
		[series setName: name];
		
		return series;
	} ();
	[vehicle setSeries: series];
	
	NSString* number = [jsonObject[@"car_number"] asString];
	[vehicle setNumber: number];
	
	return vehicle;
}
