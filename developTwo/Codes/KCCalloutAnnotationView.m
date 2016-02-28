//
//  KCCalloutView.m
//  MapKit
//
//  Created by Kenshin Cui on 14/3/27.
//  Copyright (c) 2014年 Kenshin Cui. All rights reserved.
//

#import "KCCalloutAnnotationView.h"

#import "DDUtilities.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>


#import "BNCoreServices.h"
#import "BNRoutePlanModel.h"
#import "BNCoreServices.h"

#import "DDEnvironment.h"




#define kSpacing 5
#define kDetailFontSize 16
#define kViewOffset 80
#define WW 65
#define HH 35
@interface KCCalloutAnnotationView()<BNNaviRoutePlanDelegate,BNNaviUIManagerDelegate>{
    UIView *_backgroundView;
    UIImageView *_iconView;
    UILabel *_detailLabel;
    UIImageView *_rateView;
    UIButton* _button;
    NSString* _address;
    
    
    DDEnvironment* _enviroment;
}
@property (nonatomic,strong) CLGeocoder *geocoder;
@property (assign, nonatomic) BN_NaviType naviType;

@end

@implementation KCCalloutAnnotationView

-(instancetype)init{
    if(self=[super init]){
        [self layoutUI];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        [self layoutUI];
    }
    return self;
}
/*-(instancetype)initWithcalloutViewWithMapView:(MKMapView *)mapView Address:(NSString *)address
{
    self.address=address;
    
    static NSString *calloutKey=@"calloutKey1";
    KCCalloutAnnotationView *calloutView=(KCCalloutAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:calloutKey];
    if (!calloutView) {
        calloutView=[[KCCalloutAnnotationView alloc]init];
    }
    return calloutView;
    
    
}*/
-(void)layoutUI{
    //背景
    _backgroundView=[[UIView alloc]init];
    _backgroundView.backgroundColor=[UIColor whiteColor];
    //左侧添加图标
    _iconView=[[UIImageView alloc]init];
    
    _button=[UIButton buttonWithType:UIButtonTypeSystem];
    _button.backgroundColor=[UIColor colorWithRed:34/255.0 green:170/255.0 blue:31/255.0 alpha:1];
    [_button setTitle:@"导航" forState:UIControlStateNormal];
    _button.titleLabel.text=@"导航";
    _button.layer.cornerRadius=4.0f;
    _button.titleLabel.font=[UIFont systemFontOfSize:16.f];
    [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    _naviType = BN_NaviTypeReal;
    [_button addTarget:self action:@selector(addPilot) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    //上方详情
    _detailLabel=[[UILabel alloc]init];
   
    _detailLabel.lineBreakMode=NSLineBreakByWordWrapping;
    
    _detailLabel.font=[UIFont systemFontOfSize:kDetailFontSize];
    
   ;
    
    [self addSubview:_backgroundView];
   // [self addSubview:_iconView];
    [self addSubview:_detailLabel];
    [self addSubview:_button];
}
-(void)addPilot{
 
    if (![self checkServicesInited]) return;
    _naviType = BN_NaviTypeReal;
    [self startNavi];
    
    
    
    /* _geocoder=[[CLGeocoder alloc]init];
    //根据“北京市”进行地理编码
    [_geocoder geocodeAddressString:self.address completionHandler:^(NSArray *placemarks, NSError *error) {
        
        //CLPlacemark *clPlacemark2=[placemarks firstObject];//获取第一个地标
       // MKPlacemark *mkPlacemark2=[[MKPlacemark alloc]initWithPlacemark:clPlacemark2];
        NSDictionary *options=@{MKLaunchOptionsMapTypeKey:@(MKMapTypeStandard)};
        CLPlacemark *clPlacemark1=[placemarks firstObject];//获取第一个地标
         MKPlacemark *mkPlacemark1=[[MKPlacemark alloc]initWithPlacemark:clPlacemark1];
          MKMapItem *mapItem1=[[MKMapItem alloc]initWithPlacemark:mkPlacemark1];
       
        [MKMapItem openMapsWithItems:@[mapItem1] launchOptions:options];
        //注意地理编码一次只能定位到一个位置，不能同时定位，所在放到第一个位置定位完成回调函数中再次定位
      
    }];*/

    
}




//发起导航
- (void)startNavi
{
    _enviroment = [DDEnvironment sharedInstance];
    // 在这里不能添加观察者
 //[_enviroment addObserver: self forKeyPath: @"location" options: 0 context: NULL];
    
    CLLocation*location=[_enviroment location];
    
    
    CLLocationCoordinate2D coordinate=translateCoordinateFromWgs84ToBaidu(location.coordinate);
    
    //节点数组
    NSMutableArray *nodesArray = [[NSMutableArray alloc]    initWithCapacity:2];
    
    //起点 自己当前的位置
    BNRoutePlanNode *startNode = [[BNRoutePlanNode alloc] init];
    startNode.pos = [[BNPosition alloc] init];
   // CLLocationCoordinate2D coordinate=self.annotationOne.coordinate;
   // NSLog(@"%f,%fcoordinate=",coordinate.latitude,coordinate.longitude);
    startNode.pos.x=coordinate.longitude;
    startNode.pos.y=coordinate.latitude;
    

   /* startNode.pos.x = 121.51299840;
    startNode.pos.y = 31.21251916;*/
    //31.21251916,+121.51299840>
    startNode.pos.eType = BNCoordinate_BaiduMapSDK;
   
    [nodesArray addObject:startNode];
    
    //终点
    BNRoutePlanNode *endNode = [[BNRoutePlanNode alloc] init];
    endNode.pos = [[BNPosition alloc] init];
      CLLocationCoordinate2D coordinate1=translateCoordinateFromGcj02ToBd09([self.annotationOne coordinate]);
    /*CLLocationCoordinate2D coordinate1=self.annotationOne.coordinate;*/
    endNode.pos.x=coordinate1.longitude;
    endNode.pos.y=coordinate1.latitude;
   /* endNode.pos.x = 121.523933;
    endNode.pos.y = 31.216219;*/
    
    endNode.pos.eType = BNCoordinate_BaiduMapSDK;
    [nodesArray addObject:endNode];
    //发起路径规划
    [BNCoreServices_RoutePlan startNaviRoutePlan:BNRoutePlanMode_Recommend naviNodes:nodesArray time:nil delegete:self userInfo:nil];
}


//算路成功回调
-(void)routePlanDidFinished:(NSDictionary *)userInfo
{
    NSLog(@"算路成功");
    
    //路径规划成功，开始导航
    [BNCoreServices_UI showNaviUI: BN_NaviTypeReal delegete:self isNeedLandscape:YES];
}

//算路失败回调
- (void)routePlanDidFailedWithError:(NSError *)error andUserInfo:(NSDictionary *)userInfo
{
    NSLog(@"算路失败");
    if ([error code] == BNRoutePlanError_LocationFailed) {
        NSLog(@"获取地理位置失败");
    }
    else if ([error code] == BNRoutePlanError_LocationServiceClosed)
    {
        NSLog(@"定位服务未开启");
    }
}
//算路取消回调
-(void)routePlanDidUserCanceled:(NSDictionary*)userInfo {
    NSLog(@"算路取消");
}

#pragma mark - BNNaviUIManagerDelegate

//退出导航回调
-(void)onExitNaviUI:(NSDictionary*)extraInfo
{
    NSLog(@"退出导航");
}



- (BOOL)checkServicesInited
{
    if(![BNCoreServices_Instance isServicesInited])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"引擎尚未初始化完成，请稍后再试"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    return YES;
}



+(instancetype)calloutViewWithMapView:(MKMapView *)mapView{
    
    //_address=address;
    
    static NSString *calloutKey=@"calloutKey1";
    KCCalloutAnnotationView *calloutView=(KCCalloutAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:calloutKey];
    if (!calloutView) {
        calloutView=[[KCCalloutAnnotationView alloc]init];
    }
    return calloutView;
}

#pragma mark 当给大头针视图设置大头针模型时可以在此根据模型设置视图内容
-(void)setAnnotation:(KCCalloutAnnotation *)annotation{
    // 高德地图使用的是GCJ-02坐标，需要转换。
    
   annotation.coordinate = translateCoordinateFromWgs84ToGcj02([annotation.location coordinate]);
    
    
    [super setAnnotation:annotation];
    //根据模型调整布局
    //_iconView.image=annotation.icon;
    //NSLog(@"%f %f",annotation.icon.size.width, annotation.icon.size.height);
   // _iconView.frame=CGRectMake(kSpacing, kSpacing, WW, HH);
    _button.frame=CGRectMake(kSpacing, kSpacing, WW, HH);
    _detailLabel.text=annotation.detail;
    float detailWidth=150.0;
    CGSize detailSize= [annotation.detail boundingRectWithSize:CGSizeMake(detailWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:kDetailFontSize]} context:nil].size;
    float detailX=CGRectGetMaxX(_button.frame);
    _detailLabel.frame=CGRectMake(detailX-WW, kSpacing-2, detailSize.width, detailSize.height);
    
     _button.frame=CGRectMake(_detailLabel.frame.size.width+10, kSpacing,WW, HH);
  
    
    float backgroundWidth=CGRectGetMaxX(_detailLabel.frame)+kSpacing+WW;
    float backgroundHeight=_button.frame.size.height+2*kSpacing;
    _backgroundView.frame=CGRectMake(0, 0, backgroundWidth+10, backgroundHeight);
    self.bounds=CGRectMake(0, 0, backgroundWidth, backgroundHeight+kViewOffset);
    
}
@end
