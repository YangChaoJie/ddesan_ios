#import "UIImage+Cache.h"

#import "ACWeakMap.h"

@implementation UIImage(Cache)

static NSMutableDictionary* UIImage_cachedImages;

+ (UIImage*)cachedImageWithContentsOfFile: (NSString*)file {
#if TRUE
	if(file == nil) {
		return nil;
	}
	
	static dispatch_once_t predicate = 0;
	dispatch_once(&predicate, ^{
		UIImage_cachedImages = [NSMutableDictionary new];
	});
	
	UIImage* image = nil;
	
	// Note:
	// Methods of ACWeakMap are not synchronized.  As we are going to use it in multi-threads, we should synchronize it explicitly.
	@synchronized(UIImage_cachedImages) {
		image = [UIImage_cachedImages objectForKey: file];
		if(image == nil) {
			image = [UIImage imageWithContentsOfFile: file];
			if(image != nil) {
				[UIImage_cachedImages setObject: image forKey: file];
			}
		}
	}
	
	return image;
#else
	// In case that the cache usage appears to be problematic...
	return [UIImage imageWithContentsOfFile: file];
#endif
}

+ (void)clearCacheForFile: (NSString*)file {
	@synchronized(UIImage_cachedImages) {
		[UIImage_cachedImages removeObjectForKey: file];
	}
}

+ (void)clearAllCaches {
	@synchronized(UIImage_cachedImages) {
		[UIImage_cachedImages removeAllObjects];
	}
}

@end
