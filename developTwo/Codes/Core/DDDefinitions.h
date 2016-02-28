#import <Foundation/Foundation.h>

extern NSString* kWeixinAppKey;

// 抢名额成功的通知ID。
extern NSString* kBookingSuccessNotification;

// 抢名额失败的通知ID。
extern NSString* kBookingFailureNotification;

// 结算完成的通知ID。
extern NSString* kSettlementNotification;

// 获取设置参数的接口URL。
extern NSURL* getConfigUrl();

// 获取手机验证码的接口URL。
extern NSURL* getVerificationUrl();

// 获取注册的接口URL。
extern NSURL* getRegistryUrl();

// 获取登录的接口URL。
extern NSURL* getLoginUrl();

// 获取重置密码的接口URL。
extern NSURL* getPasswordResetUrl();

// 获取修改密码的接口URL。
extern NSURL* getPasswordChangeUrl();

// 获取活动列表的接口URL。
extern NSURL* getCampaignListUrl();

// 获取下订单的接口URL。
extern NSURL* getOrderEntryUrl();

// 获取修改订单的接口URL。
extern NSURL* getOrderModificationUrl();

// 获取报名热度活动的接口URL。
extern NSURL* getBookingEntryUrl();

// 获取热度活动摇一摇抢名额的接口URL。
extern NSURL* getBookingUrl();

// 获取热度活动抢到名额后下单的接口URL。
extern NSURL* getBookingOrderUrl();

// 获取特定站点活动列表的接口URL。
extern NSURL* getStationCampaignListUrl();

// 获取订单列表的接口URL。
extern NSURL* getOrderListUrl();

// 获取撤销订单的接口URL。
extern NSURL* getOrderCancelationUrl();

// 获取单个订单详情的接口URL。
extern NSURL* getOrderDetailUrl();

// 获取提交评价的接口URL。
extern NSURL* getScoringUrl();

// 获取提交投诉的接口URL。
extern NSURL* getComplainingUrl();

// 获取用户车辆列表的接口URL。
extern NSURL* getUserVehicleListUrl();

// 获取更新用户车辆的接口URL。
extern NSURL* getUserVehicleUpdatingUrl();

// 获取车牌车系列表的接口URL。
extern NSURL* getVehicleTypeListUrl();

// 获取天使基金余额的接口URL。
extern NSURL* getBalanceUrl();

// 获取天使基金收入列表的接口URL。
extern NSURL * getIncomeListUrl();

// 获取天使基金支出列表的接口URL。
extern NSURL* getOutcomeListUrl();

// 获取更新用户信息的接口URL。
extern NSURL* getInfoUpdatingUrl();

// 获取更改手机号的接口URL。
extern NSURL* getMobileChangeUrl();

// 获取上传头像的接口URL。
extern NSURL* getPortraitUploadingUrl();
//油品列表获得接口URL
extern NSURL* getConfigListUrlTwo();

