#import <UIKit/UIKit.h>

@interface UIImage(Cache)

+ (UIImage*)cachedImageWithContentsOfFile: (NSString*)file;
+ (void)clearCacheForFile: (NSString*)file;
+ (void)clearAllCaches;

@end
