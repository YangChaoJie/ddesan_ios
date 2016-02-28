#import "DDUserVehicleViewController.h"

#import "ACMessageDialog.h"
#import "ASIFormDataRequest.h"
#import "DDDefinitions.h"
#import "DDEnvironment.h"
#import "DDUser.h"
#import "DDUtilities.h"
#import "DDVehicle.h"
#import "DDVehicleBrand.h"
#import "DDVehicleSeries.h"
#import "DDVehicleTypeViewController.h"
#import "NSObject+JsonParsing.h"

@interface DDUserVehicleViewController()<ASIHTTPRequestDelegate, UITextFieldDelegate> {
	IBOutlet UIButton* _backButton;
	
	IBOutlet UIButton* _vehicleTypeButton;
	IBOutlet UITextField* _vehicleTypeField;
	
	IBOutlet UIButton* _vehicleNumberButton;
	IBOutlet UITextField* _vehicleNumberField;
	
	IBOutlet UIButton* _saveButton;
	
	ASIHTTPRequest* _userVehicleUpdatingRequest;
	ACMessageDialog* _userVehicleUpdatingDialog;
}

@end

#pragma mark -

@implementation DDUserVehicleViewController

- (instancetype)init {
	self = [super init];
	if(self != nil) {
		[super view];
	}
	
	return self;
}

- (IBAction)handleButton: (UIButton*)button {
	if(button == _backButton) {
		[self goBack];
		
		return;
	}
	
	if(button == _vehicleTypeButton) {
		[self goVehicleType];
		
		return;
	}
	
	if(button == _saveButton) {
		[self queryForUserVehicleUpdating];
		
		return;
	}
}

- (void)setVehicleBrand: (DDVehicleBrand*)vehicleBrand {
	_vehicleBrand = vehicleBrand;
	
	[self updateVehicleTypeField];
	[self updateSaveButton];
}

- (void)setVehicleSeries: (DDVehicleSeries*)vehicleSeries {
	_vehicleSeries = vehicleSeries;
	
	[self updateVehicleTypeField];
	[self updateSaveButton];
}

- (void)setVehicleNumber: (NSString*)vehicleNumber {
	_vehicleNumber = [vehicleNumber copy];
	
	[self updateVehicleNumberField];
	[self updateSaveButton];
}

- (void)queryForUserVehicleUpdating {
	NSString* accessToken = [[[DDEnvironment sharedInstance] user] accessToken];
	// accessToken按理在此时应该不为空，但由于那是外部数据，在此不作断言。
	if(accessToken == nil) {
		return;
	}
	
	assert(_vehicleBrand != nil);
	assert(_vehicleSeries != nil);
	assert(_vehicleNumber != nil);
	
	NSString* brandCode = [_vehicleBrand code];
	// brandCode按理在此时应该不为空，但由于那是外部数据，在此不作断言。
	if(brandCode == nil) {
		return;
	}
	
	NSString* seriesCode = [_vehicleSeries code];
	// seriesCode按理在此时应该不为空，但由于那是外部数据，在此不作断言。
	if(seriesCode == nil) {
		return;
	}
	
	{
		NSURL* requestUrl = getUserVehicleUpdatingUrl();
		NSLog(@"URL - %@", requestUrl);
		
		NSDictionary* requestParameters = @{ @"access_token": accessToken, @"car_brand_1": brandCode, @"car_brand_2": seriesCode, @"car_number": _vehicleNumber };
		NSString* requestString = NSStringFromJsonObject(requestParameters);
		NSLog(@"IN - %@", requestString);
		
		ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL: requestUrl];
		[request setDelegate: self];
		[request setPostValue: requestString forKey: @"data"];
		[request startAsynchronous];
		
		_userVehicleUpdatingRequest = request;
	}
	
	{
		ACMessageDialog* dialog = [[ACMessageDialog alloc] init];
		[dialog setMessage: @"正在更新车辆信息，请稍候……"];
		[dialog setCancelButtonTitle: @"取消"];
		[dialog setDismissHandler: ^(ACMessageDialog* dialog) {
			[_userVehicleUpdatingRequest clearDelegatesAndCancel];
			_userVehicleUpdatingRequest = nil;
		}];
		[dialog show];
		
		_userVehicleUpdatingDialog = dialog;
	}
}

- (void)updateVehicleTypeField {
	NSString* brandName = [_vehicleBrand name];
	NSString* seriesName = [_vehicleSeries name];
	if(brandName != nil && seriesName != nil) {
		[_vehicleTypeField setText: [[NSString alloc] initWithFormat: @"%@ %@", brandName, seriesName]];
	}
	else {
		[_vehicleTypeField setText: nil];
	}
}

- (void)updateVehicleNumberField {
	[_vehicleNumberField setText: _vehicleNumber];
}

- (void)updateSaveButton {
	[_saveButton setEnabled: _vehicleBrand != nil && _vehicleSeries != nil && _vehicleNumber != nil];
}

- (void)goVehicleType {
	DDVehicleTypeViewController* vehicleTypeViewController = [[DDVehicleTypeViewController alloc] init];
	[self push: vehicleTypeViewController animated: TRUE];
}

- (void)requestFinished: (ASIHTTPRequest*)request {
	if(request == _userVehicleUpdatingRequest) {
		_userVehicleUpdatingRequest = nil;
		
		[_userVehicleUpdatingDialog dismiss];
		_userVehicleUpdatingDialog = nil;
		
		NSData* responseData = [request responseData];
		NSString* responseString = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
		NSLog(@"OUT - %@", responseString);
		
		NSDictionary* responseParameters = [NSJSONSerialization JSONObjectWithData: responseData options: 0 error: NULL];
		if(responseParameters == nil) {
			alert(@"无法更新用户车辆（接口返回格式错误）。");
			
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
					errorMessage = @"无法更新用户车辆（发生未知错误）。";
				}
				
				alert(errorMessage);
			}
			
			return;
		}
		
		DDVehicle* vehicle = [[DDVehicle alloc] init];
		[vehicle setBrand: _vehicleBrand];
		[vehicle setSeries: _vehicleSeries];
		[vehicle setNumber: _vehicleNumber];
		[[[DDEnvironment sharedInstance] user] setVehicle: vehicle];
		
		[self popAnimated: TRUE];
		
		return;
	}
}

- (void)requestFailed: (ASIHTTPRequest*)request {
	if(request == _userVehicleUpdatingRequest) {
		_userVehicleUpdatingRequest = nil;
		
		[_userVehicleUpdatingDialog dismiss];
		_userVehicleUpdatingDialog = nil;
		
		alert(@"无法更新用户车辆（网络连接失败）。");
		
		return;
	}
}

- (void)textFieldDidEndEditing: (UITextField*)textField {
	if(textField == _vehicleNumberField) {
		[self setVehicleNumber: [textField text]];
		
		return;
	}
}

- (void)dealloc {
	if(_userVehicleUpdatingRequest != nil) {
		[_userVehicleUpdatingRequest clearDelegatesAndCancel];
	}
}

@end
