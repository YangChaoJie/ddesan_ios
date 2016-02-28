#import "DDLoginViewController.h"

#import "ACMessageDialog.h"
#import "ASIFormDataRequest.h"
#import "DDDefinitions.h"
#import "DDEnvironment.h"
#import "DDPasswordResetViewController.h"
#import "DDRegistryViewController.h"
#import "DDRootViewController.h"
#import "DDUser.h"
#import "DDUtilities.h"
#import "NSObject+JsonParsing.h"

@interface DDLoginViewController()<ASIHTTPRequestDelegate, UITextFieldDelegate> {
	IBOutlet UIButton* _backButton;
	
	IBOutlet UITextField* _mobileField;
	IBOutlet UITextField* _passwordField;
	IBOutlet UIButton* _registerButton;
	IBOutlet UIButton* _passwordResetButton;
	
	IBOutlet UIButton* _submitButton;
	
	DDEnvironment* _environment;
	
	ASIHTTPRequest* _loginRequest;
	ACMessageDialog* _loginDialog;
}

@end

#pragma mark -

@implementation DDLoginViewController

- (instancetype)init {
	self = [super init];
	if(self != nil) {
		[super view];
		
		// 修正文本框边框，使其变浅。
		{
			UITextField* fields[] = { _mobileField, _passwordField };
			int fieldCount = sizeof(fields) / sizeof(UITextField*);
			for(int fieldIndex = 0; fieldIndex < fieldCount; fieldIndex++) {
				UITextField* field = fields[fieldIndex];
				[field setBackground: [UIImage imageNamed: @"common~white_color"]];
				
				CALayer* layer = [field layer];
				[layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
				[layer setBorderWidth: 1];
			}
		}
		
		_environment = [DDEnvironment sharedInstance];
		
		[_mobileField setText: [_environment recentUsername]];
	}
	
	return self;
}

- (IBAction)handleButton: (UIButton*)button {
	if(button == _backButton) {
		[self goBack];
		
		return;
	}
	
	if(button == _registerButton) {
		[self goRegister];
		
		return;
	}
	
	if(button == _passwordResetButton) {
		[self goPasswordReset];
		
		return;
	}
	
	if(button == _submitButton) {
		[self queryForLogin];
		
		return;
	}
}

- (void)goRegister {
	DDRegistryViewController* registryViewController = [[DDRegistryViewController alloc] init];
	[self push: registryViewController animated: TRUE];
}

- (void)goPasswordReset {
	DDPasswordResetViewController* passwordResetViewController = [[DDPasswordResetViewController alloc] init];
	[self push: passwordResetViewController animated: TRUE];
}

- (void)queryForLogin {
	NSString* mobile = [_mobileField text];
//	if(!isValidMobile(mobile)) {
//		alert(@"请输入正确的手机号。");
//		
//		[_mobileField becomeFirstResponder];
//		
//		return;
//	}
	
	NSString* password = [_passwordField text];
	if(!isValidPassword(password)) {
		alert(@"请输入正确的密码。");
		
		[_passwordField becomeFirstResponder];
		
		return;
	}
	
	{
		NSURL* requestUrl = getLoginUrl();
		NSLog(@"URL - %@", requestUrl);
		
		NSDictionary* requestParameters = [[NSMutableDictionary alloc] init];
		[requestParameters setValue: mobile forKey: @"phone"];
		[requestParameters setValue: password forKey: @"password"];
		[requestParameters setValue: @"1" forKey: @"client_type"];
		
		NSString* requestString = NSStringFromJsonObject(requestParameters);
		NSLog(@"IN - %@", requestString);
		
		ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL: requestUrl];
		[request setDelegate: self];
		[request setPostValue: requestString forKey: @"data"];
		[request startAsynchronous];
		
		_loginRequest = request;
	}
	
	{
		ACMessageDialog* dialog = [[ACMessageDialog alloc] init];
		[dialog setMessage: @"正在进行登录，请稍候……"];
		[dialog setCancelButtonTitle: @"取消"];
		[dialog setDismissHandler: ^(ACMessageDialog* dialog) {
			if(dialog == _loginDialog) {
				_loginDialog = nil;
				
				[_loginRequest clearDelegatesAndCancel];
				_loginRequest = nil;
			}
		}];
		[dialog show];
		
		_loginDialog = dialog;
	}
}

- (void)requestFinished: (ASIHTTPRequest*)request {
	if(request == _loginRequest) {
		_loginRequest = nil;
		
		[_loginDialog dismiss];
		_loginDialog = nil;
		
		int httpStatusCode = [request responseStatusCode];
		if(httpStatusCode != 200) {
			NSLog(@"HTTP - %d", httpStatusCode);
			
			alert(@"无法进行登录（接口返回无效状态）。");
			
			return;
		}
		
		NSData* responseData = [request responseData];
		NSString* responseString = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
		NSLog(@"OUT - %@", responseString);
		
		NSDictionary* responseParameters = [NSJSONSerialization JSONObjectWithData: responseData options: 0 error: NULL];
		if(responseParameters == nil) {
			alert(@"无法进行登录（接口返回格式错误）。");
			
			return;
		}
		
		NSString* responseStatus = [responseParameters[@"status"] asString];
		if(![[responseStatus lowercaseString] isEqualToString: @"ok"]) {
			NSString* errorMessage = [[responseParameters[@"error"] asDictionary][@"msg"] asString];
			if(errorMessage == nil) {
				errorMessage = @"无法进行登录（发生未知错误）。";
			}
			
			alert(errorMessage);
			
			return;
		}
			
		DDUser* user = DDUserFromJsonObject(responseParameters[@"data"]);
		[_environment setUser: user];
		
		[_environment setRecentUsername: [_mobileField text]];
		[_environment setRecentPassword: [_passwordField text]];
		
		[self popToRootAnimated: TRUE];
		
		return;
	}
}

- (void)requestFailed: (ASIHTTPRequest*)request {
	if(request == _loginRequest) {
		_loginRequest = nil;
		
		[_loginDialog dismiss];
		_loginDialog = nil;
		
		alert(@"无法进行登录（网络连接失败）。");
		
		return;
	}
}

- (BOOL)textFieldShouldReturn: (UITextField*)textField {
	[textField resignFirstResponder];
	
	return TRUE;
}

- (void)dealloc {
	if(_loginRequest != nil) {
		[_loginRequest clearDelegatesAndCancel];
	}
}

@end
