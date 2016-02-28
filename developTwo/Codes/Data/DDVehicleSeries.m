#import "DDVehicleSeries.h"

#import "NSObject+JsonParsing.h"

@implementation DDVehicleSeries

@end

#pragma mark -

DDVehicleSeries* DDVehicleSeriesFromJsonObject(NSDictionary* jsonObject) {
	DDVehicleSeries* series = [[DDVehicleSeries alloc] init];
	[series setCode: [jsonObject[@"code"] asString]];
	[series setName: [jsonObject[@"name"] asString]];
	
	return series;
}
