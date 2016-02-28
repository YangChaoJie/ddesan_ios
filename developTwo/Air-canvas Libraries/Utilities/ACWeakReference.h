#import <Foundation/Foundation.h>

@interface ACWeakReference : NSObject

+ (id)weakReferenceForObject: (NSObject*)object;

- (id)initWithObject: (id)object;

@property(nonatomic, readonly) id object;

@end
