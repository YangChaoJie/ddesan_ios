#import <Foundation/Foundation.h>

// XXX Should ACWeakMap be a subclass of NSDictionary?

@interface ACWeakMap : NSObject

- (void)setObject: (id)value forKey: (id)key;
- (id)objectForKey: (id)key;

- (NSArray*)allKeys;
- (BOOL)containsKey: (id)key;
- (NSArray*)allKeysForObject: (id)value;

- (void)removeAllObjects;
- (void)removeObjectForKey: (id)key;
- (void)removeObjectForKeys: (NSArray*)keys;

@end
