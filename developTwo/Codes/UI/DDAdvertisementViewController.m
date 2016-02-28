#import "DDAdvertisementViewController.h"

#import "DDHomeViewController.h"

@interface DDAdvertisementViewController() {
	IBOutlet UIImageView* _imageView;
}

@end

#pragma mark -

@implementation DDAdvertisementViewController

- (instancetype)initWithImage: (UIImage*)image {
	self = [super init];
	if(self != nil) {
		[super view];
		
		[_imageView setImage: image];
	}
	
	return self;
}

- (void)goHome {
	DDHomeViewController* homeViewController = [[DDHomeViewController alloc] init];
	[self switchTo: homeViewController animated: FALSE];
}

- (void)viewDidAppear: (BOOL)animated {
	[super viewDidAppear: animated];
	
	[self performSelector: @selector(goHome) withObject: nil afterDelay: 3];
}

@end
