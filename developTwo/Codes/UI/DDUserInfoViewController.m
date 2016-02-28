#import "DDUserInfoViewController.h"

#import "ACMessageDialog.h"
#import "ACQueuedImageView.h"
#import "ASIFormDataRequest.h"
#import "DDDefinitions.h"
#import "DDEnvironment.h"
#import "DDLoginViewController.h"
#import "DDUser.h"
#import "DDUserVehicleViewController.h"
#import "DDUtilities.h"
#import "DDVehicle.h"
#import "DDVehicleBrand.h"
#import "DDVehicleSeries.h"
#import "NSObject+JsonParsing.h"

#define NICK_NAME_KEY @"NICK_NAME"

#pragma mark -

@interface DDUserInfoViewController()<ASIHTTPRequestDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
	IBOutlet UIButton* _backButton;
	IBOutlet UIButton* _accountButton;
	
	IBOutlet UIButton* _portraitButton;
	IBOutlet ACQueuedImageView* _portraitImageView;
	
	IBOutlet UIButton* _nickNameButton;
	IBOutlet UILabel* _nickNameLabel;
	
	IBOutlet UIButton* _mobileButton;
	IBOutlet UILabel* _mobileLabel;
	
	IBOutlet UIButton* _vehicleButton;
	IBOutlet UILabel* _vehicleLabel;
	
	DDEnvironment* _environment;
	
	ASIHTTPRequest* _vehicleListRequest;
	
	UIActionSheet* _portraitTypeActionSheet;
	UIImagePickerController* _portraitImagePickerController;
	ASIHTTPRequest* _portraitRequest;
	ACMessageDialog* _portraitDialog;
	
	UIAlertView* _nickNameAlertView;
	ASIHTTPRequest* _nickNameRequest;
	ACMessageDialog* _nickNameDialog;
	
}

@end

#pragma mark -

@implementation DDUserInfoViewController

- (instancetype)init {
	self = [super init];
	if(self != nil) {
		[super view];
		
		[_nickNameLabel setText: nil];
		[_mobileLabel setText: nil];
		[_vehicleLabel setText: nil];
		
		_environment = [DDEnvironment sharedInstance];
		[_environment addObserver: self forKeyPath: @"user.portraitImageFile" options: 0 context: NULL];
		[_environment addObserver: self forKeyPath: @"user.nickName" options: 0 context: NULL];
		[_environment addObserver: self forKeyPath: @"user.mobile" options: 0 context: NULL];
		[_environment addObserver: self forKeyPath: @"user.vehicle.number" options: 0 context: NULL];
		
		[self updatePortrait];
		[self updateNickName];
		[self updateMobile];
		[self updateVehicle];
		
		if([[_environment user] vehicle] == nil) {
			[self queryForVehicleList];
		}
	}
	
	return self;
}

- (IBAction)handleButton: (UIButton*)button {
	if(button == _backButton) {
		[self goBack];
		
		return;
	}
	
	if(button == _accountButton) {
		[self goSwitchAccount];
		
		return;
	}
	
	if(button == _portraitButton) {
		[self askForPortraitType];
		
		return;
	}
	
	if(button == _nickNameButton) {
		[self askForNickName];
		
		return;
	}
	
	if(button == _vehicleButton) {
		[self goVehicle];
		
		return;
	}
}

- (void)updatePortrait {
	NSString* portraitImageFile = [[_environment user] portraitImageFile];
	if(portraitImageFile != nil) {
		[_portraitImageView setImageWithContentsOfFile: portraitImageFile];
	}
	else {
		[_portraitImageView setImage: [UIImage imageNamed: @"common~default_portrait"]];
	}
}

- (void)updateNickName {
	[_nickNameLabel setText: [[_environment user] nickName]];
}

- (void)updateMobile {
	[_mobileLabel setText: [[_environment user] mobile]];
}

- (void)updateVehicle {
	[_vehicleLabel setText: [[[_environment user] vehicle] number]];
}

- (void)goSwitchAccount {
	DDLoginViewController* loginViewController = [[DDLoginViewController alloc] init];
	[self switchTo: loginViewController animated: TRUE];
}

- (void)askForPortraitType {
	UIActionSheet* portraitTypeActionSheet = [[UIActionSheet alloc] initWithTitle: nil delegate: self cancelButtonTitle: @"取消" destructiveButtonTitle: nil otherButtonTitles: @"拍照", @"从相册选择", nil];
	[portraitTypeActionSheet showInView: [self view]];
	
	_portraitTypeActionSheet = portraitTypeActionSheet;
}

- (void)askForNickName {
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: nil message: @"请输入昵称" delegate: self cancelButtonTitle: @"取消" otherButtonTitles: @"确认", nil];
	[alertView setAlertViewStyle: UIAlertViewStylePlainTextInput];
	[alertView show];
	
	_nickNameAlertView = alertView;
}

- (void)goVehicle {
	DDVehicle* vehicle = [[_environment user] vehicle];
	
	DDUserVehicleViewController* userVehicleViewController = [[DDUserVehicleViewController alloc] init];
	[userVehicleViewController setVehicleBrand: [vehicle brand]];
	[userVehicleViewController setVehicleSeries: [vehicle series]];
	[userVehicleViewController setVehicleNumber: [vehicle number]];
	[self push: userVehicleViewController animated: TRUE];
}

- (void)queryForVehicleList {
	NSURL* requestUrl = getUserVehicleListUrl();
	NSLog(@"URL - %@", requestUrl);
	
	NSMutableDictionary* requestParameters = [[NSMutableDictionary alloc] init];
	[requestParameters setValue: [[_environment user] accessToken] forKey: @"access_token"];
	
	NSString* requestString = NSStringFromJsonObject(requestParameters);
	NSLog(@"IN - %@", requestString);
	
	ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL: requestUrl];
	[request setDelegate: self];
	[request setPostValue: requestString forKey: @"data"];
	[request startAsynchronous];
	
	_vehicleListRequest = request;
}

- (void)observeValueForKeyPath: (NSString*)keyPath ofObject: (id)object change: (NSDictionary*)change context: (void*)context {
	if(object == _environment) {
		if([keyPath isEqualToString: @"user.portraitImageFile"]) {
			[self updatePortrait];
			
			return;
		}
		
		if([keyPath isEqualToString: @"user.nickName"]) {
			[self updateNickName];
			
			return;
		}
		
		if([keyPath isEqualToString: @"user.mobile"]) {
			[self updateMobile];
			
			return;
		}
		
		if([keyPath isEqualToString: @"user.vehicle.number"]) {
			[self updateVehicle];
			
			return;
		}
		
		return;
	}
}

- (void)requestFinished: (ASIHTTPRequest*)request {
	if(request == _vehicleListRequest) {
		_vehicleListRequest = nil;
		
		NSData* responseData = [request responseData];
		NSString* responseString = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
		NSLog(@"OUT - %@", responseString);
		
		NSDictionary* responseParameters = [NSJSONSerialization JSONObjectWithData: responseData options: 0 error: NULL];
		if(responseParameters == nil) {
			alert(@"无法获取用户车辆（接口返回格式错误）。");
			
			return;
		}
		
		NSString* responseStatus = [responseParameters[@"status"] asString];
		if(![[responseStatus lowercaseString] isEqualToString: @"ok"]) {
			NSDictionary* jsonError = [responseParameters[@"error"] asDictionary];
			
			NSString* errorCode = [jsonError[@"code"] asString];
			if([errorCode isEqualToString: @"ERR007"]) {
				[self loginTimedOut];
			}
			else {
				NSString* errorMessage = [jsonError[@"msg"] asString];
				if(errorMessage == nil) {
					errorMessage = @"无法获取用户车辆（发生未知错误）。";
				}
				
				alert(errorMessage);
			}
			
			return;
		}
		
		NSArray* jsonVehicleList = [responseParameters[@"data"] asArray];
		NSDictionary* jsonVehicle = [[jsonVehicleList lastObject] asDictionary];
		
		DDVehicle* vehicle = DDVehicleFromJsonObject(jsonVehicle);
		if(vehicle == nil) {
			return;
		}
		
		[[_environment user] setVehicle: vehicle];
		
		return;
	}
	
	if(request == _portraitRequest) {
		_portraitRequest = nil;
		
		[_portraitDialog dismiss];
		_portraitDialog = nil;
		
		
		int httpStatusCode = [request responseStatusCode];
		if(httpStatusCode != 200) {
			NSLog(@"HTTP - %d", httpStatusCode);
			
			alert(@"无法上传头像（接口返回无效状态）。");
			
			return;
		}
		
		NSData* responseData = [request responseData];
		NSString* responseString = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
		NSLog(@"OUT - %@", responseString);
		
		NSDictionary* responseParameters = [NSJSONSerialization JSONObjectWithData: responseData options: 0 error: NULL];
		if(responseParameters == nil) {
			alert(@"无法上传头像（接口返回格式错误）。");
			
			return;
		}
		
		NSString* responseStatus = [responseParameters[@"status"] asString];
		if(![[responseStatus lowercaseString] isEqualToString: @"ok"]) {
			NSDictionary* jsonError = [responseParameters[@"error"] asDictionary];
			
			NSString* errorCode = [jsonError[@"code"] asString];
			if([errorCode isEqualToString: @"ERR007"]) {
				[self loginTimedOut];
			}
			else {
				NSString* errorMessage = [jsonError[@"msg"] asString];
				if(errorMessage == nil) {
					errorMessage = @"无法上传头像（发生未知错误）。";
				}
				
				alert(errorMessage);
			}
			
			return;
		}
		
		NSString* portraitImageFile = [[responseParameters[@"data"] asDictionary][@"icon"] asString];
		[[_environment user] setPortraitImageFile: portraitImageFile];
		
		return;
	}
	
	if(request == _nickNameRequest) {
		_nickNameRequest = nil;
		
		[_nickNameDialog dismiss];
		_nickNameDialog = nil;
		
		int httpStatusCode = [request responseStatusCode];
		if(httpStatusCode != 200) {
			NSLog(@"HTTP - %d", httpStatusCode);
			
			alert(@"无法修改昵称（接口返回无效状态）。");
			
			return;
		}
		
		NSData* responseData = [request responseData];
		NSString* responseString = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
		NSLog(@"OUT - %@", responseString);
		
		NSDictionary* responseParameters = [NSJSONSerialization JSONObjectWithData: responseData options: 0 error: NULL];
		if(responseParameters == nil) {
			alert(@"无法修改昵称（接口返回格式错误）。");
			
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
					errorMessage = @"无法修改昵称（发生未知错误）。";
				}
				
				alert(errorMessage);
			}
			
			return;
		}
		
		NSString* nickName = [request userInfo][NICK_NAME_KEY];
		[[_environment user] setNickName: nickName];
		
		return;
	}
}

- (void)requestFailed: (ASIHTTPRequest*)request {
	if(request == _vehicleListRequest) {
		_vehicleListRequest = nil;
		
		alert(@"无法获取用户车辆（网络连接失败）。");
		
		return;
	}
	
	if(request == _portraitRequest) {
		_portraitRequest = nil;
		
		[_portraitDialog dismiss];
		_portraitDialog = nil;
		
		alert(@"无法上传头像（网络连接失败）。");
		
		return;
	}
	
	if(request == _nickNameRequest) {
		_nickNameRequest = nil;
		
		[_nickNameDialog dismiss];
		_nickNameDialog = nil;
		
		alert(@"无法修改昵称（网络连接失败）。");
		
		return;
	}
}

- (void)actionSheet: (UIActionSheet*)actionSheet didDismissWithButtonIndex: (NSInteger)buttonIndex {
	if(actionSheet == _portraitTypeActionSheet) {
		_portraitTypeActionSheet = nil;
		
		if(buttonIndex != [actionSheet cancelButtonIndex]) {
			switch(buttonIndex - [actionSheet firstOtherButtonIndex]) {
				case 0:
				{
					if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
						UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
						[imagePickerController setAllowsEditing: TRUE];
						[imagePickerController setDelegate: self];
						[imagePickerController setSourceType: UIImagePickerControllerSourceTypeCamera];
						[self presentViewController: imagePickerController animated: TRUE completion: NULL];
						
						_portraitImagePickerController = imagePickerController;
					}
					else {
						alert(@"您的设备不支持拍照。");
					}
					
					break;
				}
				
				case 1:
				{
					if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
						UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
						[imagePickerController setAllowsEditing: TRUE];
						[imagePickerController setDelegate: self];
						[imagePickerController setSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
						[self presentViewController: imagePickerController animated: TRUE completion: NULL];
						
						_portraitImagePickerController = imagePickerController;
					}
					else {
						alert(@"您的设备不支持相册。");
					}
					
					break;
				}
				
				default:
				break;
			}
		}
	}
}

- (void)alertView: (UIAlertView*)alertView clickedButtonAtIndex: (NSInteger)buttonIndex {
	if(alertView == _nickNameAlertView) {
		_nickNameAlertView = nil;
		
		if(buttonIndex == [alertView firstOtherButtonIndex]) {
			NSString* nickName = [[alertView textFieldAtIndex: 0] text];
			if(nickName == nil) {
				alert(@"昵称不能为空。");
				
				return;
			}
			
			{
				NSURL* requestUrl = getInfoUpdatingUrl();
				NSLog(@"URL - %@", requestUrl);
				
				NSMutableDictionary* requestParameters = [[NSMutableDictionary alloc] init];
				[requestParameters setValue: [[_environment user] accessToken] forKey: @"access_token"];
				[requestParameters setValue: nickName forKey: @"nick_name"];
				
				NSString* requestString = NSStringFromJsonObject(requestParameters);
				NSLog(@"IN - %@", requestString);
				
				ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL: requestUrl];
				[request setDelegate: self];
				[request setPostValue: requestString forKey: @"data"];
				[request setUserInfo: @{ NICK_NAME_KEY: nickName }];
				[request startAsynchronous];
				
				_nickNameRequest = request;
			}
			
			{
				ACMessageDialog* dialog = [[ACMessageDialog alloc] init];
				[dialog setMessage: @"正在修改昵称，请稍候……"];
				[dialog setDismissHandler: ^(ACMessageDialog* dialog) {
					if(dialog == _nickNameDialog) {
						_nickNameDialog = nil;
						
						[_nickNameRequest clearDelegatesAndCancel];
						_nickNameRequest = nil;
					}
				}];
				[dialog show];
				
				_nickNameDialog = dialog;
			}
		}
		
		return;
	}
}

- (void)imagePickerController: (UIImagePickerController*)picker didFinishPickingMediaWithInfo: (NSDictionary*)info {
	if(picker == _portraitImagePickerController) {
		_portraitImagePickerController = nil;
		
		[picker dismissViewControllerAnimated: TRUE completion: NULL];
		
		// 取得编辑过的图片。
		UIImage* image = info[UIImagePickerControllerEditedImage];
		
		// 如果没有编辑过的图片，则取原始图片。
		if(image == nil) {
			image = info[UIImagePickerControllerOriginalImage];
		}
		
		// 如果还是没有，就不管了。
		if(image == nil) {
			return;
		}
		
		CGSize imageSize = [image size];
		CGFloat imageWidth = imageSize.width;
		CGFloat imageHeight = imageSize.height;
		
		if(imageWidth <= 0 || imageHeight <= 0) {
			return;
		}
		
		// 最终图片要求：正方形，边长不大于320。如果不满足，就需要修图。
		if(!(imageWidth == imageHeight && imageWidth <= 320)) {
			CGFloat imageSideLength = MIN(imageWidth, imageHeight);
			CGFloat fixedImageSideLength = MIN(imageSideLength, 320);
			CGFloat scale = fixedImageSideLength / imageSideLength;
			
			UIGraphicsBeginImageContext(CGSizeMake(fixedImageSideLength, fixedImageSideLength));
			[image drawInRect: CGRectMake((fixedImageSideLength - imageWidth * scale) / 2, (fixedImageSideLength - imageHeight * scale) / 2, fixedImageSideLength, fixedImageSideLength)];
			image = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
		}
		
		{
			NSURL* requestUrl = getPortraitUploadingUrl();
			NSLog(@"URL - %@", requestUrl);
			
			NSMutableDictionary* requestParameters = [[NSMutableDictionary alloc] init];
			[requestParameters setValue: [[_environment user] accessToken] forKey: @"access_token"];
			
			NSString* requestString = NSStringFromJsonObject(requestParameters);
			NSLog(@"IN - %@", requestString);
			
			ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL: requestUrl];
			[request setDelegate: self];
			[request setPostValue: requestString forKey: @"data"];
			[request setData: UIImagePNGRepresentation(image) withFileName: nil andContentType: @"image/png" forKey: @"icon"];
			[request startAsynchronous];
			
			_portraitRequest = request;
		}
		
		{
			ACMessageDialog* dialog = [[ACMessageDialog alloc] init];
			[dialog setMessage: @"正在上传头像，请稍候……"];
			[dialog setDismissHandler: ^(ACMessageDialog* dialog) {
				if(dialog == _nickNameDialog) {
					_nickNameDialog = nil;
					
					[_nickNameRequest clearDelegatesAndCancel];
					_nickNameRequest = nil;
				}
			}];
			[dialog show];
			
			_portraitDialog = dialog;
		}
	}
}

- (void)imagePickerControllerDidCancel: (UIImagePickerController*)picker {
	if(picker == _portraitImagePickerController) {
		_portraitImagePickerController = nil;
		
		[picker dismissViewControllerAnimated: TRUE completion: NULL];
	}
}

- (void)dealloc {
	[_environment removeObserver: self forKeyPath: @"user.portraitImageFile"];
	[_environment removeObserver: self forKeyPath: @"user.nickName"];
	[_environment removeObserver: self forKeyPath: @"user.mobile"];
	[_environment removeObserver: self forKeyPath: @"user.vehicle.number"];
	
	if(_vehicleListRequest != nil) {
		[_vehicleListRequest clearDelegatesAndCancel];
	}
	
	if(_portraitRequest != nil) {
		[_portraitRequest clearDelegatesAndCancel];
	}
	
	if(_nickNameAlertView != nil) {
		[_nickNameAlertView setDelegate: nil];
		[_nickNameAlertView dismissWithClickedButtonIndex: -1 animated: FALSE];
	}
	
	if(_nickNameRequest != nil) {
		[_nickNameRequest clearDelegatesAndCancel];
	}
}

@end
