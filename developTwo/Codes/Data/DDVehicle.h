#import <Foundation/Foundation.h>

@class DDVehicleBrand;
@class DDVehicleSeries;

@interface DDVehicle : NSObject

@property(nonatomic, strong) DDVehicleBrand* brand;
@property(nonatomic, strong) DDVehicleSeries* series;
@property(nonatomic, copy) NSString* number;

@end

#pragma mark -

DDVehicle* DDVehicleFromJsonObject(NSDictionary* jsonObject);
