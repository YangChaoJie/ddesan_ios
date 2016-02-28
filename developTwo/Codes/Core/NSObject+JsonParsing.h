#import <Foundation/Foundation.h>

@interface NSObject(JsonParsing)

- (NSDictionary*)asDictionary;
- (NSArray*)asArray;
- (NSNumber*)asNumber;
- (NSString*)asString;

@end
