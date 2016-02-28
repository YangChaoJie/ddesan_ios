#import "ACWeakReference.h"

@interface ACWeakReference() {
	NSObject* __weak _object;
}

@end

#pragma mark -

@implementation ACWeakReference

+ (id)weakReferenceForObject: (NSObject*)object {
	return [[self alloc] initWithObject: object];
}

- (id)initWithObject: (NSObject*)object {
	self = [super init];
	if(self != nil) {
		_object = object;
	}
	
	return self;
}

@synthesize object = _object;

@end
