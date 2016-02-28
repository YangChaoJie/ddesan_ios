#import "ACConfirmingDialog.h"

#import <UIKit/UIKit.h>

@interface ACConfirmingDialog()<UIAlertViewDelegate> {
	NSString* _title;
	NSString* _message;
	NSString* _confirmButtonTitle;
	NSString* _cancelButtonTitle;
	ACConfirmingDialogDismissHandler _dismissHandler;
	
	id _retainedSelf;
	
	UIAlertView* _alertView;
}

@end

#pragma mark -

@implementation ACConfirmingDialog

@synthesize title = _title;

@synthesize message = _message;

@synthesize confirmButtonTitle = _confirmButtonTitle;

@synthesize cancelButtonTitle = _cancelButtonTitle;

@synthesize dismissHandler = _dismissHandler;

- (void)show {
	assert(_alertView == nil);
	
	_retainedSelf = self;
	
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: _title message: _message delegate: self cancelButtonTitle: _cancelButtonTitle otherButtonTitles: _confirmButtonTitle, nil];
	
	_alertView = alertView;
	
	[alertView show];
}

- (void)dismiss {
	[_alertView dismissWithClickedButtonIndex: -1 animated: FALSE];
}

- (void)alertView: (UIAlertView*)alertView didDismissWithButtonIndex: (NSInteger)buttonIndex {
	assert(alertView == _alertView);
	
	if(buttonIndex >= 0) {
		if(_dismissHandler != nil) {
			_dismissHandler(self, buttonIndex != [alertView cancelButtonIndex]);
		}
	}
	
	_retainedSelf = nil;
	
	_alertView = nil;
}

@end
