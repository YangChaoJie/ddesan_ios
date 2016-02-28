#import "DDPasswordResetViewController.h"

#import "ACMessageDialog.h"
#import "ASIFormDataRequest.h"
#import "DDDefinitions.h"
#import "DDEnvironment.h"
#import "DDLoginViewController.h"
#import "DDRootViewController.h"
#import "DDUtilities.h"
#import "NSObject+JsonParsing.h"

#define TIMER_INTERVAL (NSTimeInterval)0.1

#pragma mark -

@interface DDPasswordResetViewController() {
	IBOutlet UIButton* _backButton;
	
	IBOutlet UITextField* _mobileField;
	IBOutlet UITextField* _verificationField;
	IBOutlet UIButton* _verifyButton;
	IBOutlet UITextField* _passwordField;
	IBOutlet UITextField* _repeatedPasswordField;
	
	IBOutlet UIButton* _submitButton;
	
	DDEnvironment* _environment;
	
	ASIHTTPRequest* _verificationRequest;
	NSTimer* _verificationTimer;
	
	ASIHTTPRequest* _passwordResetRequest;
	ACMessageDialog* _passwordResetDialog;
}

@end

#pragma mark -

@interface DDLoginViewController() {
@package
	UITextField* _mobileField;
	UITextField* _passwordField;
	
	UIButton* _submitButton;
}

- (void)handleButton: (UIButton*)button;

@end

#pragma mark -

@implementation DDPasswordResetViewController

- (instancetype)init {
	self = [super init];
	if(self != nil) {
		[super view];
		
		// 修正文本框边框，使其变浅。
		{
			UITextField* fields[] = { _mobileField, _verificationField, _passwordField, _repeatedPasswordField };
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
		[_environment addObserver: self forKeyPath: @"verificationDate" options: 0 context: NULL];
		
		[self updateVerifyButton];
	}
	
	return self;
}

- (IBAction)handleButton: (UIButton*)button {
	if(button == _backButton) {
		[self goBack];
		
		return;
	}
	
	if(button == _verifyButton) {
		[self queryForVerification];
		
		return;
	}
	
	if(button == _submitButton) {
		[self queryForPasswordReset];
		
		return;
	}
}

- (void)updateVerifyButton {
	if(_verificationTimer != nil) {
		[_verificationTimer invalidate];
		_verificationTimer = nil;
	}
	
	NSTimeInterval cooldownBeforeNextVerification = [_environment cooldownBeforeNextVerification];
	if(cooldownBeforeNextVerification == 0) {
		[_verifyButton setEnabled: TRUE];
	}
	else {
		[_verifyButton setEnabled: FALSE];
		
		_verificationTimer = [NSTimer scheduledTimerWithTimeInterval: TIMER_INTERVAL target: self selector: @selector(handleTimer:) userInfo: nil repeats: TRUE];
		[_verificationTimer fire];
	}
}

- (void)handleTimer: (NSTimer*)timer {
	if(timer == _verificationTimer) {
		NSTimeInterval cooldownBeforeNextVerification = [_environment cooldownBeforeNextVerification];
		if(cooldownBeforeNextVerification == 0) {
			[_verificationTimer invalidate];
			_verificationTimer = nil;
			
			[_verifyButton setTitle: nil forState: UIControlStateDisabled];
			[_verifyButton setEnabled: TRUE];
		}
		else {
			NSString* title = [[NSString alloc] initWithFormat: @"%.0f秒", floor(cooldownBeforeNextVerification)];
			[_verifyButton setTitle: title forState: UIControlStateDisabled];
		}
		
		return;
	}
}

- (void)queryForVerification {
	NSString* mobile = [_mobileField text];
	if(!isValidMobile(mobile)) {
		alert(@"请输入正确的手机号。");
		
		return;
	}
	
	[_environment setVerificationDate: [[NSDate alloc] init]];
	
	{
		NSURL* requestUrl = getVerificationUrl();
		NSLog(@"URL - %@", requestUrl);
		
		NSDictionary* requestParameters = @{ @"phone": mobile, @"use_type": @2 };
		NSString* requestString = NSStringFromJsonObject(requestParameters);
		NSLog(@"IN - %@", requestString);
		
		ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL: requestUrl];
		[request setDelegate: self];
		[request setPostValue: NSStringFromJsonObject(requestParameters) forKey: @"data"];
		[request startAsynchronous];
		
		_verificationRequest = request;
	}
}

- (void)queryForPasswordReset {
	NSString* mobile = [_mobileField text];
//	if(!isValidMobile(mobile)) {
//		alert(@"请输入正确的手机号。");
//		
//		[_mobileField becomeFirstResponder];
//		
//		return;
//	}
	
	NSString* verification = [_verificationField text];
	if(!isValidVerification(verification)) {
		alert(@"请输入正确的验证码。");
		
		[_verificationField becomeFirstResponder];
		
		return;
	}
	
	NSString* password = [_passwordField text];
	if(!isValidPassword(password)) {
		alert(@"请输入至少6位长度的密码。");
		
		[_passwordField becomeFirstResponder];
		
		return;
	}
	
	NSString* repeatedPassword = [_repeatedPasswordField text];
	if(![repeatedPassword isEqualToString: password]) {
		alert(@"密码和确认密码不一致。");
		
		[_repeatedPasswordField becomeFirstResponder];
		
		return;
	}
	
	{
		NSURL* requestUrl = getPasswordResetUrl();
		NSLog(@"URL - %@", requestUrl);
		
		NSDictionary* requestParameters = @{ @"phone": mobile, @"chk_code": verification, @"password": password };
		NSString* requestString = NSStringFromJsonObject(requestParameters);
		NSLog(@"IN - %@", requestString);
		
		ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL: requestUrl];
		[request setDelegate: self];
		[request setPostValue: requestString forKey: @"data"];
		[request startAsynchronous];
		
		_passwordResetRequest = request;
	}
	
	{
		ACMessageDialog* dialog = [[ACMessageDialog alloc] init];
		[dialog setMessage: @"正在进行注册，请稍候……"];
		[dialog setCancelButtonTitle: @"取消"];
		[dialog setDismissHandler: ^(ACMessageDialog* dialog) {
			if(dialog == _passwordResetDialog) {
				_passwordResetDialog = nil;
				
				[_passwordResetRequest clearDelegatesAndCancel];
				_passwordResetRequest = nil;
			}
		}];
		[dialog show];
		
		_passwordResetDialog = dialog;
		
	}
}

- (void)observeValueForKeyPath: (NSString*)keyPath ofObject: (id)object change: (NSDictionary*)change context: (void*)context {
	if(object == _environment) {
		if([keyPath isEqualToString: @"verificationDate"]) {
			[self updateVerifyButton];
			
			return;
		}
		
		return;
	}
}

- (void)requestFinished: (ASIHTTPRequest*)request {
	if(request == _verificationRequest) {
		_verificationRequest = nil;
		
		int httpStatusCode = [request responseStatusCode];
		if(httpStatusCode != 200) {
			NSLog(@"HTTP - %d", httpStatusCode);
			
			alert(@"无法获取手机验证码（接口返回无效状态）。");
			
			return;
		}
		
		NSData* responseData = [request responseData];
		NSString* responseString = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
		NSLog(@"OUT - %@", responseString);
		
		NSDictionary* responseParameters = [[NSJSONSerialization JSONObjectWithData: responseData options: 0 error: NULL] asDictionary];
		if(responseParameters == nil) {
			alert(@"无法获取手机验证码（接口返回格式错误）。");
			
			return;
		}
		
		NSString* responseStatus = [responseParameters[@"status"] asString];
		if(![[responseStatus lowercaseString] isEqualToString: @"ok"]) {
			NSString* errorMessage = [[responseParameters[@"error"] asDictionary][@"msg"] asString];
			if(errorMessage == nil) {
				errorMessage = @"无法获取手机验证码（发生未知错误）。";
			}
			
			alert(errorMessage);
			
			return;
		}
		
		alert(@"验证码已发送，请耐心等待短信通知。");
		
		return;
	}
	
	if(request == _passwordResetRequest) {
		_passwordResetRequest = nil;
		
		[_passwordResetDialog dismiss];
		_passwordResetDialog = nil;
		
		int httpStatusCode = [request responseStatusCode];
		if(httpStatusCode != 200) {
			NSLog(@"HTTP - %d", httpStatusCode);
			
			alert(@"无法重置密码（接口返回无效状态）。");
			
			return;
		}
		
		NSData* responseData = [request responseData];
		NSString* responseString = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
		NSLog(@"OUT - %@", responseString);
		
		NSDictionary* responseParameters = [[NSJSONSerialization JSONObjectWithData: responseData options: 0 error: NULL] asDictionary];
		if(responseParameters == nil) {
			alert(@"无法重置密码（接口返回格式错误）。");
			
			return;
		}
		
		NSString* responseStatus = [responseParameters[@"status"] asString];
		if(![[responseStatus lowercaseString] isEqualToString: @"ok"]) {
			NSString* errorMessage = [[responseParameters[@"error"] asDictionary][@"msg"] asString];
			if(errorMessage == nil) {
				errorMessage = @"无法重置密码（发生未知错误）。";
			}
			
			alert(errorMessage);
			
			return;
		}
		
		// 必须在本页弹出动画开始前取得上页。
		DDLoginViewController* loginViewController = (DDLoginViewController*)[self previousViewController];
		
		[self popAnimated: FALSE];
		
		[loginViewController->_mobileField setText: [_mobileField text]];
		[loginViewController->_passwordField setText: [_passwordField text]];
		[loginViewController handleButton: loginViewController->_submitButton];

		return;
	}
}

- (void)requestFailed: (ASIHTTPRequest*)request {
	if(request == _verificationRequest) {
		_verificationRequest = nil;
		
		alert(@"无法获取手机验证码（网络连接失败）。");
		
		return;
	}
	
	if(request == _passwordResetRequest) {
		_passwordResetRequest = nil;
		
		[_passwordResetDialog dismiss];
		_passwordResetDialog = nil;
		
		alert(@"无法重置密码（网络连接失败）。");
		
		return;
	}
}

- (BOOL)textFieldShouldReturn: (UITextField*)textField {
	[textField resignFirstResponder];
	
	return TRUE;
}

- (void)dealloc {
	[_environment removeObserver: self forKeyPath: @"verificationDate"];
	
	if(_verificationTimer != nil) {
		[_verificationTimer invalidate];
	}
	
	if(_passwordResetRequest != nil) {
		[_passwordResetRequest clearDelegatesAndCancel];
	}
}

@end
