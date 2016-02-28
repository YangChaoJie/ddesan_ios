#import "DDOrderViewController.h"

#import <MapKit/MapKit.h>
#import "DDCampaign.h"
#import "DDCampaigningStation.h"
#import "DDDiscountedPriceViewController.h"
#import "DDEnvironment.h"
#import "DDHotCampaign.h"
#import "DDMapAnnotation.h"
#import "DDOrderConfirmationViewController.h"
#import "DDOrderRecord.h"
#import "DDOrderViewController.h"
#import "DDRegularCampaign.h"
#import "DDStation.h"
#import "DDUtilities.h"


#import "KCCalloutAnnotationView.h"
static NSString* formatTime(NSDate* time) {
	NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
	[timeFormatter setDateFormat: @"HH:mm"];
	
	NSString* string = [timeFormatter stringFromDate: time];
	
	return string;
}

#pragma mark -

@interface DDOrderViewController() <MKMapViewDelegate>{
	DDOrderRecord* _orderRecord;
	
	IBOutlet UIButton* _backButton;
	
	IBOutlet UILabel* _stationNameLabel;
	IBOutletCollection(UIButton) NSArray* _starButtons;
	
	IBOutlet UIView* _mapPanel;
	IBOutlet MKMapView* _mapView;
	IBOutlet UIButton* _locateButton;
	
	IBOutlet UILabel* _stationAddressLabel;
	IBOutlet UILabel* _timeConditionLabel;
	
	IBOutletCollection(UIButton) NSArray* _itemButtons;
	IBOutlet UIButton* _firstItemButton;
	IBOutlet UIButton* _secondItemButton;
	IBOutlet UIButton* _discountedPriceButton;
	
	IBOutlet UIView* _settlementPanel;
	IBOutlet UILabel* _originalPriceLabel;
	IBOutlet UILabel* _originalPriceExplanationLabel;
	IBOutlet UILabel* _amountLabel;
	
	IBOutlet UIButton* _submitButton;
	
	UIButton* _selectedItemButton;
	
	NSInteger _priceStep;
    
    NSString* _address;
    CLLocation* _location;
}

@end

#pragma mark -

@implementation DDOrderViewController

//add by YCJ
- (instancetype)initWithCampaigningStation: (DDCampaigningStation*)campaigningStation Dictary:(NSDictionary*)dic{
    //self.dic=dic;
   // NSLog(@"%@",self.dic);
    
   
    
    return [self initWithCampaigningStation: campaigningStation andOrderCode: nil Dictary:dic];
    //return [self initWithOrderRecord:nil Dictary:dic];
}

- (instancetype)initWithCampaigningStation: (DDCampaigningStation*)campaigningStation {
    return [self initWithCampaigningStation: campaigningStation andOrderCode: nil Dictary:nil];
}
- (instancetype)initWithCampaigningStation: (DDCampaigningStation*)campaigningStation andOrderCode: (NSString*)orderCode Dictary:(NSDictionary*)dic{
    
	DDOrderRecord* orderRecord = [[DDOrderRecord alloc] init];
	[orderRecord setCode: orderCode];
	[orderRecord setStation: [campaigningStation station]];
	[orderRecord setCampaign: [campaigningStation campaign]];
	
	return [self initWithOrderRecord: orderRecord Dictary:dic];
}

- (instancetype)initWithOrderRecord: (DDOrderRecord*)orderRecord Dictary:(NSDictionary*)dic{
    
    self.dic=dic;
	self = [super init];
	if(self != nil) {
		_orderRecord = orderRecord;
		
		[super view];
		
		for(UIButton* button in @[ _firstItemButton, _secondItemButton, _discountedPriceButton ]) {
			CALayer* layer = [button layer];
			[layer setBorderWidth: 1];
			[layer setBorderColor: [[UIColor colorWithRed: 0.11 green: 0.62 blue: 0.23 alpha: 1] CGColor]];
		}
		
		DDStation* station = [_orderRecord station];
        //将地址编码 传到 地图中
        _address=station.address;
        
          _location=station.location;
        NSLog(@"location= %@",_location);
        
		DDCampaign* campaign = [_orderRecord campaign];
		//31.21251916,+121.51299840
		{
			// 高德地图使用的是GCJ-02坐标，需要转换。
			CLLocationCoordinate2D coordinate = translateCoordinateFromWgs84ToGcj02([[station location] coordinate]);
			
            
          
			[_mapView setRegion: [_mapView regionThatFits: MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0, 0))]];
			
            
            //alter by YCJ
			DDMapAnnotation* annotion = [[DDMapAnnotation alloc] init];
			[annotion setCoordinate: coordinate];
			[annotion setTitle: [station name]];
            
            [annotion setImage:[UIImage imageNamed:@"icon_openmap_item@2x.png"]];
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
        
        
        NSString*s1=[self.dic objectForKey:fuelType0];
        
		if(fuelType0 != nil) {
			NSNumber* fuelPrice0 = fuelPrices[fuelType0];
            
			NSNumber* fuelPriceCut0 = fuelPriceCuts[fuelType0];
			NSString* fuelInfo0 = [[NSString alloc] initWithFormat: @"%@    ¥%.02f-%.02f", s1, [fuelPrice0 doubleValue], [fuelPriceCut0 doubleValue]];
			[_firstItemButton setTitle: fuelInfo0 forState: UIControlStateNormal];
          
		}
		else {
			[_firstItemButton setTitle: nil forState: UIControlStateNormal];
//			[_firstItemButton setEnabled: FALSE];
			[_firstItemButton setHidden: TRUE];
		}
		
		NSString* fuelType1 = [fuelTypes count] > 1 ? fuelTypes[1] : nil;
        
        NSString*s2=[self.dic objectForKey:fuelType1];
		if(fuelType1 != nil) {
			NSNumber* fuelPrice1 = fuelPrices[fuelType1];
			NSNumber* fuelPriceCut1 = fuelPriceCuts[fuelType1];
			NSString* fuelInfo1 = [[NSString alloc] initWithFormat: @"%@    ¥%.02f-%.02f", s2, [fuelPrice1 doubleValue], [fuelPriceCut1 doubleValue]];
			[_secondItemButton setTitle: fuelInfo1 forState: UIControlStateNormal];
         
		}
		else {
			[_secondItemButton setTitle: nil forState: UIControlStateNormal];
//			[_secondItemButton setEnabled: FALSE];
			[_secondItemButton setHidden: TRUE];
            
            //2015-09修改
            
//            [_firstItemButton setFrame: CGRectMake(CGRectGetMinX(_firstItemButton.frame), CGRectGetMinY(_firstItemButton.frame), CGRectGetWidth([UIScreen mainScreen].bounds) - 40, CGRectGetHeight(_firstItemButton.bounds))];
		}
		
		NSString* fuelType = [_orderRecord fuelType];
		if(fuelType != nil) {
			if([fuelType0 isEqualToString: fuelType]) {
				[self selectItemButton: _firstItemButton];
			}
			else if([fuelType1 isEqualToString:fuelType]) {
				[self selectItemButton: _secondItemButton];
			}
		}
		
		NSNumber* discountedPrice = [_orderRecord discountedPrice];
		[self setDiscountedPrice: discountedPrice];
		
		_priceStep = [[[DDEnvironment sharedInstance] priceStep] integerValue];
		if(_priceStep <= 0) {
			_priceStep = 10;
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
        NSLog(@"%@",calloutView.annotationOne.location);
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


- (void)viewDidLoad {
    [super viewDidLoad];
    
//    _secondItemButton.hidden = true;
    
    if (_secondItemButton.hidden) {
        
        [_firstItemButton setFrame: CGRectMake(20, CGRectGetMinY(_firstItemButton.frame), CGRectGetWidth(_discountedPriceButton.frame), CGRectGetHeight(_firstItemButton.bounds))];
        _firstItemButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    }
}

/*-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
     NSLog(@"%@",self.dic);
    
}*/

- (void)setDiscountedPrice: (NSNumber*)discountedPrice {
	_discountedPrice = [discountedPrice copy];
	
	if(discountedPrice == nil) {
		[_discountedPriceButton setTitle: @"实付金额" forState: UIControlStateNormal];
		[_discountedPriceButton setTitleColor: [UIColor colorWithRed: 0.11 green: 0.62 blue: 0.23 alpha: 1] forState: UIControlStateNormal];
		
		[_settlementPanel setHidden: TRUE];
		
		[_submitButton setEnabled: FALSE];
	}
	else {
		[_discountedPriceButton setTitle: [[NSString alloc] initWithFormat: @"实付 ¥%d", [discountedPrice intValue]] forState: UIControlStateNormal];
		[_discountedPriceButton setTitleColor: [UIColor redColor] forState: UIControlStateNormal];
		
		[_settlementPanel setHidden: FALSE];
		[self updateSettlement];
		
		[_submitButton setEnabled: TRUE];
	}
}

- (IBAction)handleButton: (UIButton*)button {
	if(button == _backButton) {
		[self goBack];
		
		return;
	}
	
	if([_itemButtons containsObject: button]) {
		[self selectItemButton: button];
		
		return;
	}
	
	if(button == _discountedPriceButton) {
		[self askForDiscountedPrice];
		
		return;
	}
	
	if(button == _submitButton) {
		[self goOrderConfirmation];
		
		return;
	}
}

- (void)selectItemButton: (UIButton*)selectedItemButton {
	for(UIButton* itemButton in _itemButtons) {
		BOOL selected = itemButton == selectedItemButton;
		[itemButton setSelected: selected];
		[itemButton setUserInteractionEnabled: !selected];
	}
	
	_selectedItemButton = selectedItemButton;
	
	[self setDiscountedPrice: nil];
	[_discountedPriceButton setEnabled: selectedItemButton != nil];
}

- (void)askForDiscountedPrice {
	assert(_selectedItemButton != nil);
	
	DDStation* station = [_orderRecord station];
	DDCampaign* campaign = [_orderRecord campaign];
	
	NSInteger selectedItemIndex = [_selectedItemButton tag];
	
	NSArray* fuelTypes = [station fuelTypes];
	NSNumber* selectedFuelType = fuelTypes[selectedItemIndex];
	
	NSDictionary* fuelPrices = [station fuelPrices];
	double selectedFuelPrice = [fuelPrices[selectedFuelType] doubleValue];
	
	NSDictionary* fuelPriceCuts = [campaign fuelPriceCuts];
	double selectedFuelPriceCut = [fuelPriceCuts[selectedFuelType] doubleValue];
	
	double fuelMinimum = [[campaign fuelMinimum] doubleValue];
	double fuelLimit = [[campaign fuelLimit] doubleValue];
	
	NSInteger discountedPriceFloor = (NSInteger)ceil((selectedFuelPrice - selectedFuelPriceCut) * fuelMinimum / _priceStep) * _priceStep;
	NSInteger discountedPriceCeiling = (NSInteger)floor((selectedFuelPrice - selectedFuelPriceCut) * fuelLimit / _priceStep) * _priceStep;
	
	DDDiscountedPriceViewController* discountedPriceViewController = [[DDDiscountedPriceViewController alloc] initWithFloor: discountedPriceFloor andCeiling: discountedPriceCeiling];
	[self push: discountedPriceViewController animated: TRUE];
}

- (void)updateSettlement {
	assert(_selectedItemButton != nil);
	assert(_discountedPrice != nil);
	
	DDStation* station = [_orderRecord station];
	DDCampaign* campaign = [_orderRecord campaign];
	
	NSInteger selectedItemIndex = [_selectedItemButton tag];
	
	NSArray* fuelTypes = [station fuelTypes];
    //
	NSString* selectedFuelType = fuelTypes[selectedItemIndex];  //选择的油号
	
	NSDictionary* fuelPrices = [station fuelPrices];
	double selectedFuelPrice = [fuelPrices[selectedFuelType] doubleValue];  //选择的油号对应的牌价
	
	NSDictionary* fuelPriceCuts = [campaign fuelPriceCuts];
	double selectedFuelPriceCut = [fuelPriceCuts[selectedFuelType] doubleValue];    //选择的油号对应的折扣价
	
	NSInteger discountedPrice = [_discountedPrice integerValue];                    //用户输入的金额
    
    //  2015-09-08修改
    //总金额
    double totalAmount = discountedPrice * selectedFuelPrice / (selectedFuelPrice - selectedFuelPriceCut);

    //  优惠后的总原价
    NSInteger originalPrice = (NSInteger)floor(totalAmount);
    
    //  油量
    double amount = originalPrice / selectedFuelPrice;
    

    
//	double amount = discountedPrice / (selectedFuelPrice - selectedFuelPriceCut);
//	NSInteger originalPrice = (NSInteger)floor(selectedFuelPrice * amount);
	
	[_originalPriceLabel setText: [[NSString alloc] initWithFormat: @"¥%d", (int)originalPrice]];
	[_originalPriceExplanationLabel setText: [[NSString alloc] initWithFormat: @"请按¥%d报加油", (int)originalPrice]];
	[_amountLabel setText: [[NSString alloc] initWithFormat: @"%.02fL", amount]];
}

- (void)goOrderConfirmation {
	DDStation* station = [_orderRecord station];
	DDCampaign* campaign = [_orderRecord campaign];
	
	NSInteger selectedItemIndex = [_selectedItemButton tag];
	
	NSArray* fuelTypes = [station fuelTypes];
	NSString* selectedFuelType = fuelTypes[selectedItemIndex];
	
	NSDictionary* fuelPrices = [station fuelPrices];
	double selectedFuelPrice = [fuelPrices[selectedFuelType] doubleValue];
	
	NSDictionary* fuelPriceCuts = [campaign fuelPriceCuts];
	double selectedFuelPriceCut = [fuelPriceCuts[selectedFuelType] doubleValue];
	
	NSInteger discountedPrice = [_discountedPrice integerValue];
    
    //  2015-09-08修改
    //总金额
    double totalAmount = discountedPrice * selectedFuelPrice / (selectedFuelPrice - selectedFuelPriceCut);

    //  优惠后的总原价
    NSInteger originalPrice = (NSInteger)floor(totalAmount);
    
    //  油量
    double amount = originalPrice / selectedFuelPrice;
    
//	double amount = discountedPrice / (selectedFuelPrice - selectedFuelPriceCut);
//	NSInteger originalPrice = (NSInteger)floor(selectedFuelPrice * amount);
	
	[_orderRecord setFuelType: selectedFuelType];
	[_orderRecord setFuelPrice: [[NSNumber alloc] initWithDouble: selectedFuelPrice]];
	[_orderRecord setFuelPriceCut: [[NSNumber alloc] initWithDouble: selectedFuelPriceCut]];
	[_orderRecord setFuelAmount: [[NSNumber alloc] initWithDouble: amount]];
	[_orderRecord setOriginalPrice: [[NSNumber alloc] initWithInteger: originalPrice]];
	[_orderRecord setDiscountedPrice: [[NSNumber alloc] initWithInteger: discountedPrice]];
	
	DDOrderConfirmationViewController* orderConfirmationViewController = [[DDOrderConfirmationViewController alloc] initWithOrderRecord: _orderRecord Dictary:self.dic];
   // orderConfirmationViewController.dict=self.dic;
   // NSLog(@"%@",orderConfirmationViewController.dict);
	[self push: orderConfirmationViewController animated: TRUE];
}

@end
