#import "DDVehicleTypeViewController.h"

#import "ASIFormDataRequest.h"
#import "DDDefinitions.h"
#import "DDUtilities.h"
#import "DDVehicleBrand.h"
#import "DDVehicleSeries.h"
#import "DDUserVehicleViewController.h"
#import "NSObject+JsonParsing.h"

#define TRANSITION_DURATION (NSTimeInterval)0.3

#define BRAND_CELL_REUSE_IDENTIFIER @"BRAND"
#define SERIES_CELL_REUSE_IDENTIFIER @"SERIES"

#pragma mark -

@interface DDVehicleTypeViewController()<ASIHTTPRequestDelegate, UITableViewDataSource, UITableViewDelegate> {
	IBOutlet UIButton* _backButton;
	
	IBOutlet UITableView* _brandTableView;
	IBOutlet UITableView* _seriesTableView;
	
	IBOutlet UIActivityIndicatorView* _loadingIndicator;
	
	NSMutableArray* _brandCategories; // 项：首字母（类型：NSString）。
	NSMutableDictionary* _categorizedBrands; // 键：首字母（类型：NSString） 值：品牌数组（类型：NSArray<DDVehicleBrand>）。
	
	DDVehicleBrand* _selectedBrand;
	NSMutableArray* _seriesList; // 项：车系（类型：DDVehicleSeries）。
	
	ASIHTTPRequest* _brandListRequest;
	ASIHTTPRequest* _seriesListRequest;
}

@end

#pragma mark -

@implementation DDVehicleTypeViewController

- (instancetype)init {
	self = [super init];
	if(self != nil) {
		[super view];
		
		_brandCategories = [[NSMutableArray alloc] init];
		_categorizedBrands = [[NSMutableDictionary alloc] init];
		
		_seriesList = [[NSMutableArray alloc] init];
		
		[self queryForBrandList];
	}
	
	return self;
}

- (IBAction)handleButton: (UIButton*)button {
	if(button == _backButton) {
		[self goBack];
		
		return;
	}
}

- (void)queryForBrandList {
	[_brandCategories removeAllObjects];
	[_categorizedBrands removeAllObjects];
	
	NSURL* requestUrl = getVehicleTypeListUrl();
	NSLog(@"URL - %@", requestUrl);
	
	NSDictionary* requestParameters = @{ @"p_id": @"" };
	NSString* requestString = NSStringFromJsonObject(requestParameters);
	NSLog(@"IN - %@", requestString);
	
	ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL: requestUrl];
	[request setDelegate: self];
	[request setPostValue: requestString forKey: @"data"];
	[request startAsynchronous];
	
	_brandListRequest = request;
	
	[_loadingIndicator startAnimating];
}

- (void)queryForSeriesList {
	assert(_selectedBrand != nil);
	
	[_seriesList removeAllObjects];
	
	NSURL* requestUrl = getVehicleTypeListUrl();
	NSLog(@"URL - %@", requestUrl);
	
	NSDictionary* requestParameters = @{ @"p_id": [_selectedBrand code] };
	NSString* requestString = NSStringFromJsonObject(requestParameters);
	NSLog(@"IN - %@", requestString);
	
	ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL: requestUrl];
	[request setDelegate: self];
	[request setPostValue: requestString forKey: @"data"];
	[request startAsynchronous];
	
	_seriesListRequest = request;
	
	[_loadingIndicator startAnimating];
}

- (void)requestFinished: (ASIHTTPRequest*)request {
	if(request == _brandListRequest) {
		_brandListRequest = nil;
		[_loadingIndicator stopAnimating];
		
		NSData* responseData = [request responseData];
		NSString* responseString = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
		NSLog(@"OUT - %@", responseString);
		
		NSDictionary* responseParameters = [NSJSONSerialization JSONObjectWithData: responseData options: 0 error: NULL];
		if(responseParameters == nil) {
			alert(@"无法获取品牌列表（接口返回格式错误）。");
			
			return;
		}
		
		NSString* responseStatus = [responseParameters[@"status"] asString];
		if(![[responseStatus lowercaseString] isEqualToString: @"ok"]) {
			NSString* errorMessage = [[responseParameters[@"error"] asDictionary][@"msg"] asString];
			if(errorMessage == nil) {
				errorMessage = @"无法获取品牌列表（发生未知错误）。";
			}
			
			alert(errorMessage);
			
			return;
		}
		
		NSArray* jsonBrandTree = [responseParameters[@"data"] asArray];
		for(NSObject* element in jsonBrandTree) {
			NSDictionary* jsonBrandNode = [element asDictionary];
			for(NSObject* key in [jsonBrandNode allKeys]) {
				NSString* initial = [key asString];
				if(initial == nil) {
					continue;
				}
				
				NSObject* value = jsonBrandNode[key];
				NSArray* jsonBrandList = [value asArray];
				if(jsonBrandList == nil) {
					continue;
				}
				
				NSMutableArray* brands = [[NSMutableArray alloc] init];
				for(NSObject* element in jsonBrandList) {
					NSDictionary* jsonBrand = [element asDictionary];
					if(jsonBrand == nil) {
						continue;
					}
					
					DDVehicleBrand* brand = DDVehicleBrandFromJsonObject(jsonBrand);
					if(brand == nil) {
						continue;
					}
					
					[brands addObject: brand];
				}
				
				[_brandCategories addObject: initial];
				_categorizedBrands[initial] = brands;
			}
		}
		
		[_brandTableView reloadData];
		
		return;
	}
	
	if(request == _seriesListRequest) {
		_seriesListRequest = nil;
		[_loadingIndicator stopAnimating];
		
		NSData* responseData = [request responseData];
		NSString* responseString = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
		NSLog(@"OUT - %@", responseString);
		
		NSDictionary* responseParameters = [NSJSONSerialization JSONObjectWithData: responseData options: 0 error: NULL];
		if(responseParameters == nil) {
			alert(@"无法获取车系列表（接口返回格式错误）。");
			
			return;
		}
		
		NSString* responseStatus = [responseParameters[@"status"] asString];
		if(![[responseStatus lowercaseString] isEqualToString: @"ok"]) {
			NSString* errorMessage = [[responseParameters[@"error"] asDictionary][@"msg"] asString];
			if(errorMessage == nil) {
				errorMessage = @"无法获取车系列表（发生未知错误）。";
			}
			
			alert(errorMessage);
			
			return;
		}
		
		NSArray* jsonSeriesList = [responseParameters[@"data"] asArray];
		for(NSObject* element in jsonSeriesList) {
			NSDictionary* jsonSeries = [element asDictionary];
			if(jsonSeries == nil) {
				continue;
			}
			
			DDVehicleSeries* series = DDVehicleSeriesFromJsonObject(jsonSeries);
			if(series == nil) {
				continue;
			}
			
			[_seriesList addObject: series];
		}
		
		[_seriesTableView reloadData];
		
		// 把车系列表移到屏幕外右方。
		{
			CGRect frame = [_seriesTableView frame];
			frame.origin.x = frame.size.width;
			[_seriesTableView setFrame: frame];
		}
		[_seriesTableView setHidden: FALSE];
		
		// 将车系列表滑入。
		[UIView transitionWithView: _seriesTableView duration: TRANSITION_DURATION options: 0 animations: ^ {
			CGRect frame = [_seriesTableView frame];
			frame.origin.x = 0;
			[_seriesTableView setFrame: frame];
		} completion: NULL];
		
		return;
	}
}

- (void)requestFailed: (ASIHTTPRequest*)request {
	if(request == _brandListRequest) {
		_brandListRequest = nil;
		[_loadingIndicator stopAnimating];
		
		alert(@"无法获取品牌列表（网络连接失败）。");
		
		return;
	}
	
	if(request == _seriesListRequest) {
		_seriesListRequest = nil;
		[_loadingIndicator stopAnimating];
		
		alert(@"无法获取车系列表（网络连接失败）。");
		
		return;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if(tableView == _brandTableView) {
		return [_brandCategories count];
	}
	
	if(tableView == _seriesTableView) {
		return 1;
	}
	
	return 0;
}

- (NSInteger)tableView: (UITableView*)tableView numberOfRowsInSection: (NSInteger)section {
	if(tableView == _brandTableView) {
		NSString* initial = _brandCategories[section];
		NSArray* brands = _categorizedBrands[initial];
		NSInteger count = [brands count];
		
		return count;
	}
	
	if(tableView == _seriesTableView) {
		assert(section == 0);
		
		NSInteger count = [_seriesList count];
		
		return count;
	}
	
	return 0;
}

- (NSString*)tableView: (UITableView*)tableView titleForHeaderInSection: (NSInteger)section {
	if(tableView == _brandTableView) {
		NSString* initial = _brandCategories[section];
		
		return initial;
	}
	
	return nil;
}

- (NSArray*)sectionIndexTitlesForTableView: (UITableView *)tableView {
	if(tableView == _brandTableView) {
		return _brandCategories;
	}
	
	return nil;
}

- (UITableViewCell*)tableView: (UITableView*)tableView cellForRowAtIndexPath: (NSIndexPath*)indexPath {
	if(tableView == _brandTableView) {
		NSInteger section = [indexPath section];
		NSInteger row = [indexPath row];
		
		NSString* initial = _brandCategories[section];
		NSArray* brands = _categorizedBrands[initial];
		DDVehicleBrand* brand = brands[row];
		
		UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: BRAND_CELL_REUSE_IDENTIFIER];
		if(cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: BRAND_CELL_REUSE_IDENTIFIER];
		}
		[[cell textLabel] setText: [brand name]];
		
		return cell;
	}
	
	if(tableView == _seriesTableView) {
		NSInteger row = [indexPath row];
		
		DDVehicleSeries* series = _seriesList[row];
		
		UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: SERIES_CELL_REUSE_IDENTIFIER];
		if(cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: SERIES_CELL_REUSE_IDENTIFIER];
		}
		[[cell textLabel] setText: [series name]];
		
		return cell;
	}
	
	return nil;
}

- (void)tableView: (UITableView*)tableView didSelectRowAtIndexPath: (NSIndexPath*)indexPath {
	if(tableView == _brandTableView) {
		[tableView deselectRowAtIndexPath: indexPath animated: FALSE];
		
		NSInteger section = [indexPath section];
		NSInteger row = [indexPath row];
		
		NSString* initial = _brandCategories[section];
		NSArray* brands = _categorizedBrands[initial];
		DDVehicleBrand* brand = brands[row];
		
		_selectedBrand = brand;
		[self queryForSeriesList];
		
		return;
	}
	
	if(tableView == _seriesTableView) {
		[tableView deselectRowAtIndexPath: indexPath animated: FALSE];
	
		NSInteger row = [indexPath row];
		DDVehicleSeries* selectedSeries = _seriesList[row];
		
		DDChildViewController* previousViewController = [self previousViewController];
		if([previousViewController isKindOfClass: [DDUserVehicleViewController class]]) {
			DDUserVehicleViewController* vehicleViewController = (DDUserVehicleViewController*)previousViewController;
			[vehicleViewController setVehicleBrand: _selectedBrand];
			[vehicleViewController setVehicleSeries: selectedSeries];
		}
		
		[self popAnimated: TRUE];
		
		return;
	}
}

- (void)goBack {
	if(_selectedBrand != nil) {
		_selectedBrand = nil;
		[_seriesList removeAllObjects];
		
		// 将车系列表滑出。
		[UIView transitionWithView: _seriesTableView duration: TRANSITION_DURATION options: 0 animations: ^ {
			CGRect frame = [_seriesTableView frame];
			frame.origin.x = frame.size.width;
			[_seriesTableView setFrame: frame];
		} completion: ^(BOOL finished) {
			[_seriesTableView reloadData];
		}];
	}
	else {
		[super goBack];
	}
}

- (void)dealloc {
	if(_brandListRequest != nil) {
		[_brandListRequest clearDelegatesAndCancel];
	}
	
	if(_seriesListRequest != nil) {
		[_seriesListRequest clearDelegatesAndCancel];
	}
}

@end
