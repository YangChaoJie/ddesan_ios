#import "DDOrderConfirmationViewController.h"

#import "ACMessageDialog.h"
#import "ASIFormDataRequest.h"
#import "DDCampaign.h"
#import "DDDefinitions.h"
#import "DDEnvironment.h"
#import "DDOrderOfflineViewController.h"
#import "DDOrderRecord.h"
#import "DDRootViewController.h"
#import "DDStation.h"
#import "DDUser.h"
#import "DDUtilities.h"
#import "NSObject+JsonParsing.h"

@interface DDOrderConfirmationViewController()<ASIHTTPRequestDelegate, UITextFieldDelegate> {
	DDOrderRecord* _orderRecord;
	
	IBOutlet UIButton* _backButton;
	
	IBOutlet UILabel* _stationLabel;
	IBOutlet UILabel* _fuelTypeLabel;
	IBOutlet UILabel* _amountLabel;
	IBOutlet UILabel* _originalPriceLabel;
	IBOutlet UILabel* _discountageLabel;
	IBOutlet UILabel* _discountedPriceLabel;
	
	IBOutlet UITextField* _tubeField;
	
	IBOutlet UIButton* _submitButton;
	
	ASIHTTPRequest* _orderEntryRequest;
	ACMessageDialog* _orderEntryDialog;
	
	ASIHTTPRequest* _orderModificationRequest;
	ACMessageDialog* _orderModificationDialog;
    
    
    
    //add by YCJ 2015-12-01
    NSString* s1;
    NSString* s2;
}

@end

#pragma mark -

@implementation DDOrderConfirmationViewController


/*-(instancetype)initWithOrderDictary:(NSDictionary *)dict{
    self.dict=dict;
    return self;
}*/


- (instancetype)initWithOrderRecord: (DDOrderRecord*)orderRecord Dictary:(NSDictionary *)dict{
    self.dict=dict;
	self = [super init];
	if(self != nil) {
		_orderRecord = orderRecord;
		
		[super view];
		
		NSString* stationName = [[_orderRecord station] name];
		[_stationLabel setText: [[NSString alloc] initWithFormat: @"付予：%@", stationName]];
		
        
        //修改
		NSString *fuelType = [_orderRecord fuelType];
         s1=[self.dict objectForKey:fuelType];
		[_fuelTypeLabel setText: s1];
		
        
        
		double fuelAmount = [[_orderRecord fuelAmount] doubleValue];
		[_amountLabel setText: [[NSString alloc] initWithFormat: @"%.2fL", fuelAmount]];
		
		NSInteger originalPrice = [[_orderRecord originalPrice] integerValue];
		NSInteger discountedPrice = [[_orderRecord discountedPrice] integerValue];
		NSInteger discountage = originalPrice - discountedPrice;
		
		[_originalPriceLabel setText: [[NSString alloc] initWithFormat: @"¥%d", (int)originalPrice]];
		[_discountageLabel setText: [[NSString alloc] initWithFormat: @"¥%d", (int)discountage]];
		[_discountedPriceLabel setText: [[NSString alloc] initWithFormat: @"¥%d", (int)discountedPrice]];
		
		NSNumber* tubeNumber = [_orderRecord tubeNumber];
		if(tubeNumber != nil) {
			[_tubeField setText: [[NSString alloc] initWithFormat: @"%d", [tubeNumber intValue]]];
			[_submitButton setEnabled: TRUE];
		}
	}
	
	return self;
}

- (IBAction)handleButton: (UIButton*)button {
	if(button == _backButton) {
		[self goBack];
		
		return;
	}
	if(button == _submitButton) {
		[self queryToSubmitOrder];
		
		return;
	}
}

- (void)textFieldDidEndEditing: (UITextField*)textField {
	if(textField == _tubeField) {
		NSNumber* tubeNumber = nil;
		{
			NSInteger value;
			if([[[NSScanner alloc] initWithString: [textField text]] scanInteger: &value]) {
				tubeNumber = [[NSNumber alloc] initWithInteger: value];
			}
		}
		
		[_orderRecord setTubeNumber: tubeNumber];
		[_submitButton setEnabled: tubeNumber != nil];
		
		return;
	}
}

- (void)queryToSubmitOrder {
	NSString* accessToken = [[[DDEnvironment sharedInstance] user] accessToken];
	
	NSString* fuelType = [_orderRecord fuelType];
	NSNumber* discountedPrice = [_orderRecord discountedPrice];
	NSNumber* tubeNumber = [_orderRecord tubeNumber];
	
	NSString* code = [_orderRecord code];
	if(code == nil) {
		// 订单号为空，需要提交新的订单。
		
		NSString* stationId = [[_orderRecord station] id];
		NSString* campaignId = [[_orderRecord campaign] id];
		
		NSURL* requestUrl = getOrderEntryUrl();
		NSLog(@"URL - %@", requestUrl);
		
		NSMutableDictionary* requestParameters = [[NSMutableDictionary alloc] init];
		[requestParameters setValue: stationId forKey: @"shop_id"];
		[requestParameters setValue: campaignId forKey: @"campaign_id"];
        
        
		[requestParameters setValue: fuelType forKey: @"oil_type"];
        
        
		[requestParameters setValue: discountedPrice forKey: @"price"];
		[requestParameters setValue: tubeNumber forKey: @"eqt"];
		[requestParameters setValue: accessToken forKey: @"access_token"];
        
        [requestParameters setValue: @"27" forKey: @"versionCode"];
		
		NSString* requestString = NSStringFromJsonObject(requestParameters);
		NSLog(@"IN - %@", requestString);
		
		ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL: requestUrl];
		[request setDelegate: self];
		[request setPostValue: requestString forKey: @"data"];
		[request startAsynchronous];
		
		_orderEntryRequest = request;
		
		ACMessageDialog* dialog = [[ACMessageDialog alloc] init];
		[dialog setMessage: @"正在提交订单，请稍候……"];
		[dialog setCancelButtonTitle: @"取消"];
		[dialog setDismissHandler: ^(ACMessageDialog* dialog) {
			_orderEntryDialog = nil;
			
			[_orderEntryRequest clearDelegatesAndCancel];
			_orderEntryRequest = nil;
		}];
		[dialog show];
		
		_orderEntryDialog = dialog;
	}
	else {
		// 订单号不为空，则是修改已有订单。
		
		NSNumber* state = [_orderRecord state];
		
		NSURL* requestUrl = [state integerValue] == DDOrderRecordStateBooking ? getBookingOrderUrl() : getOrderModificationUrl();
		NSLog(@"URL - %@", requestUrl);
		
		NSMutableDictionary* requestParameters = [[NSMutableDictionary alloc] init];
		[requestParameters setValue: code forKey: @"order_code"];
		[requestParameters setValue: fuelType forKey: @"oil_type"];
		[requestParameters setValue: discountedPrice forKey: @"price"];
		[requestParameters setValue: tubeNumber forKey: @"eqt"];
		[requestParameters setValue: accessToken forKey: @"access_token"];
        
        [requestParameters setValue: @"27" forKey: @"versionCode"];
		
		NSString* requestString = NSStringFromJsonObject(requestParameters);
		NSLog(@"IN - %@", requestString);
		
		ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL: requestUrl];
		[request setDelegate: self];
		[request setPostValue: requestString forKey: @"data"];
		[request startAsynchronous];
		
		_orderModificationRequest = request;
		
		ACMessageDialog* dialog = [[ACMessageDialog alloc] init];
		[dialog setMessage: @"正在提交订单，请稍候……"];
		[dialog setCancelButtonTitle: @"取消"];
		[dialog setDismissHandler: ^(ACMessageDialog* dialog) {
			_orderModificationDialog = nil;
			
			[_orderModificationRequest clearDelegatesAndCancel];
			_orderModificationRequest = nil;
		}];
		[dialog show];
		
		_orderModificationDialog = dialog;
	}
}

- (void)requestFinished: (ASIHTTPRequest*)request {
	if(request == _orderEntryRequest) {
		_orderEntryRequest = nil;
		
		[_orderEntryDialog dismiss];
		_orderEntryDialog = nil;
		
		int httpStatusCode = [request responseStatusCode];
		if(httpStatusCode != 200) {
			NSLog(@"HTTP - %d", httpStatusCode);
			
			alert(@"无法提交订单（接口返回无效状态）。");
			
			return;
		}
		
		NSData* responseData = [request responseData];
		NSString* responseString = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
		NSLog(@"OUT - %@", responseString);
		
		NSDictionary* responseParameters = [NSJSONSerialization JSONObjectWithData: responseData options: 0 error: NULL];
		if(responseParameters == nil) {
			alert(@"无法提交订单（接口返回格式错误）。");
			
			return;
		}
		
		NSString* responseStatus = responseParameters[@"status"];
		if(![[responseStatus lowercaseString] isEqualToString: @"ok"]) {
			NSDictionary* jsonError = [responseParameters[@"error"] asDictionary];
			
			NSString* errorCode = [jsonError[@"code"] asString];
			if([errorCode isEqualToString: @"ERR007"]) {
				[self loginTimedOut];
			}
			else {
				NSString* errorMessage = [jsonError[@"msg"] asString];
				if(errorMessage == nil) {
					errorMessage = @"无法提交订单（发生未知错误）。";
				}
				
				alert(errorMessage);
			}
			
			return;
		}
		
		NSDictionary* jsonData = [responseParameters[@"data"] asDictionary];
		
		NSDictionary* jsonOrder = [jsonData[@"CampaignOrder"] asDictionary];
		
		NSString* orderCode = [jsonOrder[@"order_code"] asString];
		[_orderRecord setCode: orderCode];
		
		DDOrderOfflineViewController* orderOfflineViewController = [[DDOrderOfflineViewController alloc] initWithOrderRecord: _orderRecord Dictary:self.dict];
		[self push: orderOfflineViewController animated: TRUE];
		
		return;
	}
	
	if(request == _orderModificationRequest) {
		_orderModificationRequest = nil;
		
		[_orderModificationDialog dismiss];
		_orderModificationDialog = nil;
		
		int httpStatusCode = [request responseStatusCode];
		if(httpStatusCode != 200) {
			NSLog(@"HTTP - %d", httpStatusCode);
			
			alert(@"无法提交订单（接口返回无效状态）。");
			
			return;
		}
		
		NSData* responseData = [request responseData];
		NSString* responseString = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
		NSLog(@"OUT - %@", responseString);
		
		NSDictionary* responseParameters = [NSJSONSerialization JSONObjectWithData: responseData options: 0 error: NULL];
		if(responseParameters == nil) {
			alert(@"无法提交订单（接口返回格式错误）。");
			
			return;
		}
		
		NSString* responseStatus = responseParameters[@"status"];
		if(![[responseStatus lowercaseString] isEqualToString: @"ok"]) {
			NSDictionary* jsonError = [responseParameters[@"error"] asDictionary];
			
			NSString* errorCode = [jsonError[@"code"] asString];
			if([errorCode isEqualToString: @"ERR007"]) {
				[self loginTimedOut];
			}
			else {
				NSString* errorMessage = [jsonError[@"msg"] asString];
				if(errorMessage == nil) {
					errorMessage = @"无法提交订单（发生未知错误）。";
				}
				
				alert(errorMessage);
			}
			
			return;
		}
		
		[_orderRecord setState: [[NSNumber alloc] initWithInteger: DDOrderRecordStateProcessing]];
		
		DDOrderOfflineViewController* orderOfflineViewController = [[DDOrderOfflineViewController alloc] initWithOrderRecord: _orderRecord Dictary:self.dict];
		[self push: orderOfflineViewController animated: TRUE];
		
		return;
	}
}

- (void)requestFailed: (ASIHTTPRequest*)request {
	if(request == _orderEntryRequest) {
		_orderEntryRequest = nil;
		
		[_orderEntryDialog dismiss];
		_orderEntryDialog = nil;
		
		alert(@"无法提交订单（网络连接失败）。");
		
		return;
	}
	
	if(request == _orderModificationRequest) {
		_orderModificationRequest = nil;
		
		[_orderModificationDialog dismiss];
		_orderModificationDialog = nil;
		
		alert(@"无法提交订单（网络连接失败）。");
		
		return;
	}
}

@end
