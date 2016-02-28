#import "DDAnchorView.h"

@implementation DDAnchorView

- (BOOL)pointInside: (CGPoint)point withEvent: (UIEvent*)event {
	return TRUE;
}

- (UIView*)hitTest: (CGPoint)point withEvent: (UIEvent*)event {
	UIView* target = [super hitTest: point withEvent: event];
	if(target == self) {
		target = nil;
	}
	
	return target;
}

@end
