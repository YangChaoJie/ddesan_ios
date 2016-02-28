#import <Foundation/Foundation.h>

@class ACMessageDialog;

typedef void (^ACMessageDialogDismissHandler)(ACMessageDialog* messageDialog);

#pragma mark -

@interface ACMessageDialog : NSObject

@property(nonatomic, copy) NSString* title;
@property(nonatomic, copy) NSString* message;
@property(nonatomic, copy) NSString* cancelButtonTitle;
@property(nonatomic, copy) ACMessageDialogDismissHandler dismissHandler;

- (void)show;
- (void)dismiss;

@end
