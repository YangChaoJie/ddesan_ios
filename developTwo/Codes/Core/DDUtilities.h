#import <CoreLocation/CoreLocation.h>

#define sqr(a) { __typeof__(a) _a = (a); a * a; }

// 检查两个对象是否等值（包括同时为nil的情况）。
extern BOOL objectsEqual(NSObject* a, NSObject* b);

// 显示一个纯消息对话框。
extern void alert(NSString* message);

// 将JSON对象转为字符串。
extern NSString* NSStringFromJsonObject(id jsonObject);

// 判断是否为有效的手机号。
extern BOOL isValidMobile(NSString* mobile);

// 判断是否为有效的密码。
extern BOOL isValidPassword(NSString* password);

// 判断是否为有效的验证码。
extern BOOL isValidVerification(NSString* verification);

// 格式化距离。
extern NSString* formatDistance(double distance);

// 将WGS-84坐标转为GCJ-02坐标。
extern CLLocationCoordinate2D translateCoordinateFromWgs84ToGcj02(CLLocationCoordinate2D coordinate);

// 将GCJ-02坐标转为WGS-84坐标。
extern CLLocationCoordinate2D translateCoordinateFromGcj02ToWgs84(CLLocationCoordinate2D coordinate);

// 将GCJ-02坐标转为BD-09坐标。
extern CLLocationCoordinate2D translateCoordinateFromGcj02ToBd09(CLLocationCoordinate2D coordinate);

// 将BD-09坐标转为GCJ-02坐标。
extern CLLocationCoordinate2D translateCoordinateFromBd09ToGcj02(CLLocationCoordinate2D coordinate);


/**
 *  系统地图坐标系转成百度坐标系
 *
 *  @param coordinate 系统地图坐标
 *
 *  @return 百度地图坐标
 */
extern CLLocationCoordinate2D translateCoordinateFromWgs84ToBaidu(CLLocationCoordinate2D coordinate);

/**
 *  百度地图坐标转成系统地图坐标
 *
 *  @param coordinate 百度系统坐标
 *
 *  @return 系统地图坐标
 */
extern CLLocationCoordinate2D translateCoordinateFromBaiduToWgs84(CLLocationCoordinate2D coordinate);