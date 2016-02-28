#import <UIKit/UIKit.h>

@protocol ACQueuedImageViewDelegate;

#pragma mark -

@interface ACQueuedImageView : UIImageView

@property(nonatomic, weak) id<ACQueuedImageViewDelegate> delegate;

- (void)setImageWithContentsOfFile: (NSString*)file;

@end

#pragma mark -

@protocol ACQueuedImageViewDelegate<NSObject>

@optional

- (void)queuedImageView: (ACQueuedImageView*)queuedImageView hasFinishedLoadingWithImage: (UIImage*)image;

@end
