#import "DDHotCampaignCell.h"

#import <CoreLocation/CoreLocation.h>
#import "ACQueuedImageView.h"
#import "DDEnvironment.h"
#import "DDHotCampaign.h"
#import "DDStation.h"
#import "DDUtilities.h"

@interface DDHotCampaignCell() {
	IBOutlet ACQueuedImageView* _stationImageView;
	
	IBOutlet UILabel* _stationNameLabel;
	IBOutlet UILabel* _campaignSummaryLabel;
	IBOutlet UIButton* _availabilityButton;
	
	IBOutlet UILabel* _distanceLabel;
	IBOutlet UIButton* _quotaButton;
	
	DDHotCampaign* _campaign;
}

@end

#pragma mark -

@implementation DDHotCampaignCell

@synthesize campaign = _campaign;

- (void)setCampaign: (DDHotCampaign*)campaign {
	_campaign = campaign;
	
	DDStation* station = [campaign station];
	
	NSString* stationImageFile = [station imageFile];
	[_stationImageView setImage: nil];
	[_stationImageView setImageWithContentsOfFile: stationImageFile];
	
	NSString* stationName = [station name];
	[_stationNameLabel setText: stationName];
	
	CLLocation* userLocation = [[DDEnvironment sharedInstance] location];
	CLLocation* stationLocation = [[CLLocation alloc] initWithLatitude: [[station latitude] doubleValue] longitude: [[station longitude] doubleValue]];
	CLLocationDistance distance = [stationLocation distanceFromLocation: userLocation];
	[_distanceLabel setText: formatDistance(distance)];
	
	double priceCutPerLiter = [[campaign priceCutPerLiter] doubleValue];
	int amountLimitInLiter = [[campaign amountLimitInLiter] intValue];
	[_campaignSummaryLabel setText: [[NSString alloc] initWithFormat: @"每升减%.02f元，限%d升", priceCutPerLiter, amountLimitInLiter]];
	
	NSInteger remainingQuota = [[campaign remainingQuota] integerValue];
	BOOL available = remainingQuota > 0;
	[_availabilityButton setEnabled: available];
	[_quotaButton setTitle: [[NSString alloc] initWithFormat: @"%d", (int)remainingQuota] forState: UIControlStateNormal];
	[_quotaButton setEnabled: available];
	
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	[self setCampaign: nil];
}

- (void)prepareForReuse {
	[super prepareForReuse];
	
	[self setCampaign: nil];
}

@end
