//
//  BNSoundEventDelegate.h
//  baiduNaviSDK
//
//  Created by Yangtsing.Zhang on 15/4/7.
//  Copyright (c) 2015年 baidu. All rights reserved.
//

#ifndef baiduNaviSDK_BNSoundEventProtocol_h
#define baiduNaviSDK_BNSoundEventProtocol_h

@protocol BNSoundEventDelegate <NSObject>

@optional

- (void)onNaviTTSBeginSpeech;

- (void)onNaviTTSFinishSpeech;

@end


#endif
