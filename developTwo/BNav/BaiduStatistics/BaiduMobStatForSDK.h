//
//  BaiduMobStat.h
//  百度移动统计iOS SDK所有功能Api接口头文件
//
//  Created by Baidu on 14-05-27.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIViewController;

/**
 *  百度移动应用统计接口,更多信息请查看[百度移动统计](http://mtj.baidu.com)
 */
@interface BaiduMobStatForSDK : NSObject

/**
 *  获取统计对象的实例
 */
+ (BaiduMobStatForSDK *)defaultStat;

/**
 *  以appId为标识，启动对SDK的统计，在其他api调用以前必须先调用该api.
 *  此处AppId即为应用的appKey.
 */
- (void)startWithAppId:(NSString *)appId;

/**
 *  记录一次事件的点击，eventId请在网站上创建。未创建的evenId记录将无效。 [百度移动统计](http://mtj.baidu.com)
 */
- (void)logEvent:(NSString *)eventId eventLabel:(NSString *)eventLabel withAppId:(NSString *)appId;

/**
 *  记录一次事件的时长，eventId请在网站上创建。未创建的evenId记录将无效。duration参数以毫秒为单位。
 */
- (void)logEventWithDurationTime:(NSString *)eventId
                      eventLabel:(NSString *)eventLabel
                    durationTime:(unsigned long)duration
                       withAppId:(NSString *)appId;
/**
 *  记录一次事件的开始，eventId请在网站上创建。未创建的evenId记录将无效。
 */
- (void)eventStart:(NSString *)eventId eventLabel:(NSString *)eventLabel withAppId:(NSString *)appId;

/**
 *  记录一次事件的结束，eventId请在网站上创建。未创建的evenId记录将无效。
 */
- (void)eventEnd:(NSString *)eventId eventLabel:(NSString *)eventLabel withAppId:(NSString *)appId;

/**
 *  标识某个页面访问的开始，请参见Example程序，在合适的位置调用。
 */
- (void)pageviewStartWithName:(NSString *)name withAppId:(NSString *)appId;

/**
 *  标识某个页面访问的结束，与pageviewStartWithName配对使用，请参见Example程序，在合适的位置调用。
 */
- (void)pageviewEndWithName:(NSString *)name withAppId:(NSString *)appId;

/**
 *  设置渠道Id。
 *  不设置时系统会处理为nil
 */
- (void)setChannelId:(NSString *)channelId withAppId:(NSString *)appId;

/**
 *  获取渠道Id。
 *  当传入appId无效，则返回nil
 */
- (NSString *)getChannelIdWithAppId:(NSString *)appId;

/**
 *  是否只在wifi连接下才发送日志
 *  默认值为 NO, 不管什么网络都发送日志
 */
- (void)setLogSendWifiOnly:(BOOL)logSendWifiOnly withAppId:(NSString *)appId;

/**
 *  获取是否只在wifi连接下才发送日志
 *  当传入appId无效，则返回NO
 */
- (BOOL)getLogSendWifiOnlyWithAppId:(NSString *)appId;

/**
 *  设置应用进入后台再回到前台为同一次session的间隔时间[0~600s],超过600s则设为600s，默认为30s
 */
- (void)setSessionResumeInterval:(int)sessionResumeInterval withAppId:(NSString *)appId;

/**
 *  获取应用进入后台再回到前台为同一次session的间隔时间参数
 *  当传入appId无效，则返回默认值30s
 */
- (int)getSessionResumeIntervalWithAppId:(NSString *)appId;

/**
 *  设置SDK版本号
 *  不设置时默认值为"1.0"
 */
- (void)setSDKVersion:(NSString *)sdkVersion withAppId:(NSString *)appId;

/**
 *  获取SDK版本号参数
 *  当传入appId无效，则返回nil
 */
- (NSString *)getSDKVersionWithAppId:(NSString *)appId;

/**
 *  开发这可以调用此接口来打印SDK中的日志，用于调试
 */
- (void)setEnableDebugOn:(BOOL)enableDebugOn withAppId:(NSString *)appId;

/**
 *  获取打印SDK中的日志参数
 *  当传入appId无效，则返回NO
 */
- (BOOL)getEnableDebugOnWithAppId:(NSString *)appId;

/**
 *  让开发者来填写adid，让统计更加精确
 */
- (void)setAdid:(NSString *)adid withAppId:(NSString *)appId;

/**
 *  获取adid
 *  当传入appId无效，则返回nil
 */
- (NSString *)getAdidWithAppId:(NSString *)appId;

@end
