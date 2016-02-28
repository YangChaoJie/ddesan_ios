#import "DDChildViewController.h"

@class DDVehicleBrand;
@class DDVehicleSeries;

@interface DDUserVehicleViewController : DDChildViewController

@property(nonatomic, strong) DDVehicleBrand* vehicleBrand;
@property(nonatomic, strong) DDVehicleSeries* vehicleSeries;

@property(nonatomic, copy) NSString* vehicleNumber;

@end
