#import "DDHomeViewController.h"

#import "ACConfirmingDialog.h"
#import "ACQueuedImageView.h"
#import "ASIDownloadCache.h"
#import "DDAngelViewController.h"
#import "DDAngelFundViewController.h"
#import "DDCampaignListViewController.h"
#import "DDEnvironment.h"
#import "DDLoginViewController.h"
#import "DDOrderListViewController.h"
#import "DDPasswordChangeViewController.h"
#import "DDQrcodeViewController.h"
#import "DDUser.h"
#import "DDUserInfoViewController.h"
#import "DDUtilities.h"



#define MENU_WIDTH (CGFloat)144

#define MENU_ANIMATION_DURATION (NSTimeInterval)0.3

#pragma mark -

@interface DDHomeViewController() {
	IBOutlet UIView* _mainView;
	IBOutlet ACQueuedImageView* _portraitImageView;
	IBOutlet UIButton* _menuButton;
	IBOutlet UIButton* _fuelingButton;
	IBOutlet UIButton* _logoButton;
	IBOutlet UIButton* _washingButton;
	IBOutlet UIButton* _maintainanceButton;
	IBOutlet UIButton* _repairingButton;
	IBOutlet UIButton* _orderListButton;
	IBOutlet UIButton* _mainMaskButton;
	
	IBOutlet UIView* _sideView;
	IBOutlet ACQueuedImageView* _sidePortraitImageView;
	IBOutlet UIButton* _sidePortraitButton;
	IBOutlet UIButton* _sideLoginButton;
	IBOutlet UIButton* _sideOrderListButton;
	IBOutlet UIButton* _sideAngelButton;
	IBOutlet UIButton* _sideAngelFundButton;
	IBOutlet UIButton* _sideUserInfoButton;
	IBOutlet UIButton* _sidePasswordChangeButton;
	IBOutlet UIButton* _sideClearCacheButton;
	IBOutlet UIButton* _sideContactUsButton;
	
	DDEnvironment* _environment;
	
	BOOL _sideVisible;
}

@property(nonatomic, assign) BOOL sideVisible;

@end

#pragma mark -

@implementation DDHomeViewController

- (instancetype)init {
	self = [super init];
	if(self != nil) {
		[super view];
		
		{
			CALayer* layer = [_mainView layer];
			[layer setShadowColor: [[UIColor blackColor] CGColor]];
			[layer setShadowRadius: 5];
			[layer setShadowOpacity: 0.5];
		}
		
		_environment = [DDEnvironment sharedInstance];
		[_environment addObserver: self forKeyPath: @"user" options: 0 context: NULL];
		[_environment addObserver: self forKeyPath: @"user.portraitImageFile" options: 0 context: NULL];
		[_environment addObserver: self forKeyPath: @"user.nickName" options: 0 context: NULL];
		
		[self updateUser];
		[self updatePortrait];
		[self updateNickName];
	}
	
	return self;
}

- (IBAction)handleButton: (UIButton*)button {
	if(button == _menuButton) {
		[self setSideVisible: TRUE animated: TRUE];
		
		return;
	}
	
	if(button == _mainMaskButton) {
		[self setSideVisible: FALSE animated: TRUE];
		
		return;
	}
	
	if(button == _fuelingButton) {
		[self goCampaignList];
		
		return;
	}
	
	if(button == _logoButton) {
		if([_environment user] == nil) {
			[self goLogin];
		}
		else {
			[self goPersonalIdentity];
		}
		
		return;
	}
	
	if(button == _orderListButton) {
		if([_environment user] == nil) {
			[self goLogin];
		}
		else {
			[self goOrderList];
		}
		
		return;
	}
	
	if(button == _sidePortraitButton) {
		if([_environment user] == nil) {
			[self goLogin];
		}
		else {
			[self goUserInfo];
		}
		
		return;
	}
	
	if(button == _sideLoginButton) {
		[self goLogin];
		
		return;
	}
	
	if(button == _sideOrderListButton) {
		if([_environment user] == nil) {
			[self goLogin];
		}
		else {
			[self goOrderList];
		}
		
		return;
	}
	
	if(button == _sideAngelFundButton) {
		if([_environment user] == nil) {
			[self goLogin];
		}
		else {
			[self goAngelFund];
		}
		
		return;
	}
	
	if(button == _sideUserInfoButton) {
		if([_environment user] == nil) {
			[self goLogin];
		}
		else {
			[self goUserInfo];
		}
		
		return;
	}
	
	if(button == _sidePasswordChangeButton) {
		if([_environment user] == nil) {
			[self goLogin];
		}
		else {
			[self goPasswordChange];
		}
		
		return;
	}
	
	if(button == _sideClearCacheButton) {
		[self clearCache];
		
		return;
	}
	
	if(button == _sideContactUsButton) {
		[self contactUs];
		
		return;
	}
}

@synthesize sideVisible = _sideVisible;

- (void)setSideVisible: (BOOL)sideVisible {
	[self setSideVisible: sideVisible animated: FALSE];
}

- (void)setSideVisible: (BOOL)sideVisible animated: (BOOL)animated {
	if(_sideVisible == sideVisible) {
		return;
	}
	
	_sideVisible = sideVisible;
	
	[_mainMaskButton setHidden: !sideVisible];
	
	[UIView transitionWithView: _mainView duration: animated ? MENU_ANIMATION_DURATION : 0 options: UIViewAnimationOptionBeginFromCurrentState animations: ^ {
		if(sideVisible) {
			[_mainView setTransform: CGAffineTransformMakeTranslation(MENU_WIDTH, 0)];
		}
		else {
			[_mainView setTransform: CGAffineTransformIdentity];
		}
	} completion: NULL];
}

- (void)updateUser {
	if([_environment user] == nil) {
		[_sideLoginButton setUserInteractionEnabled: TRUE];
	}
	else {
		[_sideLoginButton setUserInteractionEnabled: FALSE];
	}
}

- (void)updatePortrait {
	NSString* portraitImageFile = [[_environment user] portraitImageFile];
	if(portraitImageFile != nil) {
		[_portraitImageView setImageWithContentsOfFile: portraitImageFile];
		[_sidePortraitImageView setImageWithContentsOfFile: portraitImageFile];
	}
	else {
		[_portraitImageView setImage: [UIImage imageNamed: @"home~portrait_button"]];
		[_sidePortraitImageView setImage: [UIImage imageNamed: @"common~default_portrait"]];
	}
}

- (void)updateNickName {
	DDUser* user = [_environment user];
	if(user == nil) {
		[_sideLoginButton setTitle: @"登录" forState: UIControlStateNormal];
	}
	else {
		NSString* displayName = [user nickName];
		if([displayName length] == 0) {
			displayName = [user mobile];
		}
		
		[_sideLoginButton setTitle: displayName forState: UIControlStateNormal];
	}
}

- (void)goLogin {
	DDLoginViewController* loginViewController = [[DDLoginViewController alloc] init];
	[self push: loginViewController animated: TRUE];
}

- (void)goCampaignList {
   

	DDCampaignListViewController* campaignListViewController = [[DDCampaignListViewController alloc] init];
	[self push: campaignListViewController animated: TRUE];
}

- (void)goPersonalIdentity {
	NSString* title = @"身份识别码";
	NSString* qrcodeFile = [[_environment user] personalIdentityQrcodeFile];
	
	DDQrcodeViewController* qrcodeViewContorller = [[DDQrcodeViewController alloc] initWithTitle: title andQrcodeFile: qrcodeFile];
	[self push: qrcodeViewContorller animated: TRUE];
}

- (void)goOrderList {
	DDOrderListViewController* orderListViewController = [[DDOrderListViewController alloc] init];
	[self push: orderListViewController animated: TRUE];
}

- (void)goAngel {
	DDAngelViewController* angelViewController = [[DDAngelViewController alloc] init];
	[self push: angelViewController animated: TRUE];
}

- (void)goAngelFund {
	DDAngelFundViewController* angelFundViewController = [[DDAngelFundViewController alloc] init];
	[self push: angelFundViewController animated: TRUE];
}

- (void)goUserInfo {
	DDUserInfoViewController* userInfoViewController = [[DDUserInfoViewController alloc] init];
	[self push: userInfoViewController animated: TRUE];
}

- (void)goPasswordChange {
	DDPasswordChangeViewController* passwordChangeViewController = [[DDPasswordChangeViewController alloc] init];
	[self push: passwordChangeViewController animated: TRUE];
}

- (void)clearCache {
	[[ASIDownloadCache sharedCache] clearCachedResponsesForStoragePolicy: ASICachePermanentlyCacheStoragePolicy];
	
	alert(@"缓存已清除。");
}

- (void)contactUs {
	ACConfirmingDialog* dialog = [[ACConfirmingDialog alloc] init];
	[dialog setMessage: @"即将拨打我们的客服电话，是否继续？"];
	[dialog setConfirmButtonTitle: @"是"];
	[dialog setCancelButtonTitle: @"否"];
	[dialog setDismissHandler: ^(ACConfirmingDialog* dialog, BOOL confirmed) {
		if(confirmed) {
			[[UIApplication sharedApplication] openURL: [[NSURL alloc] initWithString: @"TEL://4001661666"]];
		}
	}];
	[dialog show];
}

- (void)goForward {
	[self setSideVisible: FALSE animated: TRUE];
}

- (void)goBack {
	[self setSideVisible: TRUE animated: TRUE];
}

- (void)viewWillDisappear: (BOOL)animated {
	[super viewWillDisappear: animated];
	
	[self setSideVisible: FALSE animated: animated];
}

- (void)observeValueForKeyPath: (NSString*)keyPath ofObject: (id)object change: (NSDictionary*)change context: (void*)context {
	if(object == _environment) {
		if([keyPath isEqualToString: @"user"]) {
			[self updateUser];
			
			return;
		}
		
		if([keyPath isEqualToString: @"user.portraitImageFile"]) {
			[self updatePortrait];
			
			return;
		}
		
		if([keyPath isEqualToString: @"user.nickName"]) {
			[self updateNickName];
			
			return;
		}
		
		return;
	}
}

- (void)dealloc {
	[_environment removeObserver: self forKeyPath: @"user"];
	[_environment removeObserver: self forKeyPath: @"user.portraitImageFile"];
	[_environment removeObserver: self forKeyPath: @"user.nickName"];
}

@end
