#import "DDPasswordChangeViewController.h"

#import "ACMessageDialog.h"
#import "ASIFormDataRequest.h"
#import "DDDefinitions.h"
#import "DDEnvironment.h"
#import "DDUser.h"
#import "DDUtilities.h"
#import "NSObject+JsonParsing.h"

@interface DDPasswordChangeViewController()<ASIHTTPRequestDelegate, UITextFieldDelegate> {
	IBOutlet UIButton* _backButton;
	
	IBOutlet UITextField* _oldPasswordField;
	IBOutlet UITextField* _newPasswordField;
	
	IBOutlet UIButton* _submitButton;
	
	ASIHTTPRequest* _passwordChangeRequest;
	ACMessageDialog* _passwordChangeDialog;
}

@end

#pragma mark -

@implementation DDPasswordChangeViewController

- (instancetype)init {
	self = [super init];
	if(self != nil) {
		[super view];
		
		// 修正文本框边框，使其变浅。
		{
			UITextField* fields[] = { _oldPasswordField, _newPasswordField };
			int fieldCount = sizeof(fields) / sizeof(UITextField*);
			for(int fieldIndex = 0; fieldIndex < fieldCount; fieldIndex++) {
				UITextField* field = fields[fieldIndex];
				[field setBackground: [UIImage imageNamed: @"common~white_color"]];
				
				CALayer* layer = [field layer];
				[layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
				[layer setBorderWidth: 1];
			}
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
		[self queryForPasswordChange];
		
		return;
	}
}

- (void)queryForPasswordChange {
	NSString* oldPassword = [_oldPasswordField text];
	if(!isValidPassword(oldPassword)) {
		alert(@"请输入正确的旧密码。");
		
		[_oldPasswordField becomeFirstResponder];
		
		return;
	}
	
	NSString* newPassword = [_newPasswordField text];
	if(!isValidPassword(newPassword)) {
		alert(@"请输入至少6位长度的新密码。");
		
		[_newPasswordField becomeFirstResponder];
		
		return;
	}
	
	{
		NSURL* requestUrl = getPasswordChangeUrl();
		NSLog(@"URL - %@", requestUrl);
		
		NSMutableDictionary* requestParameters = [[NSMutableDictionary alloc] init];
		[requestParameters setValue: [[[DDEnvironment sharedInstance] user] accessToken] forKey: @"access_token"];
		[requestParameters setValue: oldPassword forKey: @"password"];
		[requestParameters setValue: newPassword forKey: @"new_password"];
		
		NSString* requestString = NSStringFromJsonObject(requestParameters);
		NSLog(@"IN - %@", requestString);
		
		ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL: requestUrl];
		[request setDelegate: self];
		[request setPostValue: requestString forKey: @"data"];
		[request startAsynchronous];
		
		_passwordChangeRequest = request;
	}
	
	{
		ACMessageDialog* dialog = [[ACMessageDialog alloc] init];
		[dialog setMessage: @"正在修改密码，请稍候……"];
		[dialog setCancelButtonTitle: @"取消"];
		[dialog setDismissHandler: ^(ACMessageDialog* dialog) {
			if(dialog == _passwordChangeDialog) {
				_passwordChangeDialog = nil;
				
				[_passwordChangeRequest clearDelegatesAndCancel];
				_passwordChangeRequest = nil;
			}
		}];
		[dialog show];
		
		_passwordChangeDialog = dialog;
	}
}

- (void)requestFinished: (ASIHTTPRequest*)request {
	if(request == _passwordChangeRequest) {
		_passwordChangeRequest = nil;
		
		[_passwordChangeDialog dismiss];
		_passwordChangeDialog = nil;
		
		int httpStatusCode = [request responseStatusCode];
		if(httpStatusCode != 200) {
			NSLog(@"HTTP - %d", httpStatusCode);
			
			alert(@"无法修改密码（接口返回无效状态）。");
			
			return;
		}
		
		NSData* responseData = [request responseData];
		NSString* responseString = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
		NSLog(@"OUT - %@", responseString);
		
		NSDictionary* responseParameters = [NSJSONSerialization JSONObjectWithData: responseData options: 0 error: NULL];
		if(responseParameters == nil) {
			alert(@"无法修改密码（接口返回格式错误）。");
			
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
					errorMessage = @"无法修改密码（发生未知错误）。";
				}
				
				alert(errorMessage);
			}
			
			return;
		}
		
		[self popAnimated: TRUE];
		
		return;
	}
}

- (void)requestFailed: (ASIHTTPRequest*)request {
	if(request == _passwordChangeRequest) {
		_passwordChangeRequest = nil;
		
		[_passwordChangeDialog dismiss];
		_passwordChangeDialog = nil;
		
		alert(@"无法修改密码（网络连接失败）。");
		
		return;
	}
}

- (BOOL)textFieldShouldReturn: (UITextField*)textField {
	[textField resignFirstResponder];
	
	return TRUE;
}

- (void)dealloc {
	if(_passwordChangeRequest != nil) {
		[_passwordChangeRequest clearDelegatesAndCancel];
	}
}

@end
