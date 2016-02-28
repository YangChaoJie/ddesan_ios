#import "DDOrderListViewController.h"

#import "ACMessageDialog.h"
#import "ASIFormDataRequest.h"
#import "DDCampaign.h"
#import "DDCampaigningStation.h"
#import "DDDefinitions.h"
#import "DDEnvironment.h"
#import "DDHotCampaignViewController.h"
#import "DDOrderCell.h"
#import "DDOrderConfirmationViewController.h"
#import "DDOrderFinishedViewController.h"
#import "DDOrderOfflineViewController.h"
#import "DDOrderRecord.h"
#import "DDOrderViewController.h"
#import "DDStation.h"
#import "DDUser.h"
#import "DDUtilities.h"
#import "NSObject+JsonParsing.h"

#define ORDER_KEY @"ORDER"

#define ORDER_CELL_REUSE_IDENTIFIER @"ORDER"

#pragma mark -

@interface DDOrderListViewController()<ASIHTTPRequestDelegate, UITableViewDataSource, UITableViewDelegate> {
	IBOutlet UIButton* _backButton;
	
	IBOutletCollection(UIButton) NSArray* _conditionTabButtons;
	
	IBOutlet UIButton* _unlimitedTabButton;
	IBOutlet UIButton* _unfinishedOnlyTabButton;
	IBOutlet UIButton* _finishedOnlyTabButton;
	
	IBOutlet UITableView* _orderTableView;
	IBOutlet UILabel* _orderLoadingLabel;
	IBOutlet UILabel* _orderMissingLabel;
	
	BOOL _debuted;
	
	NSMutableArray* _orderRecords;
	
	ASIHTTPRequest* _orderListRequest;
	NSInteger _orderListNextPageIndex;
	
	ASIHTTPRequest* _orderCancelationRequest;
	ACMessageDialog* _orderCancelationDialog;
	
	NSInteger _selectedCondition;
	
	UIView* _orderTableViewFooter;
    
    
    //
    
    //add by YCJ 2015-12-01
    
    ASIHTTPRequest* _loginRequest;
    NSDictionary* _data;
}

@end

#pragma mark -

@implementation DDOrderListViewController

- (instancetype)init {
	self = [super init];
	if(self != nil) {
		[super view];
		
		_orderRecords = [[NSMutableArray alloc] init];
		
		[self selectCondition: 0];
	}
	
	return self;
}

//获得油号
-(void)getConfigData{
    NSURL * requestUrl =getConfigListUrlTwo();
    //NSURL* requestUrl = [NSURL URLWithString:@"http://101.251.231.130:8001/api/config/getProductSetting"];
    
    
    ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL: requestUrl];
    [request setDelegate: self];
    [request setPostValue: nil forKey: @"data"];
    
    _loginRequest = request; // 由于是同步请求，类变量赋值必须放在请求开始前。
    
    [request startSynchronous];
    
    
}



- (IBAction)handleButton: (UIButton*)button {
	if(button == _backButton) {
		[self goBack];
		
		return;
	}
	
	if([_conditionTabButtons containsObject: button]) {
		[self selectCondition: [button tag]];
		
		return;
	}
}

- (void)selectCondition: (NSInteger)condition {
	for(UIButton* conditionTabButton in _conditionTabButtons) {
		if([conditionTabButton tag] == condition) {
			[conditionTabButton setSelected: TRUE];
			[conditionTabButton setUserInteractionEnabled: FALSE];
		}
		else {
			[conditionTabButton setSelected: FALSE];
			[conditionTabButton setUserInteractionEnabled: TRUE];
		}
	}
	
	_selectedCondition = condition;
	
	// 页面已经展示的话需要在此重新加载数据，否则等待准备展示时加载。
	if(_debuted) {
		[self refreshContents];
	}
}

- (void)refreshContents {
	[_orderRecords removeAllObjects];
	[_orderTableView reloadData];
	
	_orderListNextPageIndex = 0;
	[self queryForOrderList];
}

- (void)queryForOrderList {
	if(_orderListNextPageIndex < 0) {
		return;
	}
	
	{
		NSURL* requestUrl = getOrderListUrl();
		NSLog(@"URL - %@", requestUrl);
		
		NSMutableDictionary* requestParameters = [[NSMutableDictionary alloc] init];
		[requestParameters setValue: [[NSNumber alloc] initWithInteger: _selectedCondition] forKey: @"order_status"];
		[requestParameters setValue: [[NSNumber alloc] initWithInteger: _orderListNextPageIndex] forKey: @"page"];
		[requestParameters setValue: [[[DDEnvironment sharedInstance] user] accessToken] forKey: @"access_token"];
		
		NSString* requestString = NSStringFromJsonObject(requestParameters);
		NSLog(@"IN - %@", requestString);
		
		ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL: requestUrl];
		[request setDelegate: self];
		[request setPostValue: requestString forKey: @"data"];
		[request startAsynchronous];
		
		_orderListRequest = request;
	}
	
	{
		_orderTableViewFooter = _orderLoadingLabel;
		
		[_orderTableView reloadData];
	}
}

- (void)queryToCancelOrder: (DDOrderRecord*)orderRecord {
	{
		NSURL* requestUrl = getOrderCancelationUrl();
		NSLog(@"URL - %@", requestUrl);
		
		NSMutableDictionary* requestParameters = [[NSMutableDictionary alloc] init];
		[requestParameters setValue: [orderRecord code] forKey: @"order_code"];
		[requestParameters setValue: [[[DDEnvironment sharedInstance] user] accessToken] forKey: @"access_token"];
		
		NSString* requestString = NSStringFromJsonObject(requestParameters);
		NSLog(@"IN - %@", requestString);
		
		ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL: requestUrl];
		[request setDelegate: self];
		[request setPostValue: requestString forKey: @"data"];
		[request setUserInfo: @{ ORDER_KEY: orderRecord }];
		[request startAsynchronous];
		
		_orderCancelationRequest = request;
	}
	
	{
		ACMessageDialog* dialog = [[ACMessageDialog alloc] init];
		[dialog setMessage: @"正在撤销订单，请稍候……"];
		[dialog setDismissHandler: ^(ACMessageDialog* dialog) {
			if(dialog == _orderCancelationDialog) {
				_orderCancelationDialog = nil;
				
				[_orderCancelationRequest clearDelegatesAndCancel];
				_orderCancelationRequest = nil;
			}
		}];
		[dialog show];
		
		_orderCancelationDialog = dialog;
	}
}

- (void)goOrderWithOrderRecord: (DDOrderRecord*)orderRecord {
	DDOrderViewController* orderViewController = [[DDOrderViewController alloc] initWithOrderRecord: orderRecord Dictary:_data];
	[self push: orderViewController animated: TRUE];
}

- (void)goOrderConfirmationWithOrderRecord: (DDOrderRecord*)orderRecord {
	DDOrderConfirmationViewController* orderConfirmationViewController = [[DDOrderConfirmationViewController alloc] initWithOrderRecord: orderRecord Dictary:_data];
	[self push: orderConfirmationViewController animated: TRUE];
}

- (void)goOrderOfflineWithOrderRecord: (DDOrderRecord*)orderRecord {
	DDOrderOfflineViewController* orderOfflineViewController = [[DDOrderOfflineViewController alloc] initWithOrderRecord: orderRecord Dictary:_data];
	[orderOfflineViewController setModifyButtonEnabled: TRUE];
	[self push: orderOfflineViewController animated: TRUE];
}

- (void)goOrderFinishedWithOrderRecord: (DDOrderRecord*)orderRecord {
	DDOrderFinishedViewController* orderFinishedViewController = [[DDOrderFinishedViewController alloc] initWithOrderRecord: orderRecord Dictray:_data];
	[self push: orderFinishedViewController animated: TRUE];
}

- (void)viewWillAppear: (BOOL)animated {
	[super viewWillAppear: animated];
    
    //add by YCJ
	[self getConfigData];
    
	[self refreshContents];
	
	_debuted = TRUE;
}

- (void)requestFinished: (ASIHTTPRequest*)request {
    
    //判断是否为获得油号的请求
    if (request==_loginRequest) {
        NSData* responseData = [request responseData];
        NSDictionary*responseString=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:0];
        //NSString* responseString = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
        
        
        _data=[responseString objectForKey:@"data"];
        NSLog(@"OUT - %@", _data);
    }else{
	if(request == _orderListRequest) {
		_orderListRequest = nil;
		
		_orderTableViewFooter = nil;
		_orderListNextPageIndex = -1;
		
		int httpStatusCode = [request responseStatusCode];
		if(httpStatusCode != 200) {
			NSLog(@"HTTP - %d", httpStatusCode);
			
			alert(@"无法获取订单列表（接口返回无效状态）。");
			
			return;
		}
		
		NSData* responseData = [request responseData];
		NSString* responseString = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
		NSLog(@"OUT - %@", responseString);
		
		NSDictionary* responseParameters = [[NSJSONSerialization JSONObjectWithData: responseData options: 0 error: NULL] asDictionary];
		if(responseParameters == nil) {
			alert(@"无法获取订单列表（接口返回格式不正确）。");
			
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
					errorMessage = @"无法获取订单列表（发生未知错误）。";
				}
				
				alert(errorMessage);
			}
			
			return;
		}
		
		NSDictionary* jsonData = [responseParameters[@"data"] asDictionary];
		
		NSArray* jsonOrderList = [jsonData[@"orders"] asArray];
		for(NSObject* jsonOrder in jsonOrderList) {
			DDOrderRecord* orderRecord = DDOrderRecordFromJsonObject([jsonOrder asDictionary]);
			if(orderRecord != nil) {
				[_orderRecords addObject: orderRecord];
			}
		}
		
		NSNumber* jsonNextPageIndex = [jsonData[@"next_page"] asNumber];
		_orderListNextPageIndex = jsonNextPageIndex != nil ? [jsonNextPageIndex integerValue] : -1;
		
		if(_orderListNextPageIndex < 0 && [_orderRecords count] == 0) {
			_orderTableViewFooter = _orderMissingLabel;
		}
		
		[_orderTableView reloadData];
		
		return;
	}
	
	if(request == _orderCancelationRequest) {
		_orderCancelationRequest = nil;
		
		[_orderCancelationDialog dismiss];
		_orderCancelationDialog = nil;
		
		int httpStatusCode = [request responseStatusCode];
		if(httpStatusCode != 200) {
			NSLog(@"HTTP - %d", httpStatusCode);
			
			alert(@"无法撤销订单（接口返回无效状态）。");
			
			return;
		}
		
		NSData* responseData = [request responseData];
		NSString* responseString = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
		NSLog(@"OUT - %@", responseString);
		
		NSDictionary* responseParameters = [[NSJSONSerialization JSONObjectWithData: responseData options: 0 error: NULL] asDictionary];
		if(responseParameters == nil) {
			alert(@"无法撤销订单（接口返回格式不正确）。");
			
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
					errorMessage = @"无法撤销订单（发生未知错误）。";
				}
				
				alert(errorMessage);
			}
			
			return;
		}
		
		alert(@"已成功撤销订单。");
		
		DDOrderRecord* orderRecord = [request userInfo][ORDER_KEY];
		[orderRecord setState: [[NSNumber alloc] initWithInteger: DDOrderRecordStateCanceled]];
		[_orderTableView reloadData];
		
		return;
	}
}
}
- (void)requestFailed: (ASIHTTPRequest*)request {
	if(request == _orderListRequest) {
		_orderListRequest = nil;
		
		_orderTableViewFooter = nil;
		_orderListNextPageIndex = -1;
		
		alert(@"无法获取订单列表（网络连接失败）。");
		
		if(_orderListNextPageIndex < 0 && [_orderRecords count] == 0) {
			_orderTableViewFooter = _orderMissingLabel;
		}
		
		[_orderTableView reloadData];
		
		return;
	}
	
	if(request == _orderCancelationRequest) {
		_orderCancelationRequest = nil;
		
		[_orderCancelationDialog dismiss];
		_orderCancelationDialog = nil;
		
		alert(@"无法撤销订单（网络连接失败）。");
		
		return;
	}
}

- (NSInteger)tableView: (UITableView*)tableView numberOfRowsInSection: (NSInteger)section {
	if(tableView == _orderTableView) {
		if(section == 0) {
			NSInteger rowCount = [_orderRecords count];
			
			if(_orderTableViewFooter != nil) {
				rowCount++;
			}
			
			return rowCount;
		}
		
		return 0;
	}
	
	return 0;
}

- (UITableViewCell*)tableView: (UITableView*)tableView cellForRowAtIndexPath: (NSIndexPath*)indexPath {
	if(tableView == _orderTableView) {
		NSInteger section = [indexPath section];
		if(section == 0) {
			NSInteger row = [indexPath row];
			
			if(row < [_orderRecords count]) {
				DDOrderRecord* orderRecord = _orderRecords[row];
				
				DDOrderCell* cell = [tableView dequeueReusableCellWithIdentifier: ORDER_CELL_REUSE_IDENTIFIER];
				if(cell == nil) {
					cell = [[NSBundle mainBundle] loadNibNamed: NSStringFromClass([DDOrderCell class]) owner: nil options: nil][0];
				}
				
				[cell setOrderRecord: orderRecord Dictary:_data];
				
				return cell;
			}
			else {
				UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: nil];
				[[cell contentView] addSubview: _orderTableViewFooter];
				[_orderTableViewFooter setFrame: [[_orderTableViewFooter superview] bounds]];
				
				return cell;
			}
		}
		
		return nil;
	}
	
	return nil;
}

- (CGFloat)tableView: (UITableView*)tableView heightForRowAtIndexPath: (NSIndexPath*)indexPath {
	if(tableView == _orderTableView) {
		NSInteger section = [indexPath section];
		NSInteger row = [indexPath row];
		
		if(section == 0) {
			if(row >= [_orderRecords count]) {
				return CGRectGetHeight([_orderTableViewFooter frame]);
			}
		}
		
		return [tableView rowHeight];
	}
	
	return [tableView rowHeight];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	if(tableView == _orderTableView) {
		NSInteger section = [indexPath section];
		if(section == 0) {
			NSInteger row = [indexPath row];
			if(row < [_orderRecords count]) {
				return TRUE;
			}
			else {
				return FALSE;
			}
		}
		
		return TRUE;
	}
	
	return TRUE;
}

- (NSIndexPath*)tableView: (UITableView*)tableView willSelectRowAtIndexPath: (NSIndexPath*)indexPath {
	if(tableView == _orderTableView) {
		NSInteger section = [indexPath section];
		if(section == 0) {
			NSInteger row = [indexPath row];
			if(row < [_orderRecords count]) {
				DDOrderRecord* orderRecord = _orderRecords[row];
				
				switch((DDOrderRecordState)[[orderRecord state] integerValue]) {
					case DDOrderRecordStateBooking:
					{
						[self goOrderWithOrderRecord: orderRecord];
						
						break;
					}
					
					case DDOrderRecordStateProcessing:
					{
						[self goOrderOfflineWithOrderRecord: orderRecord];
						
						break;
					}
					
					case DDOrderRecordStateFinished:
					{
						[self goOrderFinishedWithOrderRecord: orderRecord];
						
						break;
					}
					
					default:
					{
						// Do nothing.
						
						break;
					}
				}
			}
			
			return nil;
		}
		
		return indexPath;
	}
	
	return indexPath;
}

- (NSString*)tableView: (UITableView*)tableView titleForDeleteConfirmationButtonForRowAtIndexPath: (NSIndexPath*)indexPath {
	if(tableView == _orderTableView) {
		return @"撤销订单";
	}
	
	return nil;
}

- (BOOL)tableView: (UITableView*)tableView canEditRowAtIndexPath: (NSIndexPath *)indexPath {
	if(tableView == _orderTableView) {
		NSInteger section = [indexPath section];
		if(section == 0) {
			NSInteger row = [indexPath row];
			if(row < [_orderRecords count]) {
				DDOrderRecord* orderRecord = _orderRecords[row];
				switch((DDOrderRecordState)[[orderRecord state] integerValue]) {
					case DDOrderRecordStateProcessing:
					case DDOrderRecordStateBooking:
					return TRUE;
					
					default:
					return FALSE;
				}
			}
			
			return FALSE;
		}
		
		return FALSE;
	}
	
	return FALSE;
}

- (void)tableView: (UITableView *)tableView commitEditingStyle: (UITableViewCellEditingStyle)editingStyle forRowAtIndexPath: (NSIndexPath*)indexPath {
	if(tableView == _orderTableView) {
		NSInteger section = [indexPath section];
		if(section == 0) {
			NSInteger row = [indexPath row];
			DDOrderRecord* orderRecord = _orderRecords[row];
			[self queryToCancelOrder: orderRecord];
			
			return;
		}
		
		return;
	}
}

- (void)scrollViewDidScroll: (UIScrollView*)scrollView {
	if(scrollView == _orderTableView) {
		if([scrollView contentOffset].y >= [scrollView contentSize].height - CGRectGetHeight([scrollView bounds])) {
			if(_orderListRequest == nil) {
				[self queryForOrderList];
			}
		}
		
		return;
	}
}

- (void)dealloc {
	if(_orderListRequest != nil) {
		[_orderListRequest clearDelegatesAndCancel];
	}
}

@end
