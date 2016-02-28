#import "DDUser.h"

#import "NSObject+JsonParsing.h"

@implementation DDUser

@end

#pragma mark -

DDUser* DDUserFromJsonObject(id jsonObject) {
	DDUser* user = [[DDUser alloc] init];
	
	NSString* id = [jsonObject[@"customer_id"] asString];
	[user setId: id];
	
	NSString* mobile = [jsonObject[@"phone"] asString];
	[user setMobile: mobile];
	
	NSString* nickname = [jsonObject[@"nick_name"] asString];
	[user setNickName: nickname];
	
	NSString* portraitImageFile = [jsonObject[@"icon"] asString];
	[user setPortraitImageFile: portraitImageFile];
	
	NSDictionary* jsonQrcodes = [jsonObject[@"qr"] asDictionary];
	
	NSString* personalIdentityQrcodeFile = [jsonQrcodes[@"personal"] asString];
	[user setPersonalIdentityQrcodeFile: personalIdentityQrcodeFile];
	
	NSString* customerAngelQrcodeFile = [jsonQrcodes[@"angelc"] asString];
	[user setCustomerAngelQrcodeFile: customerAngelQrcodeFile];
	
	NSString* businessAngelQrcodeFile = [jsonQrcodes[@"angelb"] asString];
	[user setBusinessAngelQrcodeFile: businessAngelQrcodeFile];
	
	NSString* accessToken = [jsonObject[@"access_token"] asString];
	[user setAccessToken: accessToken];
	
	return user;
}
