#import "DDAngelIncomeCell.h"

#import "DDIncomeRecord.h"

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

@interface DDAngelIncomeCell() {
	IBOutlet UILabel* _sourceLabel;
	IBOutlet UILabel* _dateLabel;
	IBOutlet UILabel* _amountLabel;
}

@end

#pragma mark -

@implementation DDAngelIncomeCell

- (void)setIncomeRecord: (DDIncomeRecord*)incomeRecord {
	_incomeRecord = incomeRecord;
	
	NSString* source = [incomeRecord source];
	[_sourceLabel setText: source];
	
	NSDate* date = [incomeRecord date];
	[_dateLabel setText: formatDate(date)];
	
	NSNumber* amount = [incomeRecord amount];
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
	[_sourceLabel setText: nil];
	[_dateLabel setText: nil];
	[_amountLabel setText: nil];
}

@end
