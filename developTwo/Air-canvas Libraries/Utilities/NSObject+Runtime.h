#import <Foundation/Foundation.h>

@interface NSObject(Runtime)

- (void*)getInstanceVariable: (const char*)name;
- (void)setInstanceVariable: (const char*)name withValue: (void*)value;

- (instancetype)noarcRetain;
- (instancetype)noarcAutorelease;
- (void)noarcRelease;
- (NSUInteger)noarcRetainCount;

@end
