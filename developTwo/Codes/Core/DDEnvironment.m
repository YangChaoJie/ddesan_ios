#import "DDEnvironment.h"

#define VERIFICATION_COOLDOWN (NSTimeInterval)60

#define BOOKING_DISTANCE_KEY @"BOOKING_DISTANCE"
#define CUSTOMER_ANGEL_POINT_KEY @"CUSTOMER_ANGEL_POINT"
#define BUSINESS_ANGEL_POINT_KEY @"BUSINESS_ANGEL_POINT"
#define SELECTABLE_DISTANCES_KEY @"SELECTABLE_DISTANCES"
#define DEFAULT_DISTANCE_INDEX_KEY @"DEFAULT_DISTANCE_INDEX"
#define PRICE_STEP_KEY @"PRICE_STEP"
#define SHARING_TEXT_KEY @"SHARING_TEXT"
#define SHARING_URL_KEY @"SHARING_URL"
#define SHARING_IMAGE_URLS_KEY @"SHARING_IMAGE_URLS"
#define RECENT_USERNAME_KEY @"RECENT_USERNAME"
#define RECENT_PASSWORD_KEY @"RECENT_PASSWORD"


@interface DDEnvironment() {
	CLLocation* _location;
	
	NSDate* _verificationDate;
	
	DDUser* _user;
}

@end

#pragma mark -

@implementation DDEnvironment

+ (instancetype)sharedInstance {
	static DDEnvironment* instance = nil;
	
	if(instance == nil) {
		@synchronized([DDEnvironment class]) {
			if(instance == nil) {
				instance = [[super alloc] init];
			}
		}
	}
	
	return instance;
}

- (NSNumber*)bookingDistance {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSNumber* bookingDistance = [defaults objectForKey: BOOKING_DISTANCE_KEY];
	
	return bookingDistance;
}

- (void)setBookingDistance: (NSNumber*)bookingDistance {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject: bookingDistance forKey: BOOKING_DISTANCE_KEY];
    NSLog(@"%@",defaults);
}

- (NSNumber*)customerAngelPoint {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSNumber* customerAngelPoints = [defaults objectForKey: CUSTOMER_ANGEL_POINT_KEY];
	
	return customerAngelPoints;
}

- (void)setCustomerAngelPoint: (NSNumber*)customerAngelPoint {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject: customerAngelPoint forKey: CUSTOMER_ANGEL_POINT_KEY];
}

- (NSNumber*)businessAngelPoint {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSNumber* businessAngelPoints = [defaults objectForKey: BUSINESS_ANGEL_POINT_KEY];
	
	return businessAngelPoints;
}

- (void)setBusinessAngelPoint: (NSNumber*)businessAngelPoint {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject: businessAngelPoint forKey: BUSINESS_ANGEL_POINT_KEY];
}

- (NSArray*)selectableDistances {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSArray* selectableDistances = [defaults objectForKey: SELECTABLE_DISTANCES_KEY];
	
	return selectableDistances;
}

- (void)setSelectableDistances: (NSArray*)selectableDistances {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject: selectableDistances forKey: SELECTABLE_DISTANCES_KEY];
}

- (NSNumber*)defaultDistanceIndex {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSNumber* defaultDistanceIndex = [defaults objectForKey: DEFAULT_DISTANCE_INDEX_KEY];
	
	return defaultDistanceIndex;
}

- (void)setDefaultDistanceIndex: (NSNumber*)defaultDistanceIndex {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject: defaultDistanceIndex forKey: DEFAULT_DISTANCE_INDEX_KEY];
}

- (NSNumber*)priceStep {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSNumber* priceStep = [defaults objectForKey: PRICE_STEP_KEY];
	
	return priceStep;
}

- (void)setPriceStep: (NSNumber*)priceStep {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject: priceStep forKey: PRICE_STEP_KEY];
}

- (NSString*)sharingText {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* sharingText = [defaults objectForKey: SHARING_TEXT_KEY];
	
	return sharingText;
}

- (void)setSharingText: (NSString*)sharingText {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject: sharingText forKey: SHARING_TEXT_KEY];
}

- (NSString*)sharingUrl {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* sharingUrl = [defaults objectForKey: SHARING_URL_KEY];
	
	return sharingUrl;
}

- (void)setSharingUrl: (NSString*)sharingUrl {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject: sharingUrl forKey: SHARING_URL_KEY];
}

- (NSArray*)sharingImageUrls {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSArray* sharingImageUrls = [defaults objectForKey: SHARING_IMAGE_URLS_KEY];
	
	return sharingImageUrls;
}

- (void)setSharingImageUrls:(NSArray *)sharingImageUrls {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject: sharingImageUrls forKey: SHARING_IMAGE_URLS_KEY];
}

- (NSString*)recentUsername {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* recentUsername = [defaults stringForKey: RECENT_USERNAME_KEY];
	
	return recentUsername;
}

- (void)setRecentUsername: (NSString*)recentUsername {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue: recentUsername forKey: RECENT_USERNAME_KEY];
}

- (NSString*)recentPassword {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* recentPassword = [defaults stringForKey: RECENT_PASSWORD_KEY];
	
	return recentPassword;
}

- (void)setRecentPassword: (NSString*)recentPassword {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue: recentPassword forKey: RECENT_PASSWORD_KEY];
}

@synthesize location = _location;

@synthesize verificationDate = _verificationDate;

- (NSTimeInterval)cooldownBeforeNextVerification {
	if(_verificationDate == nil) {
		return 0;
	}
	
	NSTimeInterval cooldownBeforeNextVerification = [[_verificationDate dateByAddingTimeInterval: VERIFICATION_COOLDOWN] timeIntervalSinceNow];
	if(cooldownBeforeNextVerification < 0) {
		cooldownBeforeNextVerification = 0;
	}
	
	return cooldownBeforeNextVerification;
}

@synthesize user = _user;

@end
