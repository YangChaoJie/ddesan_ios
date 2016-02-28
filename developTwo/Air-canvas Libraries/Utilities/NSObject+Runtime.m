#import "NSObject+Runtime.h"

#import <objc/runtime.h>

@implementation NSObject(Runtime)

- (void*)getInstanceVariable: (const char*)name {
	void* pointer = NULL;
	object_getInstanceVariable(self, name, &pointer);
	
	return pointer;
}

- (void)setInstanceVariable: (const char*)name withValue: (void*)value {
	object_setInstanceVariable(self, name, value);
}

- (instancetype)noarcRetain {
	return [self retain];
}

- (instancetype)noarcAutorelease {
	return [self autorelease];
}

- (void)noarcRelease {
	[self release];
}

- (NSUInteger)noarcRetainCount {
	return [self retainCount];
}

@end
