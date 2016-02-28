#import <Foundation/Foundation.h>

// 车系。
@interface DDVehicleSeries : NSObject

@property(nonatomic, copy) NSString* code;
@property(nonatomic, copy) NSString* name;

@end

#pragma mark -

DDVehicleSeries* DDVehicleSeriesFromJsonObject(NSDictionary* jsonObject);
