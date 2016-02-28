#import "DDOrderOfflineViewController.h"

#import "ACQueuedImageView.h"
#import "DDDefinitions.h"
#import "DDEnvironment.h"
#import "DDOrderFinishedViewController.h"
#import "DDOrderListViewController.h"
#import "DDOrderViewController.h"
#import "DDOrderRecord.h"
#import "DDStation.h"
#import "DDUser.h"

#import "DDUtilities.h"
#import "ASIFormDataRequest.h"
#import "DDOrderRecord.h"
#import "NSObject+JsonParsing.h"

#import "DDRootViewController.h"
#import "DDCampaignListViewController.h"

#import "ZMLoadingView.h"

@interface DDOrderOfflineViewController()<ASIHTTPRequestDelegate> {
	DDOrderRecord* _orderRecord;
	
	IBOutlet UIButton* _backButton;
	IBOutlet UIButton* _modifyButton;
	
	IBOutlet ACQueuedImageView* _qrcodeImageView;
	
	IBOutlet UILabel* _stationLabel;
	IBOutlet UILabel* _tubeLabel;
	IBOutlet UILabel* _fuelTypeLabel;
	IBOutlet UILabel* _amountLabel;
	IBOutlet UILabel* _originalPriceLabel;
	IBOutlet UILabel* _discountageLabel;
	IBOutlet UILabel* _discountedPriceLabel;
    
    __weak IBOutlet UIButton *_paymentButton;
}

@end

#pragma mark -

@implementation DDOrderOfflineViewController

- (instancetype)initWithOrderRecord: (DDOrderRecord*)orderRecord Dictary:(NSDictionary *)dict{
    //
    self.dict=dict;
    
	self = [super init];
	if(self != nil) {
		_orderRecord = orderRecord;
		
		[super view];
		
		[_qrcodeImageView setImage: nil];
		[_qrcodeImageView setImageWithContentsOfFile: [[[DDEnvironment sharedInstance] user] personalIdentityQrcodeFile]];
		
		NSString* stationName = [[_orderRecord station] name];
		[_stationLabel setText: [[NSString alloc] initWithFormat: @"付予：%@", stationName]];
		
		NSNumber* tubeNumber = [_orderRecord tubeNumber];
		[_tubeLabel setText: [[NSString alloc] initWithFormat: @"%d#", [tubeNumber intValue]]];

		NSString* fuelType = [_orderRecord fuelType];
        
        NSString*s=[self.dict objectForKey:fuelType];
		[_fuelTypeLabel setText: s];
		
		double fuelAmount = [[_orderRecord fuelAmount] doubleValue];
		[_amountLabel setText: [[NSString alloc] initWithFormat: @"%.2fL", fuelAmount]];
		
		NSInteger originalPrice = [[_orderRecord originalPrice] integerValue];
		NSInteger discountedPrice = [[_orderRecord discountedPrice] integerValue];
		NSInteger discountage = originalPrice - discountedPrice;
		
		[_originalPriceLabel setText: [[NSString alloc] initWithFormat: @"¥%d", (int)originalPrice]];
		[_discountageLabel setText: [[NSString alloc] initWithFormat: @"¥%d", (int)discountage]];
		[_discountedPriceLabel setText: [[NSString alloc] initWithFormat: @"¥%d", (int)discountedPrice]];
		
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(paymentSettled:) name: kSettlementNotification object: nil];
	}
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _paymentButton.center = CGPointMake(CGRectGetWidth([UIScreen mainScreen].bounds)/2, _paymentButton.center.y);
}

- (void)setModifyButtonEnabled: (BOOL)enabled {
	[_modifyButton setHidden: !enabled];
}

- (IBAction)handleButton: (UIButton*)button {
	if(button == _backButton) {
        
        DDRootViewController* rootViewController = [DDRootViewController sharedInstance];
        
        NSArray *viewControllers = rootViewController.viewControllers;
        
        UIViewController *targetViewController = nil;
        
        for (UIViewController* itemViewController in viewControllers) {
            if ([itemViewController isKindOfClass: [DDCampaignListViewController class]] || [itemViewController isKindOfClass: [DDOrderListViewController class]]) {
                targetViewController = itemViewController;
                break;
            }
        }
        
        if (targetViewController != nil) {
            [rootViewController popToViewController: targetViewController animated: true];
            return;
        }
        
		[self goBack];
		
		return;
	}
	
	if(button == _modifyButton) {
		[self goOrder];
		
		return;
	}
}

- (void)goOrder {
	DDOrderViewController* orderViewController = [[DDOrderViewController alloc] initWithOrderRecord: _orderRecord Dictary:self.dict];
	[self switchTo: orderViewController animated: TRUE];
}

- (void)paymentSettled: (NSNotification*)notification {
	DDOrderRecord* orderRecord = [notification userInfo][@"ORDER"];
	
	DDOrderFinishedViewController* orderFinishedViewController = [[DDOrderFinishedViewController alloc] initWithOrderRecord: orderRecord Dictray:self.dict];
	[self switchTo: orderFinishedViewController animated: TRUE];
}

- (IBAction)checkPayment:(UIButton *)sender {
    
//    NSLog(@"检查是否支付");
    
    DDEnvironment *environment = [DDEnvironment sharedInstance];
    NSString *token = environment.user.accessToken;
    
    NSString *orderCode = _orderRecord.code;
    
    if (token && orderCode) {
        
        NSDictionary* requestParameters = @{@"access_token":token, @"order_code":orderCode};
        
        NSString* requestString = NSStringFromJsonObject(requestParameters);
//        NSLog(@"IN - %@", requestString);
        
        NSURL* requestUrl = getOrderDetailUrl();
        
        ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL: requestUrl];
        [request setDelegate: self];
        [request setPostValue: requestString forKey: @"data"];
        [request startAsynchronous];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request {

    [[ZMLoadingView sharedInstance] stopLoading];
    
    NSData* responseData = [request responseData];
    if (responseData) {
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData: responseData options:NSJSONReadingMutableContainers error: nil];
        
        NSDictionary *dataDictionary = responseDictionary[@"data"];
        
        if (dataDictionary) {
            
            DDOrderRecord* orderRecord = DDOrderRecordFromJsonObject(dataDictionary);
            NSDictionary *campaignOrderDictionary = dataDictionary[@"CampaignOrder"];
            
            NSInteger state = [campaignOrderDictionary[@"status"] integerValue];
            NSInteger pay_status = [campaignOrderDictionary[@"pay_status"] integerValue];
            
            if (state == 2 && pay_status == 1) {
                
                DDOrderFinishedViewController* orderFinishedViewController = [[DDOrderFinishedViewController alloc] initWithOrderRecord: orderRecord Dictray:self.dict];
                [self switchTo: orderFinishedViewController animated: TRUE];
                return;
            }
        }
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message: @"订单未支付完成" delegate: nil cancelButtonTitle: nil otherButtonTitles: @"关闭", nil];
    [alertView show];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    
    [[ZMLoadingView sharedInstance] stopLoading];
}

- (void)requestStarted:(ASIHTTPRequest *)request {
    
    [[ZMLoadingView sharedInstance] loadingViewShowTips: @"检验中..." andWithEnable: YES];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end
