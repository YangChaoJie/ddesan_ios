#import "DDHotCampaignViewController.h"

#import <MapKit/MapKit.h>
#import "ACMessageDialog.h"
#import "ASIFormDataRequest.h"
#import "DDBookingViewController.h"
#import "DDCampaign.h"
#import "DDCampaigningStation.h"
#import "DDDefinitions.h"
#import "DDEnvironment.h"
#import "DDHotCampaign.h"
#import "DDMapAnnotation.h"
#import "DDOrderRecord.h"
#import "DDOrderViewController.h"
#import "DDRegularCampaign.h"
#import "DDStation.h"
#import "DDUser.h"
#import "DDUtilities.h"
#import "NSObject+JsonParsing.h"

#import "KCCalloutAnnotationView.h"

static NSString* formatTime(NSDate* time) {
	NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
	[timeFormatter setDateFormat: @"HH:mm"];
	
	NSString* string = [timeFormatter stringFromDate: time];
	
	return string;
}

#pragma mark -

@interface DDHotCampaignViewController()<ASIHTTPRequestDelegate,MKMapViewDelegate> {
	DDCampaigningStation* _campaigningStation;
	NSString* _orderCode;
	
	IBOutlet UIButton* _backButton;
	
	IBOutlet UILabel* _stationNameLabel;
	IBOutletCollection(UIButton) NSArray* _starButtons;
	
	IBOutlet UIView* _mapPanel;
	IBOutlet MKMapView* _mapView;
	IBOutlet UIButton* _locateButton;
	
	IBOutlet UILabel* _stationAddressLabel;
	IBOutlet UILabel* _timeConditionLabel;
	
	IBOutlet UILabel* _firstItemLabel;
	IBOutlet UILabel* _secondItemLabel;
	
	IBOutlet UIView* _remainingQuotaPanel;
	IBOutlet UILabel* _remainingQuotaLabel;
	
	IBOutlet UILabel* _exhaustedLabel;
	
	IBOutlet UIView* _bookingSuccessPanel;
	
	IBOutlet UIButton* _bookingButton;
	IBOutlet UIButton* _otherCampaignButton;
	IBOutlet UIButton* _fuelingButton;
	
	ASIHTTPRequest* _stationCampaignListRequest;
	ACMessageDialog* _stationCampaignListDialog;
    
    NSString* _address;
    
    CLLocation* _location;
}

@end

#pragma mark -

@implementation DDHotCampaignViewController
//add by YCJ
- (instancetype)initWithCampaigningStation: (DDCampaigningStation*)campaigningStation Dictary:(NSDictionary*)dic{
    self.dict=dic;
    //NSLog(@"%@",self.dict);
    return [self initWithCampaigningStation: campaigningStation andOrderCode: nil Dictary:dic];
}

- (instancetype)initWithCampaigningStation: (DDCampaigningStation*)campaigningStation {
	return [self initWithCampaigningStation: campaigningStation andOrderCode: nil Dictary:nil];
}

- (instancetype)initWithCampaigningStation: (DDCampaigningStation*)campaigningStation andOrderCode: (NSString*)orderCode Dictary:(NSDictionary*)dic{
    self.dict=dic;
	self = [super init];
	if(self != nil) {
		assert([[campaigningStation campaign] isKindOfClass: [DDHotCampaign class]]);
		
		_campaigningStation = campaigningStation;
		_orderCode = orderCode;
		
		[super view];
		
		DDStation* station = [campaigningStation station];
        _address=station.address;
        _location=station.location;
        
		DDHotCampaign* campaign = (DDHotCampaign*)[campaigningStation campaign];
		
		{
			// 高德地图使用的是GCJ-02坐标，需要转换。
			CLLocationCoordinate2D coordinate = translateCoordinateFromWgs84ToGcj02([[station location] coordinate]);
			
			[_mapView setRegion: [_mapView regionThatFits: MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0, 0))]];
			// alter by YCJ
			DDMapAnnotation* annotion = [[DDMapAnnotation alloc] init];
			[annotion setCoordinate: coordinate];
			[annotion setTitle: [station name]];
            [annotion setImage:[UIImage imageNamed:@"icon_openmap_item@2x.png"]];
           // annotion.image=[UIImage imageNamed:@"icon_openmap_item@2x.png"];
           // annotion.icon=[UIImage imageNamed:@"icon_openmap_item@2x.png"];
             _mapView.delegate=self;
			[_mapView addAnnotation: annotion];
		}
		
		[_stationNameLabel setText: [station name]];
		[_stationAddressLabel setText: [station address]];
		
		NSNumber* score = [station score];
		if(score != nil) {
			NSInteger scoreValue = [score integerValue];
			for(UIButton* starButton in _starButtons) {
				[starButton setSelected: [starButton tag] <= scoreValue];
			}
		}
		
		NSDate* excludingPeriodStart = [campaign excludingPeriodStart];
		NSDate* excludingPeriodEnd = [campaign excludingPeriodEnd];
		if(excludingPeriodStart != nil && excludingPeriodEnd != nil) {
			[_timeConditionLabel setText: [[NSString alloc] initWithFormat: @"%@-%@ 除外", formatTime(excludingPeriodStart), formatTime(excludingPeriodEnd)]];
		}
		else {
			[_timeConditionLabel setText: nil];
		}
		
		NSArray* fuelTypes = [station fuelTypes];
		NSDictionary* fuelPrices = [station fuelPrices];
		NSDictionary* fuelPriceCuts = [campaign fuelPriceCuts];
		
		NSString* fuelType0 = [fuelTypes count] > 0 ? fuelTypes[0] : nil;
        
        NSString* s=[self.dict objectForKey:fuelType0];
        
		if(fuelType0 != nil) {
			NSNumber* fuelPrice0 = fuelPrices[fuelType0];
			NSNumber* fuelPriceCut0 = fuelPriceCuts[fuelType0];
			NSString* fuelInfo0 = [[NSString alloc] initWithFormat: @"%@    ¥%.02f-%.02f", s, [fuelPrice0 doubleValue], [fuelPriceCut0 doubleValue]];
			[_firstItemLabel setText: fuelInfo0];
		}
		else {
			[_firstItemLabel setText: nil];
		}
		
		NSString* fuelType1 = [fuelTypes count] > 1 ? fuelTypes[1] : nil;
         NSString* s1=[self.dict objectForKey:fuelType1];
		if(fuelType1 != nil) {
			NSNumber* fuelPrice1 = fuelPrices[fuelType1];
			NSNumber* fuelPriceCut1 = fuelPriceCuts[fuelType1];
			NSString* fuelInfo1 = [[NSString alloc] initWithFormat: @"%@    ¥%.02f-%.02f", s1, [fuelPrice1 doubleValue], [fuelPriceCut1 doubleValue]];
			[_secondItemLabel setText: fuelInfo1];
		}
		else {
			[_secondItemLabel setText: nil];
		}
		
		NSInteger remainingQuota = [[campaign remainingQuota] integerValue];
		if(remainingQuota > 0) {
			if(_orderCode != nil) {
				[_bookingSuccessPanel setHidden: FALSE];
				
				[_fuelingButton setHidden: FALSE];
			}
			else {
				[_remainingQuotaPanel setHidden: FALSE];
				[_remainingQuotaLabel setText: remainingQuota < 1000 ? [[NSString alloc] initWithFormat: @"%d", (int)remainingQuota] : @"999+"];
				
				[_bookingButton setHidden: FALSE];
			}
		}
		else {
			[_exhaustedLabel setHidden: FALSE];
			
			[_otherCampaignButton setHidden: FALSE];
		}
	}
	
	return self;
}
//===========================================================================================
#pragma mark - 地图控件代理方法
#pragma mark 显示大头针时调用，注意方法中的annotation参数是即将显示的大头针对象
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    //由于当前位置的标注也是一个大头针，所以此时需要判断，此代理方法返回nil使用默认大头针视图
    if ([annotation isKindOfClass:[DDMapAnnotation class]]) {
        static NSString *key1=@"AnnotationKey1";
        MKAnnotationView *annotationView=[_mapView dequeueReusableAnnotationViewWithIdentifier:key1];
        //如果缓存池中不存在则新建
        if (!annotationView) {
            annotationView=[[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:key1];
            //            annotationView.canShowCallout=true;//允许交互点击
            annotationView.calloutOffset=CGPointMake(0, 1);//定义详情视图偏移量
            annotationView.leftCalloutAccessoryView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_classify_cafe.png"]];//定义详情左侧视图
        }
        
        //修改大头针视图
        //重新设置此类大头针视图的大头针模型(因为有可能是从缓存池中取出来的，位置是放到缓存池时的位置)
        annotationView.annotation=annotation;
        annotationView.image=((DDMapAnnotation  *)annotation).image;//设置大头针视图的图片
        
        return annotationView;
    }else if([annotation isKindOfClass:[KCCalloutAnnotation class]]){
        //对于作为弹出详情视图的自定义大头针视图无弹出交互功能（canShowCallout=false，这是默认值），在其中可以自由添加其他视图（因为它本身继承于UIView）
        KCCalloutAnnotationView *calloutView=[KCCalloutAnnotationView calloutViewWithMapView:mapView];
        calloutView.annotationOne=annotation;
        calloutView.address=_address;
        
        
        calloutView.annotationOne.location=_location;
        return calloutView;
    } else {
        return nil;
    }
}

#pragma mark 选中大头针时触发
//点击一般的大头针KCAnnotation时添加一个大头针作为所点大头针的弹出详情视图
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    DDMapAnnotation *annotation=view.annotation;
    if ([view.annotation isKindOfClass:[DDMapAnnotation class]]) {
        //点击一个大头针时移除其他弹出详情视图
        //        [self removeCustomAnnotation];
        //添加详情大头针，渲染此大头针视图时将此模型对象赋值给自定义大头针视图完成自动布局
        KCCalloutAnnotation *annotation1=[[KCCalloutAnnotation alloc]init];
        annotation1.icon=annotation.icon;
        annotation1.detail=annotation.title;
        //annotation1.rate=annotation.rate;
        annotation1.coordinate=view.annotation.coordinate;
        [mapView addAnnotation:annotation1];
    }
}

#pragma mark 取消选中时触发
-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
    [self removeCustomAnnotation];
}

#pragma mark 移除所用自定义大头针
-(void)removeCustomAnnotation{
    [_mapView.annotations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[KCCalloutAnnotation class]]) {
            [_mapView removeAnnotation:obj];
        }
    }];
}
//====================================================================================================



- (IBAction)handleButton: (UIButton*)button {
	if(button == _backButton) {
		[self goBack];
		
		return;
	}
	
	if(button == _locateButton) {
		[_mapView setCenterCoordinate: [[[_campaigningStation station] location] coordinate] animated: TRUE];
		
		return;
	}
	
	if(button == _bookingButton) {
		[self goBooking];
		
		return;
	}
	
	if(button == _otherCampaignButton) {
		[self queryForOtherCampaign];
		
		return;
	}
	
	if(button == _fuelingButton) {
		[self goOrder];
		
		return;
	}
}

//add alter by YCJ
- (void)goBooking {
	DDBookingViewController* bookingViewController = [[DDBookingViewController alloc] initWithCampaigningStation: _campaigningStation Dictary:self.dict];
	[self switchTo: bookingViewController animated: TRUE];
}



- (void)goOrder {
	DDOrderRecord* orderRecord = [[DDOrderRecord alloc] init];
	[orderRecord setCode: _orderCode];
	[orderRecord setState: [[NSNumber alloc] initWithInteger: DDOrderRecordStateBooking]];
	[orderRecord setStation: [_campaigningStation station]];
	[orderRecord setCampaign: [_campaigningStation campaign]];
	
	DDOrderViewController* orderViewController = [[DDOrderViewController alloc] initWithOrderRecord:orderRecord Dictary:self.dict];
	[self switchTo: orderViewController animated: TRUE];
}

- (void)queryForOtherCampaign {
    
	DDStation* station = [_campaigningStation station];
	
	{
		NSURL* requestUrl = getStationCampaignListUrl();
		NSLog(@"URL - %@", requestUrl);
		
		NSMutableDictionary* requestParameters = [[NSMutableDictionary alloc] init];
		[requestParameters setValue: [station id] forKey: @"shop_id"];
		[requestParameters setValue: [[[DDEnvironment sharedInstance] user] accessToken] forKey: @"access_token"];
		
		NSString* requestString = NSStringFromJsonObject(requestParameters);
		NSLog(@"IN - %@", requestString);
		
		ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL: requestUrl];
		[request setDelegate: self];
		[request setPostValue: requestString forKey: @"data"];
		[request startAsynchronous];
		
		_stationCampaignListRequest = request;
	}
	
	{
		ACMessageDialog* dialog = [[ACMessageDialog alloc] init];
		[dialog setMessage: @"正在查询其他活动，请稍候……"];
		[dialog setDismissHandler: ^(ACMessageDialog* dialog) {
			if(_stationCampaignListDialog == dialog) {
				_stationCampaignListDialog = nil;
				
				[_stationCampaignListRequest clearDelegatesAndCancel];
				_stationCampaignListRequest = nil;
			}
		}];
        
		[dialog show];
		
		_stationCampaignListDialog = dialog;
	}
}

- (void)requestFinished: (ASIHTTPRequest*)request {
	if(request == _stationCampaignListRequest) {
		_stationCampaignListRequest = nil;
		
		[_stationCampaignListDialog dismiss];
		_stationCampaignListDialog = nil;
		
		int httpStatusCode = [request responseStatusCode];
		if(httpStatusCode != 200) {
			NSLog(@"HTTP - %d", httpStatusCode);
			
			alert(@"无法获取其他活动（接口返回无效状态）。");
			
			return;
		}
		
		NSData* responseData = [request responseData];
		NSString* responseString = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
		NSLog(@"OUT - %@", responseString);
		
		NSDictionary* responseParameters = [NSJSONSerialization JSONObjectWithData: responseData options: 0 error: NULL];
		if(responseParameters == nil) {
			alert(@"无法获取其他活动（接口返回格式错误）。");
			
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
					errorMessage = @"无法获取其他活动（发生未知错误）。";
				}
				
				alert(errorMessage);
			}
			
			return;
		}
		
		DDCampaigningStation* firstRegularCampaigningStation = nil;
		
		NSDictionary* jsonData = [responseParameters[@"data"] asDictionary];
		
		NSArray* jsonCampaigningStationList = [jsonData[@"list"] asArray];
		for(NSObject* jsonCampaigningStation in jsonCampaigningStationList) {
			DDCampaigningStation* campaigningStation = DDCampaigningStationFromJsonObject([jsonCampaigningStation asDictionary]);
			if(campaigningStation != nil) {
				DDCampaign* campaign = [campaigningStation campaign];
				if([campaign isKindOfClass: [DDRegularCampaign class]]) {
					firstRegularCampaigningStation = campaigningStation;
					
					break;
				}
			}
		}
		
		if(firstRegularCampaigningStation != nil) {
			DDOrderViewController* orderViewController = [[DDOrderViewController alloc] initWithCampaigningStation: firstRegularCampaigningStation];
			[self switchTo: orderViewController animated: TRUE];
		}
		else {
			alert(@"对不起，该油站暂时没有其他活动。");
		}
		
		return;
	}
}

- (void)requestFailed: (ASIHTTPRequest*)request {
	if(request == _stationCampaignListRequest) {
		_stationCampaignListRequest = nil;
		
		[_stationCampaignListDialog dismiss];
		_stationCampaignListDialog = nil;
		
		alert(@"无法查询其他活动（网络连接失败）。");
		
		return;
	}
}

@end
