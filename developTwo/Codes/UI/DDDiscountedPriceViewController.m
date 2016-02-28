#import "DDDiscountedPriceViewController.h"

#import "DDEnvironment.h"
#import "DDOrderViewController.h"
#import "DDPriceCell.h"

#define PRICE_CELL_REUSE_IDENTIFIER @"PRICE"

#pragma mark -

@interface DDDiscountedPriceViewController()<UITableViewDataSource, UITableViewDelegate> {
	NSInteger _floor;
	NSInteger _ceiling;
	
	NSInteger _step;
	
	IBOutlet UIButton* _backButton;
	IBOutlet UITableView* _priceTableView;
}

@end

#pragma mark -

@implementation DDDiscountedPriceViewController

- (instancetype)initWithFloor: (NSInteger)floor andCeiling: (NSInteger)ceiling {
	self = [super init];
	if(self != nil) {
		_floor = floor;
		_ceiling = ceiling;
		
		_step = [[[DDEnvironment sharedInstance] priceStep] integerValue];
		if(_step <= 0) {
			_step = 10;
		}
		
		[super view];
	}
	
	return self;
}

- (IBAction)handleButton: (UIButton*)button {
	if(button == _backButton) {
		[self goBack];
		
		return;
	}
}

- (NSInteger)tableView: (UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
	if(tableView == _priceTableView) {
		if(section == 0) {
			return MAX((_ceiling - _floor) / _step + 1, 0);
		}
		
		return 0;
	}
	
	return 0;
}

- (UITableViewCell*)tableView: (UITableView*)tableView cellForRowAtIndexPath: (NSIndexPath*)indexPath {
	if(tableView == _priceTableView) {
		NSInteger section = [indexPath section];
		if(section == 0) {
			NSInteger row = [indexPath row];
			NSInteger price = _floor + _step * row;
			
			DDPriceCell* priceCell = [tableView dequeueReusableCellWithIdentifier: PRICE_CELL_REUSE_IDENTIFIER];
			if(priceCell == nil) {
				priceCell = [[NSBundle mainBundle] loadNibNamed: NSStringFromClass([DDPriceCell class]) owner: nil options: 0][0];
			}
			[priceCell setPrice: [[NSNumber alloc] initWithInteger: price]];
			
			return priceCell;
		}
		
		return nil;
	}
	
	return nil;
}

- (void)tableView: (UITableView*)tableView didSelectRowAtIndexPath: (NSIndexPath*)indexPath {
	if(tableView == _priceTableView) {
		NSInteger section = [indexPath section];
		if(section == 0) {
			NSInteger row = [indexPath row];
			NSInteger price = _floor + _step * row;
			
			DDChildViewController* previousViewController = [self previousViewController];
			if([previousViewController isKindOfClass: [DDOrderViewController class]]) {
				[(DDOrderViewController*)previousViewController setDiscountedPrice: [[NSNumber alloc] initWithInteger: price]];
			}
			
			[self goBack];
			
			return;
		}
		
		return;
	}
}

@end
