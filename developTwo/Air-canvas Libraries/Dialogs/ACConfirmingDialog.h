#import <Foundation/Foundation.h>

@class ACConfirmingDialog;

typedef void (^ACConfirmingDialogDismissHandler)(ACConfirmingDialog* confirmingDialog, BOOL confirmed);

#pragma mark -

@interface ACConfirmingDialog : NSObject

@property(nonatomic, copy) NSString* title;
@property(nonatomic, copy) NSString* message;
@property(nonatomic, copy) NSString* confirmButtonTitle;
@property(nonatomic, copy) NSString* cancelButtonTitle;
@property(nonatomic, copy) ACConfirmingDialogDismissHandler dismissHandler;

- (void)show;
- (void)dismiss;

@end
