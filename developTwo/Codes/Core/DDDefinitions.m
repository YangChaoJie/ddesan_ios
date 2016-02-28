#import "DDDefinitions.h"

#define SERVER_BASE_URL_STRING @"http://101.251.231.130:8001"
//#define SERVER_BASE_URL_STRING @"http://api.ddesan.com"

#pragma mark -

const NSString* kWeixinAppKey = @"b9592acd1ec91e46ee6ecc7841a27506";

// 百度地图没有用到。
// const NSString* kBaiduMapAppKey = @"7tn48wI8pDX37nCjjKBzPUb7";

const NSString* kBookingSuccessNotification = @"BOOKING_SUCCESS";
const NSString* kBookingFailureNotification = @"BOOKING_FAILURE";
const NSString* kSettlementNotification = @"SETTLEMENT";

NSURL* getConfigUrl() {
	static NSURL* url = nil;
	
	if(url == nil) {
		url = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat: @"%@/api/config/sysParam", SERVER_BASE_URL_STRING]];
	}
	
	return url;
}

NSURL* getVerificationUrl() {
	static NSURL* url = nil;
	
	if(url == nil) {
		url = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat: @"%@/api/customer/validate_phone_number", SERVER_BASE_URL_STRING]];
	}
	
	return url;
}

NSURL* getRegistryUrl() {
	static NSURL* url = nil;
	
	if(url == nil) {
		url = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat: @"%@/api/customer/register", SERVER_BASE_URL_STRING]];
	}
	
	return url;
}

NSURL* getLoginUrl() {
	static NSURL* url = nil;
	
	if(url == nil) {
		url = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat: @"%@/api/customer/login", SERVER_BASE_URL_STRING]];
	}
	
	return url;
}

NSURL* getPasswordResetUrl() {
	static NSURL* url = nil;
	
	if(url == nil) {
		url = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat: @"%@/api/customer/forget_password_reset", SERVER_BASE_URL_STRING]];
	}
	
	return url;
}

NSURL* getPasswordChangeUrl() {
	static NSURL* url = nil;
	
	if(url == nil) {
		url = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat: @"%@/api/customer/password_modify", SERVER_BASE_URL_STRING]];
	}
	
	return url;
}

NSURL* getCampaignListUrl() {
	static NSURL* url = nil;
	
	if(url == nil) {
		url = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat: @"%@/api/shop/activities", SERVER_BASE_URL_STRING]];
	}
	
	return url;
}

NSURL* getOrderEntryUrl() {
	static NSURL* url = nil;
	
	if(url == nil) {
		url = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat: @"%@/api/COrder/order_push", SERVER_BASE_URL_STRING]];
	}
	
	return url;
}

NSURL* getOrderModificationUrl() {
	static NSURL* url = nil;
	
	if(url == nil) {
		url = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat: @"%@/api/COrder/order_edit", SERVER_BASE_URL_STRING]];
	}
	
	return url;
}

NSURL* getBookingEntryUrl() {
	static NSURL* url = nil;
	
	if(url == nil) {
		url = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat: @"%@/api/COrder/cp_join", SERVER_BASE_URL_STRING]];
	}
	
	return url;
}

NSURL* getBookingUrl() {
	static NSURL* url = nil;
	
	if(url == nil) {
		url = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat: @"%@/api/COrder/shark", SERVER_BASE_URL_STRING]];
	}
	
	return url;
}

NSURL* getBookingOrderUrl() {
	static NSURL* url = nil;
	
	if(url == nil) {
		url = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat: @"%@/api/COrder/shark_order_push", SERVER_BASE_URL_STRING]];
	}
	
	return url;
}

NSURL* getStationCampaignListUrl() {
	static NSURL* url = nil;
	
	if(url == nil) {
		url = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat: @"%@/api/shop/get_all_activities", SERVER_BASE_URL_STRING]];
	}
	
	return url;
}

NSURL* getOrderListUrl() {
	static NSURL* url = nil;
	
	if(url == nil) {
		url = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat: @"%@/api/COrder/myorders", SERVER_BASE_URL_STRING]];
	}
	
	return url;
}

NSURL* getOrderCancelationUrl() {
	static NSURL* url = nil;
	
	if(url == nil) {
		url = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat: @"%@/api/COrder/order_cancel", SERVER_BASE_URL_STRING]];
	}
	
	return url;
}

NSURL* getOrderDetailUrl() {
	static NSURL* url = nil;
	
	if(url == nil) {
		url = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat: @"%@/api/COrder/get_order_detail", SERVER_BASE_URL_STRING]];
	}
	
	return url;
}

NSURL* getScoringUrl() {
	static NSURL* url = nil;
	
	if(url == nil) {
		url = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat: @"%@/api/COrder/put_order_score", SERVER_BASE_URL_STRING]];
	}
	
	return url;
}

NSURL* getComplainingUrl() {
	static NSURL* url = nil;
	
	if(url == nil) {
		url = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat: @"%@/api/COrder/put_order_complaint", SERVER_BASE_URL_STRING]];
	}
	
	return url;
}

NSURL* getUserVehicleListUrl() {
	static NSURL* url = nil;
	
	if(url == nil) {
		url = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat: @"%@/api/customer/get_customer_cars", SERVER_BASE_URL_STRING]];
	}
	
	return url;
}

NSURL* getUserVehicleUpdatingUrl() {
	static NSURL* url = nil;
	
	if(url == nil) {
		url = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat: @"%@/api/customer/update_car", SERVER_BASE_URL_STRING]];
	}
	
	return url;
}

NSURL* getVehicleTypeListUrl() {
	static NSURL* url = nil;
	
	if(url == nil) {
		url = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat: @"%@/api/config/cars", SERVER_BASE_URL_STRING]];
	}
	
	return url;
}

NSURL* getBalanceUrl() {
	static NSURL* url = nil;
	
	if(url == nil) {
		url = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat: @"%@/api/customer/get_customer_point", SERVER_BASE_URL_STRING]];
	}
	
	return url;
}

NSURL* getIncomeListUrl() {
	static NSURL* url = nil;
	
	if(url == nil) {
		url = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat: @"%@/api/customer/get_point_his_in", SERVER_BASE_URL_STRING]];
	}
	
	return url;
}

NSURL* getOutcomeListUrl() {
	static NSURL* url = nil;
	
	if(url == nil) {
		url = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat: @"%@/api/customer/get_point_his_out", SERVER_BASE_URL_STRING]];
	}
	
	return url;
}

NSURL* getInfoUpdatingUrl() {
	static NSURL* url = nil;
	
	if(url == nil) {
		url = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat: @"%@/api/customer/update_info", SERVER_BASE_URL_STRING]];
	}
	
	return url;
}

NSURL* getMobileChangeUrl() {
	// XXX 目前没有修改手机号的接口。
	return nil;
}

NSURL* getPortraitUploadingUrl() {
	static NSURL* url = nil;
	
	if(url == nil) {
		url = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat: @"%@/api/customer/upload_icon", SERVER_BASE_URL_STRING]];
	}
	
	return url;
}

//新加
NSURL* getConfigListUrlTwo() {
    static NSURL* url = nil;
    
    if(url == nil) {
        url = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat: @"%@/api/config/getProductSetting",SERVER_BASE_URL_STRING]];
    }
    
    return url;
}
