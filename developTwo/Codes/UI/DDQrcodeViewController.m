#import "DDQrcodeViewController.h"

#import "ACQueuedImageView.h"

@interface DDQrcodeViewController() {
	IBOutlet UIButton* _backButton;
	IBOutlet UILabel* _titleLabel;
	
	IBOutlet ACQueuedImageView* _qrcodeImageView;
}

@end

#pragma mark -

@implementation DDQrcodeViewController

- (instancetype)initWithTitle: (NSString*)title andQrcodeFile: (NSString*)qrcodeFile {
	self = [super init];
	if(self != nil) {
		[super view];
		
		[_titleLabel setText: title];
		
		[_qrcodeImageView setImage: nil];
		[_qrcodeImageView setImageWithContentsOfFile: qrcodeFile];
	}
	
	return self;
}

- (IBAction)handleButton: (UIButton*)button {
	if(button == _backButton) {
		[self goBack];
		
		return;
	}
}

@end
