#import "DDUtilities.h"

#import "ACMessageDialog.h"

#import <BaiduMapAPI/BMapKit.h>

#define X_PI (double)(M_PI * 3000 / 180)

BOOL objectsEqual(NSObject* a, NSObject* b) {
	return a == b || [a isEqual: b];
}

void alert(NSString* message) {
	ACMessageDialog* dialog = [[ACMessageDialog alloc] init];
	[dialog setMessage: message];
	[dialog setCancelButtonTitle: @"关闭"];
	[dialog show];
}

NSString* NSStringFromJsonObject(id jsonObject) {
	NSData* data = [NSJSONSerialization dataWithJSONObject: jsonObject options: 0 error: NULL];
	NSString* string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	
	return string;
}

BOOL isValidMobile(NSString* mobile) {
	NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: @"^[1][3,4,5,7,8][0-9]{9}$" options: 0 error: NULL];
	BOOL valid = [regex numberOfMatchesInString: mobile options: 0 range: NSMakeRange(0, [mobile length])] != 0;
	
	return valid;
}

BOOL isValidPassword(NSString* password) {
	BOOL valid = [password length] >= 6;
	
	return valid;
}

BOOL isValidVerification(NSString* verification) {
	// XXX 目前不知道验证码格式，暂时不作判断。
	return TRUE;
}

NSString* formatDistance(double distance) {
	if(distance < 0) {
		return nil;
	}
	else if(distance < 1000) {
		return [[NSString alloc] initWithFormat: @"%.0f m", floor(distance)];
	}
	else if(distance < 1000000) {
		return [[NSString alloc] initWithFormat: @"%.0f Km", floor(distance / 1000)];
	}
	else {
		return @">999 Km";
	}
}

// 地图坐标转换。

const double M_A = 6378245.0;
const double M_EE = 0.00669342162296594323;

double translateLatitude(double x, double y) {
	double result = - 100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x))
		+ (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0
		+ (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0
		+ (160.0 * sin(y / 12.0 * M_PI) + 320.0 * sin(y * M_PI / 30.0)) * 2.0 / 3.0
	;
	
	return result;
}

double translateLongitude(double x, double y) {
	double result = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x))
		+ (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0
		+ (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0
		+ (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0
	;
	
	return result;
}

CLLocationCoordinate2D translateCoordinateFromWgs84ToGcj02(CLLocationCoordinate2D coordinate) {
	double deltaLatitude = translateLatitude(coordinate.longitude - 105.0, coordinate.latitude - 35.0);
	double deltaLongitude = translateLongitude(coordinate.longitude - 105.0, coordinate.latitude - 35.0);
	double radiumLatitude = coordinate.latitude / 180.0 * M_PI;
	double magic = sin(radiumLatitude);
	magic = 1 - M_EE * magic * magic;
	double sqrtMagic = sqrt(magic);
	deltaLatitude = (deltaLatitude * 180.0) / ((M_A * (1 - M_EE)) / (magic * sqrtMagic) * M_PI);
	deltaLongitude = (deltaLongitude * 180.0) / (M_A / sqrtMagic * cos(radiumLatitude) * M_PI);
	
	coordinate.latitude += deltaLatitude;
	coordinate.longitude += deltaLongitude;
	
	return coordinate;
}

CLLocationCoordinate2D translateCoordinateFromGcj02ToWgs84(CLLocationCoordinate2D coordinate) {
	double deltaLatitude = translateLatitude(coordinate.longitude - 105.0, coordinate.latitude - 35.0);
	double deltaLongitude = translateLongitude(coordinate.longitude - 105.0, coordinate.latitude - 35.0);
	double radiumLatitude = coordinate.latitude / 180.0 * M_PI;
	double magic = sin(radiumLatitude);
	magic = 1 - M_EE * magic * magic;
	double sqrtMagic = sqrt(magic);
	deltaLatitude = (deltaLatitude * 180.0) / ((M_A * (1 - M_EE)) / (magic * sqrtMagic) * M_PI);
	deltaLongitude = (deltaLongitude * 180.0) / (M_A / sqrtMagic * cos(radiumLatitude) * M_PI);
	
	coordinate.latitude -= deltaLatitude;
	coordinate.longitude -= deltaLongitude;
	
	return coordinate;
}

CLLocationCoordinate2D translateCoordinateFromGcj02ToBd09(CLLocationCoordinate2D coordinate) {
	double x = coordinate.longitude;
	double y = coordinate.latitude;
	double z = sqrt(x * x + y * y) + 0.00002 * sin(y * X_PI);
	double theta = atan2(y, x) + 0.000003 * cos(x * X_PI);
	coordinate.longitude = z * cos(theta) + 0.0065;
	coordinate.latitude = z * sin(theta) + 0.006;
	
	return coordinate;
}

CLLocationCoordinate2D translateCoordinateFromBd09ToGcj02(CLLocationCoordinate2D coordinate) {
	double x = coordinate.longitude - 0.0065;
	double y = coordinate.latitude - 0.006;
	double z = sqrt(x * x + y * y) - 0.00002 * sin(y * X_PI);
	double theta = atan2(y, x) - 0.000003 * cos(x * X_PI);
	coordinate.longitude = z * cos(theta);
	coordinate.latitude = z * sin(theta);
	
	return coordinate;
}


/**
 *  系统地图坐标系转成百度坐标系
 *
 *  @param coordinate 系统地图坐标
 *
 *  @return 百度地图坐标
 */
CLLocationCoordinate2D translateCoordinateFromWgs84ToBaidu(CLLocationCoordinate2D coordinate) {
    
    NSDictionary *baidudict = BMKConvertBaiduCoorFrom(coordinate, BMK_COORDTYPE_GPS);
    CLLocationCoordinate2D baiduCoordinate = BMKCoorDictionaryDecode(baidudict);
    
    return baiduCoordinate;
}

/**
 *  百度地图坐标转成系统地图坐标
 *
 *  @param coordinate 百度系统坐标
 *
 *  @return 系统地图坐标
 */
CLLocationCoordinate2D translateCoordinateFromBaiduToWgs84(CLLocationCoordinate2D coordinate) {
    
    return coordinate;
}
