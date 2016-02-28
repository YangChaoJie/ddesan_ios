#import "DDSharing.h"

#import <Social/Social.h>
#import "ASIHTTPRequest.h"
#import "DDEnvironment.h"
#import "DDRootViewController.h"
#import "DDUtilities.h"
#import "WXApi.h"

@interface DDSharing()<UIActionSheetDelegate, UIAlertViewDelegate> {
	UIActionSheet* _sharingActionSheet;
	
	UIAlertView* _weixinAlertView;
}

@end

#pragma mark -

@implementation DDSharing

+ (instancetype)sharedInstance {
	static DDSharing* instance = nil;
	
	if(instance == nil) {
		@synchronized([DDSharing class]) {
			if(instance == nil) {
				instance = [[super alloc] init];
			}
		}
	}
	
	return instance;
}

- (void)share {
	UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle: nil delegate: self cancelButtonTitle: @"取消" destructiveButtonTitle: nil otherButtonTitles: @"微信聊天", @"微信朋友圈", @"新浪微博", nil];
	[actionSheet showInView: [[[DDRootViewController sharedInstance] topViewController] view]];
	
	_sharingActionSheet = actionSheet;
}

- (void)shareUsingWeixinSession {
	if([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
		DDEnvironment* environment = [DDEnvironment sharedInstance];
		
		NSData* sharingImageData = ^NSData* {
			srand((unsigned)[NSDate timeIntervalSinceReferenceDate] * 1000000);
			
			NSArray* urlStrings = [environment sharingImageUrls];
			NSInteger count = [urlStrings count];
			if(count == 0) {
				return nil;
			}
			
			NSURL* url = [[NSURL alloc] initWithString: urlStrings[rand() % count]];
			
			ASIHTTPRequest* request = [[ASIHTTPRequest alloc] initWithURL: url];
			[request setCachePolicy: ASIDontLoadCachePolicy];
			[request startSynchronous];
			
			NSData* data = [request responseData];
			
			return data;
		} ();
		
		if(sharingImageData == nil) {
			sharingImageData = UIImagePNGRepresentation([UIImage imageNamed: @"sharing~default"]);
		}
		
		assert(sharingImageData != nil);
		
		NSString* sharingText = [environment sharingText];
		
		NSString* sharingUrl = [environment sharingUrl];
		
		WXMediaMessage* message = [WXMediaMessage new];
		[message setThumbData: sharingImageData];
		[message setTitle: sharingText];
		
		WXWebpageObject* webpageObject = [WXWebpageObject new];
		[webpageObject setWebpageUrl: sharingUrl];
		[message setMediaObject: webpageObject];
		
		SendMessageToWXReq* request = [SendMessageToWXReq new];
		[request setBText: FALSE];
		[request setMessage: message];
		[request setScene: WXSceneSession];
		
		[WXApi sendReq: request];
	}
	else {
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: @"" message: @"你的设备上还没有安装微信，无法使用此功能，使用微信可以方便的把你喜欢的作品分享给好友。" delegate: self cancelButtonTitle: @"取消" otherButtonTitles: @"免费下载微信", nil];
		[alertView show];
		
		_weixinAlertView = alertView;
	}
}

- (void)shareUsingWeixinTimeline {
	if([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
		DDEnvironment* environment = [DDEnvironment sharedInstance];
		
		NSData* sharingImageData = ^NSData* {
			srand((unsigned)[NSDate timeIntervalSinceReferenceDate] * 1000000);
			
			NSArray* urlStrings = [environment sharingImageUrls];
			NSInteger count = [urlStrings count];
			if(count == 0) {
				return nil;
			}
			
			NSURL* url = [[NSURL alloc] initWithString: urlStrings[rand() % count]];
			
			ASIHTTPRequest* request = [[ASIHTTPRequest alloc] initWithURL: url];
			[request setCachePolicy: ASIDontLoadCachePolicy];
			[request startSynchronous];
			
			NSData* data = [request responseData];
			
			return data;
		} ();
		
		if(sharingImageData == nil) {
			sharingImageData = UIImagePNGRepresentation([UIImage imageNamed: @"sharing~default"]);
		}
		
		assert(sharingImageData != nil);
		
		NSString* sharingText = [environment sharingText];
		
		NSString* sharingUrl = [environment sharingUrl];
		
		WXMediaMessage* message = [WXMediaMessage new];
		[message setThumbData: sharingImageData];
		[message setTitle: sharingText];
		
		WXWebpageObject* webpageObject = [WXWebpageObject new];
		[webpageObject setWebpageUrl: sharingUrl];
		[message setMediaObject: webpageObject];
		
		SendMessageToWXReq* request = [SendMessageToWXReq new];
		[request setBText: FALSE];
		[request setMessage: message];
		[request setScene: WXSceneTimeline];
		
		[WXApi sendReq: request];
	}
	else {
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: @"" message: @"你的设备上还没有安装微信，无法使用此功能，使用微信可以方便的把你喜欢的作品分享给好友。" delegate: self cancelButtonTitle: @"取消" otherButtonTitles: @"免费下载微信", nil];
		[alertView show];
		
		_weixinAlertView = alertView;
	}
}

- (void)shareUsingSinaWeibo {
	DDEnvironment* environment = [DDEnvironment sharedInstance];
	
	NSData* sharingImageData = ^NSData* {
		srand((unsigned)[NSDate timeIntervalSinceReferenceDate] * 1000000);
		
		NSArray* urlStrings = [environment sharingImageUrls];
		NSInteger count = [urlStrings count];
		if(count == 0) {
			return nil;
		}
		
		NSURL* url = [[NSURL alloc] initWithString: urlStrings[rand() % count]];
		
		ASIHTTPRequest* request = [[ASIHTTPRequest alloc] initWithURL: url];
		[request setCachePolicy: ASIDontLoadCachePolicy];
		[request startSynchronous];
		
		NSData* data = [request responseData];
		
		return data;
	} ();
	
	if(sharingImageData == nil) {
		sharingImageData = UIImagePNGRepresentation([UIImage imageNamed: @"sharing~default"]);
	}
	
	assert(sharingImageData != nil);
	
	NSString* sharingText = [environment sharingText];
	
	NSString* sharingUrl = [environment sharingUrl];
	
	SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
	[composeViewController addImage: [[UIImage alloc] initWithData: sharingImageData]];
	[composeViewController setInitialText: sharingText];
	[composeViewController addURL: [[NSURL alloc] initWithString: sharingUrl]];
	
	[[[DDRootViewController sharedInstance] topViewController] presentViewController: composeViewController animated: TRUE completion: nil];
}

- (void)actionSheet: (UIActionSheet*)actionSheet didDismissWithButtonIndex: (NSInteger)buttonIndex {
	if(actionSheet == _sharingActionSheet) {
		_sharingActionSheet = nil;
		
		if(buttonIndex != [actionSheet cancelButtonIndex]) {
			switch(buttonIndex - [actionSheet firstOtherButtonIndex]) {
				case 0:
				{
					[self shareUsingWeixinSession];
					
					break;
				}
				
				case 1:
				{
					[self shareUsingWeixinTimeline];
					
					break;
				}
				
				case 2:
				{
					[self shareUsingSinaWeibo];
					
					break;
				}
				
				default:
				break;
			}
		}
		
		return;
	}
}

- (void)alertView: (UIAlertView*)alertView clickedButtonAtIndex: (NSInteger)buttonIndex {
	if(alertView == _weixinAlertView) {
		if(buttonIndex != [alertView cancelButtonIndex]) {
			[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"itms-apps://itunes.apple.com/cn/app/wei-xin/id414478124?mt=8"]];
		}
		
		return;
	}
}

@end
