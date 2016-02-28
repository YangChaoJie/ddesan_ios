#import "DDAngelViewController.h"

#import "DDEnvironment.h"
#import "DDQrcodeViewController.h"
#import "DDUser.h"

#define SUMMARY_TEXT_PATTERN @"天使的使命，就是让更多好友分享促销带来的实惠；你每行一善自有回报。\n推荐好友使用一善加油，获红包%g元。\n多多一善哦！\n加入办法，开通你的导引二维码，被推荐扫码加入使用，红包自动归入名下。"

@interface DDAngelViewController() {
	IBOutlet UIButton* _backButton;
	
	IBOutlet UILabel* _summaryLabel;
	
	IBOutlet UIButton* _customerAngelButton;
	IBOutlet UIButton* _businessAngelButton;
}

@end

#pragma mark -

@implementation DDAngelViewController

- (instancetype)init {
	self = [super init];
	if(self != nil) {
		[super view];
		
		{
			DDEnvironment* environment = [DDEnvironment sharedInstance];
			
			NSNumber* customerAngelPoint = [environment customerAngelPoint];
			[_summaryLabel setText: [[NSString alloc] initWithFormat: SUMMARY_TEXT_PATTERN, [customerAngelPoint doubleValue]]];
		}
	}
	
	return self;
}

- (IBAction)handleButton: (UIButton*)button {
	if(button == _backButton) {
		[self goBack];
		
		return;
	}
	
	if(button == _customerAngelButton) {
		[self goCustomerAngel];
		
		return;
	}
	
	if(button == _businessAngelButton) {
		[self goBusinessAngel];
		
		return;
	}
}

- (void)goCustomerAngel {
	NSString* title = @"好友推荐码";
	NSString* qrcodeFile = [[[DDEnvironment sharedInstance] user] customerAngelQrcodeFile];
	
	DDQrcodeViewController* qrcodeViewController = [[DDQrcodeViewController alloc] initWithTitle: title andQrcodeFile: qrcodeFile];
	[self push: qrcodeViewController animated: TRUE];
}

- (void)goBusinessAngel {
	NSString* title = @"油站推荐码";
	NSString* qrcodeFile = [[[DDEnvironment sharedInstance] user] businessAngelQrcodeFile];
	
	DDQrcodeViewController* qrcodeViewController = [[DDQrcodeViewController alloc] initWithTitle: title andQrcodeFile: qrcodeFile];
	[self push: qrcodeViewController animated: TRUE];
}

@end
