#import "DDApplicationDelegate.h"

#import <CoreLocation/CoreLocation.h>
#import "ACQueuedImageView.h"
#import "ASIDownloadCache.h"
#import "ASIFormDataRequest.h"
#import "DDAdvertisementViewController.h"
#import "DDDefinitions.h"
#import "DDEnvironment.h"
#import "DDHomeViewController.h"
#import "DDOrderRecord.h"
#import "DDRootViewController.h"
#import "DDUser.h"
#import "DDUtilities.h"
#import "NSObject+JsonParsing.h"
#import "WXApi.h"
#import "XGPush.h"



#import "BNCoreServices.h"
#define ADVERTISEMENT_KEY @"ADVERTISEMENT"

#define ACTION_TYPE_KEY @"ACTION_TYPE"
#define RESULT_KEY @"RESULT"
#define ORDER_CODE_KEY @"ORDER_CODE"


#define BNavKey @"bE4l2IChnv9bycgsQZiG3PWN"
#pragma mark -






@interface DDApplicationDelegate()<ACQueuedImageViewDelegate, ASIHTTPRequestDelegate, CLLocationManagerDelegate, WXApiDelegate> {
	DDEnvironment* _environment;
	
	UIWindow* _window;
	
	CLLocationManager* _locationManager;
	
	ASIHTTPRequest* _loginRequest;
	ASIHTTPRequest* _configRequest;
	NSMutableArray* _sharingImageRequests;
	NSMutableArray* _orderRequests;
	
	ACQueuedImageView* _advertisementImageView;
}

@end

#pragma mark -

@implementation DDApplicationDelegate

- (BOOL)application: (UIApplication*)application didFinishLaunchingWithOptions: (NSDictionary*)launchOptions {
	// 注册微信APP。
	//[WXApi registerApp: kWeixinAppKey];
	[WXApi registerApp: @"wx755879e7e1d2d081"];
	// 启动信鸽推送。
	{
		[XGPush startApp: 2200095621 appKey: @"I1D9LJU1F75S"];
		[XGPush initForReregister: ^ {
			if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
				UIUserNotificationSettings* settings = [UIUserNotificationSettings settingsForTypes: UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge categories: nil];
				[application registerUserNotificationSettings: settings];
				
				[application registerForRemoteNotifications];
			}
			else {
				[application registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound |UIRemoteNotificationTypeAlert ];
			}
		}];
	}
	
	// 监听登录用户账号，如果有变化则重新配置推送。
	_environment = [DDEnvironment sharedInstance];
	[_environment addObserver: self forKeyPath: @"user.mobile" options: 0 context: NULL];
	
	// 设置ASI下载缓存。
	[ASIHTTPRequest setDefaultCache: [ASIDownloadCache sharedCache]];
	
	// 在切换正式界面前尝试登录。
	[self tryToLogin];
	
	// 加载初始界面。
	{
		UIWindow* window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
		[window makeKeyAndVisible];
		
		_window = window;
		
		DDRootViewController* rootViewController = [DDRootViewController sharedInstance];
		[window setRootViewController: rootViewController];
		
		UIImage* advertisementImage = ^UIImage* {
			NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey: ADVERTISEMENT_KEY];
			if(imageData != nil) {
				return [[UIImage alloc] initWithData: imageData];
			}
			else {
				return nil;
			}
		} ();
		if(advertisementImage != nil) {
            //DDTestViewController*tvc=[[DDTestViewController alloc]init];
           // [rootViewController pushViewController:tvc animated:YES];
            
			DDAdvertisementViewController* advertisementViewController = [[DDAdvertisementViewController alloc] initWithImage: advertisementImage];
			[rootViewController pushViewController: advertisementViewController animated: FALSE];
		}
		else {
           
          
			DDHomeViewController* homeViewController = [[DDHomeViewController alloc] init];
			[rootViewController pushViewController: homeViewController animated: FALSE];
		}
	}
	
	// 开始监听当前位置。
	{
		CLLocationManager* locationManager = [[CLLocationManager alloc] init];
		[locationManager setDelegate: self];
		[locationManager setDistanceFilter: 100];
		[locationManager startUpdatingLocation];
		if([locationManager respondsToSelector: @selector(requestWhenInUseAuthorization)]) {
			[locationManager requestWhenInUseAuthorization];
		}
		
		_locationManager = locationManager;
	}
	
	// 加载远程配置。
	[self fetchConfig];
	
	_sharingImageRequests = [[NSMutableArray alloc] init];
	_orderRequests = [[NSMutableArray alloc] init];
    
    
    
    //百度导航
	//初始化导航SDK
    [BNCoreServices_Instance initServices:BNavKey];
    [BNCoreServices_Instance startServicesAsyn:nil fail:nil];
	return TRUE;
}

- (void)tryToLogin {
	NSString* recentUsername = [_environment recentUsername];
	if(recentUsername == nil) {
		return;
	}
	
	NSString* recentPassword = [_environment recentPassword];
	if(recentPassword == nil) {
		return;
	}
	
	NSURL* requestUrl = getLoginUrl();
	NSLog(@"URL - %@", requestUrl);
	
	NSMutableDictionary* requestParameters = [[NSMutableDictionary alloc] init];
	[requestParameters setValue: recentUsername forKey: @"phone"];
	[requestParameters setValue: recentPassword forKey: @"password"];
	[requestParameters setValue: @"1" forKey: @"client_type"];
	
	NSString* requestString = NSStringFromJsonObject(requestParameters);
	NSLog(@"IN - %@", requestString);
	
	ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL: requestUrl];
	[request setDelegate: self];
	[request setPostValue: requestString forKey: @"data"];
	[request setTimeOutSeconds: 2]; // 自动登录过程为同步处理，必须在规定时间内完成（不论成功失败）。
	
	_loginRequest = request; // 由于是同步请求，类变量赋值必须放在请求开始前。
	
	[request startSynchronous];
}

- (void)fetchConfig {
	NSURL* requestUrl = getConfigUrl();
	NSLog(@"URL - %@", requestUrl);
	
	NSString* requestString = @"";
	NSLog(@"IN - %@", requestString);
	
	ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL: requestUrl];
	[request setDelegate: self];
	[request setPostValue: requestString forKey: @"data"];
	[request startAsynchronous];
	
	_configRequest = request;
}

- (void)registerForXGPush {
	NSData* deviceToken = [_environment deviceToken];
	if(deviceToken == nil) {
		return;
	}
	
	NSString* userName = [_environment recentUsername];
	if(userName == nil) {
		return;
	}
	
	[XGPush setAccount: userName];
	[XGPush registerDevice: deviceToken];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [application setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
//    NSString* errorString = [error localizedDescription];
//    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"推送注册出错" message: errorString delegate: nil cancelButtonTitle: nil otherButtonTitles: @"关闭", nil];
//    [alertView show];
}

- (void)application: (UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken: (NSData*)deviceToken {
    
//    NSString *response = [NSString stringWithFormat: @"%@", deviceToken];
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"信鸽推送注册" message: response delegate: nil cancelButtonTitle: nil otherButtonTitles: @"关闭", nil];
//    [alertView show];
    
	[_environment setDeviceToken: deviceToken];
    
	[self registerForXGPush];
}

- (void)application: (UIApplication*)application didReceiveRemoteNotification: (NSDictionary*)userInfo {
    
//	NSString* contentString = [[userInfo[@"aps"] asDictionary][@"alert"] asString];
//    
//	NSDictionary* content = [[NSJSONSerialization JSONObjectWithData: [contentString dataUsingEncoding: NSUTF8StringEncoding] options: 0 error: nil] asDictionary];
//	if(content != nil) {
//		NSNumber* actionType = [content[@"action_type"] asNumber];
//		NSNumber* result = [content[@"result"] asNumber];
//		NSString* orderCode = [content[@"order_code"] asString];
//		if(actionType != nil && result != nil && orderCode != nil) {
//			NSURL* requestUrl = getOrderDetailUrl();
//			NSLog(@"URL - %@", requestUrl);
//			
//			NSMutableDictionary* requestParameters = [[NSMutableDictionary alloc] init];
//			[requestParameters setValue: [[_environment user] accessToken] forKey: @"access_token"];
//			[requestParameters setValue: orderCode forKey: @"order_code"];
//			
//			NSString* requestString = NSStringFromJsonObject(requestParameters);
//			NSLog(@"IN - %@", requestString);
//			
//			ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL: requestUrl];
//			[request setDelegate: self];
//			[request setPostValue: requestString forKey: @"data"];
//			[request setUserInfo: @{ ACTION_TYPE_KEY: actionType, RESULT_KEY: result, ORDER_CODE_KEY: orderCode }];
//			[request startAsynchronous];
//			
//			[_orderRequests addObject: request];
//		}
//	}
    
    if(userInfo != nil) {
        NSNumber* actionType = [userInfo[@"action_type"] asNumber];
        NSNumber* result = [userInfo[@"result"] asNumber];
        NSString* orderCode = [userInfo[@"order_code"] asString];
        if(actionType != nil && result != nil && orderCode != nil) {
            NSURL* requestUrl = getOrderDetailUrl();
            NSLog(@"URL - %@", requestUrl);
            
            NSMutableDictionary* requestParameters = [[NSMutableDictionary alloc] init];
            [requestParameters setValue: [[_environment user] accessToken] forKey: @"access_token"];
            [requestParameters setValue: orderCode forKey: @"order_code"];
            
            NSString* requestString = NSStringFromJsonObject(requestParameters);
            NSLog(@"IN - %@", requestString);
            
            ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL: requestUrl];
            [request setDelegate: self];
            [request setPostValue: requestString forKey: @"data"];
            [request setUserInfo: @{ ACTION_TYPE_KEY: actionType, RESULT_KEY: result, ORDER_CODE_KEY: orderCode }];
            [request startAsynchronous];
            
            [_orderRequests addObject: request];
        }
    }
    
    [application setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
}

- (BOOL)application: (UIApplication*)application handleOpenURL: (NSURL*)url {
	[WXApi handleOpenURL: url delegate: self];
	
	return TRUE;
}

- (BOOL)application: (UIApplication*)application openURL: (NSURL*)url sourceApplication: (NSString*)sourceApplication annotation: (id)annotation {
	[WXApi handleOpenURL: url delegate: self];
	
	return TRUE;
}

- (void)observeValueForKeyPath: (NSString*)keyPath ofObject: (id)object change: (NSDictionary*)change context: (void*)context {
	if(object == _environment) {
		if([keyPath isEqualToString: @"user.mobile"]) {
			[self registerForXGPush];
			
			return;
		}
		
		return;
	}
}

- (void)queuedImageView: (ACQueuedImageView*)queuedImageView hasFinishedLoadingWithImage: (UIImage*)image {
	if(queuedImageView == _advertisementImageView) {
		NSData* imageData = nil;
		if(image != nil) {
			imageData = UIImagePNGRepresentation(image);
		}
		
		[[NSUserDefaults standardUserDefaults] setObject: imageData forKey: ADVERTISEMENT_KEY];
		
		return;
	}
}

- (void)requestFinished: (ASIHTTPRequest*)request {
	if(request == _loginRequest) {
		_loginRequest = nil;
		
		int httpStatusCode = [request responseStatusCode];
		if(httpStatusCode != 200) {
			NSLog(@"HTTP - %d", httpStatusCode);
			
			return;
		}
		
		NSData* responseData = [request responseData];
		NSString* responseString = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
		NSLog(@"OUT - %@", responseString);
		
		NSDictionary* responseParameters = [NSJSONSerialization JSONObjectWithData: responseData options: 0 error: NULL];
		if(responseParameters == nil) {
			return;
		}
		
		NSString* responseStatus = [responseParameters[@"status"] asString];
		if(![[responseStatus lowercaseString] isEqualToString: @"ok"]) {
			return;
		}
			
		DDUser* user = DDUserFromJsonObject(responseParameters[@"data"]);
		[_environment setUser: user];
		
		return;
	}
	
	if(request == _configRequest) {
		_configRequest = nil;
		
		int httpStatusCode = [request responseStatusCode];
		if(httpStatusCode != 200) {
			NSLog(@"HTTP - %d", httpStatusCode);
			
			return;
		}
		
		NSData* responseData = [request responseData];
		NSString* responseString = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
		NSLog(@"OUT - %@", responseString);
		
		NSDictionary* responseParameters = [NSJSONSerialization JSONObjectWithData: responseData options: 0 error: NULL];
		if(responseParameters == nil) {
			return;
		}
		
		NSString* responseStatus = [responseParameters[@"status"] asString];
		if(![[responseStatus lowercaseString] isEqualToString: @"ok"]) {
			return;
		}
		
		NSDictionary* jsonConfig = [responseParameters[@"data"] asDictionary];
		
		NSNumber* bookingDistance = [jsonConfig[@"shake_distance"] asNumber];
		[_environment setBookingDistance: bookingDistance];
		
		NSNumber* priceStep = [jsonConfig[@"fee_input_ruler"] asNumber];
		[_environment setPriceStep: priceStep];
		
		NSNumber* customerAngelPoint = [jsonConfig[@"angelc_point"] asNumber];
		[_environment setCustomerAngelPoint: customerAngelPoint];
		
		NSNumber* businessAngelPoint = [jsonConfig[@"angelb_point"] asNumber];
		[_environment setBusinessAngelPoint: businessAngelPoint];
		
		NSArray* jsonSelectableDistances = [jsonConfig[@"select_distance"] asArray];
		if(jsonSelectableDistances != nil && [jsonSelectableDistances count] == 4) {
			NSMutableArray* selectableDistances = [[NSMutableArray alloc] init];
			
			for(int i = 0; i < 4; i++) {
				NSNumber* selectableDistance = [jsonSelectableDistances[i] asNumber];
				if(selectableDistance != nil) {
					[selectableDistances addObject: selectableDistance];
				}
			}
			
			if([selectableDistances count] == 4) {
				[_environment setSelectableDistances: selectableDistances];
			}
		}
		
		NSNumber* defaultDistanceIndex = [jsonConfig[@"select_distance_default"] asNumber];
		[_environment setDefaultDistanceIndex: defaultDistanceIndex];
		
		NSString* sharingText = [jsonConfig[@"share_text"] asString];
		[_environment setSharingText: sharingText];
		
		NSString* sharingUrl = [jsonConfig[@"share_url"] asString];
		[_environment setSharingUrl: sharingUrl];
		
		NSDictionary* jsonSharingImageUrls = [jsonConfig[@"share_icons"] asDictionary];
		if(jsonSharingImageUrls != nil) {
			NSMutableArray* sharingImageUrls = [[NSMutableArray alloc] init];
			
			for(NSString* jsonSharingImageUrl in [jsonSharingImageUrls allValues]) {
				NSString* sharingImageUrl = [jsonSharingImageUrl asString];
				if(sharingImageUrl != nil) {
					[sharingImageUrls addObject: sharingImageUrl];
				}
			}
			
			[_environment setSharingImageUrls: sharingImageUrls];
			
			// 尝试加载分享图片。
			{
				for(NSString* sharingImageUrl in sharingImageUrls) {
					NSURL* url = [[NSURL alloc] initWithString: sharingImageUrl];
					
					ASIHTTPRequest* request = [[ASIHTTPRequest alloc] initWithURL: url];
					[request setDelegate: self];
					[request startAsynchronous];
					
					[_sharingImageRequests addObject: request];
				}
			}
		}
		
		// 尝试加载广告图片。
		{
			NSString* advertisementImageFile = [jsonConfig[@"app_ad_url"] asString];
			ACQueuedImageView* imageView = [[ACQueuedImageView alloc] init];
			[imageView setDelegate: self];
			[imageView setImageWithContentsOfFile: advertisementImageFile];
			
			_advertisementImageView = imageView;
		}
		
		return;
	}
	
	if([_sharingImageRequests containsObject: request]) {
		[_sharingImageRequests removeObject: request];
		
		return;
	}
	
	if([_orderRequests containsObject: request]) {
		[_orderRequests removeObject: request];
		
		int httpStatusCode = [request responseStatusCode];
		if(httpStatusCode != 200) {
			NSLog(@"HTTP - %d", httpStatusCode);
			
			return;
		}
		
		NSData* responseData = [request responseData];
		NSString* responseString = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
		NSLog(@"OUT - %@哈哈💗😄😄😄😄😄😄虾5555555", responseString);
		
		NSDictionary* responseParameters = [NSJSONSerialization JSONObjectWithData: responseData options: 0 error: NULL];
		if(responseParameters == nil) {
			return;
		}
		
		NSString* responseStatus = [responseParameters[@"status"] asString];
		if(![[responseStatus lowercaseString] isEqualToString: @"ok"]) {
			return;
		}
		
		DDOrderRecord* orderRecord = DDOrderRecordFromJsonObject([responseParameters[@"data"] asDictionary]);
		if(orderRecord == nil) {
			return;
		}
		
		NSDictionary* userInfo = [request userInfo];
		NSNumber* actionType = [userInfo valueForKey: ACTION_TYPE_KEY];
		NSNumber* result = [userInfo valueForKey: RESULT_KEY];
		
		if([actionType isEqualToNumber: @1]) {
			if([result isEqualToNumber: @2]) {
				[[NSNotificationCenter defaultCenter] postNotificationName: kBookingSuccessNotification object: self userInfo: @{ @"ORDER": orderRecord }];
			}
			else if([result isEqualToNumber: @3]) {
				[[NSNotificationCenter defaultCenter] postNotificationName: kBookingFailureNotification object: self userInfo: @{ @"ORDER": orderRecord }];
			}
		}
		else if([actionType isEqualToNumber: @2]) {
			[[NSNotificationCenter defaultCenter] postNotificationName: kSettlementNotification object: self userInfo: @{ @"ORDER": orderRecord }];
		}
		
		return;
	}
}

- (void)requestFailed: (ASIHTTPRequest*)request {
	if(request == _loginRequest) {
		_loginRequest = nil;
		
		return;
	}
	
	if(request == _configRequest) {
		_configRequest = nil;
		
		return;
	}
	
	if([_sharingImageRequests containsObject: request]) {
		[_sharingImageRequests removeObject: request];
		
		return;
	}
	
	if([_orderRequests containsObject: request]) {
		[_orderRequests removeObject: request];
		
		return;
	}
}

- (void)locationManager: (CLLocationManager*)manager didUpdateLocations: (NSArray *)locations {
	CLLocation* location = [locations firstObject];
	[_environment setLocation: location];
}

- (void)dealloc {
	[_environment removeObserver: self forKeyPath: @"user.mobile"];
	
	if(_loginRequest != nil) {
		[_loginRequest clearDelegatesAndCancel];
	}
	
	if(_configRequest != nil) {
		[_configRequest clearDelegatesAndCancel];
	}
	
	for(ASIHTTPRequest* request in _sharingImageRequests) {
		[request clearDelegatesAndCancel];
	}
	
	for(ASIHTTPRequest* request in _orderRequests) {
		[request clearDelegatesAndCancel];
	}
}

@end
