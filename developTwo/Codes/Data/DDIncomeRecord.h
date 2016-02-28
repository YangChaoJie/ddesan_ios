#import <Foundation/Foundation.h>

@interface DDIncomeRecord : NSObject

@property(nonatomic, copy) NSString* source;
@property(nonatomic, copy) NSDate* date;
@property(nonatomic, copy) NSNumber* amount;

@end

#pragma mark -

DDIncomeRecord* DDIncomeRecordFromJsonObject(NSDictionary* jsonObject);
