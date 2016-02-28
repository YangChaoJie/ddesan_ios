#import "DDCampaigningStationCell.h"

#import <CoreLocation/CoreLocation.h>
#import "ACQueuedImageView.h"
#import "DDCampaign.h"
#import "DDCampaigningStation.h"
#import "DDEnvironment.h"
#import "DDHotCampaign.h"
#import "DDRegularCampaign.h"
#import "DDStation.h"
#import "DDUtilities.h"

@interface DDCampaigningStationCell() {
	IBOutlet ACQueuedImageView* _photoImageView;
	
	IBOutlet UILabel* _nameLabel;
	IBOutlet UILabel* _distanceLabel;
	
	IBOutlet UILabel* _secondaryLabel0;
	IBOutlet UILabel* _secondaryLabel1;
	IBOutlet UILabel* _secondaryLabel2;
	IBOutlet UILabel* _secondaryLabel3;
	
	IBOutlet UIButton* _bookingButton;
}

@end

#pragma mark -

@implementation DDCampaigningStationCell


- (void)setCampaigningStation: (DDCampaigningStation*)campaigningStation Dictionary:(NSDictionary*)dict{
   
    
    
    
	if(_campaigningStation == campaigningStation) {
		return;
	}
	
	_campaigningStation = campaigningStation;
	
	[self reset];
	
	DDCampaign* campaign = [campaigningStation campaign];
	DDStation* station = [campaigningStation station];
	
	NSString* stationPhotoImageFile = [station photoImageFile];
	[_photoImageView setImageWithContentsOfFile: stationPhotoImageFile];
	
	NSString* stationName = [station name];
	[_nameLabel setText: stationName];
	
	CLLocation* userLocation = [[DDEnvironment sharedInstance] location];
	CLLocation* stationLocation = [station location];
	if(userLocation != nil && stationLocation != nil) {
		[_distanceLabel setText: formatDistance([userLocation distanceFromLocation: stationLocation])];
	}
	//
    
    
    
	NSString* fuelType0 = nil;
	NSString* fuelType1 = nil;
    
    
	{
		NSArray* fuelTypes = [station fuelTypes];
		NSInteger fuelTypeCount = [fuelTypes count];
		do {
			if(fuelTypeCount == 0) {
				break;
			}
			
			fuelType0 = fuelTypes[0];
			
			if(fuelTypeCount == 1) {
				break;
			}
			
			fuelType1 = fuelTypes[1];
		} while(FALSE);
	}
	
	if([campaign isKindOfClass: [DDHotCampaign class]]) {
		[_bookingButton setHidden: FALSE];
		
		DDHotCampaign* hotCampaign = (DDHotCampaign*)campaign;
		NSDictionary* fuelPriceCuts = [hotCampaign fuelPriceCuts];
		
		if(fuelType0 != nil) {
			NSNumber* priceCut0 = fuelPriceCuts[fuelType0];
            //
            
            NSString*s1=[dict objectForKey:fuelType0];
			if(priceCut0 != nil) {
				[_secondaryLabel0 setText: [[NSString alloc] initWithFormat: @"%@ 每升减%.02f元", s1, [priceCut0 doubleValue]]];
			}
		}
		
		if(fuelType1 != nil) {
			NSNumber* priceCut1 = fuelPriceCuts[fuelType1];
            //
            NSString*s2=[dict objectForKey:fuelType1];
            NSLog(@"s2=%@",s2);
			if(priceCut1 != nil) {
				[_secondaryLabel1 setText: [[NSString alloc] initWithFormat: @"%@ 每升减%.02f元", s2, [priceCut1 doubleValue]]];
			}
		}
	}
	else if([campaign isKindOfClass: [DDRegularCampaign class]]) {
		[_secondaryLabel2 setHidden: FALSE];
		[_secondaryLabel3 setHidden: FALSE];
		
		DDRegularCampaign* regularCampaign = (DDRegularCampaign*)campaign;
		NSDictionary* fuelPrices = [station fuelPrices];
		NSDictionary* fuelPriceCuts = [regularCampaign fuelPriceCuts];
		
		if(fuelType0 != nil) {
            //NSLog(@"%@",fuelPrices);
			NSString* price0 = [fuelPrices[fuelType0]stringValue];
            NSString*s1=[dict objectForKey:fuelType0];
           // NSLog(@"%@price0",price0);
			if(fuelPrices) {
				[_secondaryLabel0 setText: [[NSString alloc] initWithFormat: @"%@ ¥%.02f/L", s1, [price0 doubleValue]]];
			}
			
			NSString* priceCut0 = fuelPriceCuts[fuelType0];
            NSLog(@"%@",priceCut0);
			if(priceCut0 != nil) {
				[_secondaryLabel2 setText: [[NSString alloc] initWithFormat: @"减¥%.02f/L", [priceCut0 doubleValue]]];
			}
		}
		
		if(fuelType1 != nil) {
			NSString* price1 = fuelPrices[fuelType1];
             NSString*s2=[dict objectForKey:fuelType1];
			if(price1 != nil) {
				[_secondaryLabel1 setText: [[NSString alloc] initWithFormat: @"%@ ¥%.02f/L", s2,  [price1 doubleValue]]];
			}
			
			NSNumber* priceCut1 = fuelPriceCuts[fuelType1];
			if(priceCut1 != nil) {
				[_secondaryLabel3 setText: [[NSString alloc] initWithFormat: @"减¥%.02f/L", [priceCut1 doubleValue]]];
			}
		}
	}
}

- (void)reset {
	[_photoImageView setImage: nil];
	
	[_nameLabel setText: nil];
	
	[_distanceLabel setText: nil];
	
	[_secondaryLabel0 setText: nil];
	
	[_secondaryLabel1 setText: nil];
	
	[_secondaryLabel2 setText: nil];
	[_secondaryLabel2 setHidden: TRUE];
	
	[_secondaryLabel3 setText: nil];
	[_secondaryLabel3 setHidden: TRUE];
	
	[_bookingButton setHidden: TRUE];
}

- (void)prepareForReuse {
	[super prepareForReuse];
	
	[self setCampaigningStation: nil];
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	[self reset];
}

@end
