//
//  BlueToothSetWifi.h
//  EADemo
//
//  Created by apple on 12-7-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
enum {
    connecting = 1,
    connectSuccess = 2,
    connectFailed = 3,
    shareWifiInfoFailed = 4,
    rejectWifiShareInfo = 5,
    notConnectWifi = 6,
    inShareWifi = 7,
}blueToothStatus;

#define WiFiConnectRouterStatusNotification @"WiFiConnectRouterStatusNotification"//WiFi连接路由器状态
#define shareWifiInfoFailedNotification @"shareWifiInfoFailedNotification"//共享WiFi信息失败
#define rejectWifiShareInfoNotification @"rejectWifiShareInfoNotification"//拒绝共享WiFi信息
#define notConnectWifiNotification @"notConnectWifiNotification"//苹果设备未连接WiFi,没有可共享的信息
#define inShareWifiNotification @"inShareWifiNotification"//共享WiFi信息过程中
#import "BlueToothSetWifiDelegate.h"
@interface BlueToothSetWifi : NSObject<BlueToothSetWifiDelegate>
@property(nonatomic,weak)id<BlueToothSetWifiDelegate>delegate;
//上位机向下位机询问蓝牙设WiFi状态
-(NSMutableData*)requestBuleToothSetWifiStatusWithProduceStyle:(uint8_t)produceStyle withCommandId:(uint8_t)commandId;
+(BlueToothSetWifi*)blueToothSetWifi;
@end
