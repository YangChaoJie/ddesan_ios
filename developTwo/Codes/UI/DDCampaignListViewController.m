#import "DDCampaignListViewController.h"

#import "ASIFormDataRequest.h"
#import "DDCampaigningStation.h"
#import "DDCampaigningStationCell.h"
#import "DDDefinitions.h"
#import "DDEnvironment.h"
#import "DDHotCampaign.h"
#import "DDHotCampaignViewController.h"
#import "DDLoginViewController.h"
#import "DDOrderViewController.h"
#import "DDRegularCampaign.h"
#import "DDStation.h"
#import "DDUser.h"
#import "DDUtilities.h"
#import "NSObject+JsonParsing.h"

#define CAMPAIGNING_STATION_CELL_REUSE_IDENTIFIER @"CAMPAIGNING_STATION"
#define FOOTER_CELL_REUSE_IDENTIFIER @"FOOTER"

#pragma mark -

@interface DDCampaignListViewController()<ASIHTTPRequestDelegate, UITableViewDataSource, UITableViewDelegate> {
	IBOutlet UIButton* _backButton;
	
	IBOutletCollection(UIButton) NSArray* _distanceButtons;
	IBOutlet UIButton* _distanceButton0;
	IBOutlet UIButton* _distanceButton1;
	IBOutlet UIButton* _distanceButton2;
	IBOutlet UIButton* _distanceButton3;
	IBOutlet UIButton* _distanceButton4;
	
	IBOutlet UITableView* _campaignTableView;
	IBOutlet UILabel* _campaignLoadingLabel;
	IBOutlet UILabel* _campaignMissingLabel;
	
	DDEnvironment* _enviroment;
	
	NSMutableArray* _campaigningStations;
	
	ASIHTTPRequest* _campaignListRequest;
	NSInteger _campaignListNextPageIndex;
	
	UIButton* _selectedDistanceButton;
	
	UIView* _campaignTableViewFooter;
	
	BOOL _debuted;
    //add by YCJ 2015-12-01
    
     ASIHTTPRequest* _loginRequest;
     NSDictionary* _data;
    
    
   
    
    
}

@end

#pragma mark -

@implementation DDCampaignListViewController

- (instancetype)init {
	self = [super init];
	if(self != nil) {
		[super view];
		
		_enviroment = [DDEnvironment sharedInstance];
		[_enviroment addObserver: self forKeyPath: @"location" options: 0 context: NULL];
		
		{
			NSArray* selectableDistances = [_enviroment selectableDistances];
			if(selectableDistances != nil) {
				NSInteger distanceCount = [selectableDistances count];
				if(distanceCount > 0) {
					NSNumber* distance = [selectableDistances[0] asNumber];
					if(distance != nil) {
						NSInteger distanceValue = [distance integerValue];
						[_distanceButton0 setTitle: [[NSString alloc] initWithFormat: @"%d", (int)distanceValue] forState: UIControlStateNormal];
						[_distanceButton0 setTag: distanceValue];
					}
				}
				if(distanceCount > 1) {
					NSNumber* distance = [selectableDistances[1] asNumber];
					if(distance != nil) {
						NSInteger distanceValue = [distance integerValue];
						[_distanceButton1 setTitle: [[NSString alloc] initWithFormat: @"%d", (int)distanceValue] forState: UIControlStateNormal];
						[_distanceButton1 setTag: distanceValue];
					}
				}
				if(distanceCount > 2) {
					NSNumber* distance = [selectableDistances[2] asNumber];
					if(distance != nil) {
						NSInteger distanceValue = [distance integerValue];
						[_distanceButton2 setTitle: [[NSString alloc] initWithFormat: @"%d", (int)distanceValue] forState: UIControlStateNormal];
						[_distanceButton2 setTag: distanceValue];
					}
				}
				if(distanceCount > 3) {
					NSNumber* distance = [selectableDistances[3] asNumber];
					if(distance != nil) {
						NSInteger distanceValue = [distance integerValue];
						[_distanceButton3 setTitle: [[NSString alloc] initWithFormat: @"%d", (int)distanceValue] forState: UIControlStateNormal];
						[_distanceButton3 setTag: distanceValue];
					}
				}
			}
		}
		
		_campaigningStations = [[NSMutableArray alloc] init];
		
		{
			NSInteger defaultDistanceIndex = ^NSInteger {
				NSNumber* number = [_enviroment defaultDistanceIndex];
				if(number != nil) {
					NSInteger value = [number integerValue];
					if(value >= 0 && value <= 4) {
						return value;
					}
				}
				
				return 2;
			} ();
			
			[self setSelectedDistanceButton: @[_distanceButton0, _distanceButton1, _distanceButton2, _distanceButton3, _distanceButton4][defaultDistanceIndex]];
		}
	}
	
	return self;
}

- (IBAction)handleButton: (UIButton*)button {
	if(button == _backButton) {
		[self goBack];
		
		return;
	}
	
	if([_distanceButtons containsObject: button]) {
		[self setSelectedDistanceButton: button];
		
		return;
	}
}

- (void)setSelectedDistanceButton: (UIButton*)selectedDistanceButton {
	if(_selectedDistanceButton == selectedDistanceButton) {
		return;
	}
	
	_selectedDistanceButton = selectedDistanceButton;
	
	for(UIButton* distanceButton in _distanceButtons) {
		[distanceButton setSelected: distanceButton == selectedDistanceButton];
	}
	
	// 如果页面已经展示需要在此刷新内容，否则等到页面展示时进行刷新。
	if(_debuted) {
		[self updateLocationAndRange];
	}
}

- (void)updateLocationAndRange {
	CLLocation* location = [_enviroment location];
	if(location != nil) {
		[_campaigningStations removeAllObjects];
		_campaignListNextPageIndex = 0;
		
		[self queryForCampaignList];
	}
	else {
		_campaignTableViewFooter = _campaignMissingLabel;
		
		[_campaignTableView reloadData];
	}
}
//获得油号
-(void)getConfigData{
    //NSURL* requestUrl = [NSURL URLWithString:@"http://101.251.231.130:8001/api/config/getProductSetting"];
    NSURL* requestUrl=getConfigListUrlTwo();
    
    ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL: requestUrl];
    [request setDelegate: self];
    [request setPostValue: nil forKey: @"data"];
    
    _loginRequest = request; // 由于是同步请求，类变量赋值必须放在请求开始前。
    
    [request startSynchronous];
    
    
}
- (void)queryForCampaignList {
    
    
	CLLocation* location = [_enviroment location];
	if(location == nil) {
		return;
	}
	
	if(_selectedDistanceButton == nil) {
		return;
	}
	
	if(_campaignListNextPageIndex < 0) {
		return;
	}
	
	// 上传至接口的坐标应从WGS-84坐标转为BD-09坐标。
//	CLLocationCoordinate2D coordinate = translateCoordinateFromGcj02ToWgs84(translateCoordinateFromBd09ToGcj02([location coordinate]));
//	NSNumber* longitude = [[NSNumber alloc] initWithDouble: coordinate.longitude];
//	NSNumber* latitude = [[NSNumber alloc] initWithDouble: coordinate.latitude];
    
    //  更新用百度SDK提供的坐标转码
    CLLocationCoordinate2D coordinate = translateCoordinateFromWgs84ToBaidu(location.coordinate);
    
    NSString* longitude = [NSString stringWithFormat: @"%.8f", coordinate.longitude];
     NSString* latitude = [NSString stringWithFormat: @"%.8f", coordinate.latitude];
	
	NSNumber* range = [[NSNumber alloc] initWithInteger: [_selectedDistanceButton tag]];
	
	NSNumber* page = [[NSNumber alloc] initWithInteger: _campaignListNextPageIndex];
	
	NSString* accessToken = [[_enviroment user] accessToken];
	
//	// FIXME 为了测试热度活动，去除了accessToken，之后应加回。
//	accessToken = nil;
	
	{
       
    
		NSURL* requestUrl = getCampaignListUrl();
		NSLog(@"URL - %@", requestUrl);
		
		NSMutableDictionary* requestParameters = [[NSMutableDictionary alloc] init];
		[requestParameters setValue: longitude forKey: @"user_lng"];
		[requestParameters setValue: latitude forKey: @"user_lat"];
		[requestParameters setValue: range forKey: @"range"];
		[requestParameters setValue: page forKey: @"page"];
		[requestParameters setValue: accessToken forKey: @"access_token"];
		
		NSString* requestString = NSStringFromJsonObject(requestParameters);
		NSLog(@"IN - %@", requestString);
		
		ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL: requestUrl];
		[request setDelegate: self];
        
		[request setPostValue: requestString forKey: @"data"];
       
		[request startAsynchronous];
		
        
		_campaignListRequest = request;
        
        
        
      
	}
	
	{
		_campaignTableViewFooter = _campaignLoadingLabel;
		
		[_campaignTableView reloadData];
	}
}

- (void)goCampaignWithCampaigningStation: (DDCampaigningStation*)campaigningStation Dictary:(NSDictionary*)dic{
	DDCampaign* campaign = [campaigningStation campaign];
	if([campaign isKindOfClass: [DDHotCampaign class]]) {
		DDHotCampaignViewController* hotCampaignViewController = [[DDHotCampaignViewController alloc] initWithCampaigningStation: campaigningStation Dictary:_data];
		[self push: hotCampaignViewController animated: TRUE];
	}
	else if([campaign isKindOfClass: [DDRegularCampaign class]]) {
		DDOrderViewController* orderViewController = [[DDOrderViewController alloc] initWithCampaigningStation: campaigningStation Dictary:_data];
       
		[self push: orderViewController animated: TRUE];
	}
}

- (void)viewWillAppear: (BOOL)animated {
	[super viewWillAppear: animated];
    
    //新加
    [self getConfigData];
	[self updateLocationAndRange];
	
	_debuted = TRUE;
}

- (void)observeValueForKeyPath: (NSString*)keyPath ofObject: (id)object change: (NSDictionary*)change context: (void*)context {
	if(object == _enviroment) {
		if([keyPath isEqualToString: @"location"]) {
			[self updateLocationAndRange];
			
			return;
		}
		
		return;
	}
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
    
    
	if(request == _campaignListRequest) {
		_campaignListRequest = nil;
		
		_campaignTableViewFooter = nil;
		_campaignListNextPageIndex = -1;
		
		int httpStatusCode = [request responseStatusCode];
		if(httpStatusCode != 200) {
			NSLog(@"HTTP - %d", httpStatusCode);
			
			alert(@"无法获取活动列表（接口返回无效状态）。");
			
			return;
		}
		
		NSData* responseData = [request responseData];
		NSString* responseString =[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:0];
        
		NSLog(@"OUT - 😄☎️🐶😄☎️🐶😄☎️🐶😄☎️🐶😄☎️🐶😄☎️🐶😄☎️🐶%@", responseString);
		
		NSDictionary* responseParameters = [[NSJSONSerialization JSONObjectWithData: responseData options: 0 error: NULL] asDictionary];
		if(responseParameters == nil) {
			alert(@"无法获取活动列表（接口返回格式不正确）。");
			
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
					errorMessage = @"无法获取活动列表（发生未知错误）。";
				}
				
				alert(errorMessage);
			}
			
			return;
		}
		
        
		NSDictionary* jsonData = [responseParameters[@"data"] asDictionary];
		
        //NSLog(@"%@😄😄哈奥😄5❤️❤️",jsonData);
        
		NSArray* jsonCampaigningStationList = [jsonData[@"list"] asArray];
		for(NSObject* jsonCampaigningStation in jsonCampaigningStationList) {
			DDCampaigningStation* campaigningStation = DDCampaigningStationFromJsonObject([jsonCampaigningStation asDictionary]);
            NSLog(@"%@",campaigningStation.station.fuelTypes);
            
            //campaigningStation.station.fuelTypes
			if(campaigningStation != nil) {
				[_campaigningStations addObject: campaigningStation];
			}
		}
		
		NSNumber* jsonNextPageIndex = [jsonData[@"next_page"] asNumber];
		_campaignListNextPageIndex = jsonNextPageIndex != nil ? [jsonNextPageIndex integerValue] : -1;
		
		if(_campaignListNextPageIndex < 0 && [_campaigningStations count] == 0) {
			_campaignTableViewFooter = _campaignMissingLabel;
		}
		
		[_campaignTableView reloadData];
		
		return;
	}
    }
}

- (void)requestFailed: (ASIHTTPRequest*)request {
	if(request == _campaignListRequest) {
		_campaignListRequest = nil;
		
		_campaignTableViewFooter = nil;
		_campaignListNextPageIndex = -1;
		
		alert(@"无法获取活动列表（网络连接失败）。");
		
		if(_campaignListNextPageIndex < 0 && [_campaigningStations count] == 0) {
			_campaignTableViewFooter = _campaignMissingLabel;
		}
		
		[_campaignTableView reloadData];
		
		return;
	}
}

- (NSInteger)tableView: (UITableView*)tableView numberOfRowsInSection: (NSInteger)section {
	if(tableView == _campaignTableView) {
		if(section == 0) {
			NSInteger rowCount = [_campaigningStations count];
			
			if(_campaignTableViewFooter != nil) {
				rowCount++;
			}
			
			return rowCount;
		}
		
		return 0;
	}
	
	return 0;
}

- (UITableViewCell*)tableView: (UITableView*)tableView cellForRowAtIndexPath: (NSIndexPath*)indexPath {
	if(tableView == _campaignTableView) {
		NSInteger section = [indexPath section];
		
		if(section == 0) {
			NSInteger row = [indexPath row];
			
			if(row < [_campaigningStations count]) {
				DDCampaigningStation* campaigningStation = _campaigningStations[row];
				
				DDCampaigningStationCell* cell = [tableView dequeueReusableCellWithIdentifier: CAMPAIGNING_STATION_CELL_REUSE_IDENTIFIER];
				if(cell == nil) {
					cell = [[NSBundle mainBundle] loadNibNamed: NSStringFromClass([DDCampaigningStationCell class]) owner: nil options: nil][0];
				}
				
				[cell setCampaigningStation: campaigningStation Dictionary:_data];
				
				return cell;
			}
			else {
				UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: nil];
				[[cell contentView] addSubview: _campaignTableViewFooter];
				[_campaignTableViewFooter setFrame: [[_campaignTableViewFooter superview] bounds]];
				
				return cell;
			}
		}
		
		return nil;
	}
	
	return nil;
}

- (CGFloat)tableView: (UITableView*)tableView heightForRowAtIndexPath: (NSIndexPath*)indexPath {
	if(tableView == _campaignTableView) {
		NSInteger section = [indexPath section];
		NSInteger row = [indexPath row];
		
		if(section == 0) {
			if(row >= [_campaigningStations count]) {
				return CGRectGetHeight([_campaignTableViewFooter frame]);
			}
		}
		
		return [tableView rowHeight];
	}
	
	return [tableView rowHeight];
}

- (BOOL)tableView: (UITableView*)tableView shouldHighlightRowAtIndexPath: (NSIndexPath*)indexPath {
	if(tableView == _campaignTableView) {
		NSInteger section = [indexPath section];
		if(section == 0) {
			NSInteger row = [indexPath row];
			if(row < [_campaigningStations count]) {
				return TRUE;
			}
			else {
				return FALSE;
			}
		}
	}
	
	return TRUE;
}

- (NSIndexPath*)tableView: (UITableView*)tableView willSelectRowAtIndexPath: (NSIndexPath*)indexPath {
	if(tableView == _campaignTableView) {
		NSInteger section = [indexPath section];
		if(section == 0) {
			NSInteger row = [indexPath row];
			if(row < [_campaigningStations count]) {
				if([_enviroment user] == nil) {
					DDLoginViewController* loginViewController = [[DDLoginViewController alloc] init];
					[self push: loginViewController animated: TRUE];
				}
				else {
					DDCampaigningStation* campaigningStation = [_campaigningStations objectAtIndex: row];
					[self goCampaignWithCampaigningStation: campaigningStation Dictary:_data];
				}
			}
			
			return nil;
		}
		
		return indexPath;
	}
	
	return indexPath;
}

- (void)scrollViewDidScroll: (UIScrollView*)scrollView {
	if(scrollView == _campaignTableView) {
		if([scrollView contentOffset].y >= [scrollView contentSize].height - CGRectGetHeight([scrollView bounds])) {
			if(_campaignListRequest == nil) {
				[self queryForCampaignList];
			}
		}
		
		return;
	}
}

- (void)dealloc {
	[_enviroment removeObserver: self forKeyPath: @"location"];
	
	if(_campaignListRequest != nil) {
		[_campaignListRequest clearDelegatesAndCancel];
	}
}

@end
