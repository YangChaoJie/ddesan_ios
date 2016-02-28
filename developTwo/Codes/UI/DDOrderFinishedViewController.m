#import "DDOrderFinishedViewController.h"

#import "ACConfirmingDialog.h"
#import "ACMessageDialog.h"
#import "ASIFormDataRequest.h"
#import "DDDefinitions.h"
#import "DDEnvironment.h"
#import "DDOrderRecord.h"
#import "DDSharing.h"
#import "DDStation.h"
#import "DDUser.h"
#import "DDUtilities.h"
#import "NSObject+JsonParsing.h"

#define SCORE_KEY @"SCORE"
#define COMPLAINT_KEY @"COMPLAINT"

static NSString* formatDate(NSDate* date) {
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat: @"yyyy年M月d日 HH:mm"];
	[dateFormatter setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: 28800]];
	
	NSString* string = [dateFormatter stringFromDate: date];
	
	return string;
}

#pragma mark -

@interface DDOrderFinishedViewController()<UIActionSheetDelegate> {
	DDOrderRecord* _orderRecord;
	
	IBOutlet UIButton* _backButton;
	
	IBOutlet UILabel* _dateLabel;
	
	IBOutlet UILabel* _tubeLabel;
	IBOutlet UILabel* _stationLabel;
	IBOutlet UILabel* _fuelTypeLabel;
	IBOutlet UILabel* _amountLabel;
	IBOutlet UILabel* _originalPriceLabel;
	IBOutlet UILabel* _discountageLabel;
	IBOutlet UILabel* _discountedPriceLabel;
	
	IBOutlet UILabel* _operatorLabel;
	
	IBOutlet UIButton* _scoreButton;
	IBOutlet UIButton* _shareButton;
	IBOutlet UIButton* _complaintButton;
	
	IBOutlet UIView* _scorePanel;
	IBOutletCollection(UIButton) NSArray* _scoreStarButtons;
	IBOutlet UIButton* _scoreCancelButton;
	IBOutlet UIButton* _scoreConfirmButton;
	
	IBOutlet UIView* _complaintPanel;
	IBOutlet UITextView* _complaintTextView;
	IBOutlet UIButton* _complaintCancelButton;
	IBOutlet UIButton* _complaintConfirmButton;
	
	ASIHTTPRequest* _scoringRequest;
	ACMessageDialog* _scoringDialog;
	
	ASIHTTPRequest* _complainingRequest;
	ACMessageDialog* _complainingDialog;
}

@end

#pragma mark -

@implementation DDOrderFinishedViewController

- (instancetype)initWithOrderRecord: (DDOrderRecord*)orderRecord Dictray:(NSDictionary *)dict{
    self.dict=dict;
	self = [super init];
	if(self != nil) {
		_orderRecord = orderRecord;
		
		[super view];
		
		NSDate* paymentDate = [_orderRecord paymentDate];
		[_dateLabel setText: formatDate(paymentDate)];
		
		NSNumber* tubeNumber = [_orderRecord tubeNumber];
		if(tubeNumber != nil) {
			[_tubeLabel setText: [[NSString alloc] initWithFormat: @"%d#油枪", [tubeNumber intValue]]];
		}
		
		NSString* stationName = [[_orderRecord station] name];
		[_stationLabel setText: [[NSString alloc] initWithFormat: @"付予：%@", stationName]];
		
		NSString* fuelType = [_orderRecord fuelType];
        //加
        NSString*s =[self.dict objectForKey:fuelType];
		[_fuelTypeLabel setText: s];
		
		double fuelAmount = [[_orderRecord fuelAmount] doubleValue];
		[_amountLabel setText: [[NSString alloc] initWithFormat: @"%.2fL", fuelAmount]];
		
		NSInteger originalPrice = [[_orderRecord originalPrice] integerValue];
		NSInteger discountedPrice = [[_orderRecord discountedPrice] integerValue];
		NSInteger discountage = originalPrice - discountedPrice;
		
		[_originalPriceLabel setText: [[NSString alloc] initWithFormat: @"¥%d", (int)originalPrice]];
		[_discountageLabel setText: [[NSString alloc] initWithFormat: @"¥%d", (int)discountage]];
		[_discountedPriceLabel setText: [[NSString alloc] initWithFormat: @"¥%d", (int)discountedPrice]];
		
		[_operatorLabel setText: [_orderRecord operatorName]];
		
		if([_orderRecord score] != nil) {
			[_scoreButton setEnabled: FALSE];
		}
		
		if([_orderRecord complaint] != nil) {
			[_complaintButton setEnabled: FALSE];
		}
		
		{
			CALayer* layer = [_complaintTextView layer];
			[layer setBorderColor: [[UIColor darkGrayColor] CGColor]];
			[layer setBorderWidth: 1];
			[layer setCornerRadius: 5];
		}
	}
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for(UIButton* starButton in _scoreStarButtons) {
        [starButton setSelected: true];
    }
}

- (IBAction)handleButton: (UIButton*)button {
	if(button == _backButton) {
		[self goBack];
		
		return;
	}
	
	if(button == _scoreButton) {
		[_scorePanel setHidden: FALSE];
		
		return;
	}
	
	if(button == _shareButton) {
		[self share];
		
		return;
	}
	
	if(button == _complaintButton) {
		[_complaintPanel setHidden: FALSE];
		
		return;
	}
	
	if([_scoreStarButtons containsObject: button]) {
		NSInteger score = [button tag];
		
		for(UIButton* starButton in _scoreStarButtons) {
			[starButton setSelected: [starButton tag] <= score];
		}
		
		return;
	}
	
	if(button == _scoreCancelButton) {
		[_scorePanel setHidden: TRUE];
		
		return;
	}
	
	if(button == _scoreConfirmButton) {
		[self queryForScoring];
		
		return;
	}
	
	if(button == _complaintCancelButton) {
		[_complaintPanel setHidden: TRUE];
		
		return;
	}
	
	if(button == _complaintConfirmButton) {
		[self queryForComplaining];
		
		return;
	}
}

- (void)share {
	[[DDSharing sharedInstance] share];
}

- (void)queryForScoring {
	NSInteger score = 0;
	for(UIButton* starButton in _scoreStarButtons) {
		if([starButton isSelected]) {
			score++;
		}
	}
	
	if(score == 0) {
		alert(@"请选择星数。");
		
		return;
	}
	
	{
		NSURL* requestUrl = getScoringUrl();
		NSLog(@"URL - %@", requestUrl);
		
		NSDictionary* requestParameters = [[NSMutableDictionary alloc] init];
		[requestParameters setValue: [_orderRecord code] forKey: @"order_code"];
		[requestParameters setValue: [[NSNumber alloc] initWithInteger: score] forKey: @"score"];
		[requestParameters setValue: [[[DDEnvironment sharedInstance] user] accessToken] forKey: @"access_token"];
		
		NSString* requestString = NSStringFromJsonObject(requestParameters);
		NSLog(@"IN - %@", requestString);
		
		ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL: requestUrl];
		[request setDelegate: self];
		[request setPostValue: requestString forKey: @"data"];
		[request setUserInfo: @{ SCORE_KEY: [[NSNumber alloc] initWithInteger: score] }];
		[request startAsynchronous];
		
		_scoringRequest = request;
	}
	
	{
		ACMessageDialog* dialog = [[ACMessageDialog alloc] init];
		[dialog setMessage: @"正在提交评价，请稍候……"];
		[dialog setCancelButtonTitle: @"取消"];
		[dialog setDismissHandler: ^(ACMessageDialog* dialog) {
			if(dialog == _scoringDialog) {
				_scoringDialog = nil;
				
				[_scoringRequest clearDelegatesAndCancel];
				_scoringRequest = nil;
			}
		}];
		[dialog show];
		
		_scoringDialog = dialog;
	}
}

- (void)queryForComplaining {
	NSString* complaint = [_complaintTextView text];
	
	if([complaint length] == 0) {
		alert(@"请输入投诉内容。");
		
		return;
	}
	
	{
		NSURL* requestUrl = getComplainingUrl();
		NSLog(@"URL - %@", requestUrl);
		
		NSDictionary* requestParameters = [[NSMutableDictionary alloc] init];
		[requestParameters setValue: [_orderRecord code] forKey: @"order_code"];
		[requestParameters setValue: complaint forKey: @"complaint"];
		[requestParameters setValue: [[[DDEnvironment sharedInstance] user] accessToken] forKey: @"access_token"];
		
		NSString* requestString = NSStringFromJsonObject(requestParameters);
		NSLog(@"IN - %@", requestString);
		
		ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL: requestUrl];
		[request setDelegate: self];
		[request setPostValue: requestString forKey: @"data"];
		[request setUserInfo: @{ COMPLAINT_KEY: complaint }];
		[request startAsynchronous];
		
		_complainingRequest = request;
	}
	
	{
		ACMessageDialog* dialog = [[ACMessageDialog alloc] init];
		[dialog setMessage: @"正在提交评价，请稍候……"];
		[dialog setCancelButtonTitle: @"取消"];
		[dialog setDismissHandler: ^(ACMessageDialog* dialog) {
			if(dialog == _complainingDialog) {
				_complainingDialog = nil;
				
				[_complainingRequest clearDelegatesAndCancel];
				_complainingRequest = nil;
			}
		}];
		[dialog show];
		
		_complainingDialog = dialog;
	}
	
}

- (void)requestFinished: (ASIHTTPRequest*)request {
	if(request == _scoringRequest) {
		_scoringRequest = nil;
		
		[_scoringDialog dismiss];
		_scoringDialog = nil;
		
		int httpStatusCode = [request responseStatusCode];
		if(httpStatusCode != 200) {
			NSLog(@"HTTP - %d", httpStatusCode);
			
			alert(@"无法提交评价（接口返回无效状态）。");
			
			return;
		}
		
		NSData* responseData = [request responseData];
		NSString* responseString = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
		NSLog(@"OUT - %@", responseString);
		
		NSDictionary* responseParameters = [NSJSONSerialization JSONObjectWithData: responseData options: 0 error: NULL];
		if(responseParameters == nil) {
			alert(@"无法提交评价（接口返回格式错误）。");
			
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
					errorMessage = @"无法提交评价（发生未知错误）。";
				}
				
				alert(errorMessage);
			}
			
			return;
		}
		
		alert(@"已成功提交评价。");
		
		[_orderRecord setScore: [[request userInfo][SCORE_KEY] asNumber]];
		[_scoreButton setEnabled: FALSE];
		[_scorePanel setHidden: TRUE];
		
		return;
	}
	
	if(request == _complainingRequest) {
		_complainingRequest = nil;
		
		[_complainingDialog dismiss];
		_complainingDialog = nil;
		
		int httpStatusCode = [request responseStatusCode];
		if(httpStatusCode != 200) {
			NSLog(@"HTTP - %d", httpStatusCode);
			
			alert(@"无法提交投诉（接口返回无效状态）。");
			
			return;
		}
		
		NSData* responseData = [request responseData];
		NSString* responseString = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
		NSLog(@"OUT - %@", responseString);
		
		NSDictionary* responseParameters = [NSJSONSerialization JSONObjectWithData: responseData options: 0 error: NULL];
		if(responseParameters == nil) {
			alert(@"无法提交投诉（接口返回格式错误）。");
			
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
					errorMessage = @"无法提交投诉（发生未知错误）。";
				}
				
				alert(errorMessage);
			}
			
			return;
		}
		
		alert(@"已成功提交投诉。");
		
		[_orderRecord setComplaint: [[request userInfo][COMPLAINT_KEY] asString]];
		[_complaintButton setEnabled: FALSE];
		[_complaintPanel setHidden: TRUE];
		
		return;
	}
}

- (void)requestFailed: (ASIHTTPRequest*)request {
	if(request == _scoringRequest) {
		_scoringRequest = nil;
		
		[_scoringDialog dismiss];
		_scoringDialog = nil;
		
		alert(@"无法提交评价（网络连接失败）。");
		
		return;
	}
	
	if(request == _complainingRequest) {
		_complainingRequest = nil;
		
		[_complainingDialog dismiss];
		_complainingDialog = nil;
		
		alert(@"无法提交投诉（网络连接失败）。");
		
		return;
	}
}

- (void)dealloc {
	if(_scoringRequest != nil) {
		[_scoringRequest clearDelegatesAndCancel];
	}
	
	if(_complainingRequest != nil) {
		[_complainingRequest clearDelegatesAndCancel];
	}
}

@end
