#import <Foundation/Foundation.h>

// 热度活动预约纪录。
@interface DDBookingRecord : NSObject

@property(nonatomic, copy) NSString* stationId;
@property(nonatomic, copy) NSString* stationName;
@property(nonatomic, copy) NSString* stationAddress;
@property(nonatomic, copy) NSString* campaignId;
@property(nonatomic, copy) NSNumber* fuelType;
@property(nonatomic, copy) NSNumber* fuelPrice;
@property(nonatomic, copy) NSNumber* fuelPriceCut;
@property(nonatomic, copy) NSNumber* fuelAmount;

@end
