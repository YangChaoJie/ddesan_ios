#import "NSObject+JsonParsing.h"

@implementation NSObject(JsonParsing)

- (NSDictionary*)asDictionary {
	if([self isKindOfClass: [NSDictionary class]]) {
		return (NSDictionary*)self;
	}
	else {
		return nil;
	}
}

- (NSArray*)asArray {
	if([self isKindOfClass: [NSArray class]]) {
		return (NSArray*)self;
	}
	else {
		return nil;
	}
}

- (NSNumber*)asNumber {
	if([self isKindOfClass: [NSNumber class]]) {
		return (NSNumber*)self;
	}
	else if([self isKindOfClass: [NSString class]]) {
		double value;
		if([[[NSScanner alloc] initWithString: (NSString*)self] scanDouble: &value]) {
			return [[NSNumber alloc] initWithDouble: value];
		}
		else {
			return nil;
		}
	}
	else {
		return nil;
	}
}

- (NSString*)asString {
	if([self isKindOfClass: [NSString class]]) {
		return (NSString*)self;
	}
	else if([self isKindOfClass: [NSNumber class]]) {
		return [(NSNumber*)self stringValue];
	}
	else {
		return nil;
	}
}

@end
