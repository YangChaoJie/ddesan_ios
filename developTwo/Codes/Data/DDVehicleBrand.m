#import "DDVehicleBrand.h"

#import "NSObject+JsonParsing.h"

@implementation DDVehicleBrand

@end

#pragma mark -

DDVehicleBrand* DDVehicleBrandFromJsonObject(NSDictionary* jsonObject) {
	DDVehicleBrand* brand = [[DDVehicleBrand alloc] init];
	[brand setCode: [jsonObject[@"code"] asString]];
	[brand setName: [jsonObject[@"name"] asString]];
	
	return brand;
}
