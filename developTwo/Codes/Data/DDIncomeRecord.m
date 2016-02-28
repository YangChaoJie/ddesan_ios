#import "DDIncomeRecord.h"

#import "NSObject+JsonParsing.h"

static NSDate* parseDate(NSString* string) {
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm"];
	[dateFormatter setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: 28800]];
	
	NSDate* date = [dateFormatter dateFromString: string];
	
	return date;
}

#pragma mark -

@implementation DDIncomeRecord

@end

#pragma mark -

DDIncomeRecord* DDIncomeRecordFromJsonObject(NSDictionary* jsonObject) {
	if(jsonObject == nil) {
		return nil;
	}
	
	DDIncomeRecord* incomeRecord = [[DDIncomeRecord alloc] init];
	
	NSString* source = [jsonObject[@"in_content"] asString];
	[incomeRecord setSource: source];
	
	NSDate* date = parseDate([jsonObject[@"get_time"] asString]);
	[incomeRecord setDate: date];
	
	NSNumber* amount = [jsonObject[@"point"] asNumber];
	[incomeRecord setAmount: amount];
	
	return incomeRecord;
}

