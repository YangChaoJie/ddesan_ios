#import "ACQueuedImageView.h"

#import "ACWeakReference.h"
#import "ASICacheDelegate.h"
#import "ASIDownloadCache.h"
#import "ASIHTTPRequest.h"
#import "UIImage+Cache.h"

#define _condition QueuedImageView_condition
#define _queue QueuedImageView_queue
#define _thread QueuedImageView_thread

static NSCondition* _condition;
static NSMutableArray* _queue;
static NSThread* _thread;

#pragma mark -

@interface ACQueuedImageView()<ASIHTTPRequestDelegate> {
	id<ACQueuedImageViewDelegate> __weak _delegate;
	
	NSString* _file;
	
	ASIHTTPRequest* _request;
	
	UIActivityIndicatorView* _indicator;
    
}

+ (void)dealWithQueue;

- (void)addToQueue;

- (void)loadInBackground;
- (void)loadingFinishedWithImage: (UIImage*)image;

@end

#pragma mark -

@implementation ACQueuedImageView

+ (void)dealWithQueue {
	while(TRUE) {
		@autoreleasepool {
			ACWeakReference* weakReference = nil;
			
			[_condition lock];
			
			if([_queue count] != 0) {
				weakReference = [_queue objectAtIndex: 0];
				[_queue removeObjectAtIndex: 0];
			}
			
			if(weakReference == nil) {
				[_condition wait];
			}
			
			[_condition unlock];
			
			if(weakReference != nil) {
				ACQueuedImageView* queuedImageView = [weakReference object];
				[queuedImageView loadInBackground];
			}
		}
	}
}

@synthesize delegate = _delegate;

- (void)setImageWithContentsOfFile: (NSString*)file {
	_file = file;
	
	if(_request != nil) {
		[_request clearDelegatesAndCancel];
		_request = nil;
	}
	
	if(_indicator == nil) {
		CGRect bounds = [self bounds];
		
		UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
		[indicator setAutoresizingMask: UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin];
		[indicator setCenter: CGPointMake(CGRectGetWidth(bounds) / 2, CGRectGetHeight(bounds) / 2)];
		[self addSubview: indicator];
		
		_indicator = indicator;
	}
	
	if([self image] == nil) {
		[_indicator startAnimating];
	}
	
	[self addToQueue];
}

- (void)addToQueue {
	// Initialize static data if needed.
	
	static dispatch_once_t predicate;
	dispatch_once(&predicate, ^{
		_condition = [NSCondition new];
		_queue = [NSMutableArray new];
		_thread = [[NSThread alloc] initWithTarget: [ACQueuedImageView class] selector: @selector(dealWithQueue) object: nil];
		[_thread start];
	});
	
	// Add weak reference of self into the queue and notify the flow thread, if not already in the queue.
	
	[_condition lock];
	
	BOOL exists = FALSE;
	for(ACWeakReference* weakReference in _queue) {
		if([weakReference object] == self) {
			exists = TRUE;
		}
	}
	
	if(!exists) {
		[_queue addObject: [ACWeakReference weakReferenceForObject: self]];
	}
	
	[_condition signal];
	
	[_condition unlock];
}

- (void)loadInBackground {
	if([_file hasPrefix: @"http://"] || [_file hasPrefix: @"https://"]) {
		dispatch_sync(dispatch_get_main_queue(), ^{
			ASIHTTPRequest* request = [[ASIHTTPRequest alloc] initWithURL: [NSURL URLWithString: _file]];
			[request setCachePolicy: ASIOnlyLoadIfNotCachedCachePolicy | ASIFallbackToCacheIfLoadFailsCachePolicy];
			[request setCacheStoragePolicy: ASICachePermanentlyCacheStoragePolicy];
			[request setDelegate: self];
			[request startAsynchronous];
			
			_request = request;
		});
	}
	else {
		UIImage* image = [UIImage cachedImageWithContentsOfFile: _file];
		if(image != nil) {
			dispatch_sync(dispatch_get_main_queue(), ^{
				[self loadingFinishedWithImage: image];
			});
		}
	}
}

- (void)loadingFinishedWithImage: (UIImage*)image {
	[self setImage: image];
	
	if([_delegate respondsToSelector: @selector(queuedImageView:hasFinishedLoadingWithImage:)]) {
		[_delegate queuedImageView: self hasFinishedLoadingWithImage: image];
	}
}

- (void)setImage: (UIImage*)image {
	[super setImage: image];
	
	if(_request != nil) {
		[_request clearDelegatesAndCancel];
		_request = nil;
	}
	
	[_indicator stopAnimating];
}

- (void)requestFinished: (ASIHTTPRequest*)request {
	if(_request == request) {
		if([request responseStatusCode] == 200) {
			UIImage* image = [UIImage imageWithData: [request responseData]];
			[self loadingFinishedWithImage: image];
		}
		
		_request = nil;
	}
}

- (void)requestFailed: (ASIHTTPRequest*)request {
	if(_request == request) {
		_request = nil;
	}
}

- (void)dealloc {
	if(_request != nil) {
		[_request clearDelegatesAndCancel];
		_request = nil;
	}
}

@end
