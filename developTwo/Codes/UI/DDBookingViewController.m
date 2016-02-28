#import "DDBookingViewController.h"

#import <CoreLocation/CoreLocation.h>
#import "ASIFormDataRequest.h"
#import "ACMessageDialog.h"
#import "DDCampaigningStation.h"
#import "DDDefinitions.h"
#import "DDEnvironment.h"
#import "DDHotCampaign.h"
#import "DDHotCampaignViewController.h"
#import "DDStation.h"
#import "DDUser.h"
#import "DDUtilities.h"
#import "NSObject+JsonParsing.h"

@interface DDBookingViewController()<ASIHTTPRequestDelegate> {
	DDCampaigningStation* _campaigningStation;
	
	IBOutlet UIButton* _backButton;
	IBOutlet UILabel* _firstLineLabel;
	
	ASIFormDataRequest* _bookingRequest;
    
    
    //add by YCJ 2015-12-01
    
   /* ASIHTTPRequest* _loginRequest;
    NSDictionary* _data;*/
}

@end

#pragma mark -

@implementation DDBookingViewController



- (instancetype)initWithCampaigningStation: (DDCampaigningStation*)campaigningStation Dictary:(NSDictionary *)dict{
    //
    self.dict=dict;
    
	self = [super init];
	if(self != nil) {
		assert([[campaigningStation campaign] isKindOfClass: [DDHotCampaign class]]);
		
		_campaigningStation = campaigningStation;
		
		[super view];
	}
	
	return self;
}

- (IBAction)handleButton: (UIButton*)button {
	if(button == _backButton) {
		[self goBack];
		
		return;
	}
}

- (void)queryToBook {
	DDEnvironment* environment = [DDEnvironment sharedInstance];
	
	DDStation* station = [_campaigningStation station];
	DDHotCampaign* campaign = (DDHotCampaign*)[_campaigningStation campaign];
	
	CLLocationDistance bookingDistance = [[environment bookingDistance] doubleValue];
//	// FIXME 为了测试，不计算有效距离，之后应删除。
//	bookingDistance = 0;
	
	CLLocation* userLocation = [environment location];
	CLLocation* stationLocation = [station location];
	CLLocationDistance distance = [stationLocation distanceFromLocation: userLocation];
	if(bookingDistance != 0 && distance > bookingDistance) {
		alert([[NSString alloc] initWithFormat: @"您需要在该加油站内摇一摇才能参与抢名额。"]);
		
		return;
	}
	
	NSString* stationId = [station id];
	NSString* campaignId = [campaign id];
	NSString* accessToken = [[[DDEnvironment sharedInstance] user] accessToken];
	
	NSURL* requestUrl = getBookingUrl();
	NSLog(@"URL - %@", requestUrl);
	
	NSMutableDictionary* requestParameters = [[NSMutableDictionary alloc] init];
	[requestParameters setValue: stationId forKey: @"shop_id"];
	[requestParameters setValue: campaignId forKey: @"campaign_id"];
	[requestParameters setValue: accessToken forKey: @"access_token"];
	
	NSString* requestString = NSStringFromJsonObject(requestParameters);
	NSLog(@"IN - %@", requestString);
	
	ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL: requestUrl];
	[request setDelegate: self];
	[request setPostValue: requestString forKey: @"data"];
	[request startAsynchronous];
	
	_bookingRequest = request;
}

- (void)viewDidAppear: (BOOL)animated {
	[super viewDidAppear: animated];
	
	[self becomeFirstResponder];
}

- (void)viewWillDisappear: (BOOL)animated {
	[super viewWillDisappear: animated];
	
	[self resignFirstResponder];
}

- (void)motionEnded: (UIEventSubtype)motion withEvent: (UIEvent*)event {
	if(motion == UIEventSubtypeMotionShake) {
		[self queryToBook];
		
		return;
	}
}

- (void)requestFinished: (ASIHTTPRequest*)request {
	if(request == _bookingRequest) {
		_bookingRequest = nil;
		
		int httpStatusCode = [request responseStatusCode];
		if(httpStatusCode != 200) {
			NSLog(@"HTTP - %d", httpStatusCode);
			
			alert(@"无法进行预约（接口返回无效状态）。");
			
			return;
		}
		
		NSData* responseData = [request responseData];
		NSString* responseString = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
		NSLog(@"OUT - %@", responseString);
		
		NSDictionary* responseParameters = [NSJSONSerialization JSONObjectWithData: responseData options: 0 error: NULL];
		if(responseParameters == nil) {
			alert(@"无法进行预约（接口返回格式错误）。");
			
			return;
		}
		
		NSString* responseStatus = responseParameters[@"status"];
		if(![[responseStatus lowercaseString] isEqualToString: @"ok"]) {
			NSDictionary* jsonError = [responseParameters[@"error"] asDictionary];
			
			NSString* errorCode = [jsonError[@"code"] asString];
			if([errorCode isEqualToString: @"ERR007"]) {
				[self loginTimedOut];
			}
			else if([errorCode isEqualToString: @"ERR014"/* 名额已满 */]) {
				[(DDHotCampaign*)[_campaigningStation campaign] setRemainingQuota: [[NSNumber alloc] initWithInteger: 0]];
				DDHotCampaignViewController* hotCampaignViewController = [[DDHotCampaignViewController alloc] initWithCampaigningStation: _campaigningStation andOrderCode: nil Dictary:nil];
				[self switchTo: hotCampaignViewController animated: TRUE];
			}
			else {
				NSString* errorMessage = [jsonError[@"msg"] asString];
				if(errorMessage == nil) {
					errorMessage = @"无法进行预约（发生未知错误）。";
				}
				
				alert(errorMessage);
			}
			
			return;
		}
		
		NSDictionary* jsonData = [responseParameters[@"data"] asDictionary];
		
		NSDictionary* jsonOrder = [jsonData[@"CampaignOrder"] asDictionary];
		
		NSString* orderCode = [jsonOrder[@"order_code"] asString];
		
		DDHotCampaignViewController* hotCampaignViewController = [[DDHotCampaignViewController alloc] initWithCampaigningStation: _campaigningStation andOrderCode: orderCode Dictary:self.dict];
		[self switchTo: hotCampaignViewController animated: TRUE];
		
		return;
	}
}

- (void)requestFailed: (ASIHTTPRequest*)request {
	if(request == _bookingRequest) {
		_bookingRequest = nil;
		
		alert(@"无法进行预约（网络连接失败）。");
		
		return;
	}
}

@end

/*
{"data":{"CampaignOrder":{"order_code":"13482222433150518020920","campaign_id":"50","shop_id":"4","merchant_id":"193","customer_id":"27","status":4},"Campaign":{"campaign_id":"50","title":"\u65b0\u6d41\u7a0b\u6d3b\u52a8\u6d4b\u8bd5","target":"1","target2":null,"pub_type":"1","merchant_id":null,"merchant_user_id":null,"admin_user_id":"1","campaign_type":"1","subtract_price":{"92":"0.8","93":"0.8","95":"0.8","97":"0.8"},"date_from":"2015-05-11","date_to":"2015-05-31","without_time1_from":null,"without_time1_to":null,"start_time":null,"oil_limit":"60","person_limit":"2","join_type":"1","comment":null,"business_img":null,"enroll_message":"","enroll_deadline":null,"stop_flg":"0","status":"3","del_flg":"0","modified":"2015-05-11 17:54:07","created":"2015-05-11 17:52:59"},"MerchantShop":{"shop_id":"4","merchant_id":"193","shop_name":"\u6c5d\u70b9\u6d4b\u8bd5\u52a0\u6cb9\u7ad9","shop_short_name":"\u6c5d\u70b9\u6d4b\u8bd5\u52a0\u6cb9\u7ad9","oil_type":"93,97","oil_price":{"92":"9.8","95":"7.6"},"contact_name":"\u80e1\u53ef","tel":"18516171031","Email":null,"size":null,"supply":"0","addr":"\u5858\u6865\u8def400\u5f043\u53f7\u697c502","shop_lng":"121.524002","shop_lat":"31.216402","map":null,"district_1":"020000000000","district_2":"020100000000","district_3":"020102000000","district_name_1":"\u4e0a\u6d77","district_name_2":"\u4e0a\u6d77\u5e02","district_name_3":"\u6768\u6d66\u533a","examine_stat":null,"business_img":null,"token":"6108F620687D96FE70C2739491CF96EC","from_token":null,"shop_icon":"\/files\/merchant\/4BD7EE8C4D96D12F1961780CD806E6FB\/20150416185940968099.JPG","up_file_code_1":"123456","up_file_img_1":"","up_file_code_2":"123456","up_file_img_2":"","up_file_code_3":"123456","up_file_img_3":"","up_file_code_4":"123456","up_file_img_4":"","check_date":"2015-05-13","status":"1","comment":null,"avg_score":"3","shop_order_fee":null,"del_flg":"0","modified":"2015-05-18 02:05:01","created":"2015-03-30 18:15:58"},"Customer":{"customer_id":"27","name":null,"phone":"13482222433","password":"c488fdd544d560c9f6101c0c86473b5a6cf77a86","nick_name":"Yaiba Kirisame","icon":null,"token":"6BE822BF303CC1B6963824DA67DC04F7","from_type":"5","from_token":null,"last_active":"2015-04-18 21:00:31","client_type":"1","qr":{"personal":"http:\/\/101.251.231.130:8004\/files\/customer\/6BE822BF303CC1B6963824DA67DC04F7\/xGMBbUnpwnxuuujVLF3c.png","angelc":"http:\/\/101.251.231.130:8004\/files\/customer\/6BE822BF303CC1B6963824DA67DC04F7\/DtswdjCbxM06sjVkdbnt.png","angelb":"http:\/\/101.251.231.130:8004\/files\/customer\/6BE822BF303CC1B6963824DA67DC04F7\/B2XYvBys8jDwhG5v3Fyy.png"}}},"status":"OK","error":{"code":null,"msg":null}}
*/
