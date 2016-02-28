#import <Foundation/Foundation.h>

@class DDVehicle;

// 用户。
@interface DDUser : NSObject

@property(nonatomic, copy) NSString* id;
@property(nonatomic, copy) NSString* mobile;
@property(nonatomic, copy) NSString* nickName;
@property(nonatomic, copy) NSString* portraitImageFile;
@property(nonatomic, copy) NSString* personalIdentityQrcodeFile;
@property(nonatomic, copy) NSString* customerAngelQrcodeFile;
@property(nonatomic, copy) NSString* businessAngelQrcodeFile;
@property(nonatomic, copy) NSString* accessToken;

@property(nonatomic, strong) DDVehicle* vehicle;

@end

#pragma mark -

DDUser* DDUserFromJsonObject(id jsonObject);
