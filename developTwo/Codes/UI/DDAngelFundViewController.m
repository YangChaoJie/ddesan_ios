#import "DDAngelFundViewController.h"

#import "ASIFormDataRequest.h"
#import "DDAngelIncomeCell.h"
#import "DDAngelOutcomeCell.h"
#import "DDDefinitions.h"
#import "DDEnvironment.h"
#import "DDIncomeRecord.h"
#import "DDLoginViewController.h"
#import "DDOutcomeRecord.h"
#import "DDRootViewController.h"
#import "DDUser.h"
#import "DDUtilities.h"
#import "NSObject+JsonParsing.h"

#define INCOME_CELL_REUSE_IDENTIFIER @"INCOME"
#define OUTCOME_CELL_REUSE_IDENTIFIER @"OUTCOME"

#pragma mark -

@interface DDAngelFundViewController()<ASIHTTPRequestDelegate, UITableViewDataSource, UITableViewDelegate> {
	IBOutlet UIButton* _backButton;
	
	IBOutletCollection(UIButton) NSArray* _tabButtons;
	IBOutlet UIButton* _incomeTabButton;
	IBOutlet UIButton* _outcomeTabButton;
	
	IBOutlet UILabel* _balanceLabel;
	
	IBOutlet UIView* _incomePanel;
	IBOutlet UITableView* _incomeTableView;
	
	IBOutlet UIView* _outcomePanel;
	IBOutlet UITableView* _outcomeTableView;
	
	NSArray* _incomeRecords;
	NSArray* _outcomeRecords;
	
	ASIHTTPRequest* _balanceRequest;
	ASIHTTPRequest* _incomeListRequest;
	ASIHTTPRequest* _outcomeListRequest;
}

@end

#pragma mark -

@implementation DDAngelFundViewController

- (instancetype)init {
	self = [super init];
	if(self != nil) {
		[super view];
			
		{
			NSURL* requestUrl = getBalanceUrl();
			NSLog(@"URL - %@", requestUrl);
			
			NSDictionary* requestParameters = [[NSMutableDictionary alloc] init];
			[requestParameters setValue: [[[DDEnvironment sharedInstance] user] accessToken] forKey: @"access_token"];
			
			NSString* requestString = NSStringFromJsonObject(requestParameters);
			NSLog(@"IN - %@", requestString);
			
			ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL: requestUrl];
			[request setDelegate: self];
			[request setPostValue: requestString forKey: @"data"];
			[request startAsynchronous];
			
			_balanceRequest = request;
		}
			
		{
			NSURL* requestUrl = getIncomeListUrl();
			NSLog(@"URL - %@", requestUrl);
			
			NSDictionary* requestParameters = [[NSMutableDictionary alloc] init];
			[requestParameters setValue: [[[DDEnvironment sharedInstance] user] accessToken] forKey: @"access_token"];
			
			NSString* requestString = NSStringFromJsonObject(requestParameters);
			NSLog(@"IN - %@", requestString);
			
			ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL: requestUrl];
			[request setDelegate: self];
			[request setPostValue: requestString forKey: @"data"];
			[request startAsynchronous];
			
			_incomeListRequest = request;
		}
			
		{
			NSURL* requestUrl = getOutcomeListUrl();
			NSLog(@"URL - %@", requestUrl);
			
			NSDictionary* requestParameters = [[NSMutableDictionary alloc] init];
			[requestParameters setValue: [[[DDEnvironment sharedInstance] user] accessToken] forKey: @"access_token"];
			
			NSString* requestString = NSStringFromJsonObject(requestParameters);
			NSLog(@"IN - %@", requestString);
			
			ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL: requestUrl];
			[request setDelegate: self];
			[request setPostValue: requestString forKey: @"data"];
			[request startAsynchronous];
			
			_outcomeListRequest = request;
		}
	}
	
	return self;
}

- (IBAction)handleButton: (UIButton*)button {
	if(button == _backButton) {
		[self goBack];
		
		return;
	}
	
	if(button == _incomeTabButton) {
		[self selectTabButton: _incomeTabButton];
		
		return;
	}
	
	if(button == _outcomeTabButton) {
		[self selectTabButton: _outcomeTabButton];
		
		return;
	}
}

- (void)selectTabButton: (UIButton*)selectedTabButton {
	for(UIButton* tabButton in _tabButtons) {
		if(tabButton == selectedTabButton) {
			[tabButton setSelected: TRUE];
			[tabButton setUserInteractionEnabled: FALSE];
		}
		else {
			[tabButton setSelected: FALSE];
			[tabButton setUserInteractionEnabled: TRUE];
		}
	}
	
	[_incomePanel setHidden: selectedTabButton != _incomeTabButton];
	
	[_outcomePanel setHidden: selectedTabButton != _outcomeTabButton];
}

- (void)requestFinished: (ASIHTTPRequest*)request {
	if(request == _balanceRequest) {
		_balanceRequest = nil;
		
		int httpStatusCode = [request responseStatusCode];
		if(httpStatusCode != 200) {
			NSLog(@"HTTP - %d", httpStatusCode);
			
			alert(@"无法取得余额（接口返回无效状态）。");
			
			return;
		}
		
		NSData* responseData = [request responseData];
		NSString* responseString = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
		NSLog(@"OUT - %@", responseString);
		
		NSDictionary* responseParameters = [NSJSONSerialization JSONObjectWithData: responseData options: 0 error: NULL];
		if(responseParameters == nil) {
			alert(@"无法取得余额（接口返回格式错误）。");
			
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
					errorMessage = @"无法取得余额（发生未知错误）。";
				}
				
				alert(errorMessage);
			}
			
			return;
		}
		
		NSNumber* balance = [[responseParameters[@"data"] asDictionary][@"point"] asNumber];
		[_balanceLabel setText: [[NSString alloc] initWithFormat: @"¥%.02f", [balance doubleValue]]];
		
		return;
	}
	
	if(request == _incomeListRequest) {
		_incomeListRequest = nil;
		
		int httpStatusCode = [request responseStatusCode];
		if(httpStatusCode != 200) {
			NSLog(@"HTTP - %d", httpStatusCode);
			
			alert(@"无法取得收入记录（接口返回无效状态）。");
			
			return;
		}
		
		NSData* responseData = [request responseData];
		NSString* responseString = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
		NSLog(@"OUT - %@", responseString);
		
		NSDictionary* responseParameters = [[NSJSONSerialization JSONObjectWithData: responseData options: 0 error: NULL] asDictionary];
		if(responseParameters == nil) {
			alert(@"无法取得收入记录（接口返回格式错误）。");
			
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
					errorMessage = @"无法取得收入记录（发生未知错误）。";
				}
				
				alert(errorMessage);
			}
			
			return;
		}
		
		NSArray* jsonIncomeRecordList = [responseParameters[@"data"] asArray];
		
		NSMutableArray* incomeRecords = [[NSMutableArray alloc] init];
		for(NSObject* jsonIncomeRecord in jsonIncomeRecordList) {
			DDIncomeRecord* incomeRecord = DDIncomeRecordFromJsonObject([jsonIncomeRecord asDictionary]);
			if(incomeRecord != nil) {
				[incomeRecords addObject: incomeRecord];
			}
		}
		
		_incomeRecords = incomeRecords;
		[_incomeTableView reloadData];
		
		return;
	}
	
	if(request == _outcomeListRequest) {
		_outcomeListRequest = nil;
		
		int httpStatusCode = [request responseStatusCode];
		if(httpStatusCode != 200) {
			NSLog(@"HTTP - %d", httpStatusCode);
			
			alert(@"无法取得支出记录（接口返回无效状态）。");
			
			return;
		}
		
		NSData* responseData = [request responseData];
		NSString* responseString = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
		NSLog(@"OUT - %@", responseString);
		
		NSDictionary* responseParameters = [NSJSONSerialization JSONObjectWithData: responseData options: 0 error: NULL];
		if(responseParameters == nil) {
			alert(@"无法取得（接口返回格式错误）。");
			
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
					errorMessage = @"无法取得支出记录（发生未知错误）。";
				}
				
				alert(errorMessage);
			}
			
			return;
		}
		
		NSArray* jsonOutcomeRecordList = [responseParameters[@"data"] asArray];
		
		NSMutableArray* outcomeRecords = [[NSMutableArray alloc] init];
		for(NSObject* jsonOutcomeRecord in jsonOutcomeRecordList) {
			DDOutcomeRecord* outcomeRecord = DDOutcomeRecordFromJsonObject([jsonOutcomeRecord asDictionary]);
			if(outcomeRecord != nil) {
				[outcomeRecords addObject: outcomeRecord];
			}
		}
		
		_outcomeRecords = outcomeRecords;
		[_outcomeTableView reloadData];
		
		return;
	}
}

- (void)requestFailed: (ASIHTTPRequest*)request {
	if(request == _balanceRequest) {
		_balanceRequest = nil;
		
		alert(@"无法取得余额（网络连接失败）。");
		
		return;
	}
}

- (NSInteger)tableView: (UITableView*)tableView numberOfRowsInSection: (NSInteger)section {
	if(tableView == _incomeTableView) {
		if(section == 0) {
			return [_incomeRecords count];
		}
		
		return 0;
	}
	
	if(tableView == _outcomeTableView) {
		if(section == 0) {
			return [_outcomeRecords count];
		}
		
		return 0;
	}
	
	return 0;
}

- (UITableViewCell*)tableView: (UITableView*)tableView cellForRowAtIndexPath: (NSIndexPath*)indexPath {
	if(tableView == _incomeTableView) {
		NSInteger section = [indexPath section];
		if(section == 0) {
			NSInteger row = [indexPath row];
			
			DDAngelIncomeCell* cell = [tableView dequeueReusableCellWithIdentifier: INCOME_CELL_REUSE_IDENTIFIER];
			if(cell == nil) {
				cell = [[NSBundle mainBundle] loadNibNamed: NSStringFromClass([DDAngelIncomeCell class]) owner: nil options: 0][0];
			}
			
			DDIncomeRecord* incomeRecord = _incomeRecords[row];
			[cell setIncomeRecord: incomeRecord];
			
			return cell;
		}
		
		return nil;
	}
	
	if(tableView == _outcomeTableView) {
		NSInteger section = [indexPath section];
		if(section == 0) {
			NSInteger row = [indexPath row];
			
			DDAngelOutcomeCell* cell = [tableView dequeueReusableCellWithIdentifier: INCOME_CELL_REUSE_IDENTIFIER];
			if(cell == nil) {
				cell = [[NSBundle mainBundle] loadNibNamed: NSStringFromClass([DDAngelOutcomeCell class]) owner: nil options: 0][0];
			}
			
			DDOutcomeRecord* outcomeRecord = _outcomeRecords[row - 1];
			[cell setOutcomeRecord: outcomeRecord];
			
			return cell;
		}
		
		return nil;
	}
	
	return nil;
}

- (void)dealloc {
	if(_balanceRequest != nil) {
		[_balanceRequest clearDelegatesAndCancel];
	}
	
	if(_incomeListRequest != nil) {
		[_incomeListRequest clearDelegatesAndCancel];
	}
	
	if(_outcomeListRequest != nil) {
		[_outcomeListRequest clearDelegatesAndCancel];
	}
}

@end
