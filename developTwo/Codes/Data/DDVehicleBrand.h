#import <Foundation/Foundation.h>

// 品牌。
@interface DDVehicleBrand : NSObject

@property(nonatomic, copy) NSString* code;
@property(nonatomic, copy) NSString* name;

@end

#pragma mark -

DDVehicleBrand* DDVehicleBrandFromJsonObject(NSDictionary* jsonObject);
