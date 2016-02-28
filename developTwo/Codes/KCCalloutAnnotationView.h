//
//  KCCalloutView.h
//  MapKit
//
//  Created by Kenshin Cui on 14/3/27.
//  Copyright (c) 2014年 Kenshin Cui. All rights reserved.
//  自定义弹出标注视图

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "KCCalloutAnnotation.h"

@interface KCCalloutAnnotationView : MKAnnotationView

@property (nonatomic ,strong) KCCalloutAnnotation *annotationOne;


@property(nonatomic,copy)NSString* address;
#pragma mark 从缓存取出标注视图
+(instancetype)calloutViewWithMapView:(MKMapView *)mapView ;
//-(instancetype)initWithcalloutViewWithMapView:(MKMapView *)mapView Address:(NSString *)address;
@end
