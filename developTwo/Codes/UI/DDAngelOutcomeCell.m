#import "DDAngelOutcomeCell.h"

#import "DDOutcomeRecord.h"

static NSString* formatDate(NSDate* date) {
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat: @"yyyy-MM-dd"];
	[dateFormatter setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: 28800]];
	
	NSString* string = [dateFormatter stringFromDate: date];
	
	return string;
}

static NSString* formatCurrency(NSNumber* amount) {
	NSString* string = [[NSString alloc] initWithFormat: @"¥%.02f", [amount doubleValue]];
	
	return string;
}

#pragma mark -

@interface DDAngelOutcomeCell() {
	IBOutlet UILabel* _targetLabel;
	IBOutlet UILabel* _dateLabel;
	IBOutlet UILabel* _amountLabel;
}

@end

#pragma mark -

@implementation DDAngelOutcomeCell

- (void)setOutcomeRecord: (DDOutcomeRecord*)outcomeRecord {
	_outcomeRecord = outcomeRecord;
	
	NSString* target = [outcomeRecord target];
	[_targetLabel setText: target];
	
	NSDate* date = [outcomeRecord date];
	[_dateLabel setText: formatDate(date)];
	
	NSNumber* amount = [outcomeRecord amount];
	[_amountLabel setText: formatCurrency(amount)];
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	[self reset];
}

- (void)prepareForReuse {
	[super prepareForReuse];
	
	[self reset];
}

- (void)reset {
	[_targetLabel setText: nil];
	[_dateLabel setText: nil];
	[_amountLabel setText: nil];
}

@end
