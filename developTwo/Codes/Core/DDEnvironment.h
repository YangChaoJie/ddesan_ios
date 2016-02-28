#import <CoreLocation/CoreLocation.h>

@class DDUser;

@interface DDEnvironment : NSObject

+ (instancetype)alloc __unavailable;
+ (instancetype)sharedInstance;

// 摇一摇抢名额的限制距离（APP重启有效，不支持KVO）。
@property(nonatomic, copy) NSNumber* bookingDistance;

// 邀请好友可得到的天使基金（APP重启有效，不支持KVO）。
@property(nonatomic, copy) NSNumber* customerAngelPoint;

// 邀请油站可得到的天使基金（APP重启有效，不支持KVO）。
@property(nonatomic, copy) NSNumber* businessAngelPoint;

// 距离选择时使用的距离参数（APP重启有效，不支持KVO）。
@property(nonatomic, copy) NSArray* selectableDistances;

// 默认选择的距离序号（APP重启有效，不支持KVO）。
@property(nonatomic, copy) NSNumber* defaultDistanceIndex;

// 价格选择的间隔（APP重启有效，不支持KVO）。
@property(nonatomic, copy) NSNumber* priceStep;

// 分享文案（APP重启有效，不支持KVO）。
@property(nonatomic, copy) NSString* sharingText;

// 分享URL（APP重启有效，不支持KVO）。
@property(nonatomic, copy) NSString* sharingUrl;

// 分享图片URL（APP重启有效，不支持KVO）。
@property(nonatomic, copy) NSArray* sharingImageUrls;

// 最近使用的用户名（APP重启有效，不支持KVO）。
@property(nonatomic, copy) NSString* recentUsername;

// 最近使用的密码（APP重启有效，不支持KVO）。
@property(nonatomic, copy) NSString* recentPassword;

// 用于推送的设备标识。
@property(nonatomic, copy) NSData* deviceToken;

// 用户的当前位置。
@property(nonatomic, copy) CLLocation* location;

// 最后一次获取手机验证码的时间。
@property(nonatomic, copy) NSDate* verificationDate;

// 下一次获取手机验证码前需要等待的冷却时间。返回0代表可以获取手机验证码。
- (NSTimeInterval)cooldownBeforeNextVerification;

// 用户登录信息。
@property(nonatomic, strong) DDUser* user;

@end
