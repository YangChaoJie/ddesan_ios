//
//  KCCalloutAnnotation.h
//  MapKit
//
//  Created by Kenshin Cui on 14/3/27.
//  Copyright (c) 2014年 Kenshin Cui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface KCCalloutAnnotation : NSObject<MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy,readonly) NSString *title;
@property (nonatomic, copy,readonly) NSString *subtitle;

#pragma mark 左侧图标
@property (nonatomic,strong) UIImage *icon;

@property (nonatomic,copy) NSString *detail;


@property(nonatomic, copy) CLLocation* location;
@property(nonatomic,copy)NSString* latitude;
@property(nonatomic,copy)NSString* longitude;
@end
