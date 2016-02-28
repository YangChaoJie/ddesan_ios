#import <Foundation/Foundation.h>

@interface DDOutcomeRecord : NSObject

@property(nonatomic, copy) NSString* target;
@property(nonatomic, copy) NSDate* date;
@property(nonatomic, copy) NSNumber* amount;

@end

#pragma mark -

DDOutcomeRecord* DDOutcomeRecordFromJsonObject(NSDictionary* jsonObject);
