#import <Foundation/Foundation.h>

@class DDCampaign;
@class DDStation;

typedef NS_ENUM(NSInteger, DDOrderRecordState) {
	DDOrderRecordStateProcessing = 1,
	DDOrderRecordStateFinished = 2,
	DDOrderRecordStateCanceled = 3,
	DDOrderRecordStateBooking = 4,
	DDOrderRecordStateFailed = 5
};

typedef NS_ENUM(NSInteger, DDCampaignType) {
	DDCampaignTypeHot = 1,
	DDCampaignTypeRegular = 2
};

typedef NS_ENUM(NSInteger, DDPaymentType) {
	DDPaymentTypeCash = 101,
	DDPaymentTypeCard = 102,
	DDPaymentTypeAlipay = 201
};

#pragma mark -

// 热度活动和常规活动共通的订单记录。
@interface DDOrderRecord : NSObject

@property(nonatomic, copy) NSString* code;
@property(nonatomic, copy) NSNumber* state;
@property(nonatomic, copy) NSString* fuelType;
@property(nonatomic, copy) NSNumber* fuelPrice;
@property(nonatomic, copy) NSNumber* fuelPriceCut;
@property(nonatomic, copy) NSNumber* fuelAmount;
@property(nonatomic, copy) NSNumber* originalPrice;
@property(nonatomic, copy) NSNumber* discountedPrice;
@property(nonatomic, copy) NSNumber* score;
@property(nonatomic, copy) NSString* complaint;
@property(nonatomic, copy) NSNumber* tubeNumber;
@property(nonatomic, copy) NSString* paymentType;
@property(nonatomic, copy) NSDate* paymentDate;

@property(nonatomic, strong) DDStation* station;
@property(nonatomic, strong) DDCampaign* campaign;

@property(nonatomic, copy) NSString* operatorName;

@end

#pragma mark -

DDOrderRecord* DDOrderRecordFromJsonObject(NSDictionary* jsonObject);
