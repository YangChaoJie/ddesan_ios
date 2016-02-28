#import "DDRegularCampaignCell.h"

#import "DDRegularCampaign.h"

@interface DDRegularCampaignCell() {
	IBOutlet UIImageView* _stationPictureImageView;
	
	IBOutlet UILabel* _stationNameLabel;
	IBOutlet UILabel* _fuelNameAndPriceLabel0;
	IBOutlet UILabel* _fuelNameAndPriceLabel1;
	
	IBOutlet UILabel* _distanceLabel;
	IBOutlet UILabel* _fuelDiscountLabel0;
	IBOutlet UILabel* _fuelDiscountLabel1;
	
	DDRegularCampaign* _campaign;
}

@end

#pragma mark -

@implementation DDRegularCampaignCell

@synthesize campaign = _campaign;

- (void)awakeFromNib {
	[super awakeFromNib];
	
	// TODO
}

@end
