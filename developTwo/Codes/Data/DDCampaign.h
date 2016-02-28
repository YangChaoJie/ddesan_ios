#import <Foundation/Foundation.h>

// 活动。
@interface DDCampaign : NSObject

@property(nonatomic, copy) NSString* id;
@property(nonatomic, copy) NSDate* sinceDate;
@property(nonatomic, copy) NSDate* tillDate;
@property(nonatomic, copy) NSDate* excludingPeriodStart;
@property(nonatomic, copy) NSDate* excludingPeriodEnd;
@property(nonatomic, copy) NSDictionary* fuelPriceCuts; // 键：油号（类型：NSNumber） 值：价格降幅（类型：NSNumber 单位：元/升）
@property(nonatomic, copy) NSNumber* fuelMinimum;
@property(nonatomic, copy) NSNumber* fuelLimit;

@end

#pragma mark -

DDCampaign* DDCampaignFromJsonObject(NSDictionary* jsonObject);
