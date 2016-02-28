#import "DDOrderCell.h"

#import <CoreLocation/CoreLocation.h>
#import "ACQueuedImageView.h"
#import "DDEnvironment.h"
#import "DDOrderRecord.h"
#import "DDStation.h"
#import "DDUtilities.h"

@interface DDOrderCell() {
	IBOutlet ACQueuedImageView* _photoImageView;
	
	IBOutlet UILabel* _nameLabel;
	
	IBOutlet UILabel* _secondaryLabel0;
	IBOutlet UILabel* _secondaryLabel1;
	
	IBOutlet UIImageView* _arrowImageView;
}

@end

#pragma mark -

@implementation DDOrderCell

- (void)reset {
	[_photoImageView setImage: nil];
	
	[_nameLabel setText: nil];
	
	[_secondaryLabel0 setText: nil];
	
	[_secondaryLabel1 setText: nil];
	
	[_arrowImageView setHidden: FALSE];
}

- (void)setOrderRecord: (DDOrderRecord*)orderRecord Dictary:(NSDictionary*)dict{
    self.dict=dict;
    
	_orderRecord = orderRecord;
	
	NSString* stationImageFile = [[orderRecord station] photoImageFile];
	[_photoImageView setImageWithContentsOfFile: stationImageFile];
	
	NSString* stationName = [[orderRecord station] name];
	[_nameLabel setText: stationName];
	
	NSString* fuelType = [orderRecord fuelType];
	NSNumber* discountedPrice = [orderRecord discountedPrice];
    
    
    NSString*s =[self.dict objectForKey:fuelType];
	if(fuelType != nil && discountedPrice != nil) {
		[_secondaryLabel0 setText: [[NSString alloc] initWithFormat: @"%@　总价：¥%d", s, [discountedPrice intValue]]];
	}
	else {
		[_secondaryLabel0 setText: @"未下单"];
	}
	
	NSNumber* state = [orderRecord state];
	if(state != nil) {
		switch([state integerValue]) {
			case DDOrderRecordStateProcessing:
			{
				[_secondaryLabel1 setText: @"未支付"];
				
				break;
			}
			
			case DDOrderRecordStateFinished:
			{
				NSNumber* score = [orderRecord score];
				if(score == nil) {
					[_secondaryLabel1 setText: @"待评价"];
				}
				else {
					[_secondaryLabel1 setText: @"已完成"];
				}
				
				break;
			}
			
			case DDOrderRecordStateCanceled:
			{
				[_secondaryLabel1 setText: @"已取消"];
				
				[_arrowImageView setHidden: TRUE];
				
				break;
			}
			
			case DDOrderRecordStateBooking:
			{
				[_secondaryLabel1 setText: @"报名成功"];
				
				break;
			}
			
			case DDOrderRecordStateFailed:
			{
				[_secondaryLabel1 setText: @"已过期"];
				
				[_arrowImageView setHidden: TRUE];
				
				break;
			}
			
			default:
			{
				// Do nothing.
				
				break;
			}
		}
	}
}

- (void)prepareForReuse {
	[super prepareForReuse];
	
	[self reset];
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	[self reset];
}

@end
