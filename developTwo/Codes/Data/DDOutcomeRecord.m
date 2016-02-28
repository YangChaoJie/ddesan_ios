#import "DDOutcomeRecord.h"

#import "NSObject+JsonParsing.h"

static NSDate* parseDate(NSString* string) {
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm"];
	[dateFormatter setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: 28800]];
	
	NSDate* date = [dateFormatter dateFromString: string];
	
	return date;
}

#pragma mark -

@implementation DDOutcomeRecord

@end

#pragma mark -

DDOutcomeRecord* DDOutcomeRecordFromJsonObject(NSDictionary* jsonObject) {
	if(jsonObject == nil) {
		return nil;
	}
	
	DDOutcomeRecord* outcomeRecord = [[DDOutcomeRecord alloc] init];
	
	// XXX 目前接口没有提供具体支出目标。
	NSString* target = nil;
	[outcomeRecord setTarget: target];
	
	NSDate* date = parseDate([jsonObject[@"use_time"] asString]);
	[outcomeRecord setDate: date];
	
	NSNumber* amount = [jsonObject[@"point"] asNumber];
	[outcomeRecord setAmount: amount];
	
	return outcomeRecord;
}
