#import <Foundation/Foundation.h>

@class CLLocation;

// 站点。
@interface DDStation : NSObject

@property(nonatomic, copy) NSString* id;
@property(nonatomic, copy) NSString* name;
@property(nonatomic, copy) NSString* address;
@property(nonatomic, copy) CLLocation* location;
@property(nonatomic, copy) NSString* photoImageFile;
@property(nonatomic, copy) NSArray* fuelTypes; // 项：油号（类型：NSNumber）
@property(nonatomic, copy) NSDictionary* fuelPrices; // 键：油号（类型：NSNumber） 值：价格（类型：NSNumber 单位：元/升）
@property(nonatomic, copy) NSNumber* score;

@end

#pragma mark -

DDStation* DDStationFromJsonObject(NSDictionary* jsonObject);
