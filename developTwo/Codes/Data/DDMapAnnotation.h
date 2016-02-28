#import <MapKit/MapKit.h>

@interface DDMapAnnotation : NSObject<MKAnnotation>

@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic, copy) NSString* title;


//add by YCJ


#pragma mark 自定义一个图片属性在创建大头针视图时使用
@property (nonatomic,strong) UIImage *image;

#pragma mark 大头针详情左侧图标
@property (nonatomic,strong) UIImage *icon;

@property (nonatomic,copy) NSString *detail;
@end
