#import "DDPriceCell.h"

@interface DDPriceCell() {
	IBOutlet UILabel* _priceLabel;
}

@end

#pragma mark -

@implementation DDPriceCell

@synthesize price = _price;

- (void)setPrice: (NSNumber*)price {
	_price = [price copy];
	
	if(price == nil) {
		[_priceLabel setText: nil];
	}
	else {
		[_priceLabel setText: [[NSString alloc] initWithFormat: @"¥%d", [price intValue]]];
	}
}

- (void)awakeFromNib {
	[_priceLabel setText: nil];
}

@end
