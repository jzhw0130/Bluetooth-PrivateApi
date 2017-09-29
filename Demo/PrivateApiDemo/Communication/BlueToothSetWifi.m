//
//  BlueToothSetWifi.m
//  EADemo
//
//  Created by apple on 12-7-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BlueToothSetWifi.h"

@implementation BlueToothSetWifi
@synthesize delegate;
static BlueToothSetWifi *mblueToothSetWifi=nil;

-(id)init
{
    if (self=[super init]) {
        delegate=self;
    }
    return self;
}
+(BlueToothSetWifi*)blueToothSetWifi
{
    if (mblueToothSetWifi==nil) {
        mblueToothSetWifi=[[BlueToothSetWifi alloc]init];
      
    }
    return mblueToothSetWifi;
}
//上位机向下位机询问蓝牙设WiFi状态
-(NSMutableData*)requestBuleToothSetWifiStatusWithProduceStyle:(uint8_t)produceStyle withCommandId:(uint8_t)commandId
{
    
    NSMutableData *m_data=[[NSMutableData alloc]init];
    uint8_t sendCommand[2];
    sendCommand[0]=produceStyle;
    sendCommand[1]=commandId;
    [m_data appendBytes:&sendCommand[0] length:sizeof(sendCommand)];
    return m_data;
    
    
}
-(void)processReceivedCommand:(NSData*)data
{
    uint32_t bytesAvailable=[data length];
    uint8_t buf[512];
    
    [data getBytes:(void *)(&buf[0]) length:bytesAvailable];
    
    NSMutableDictionary *statusDic = [[NSMutableDictionary alloc]init];
    switch (buf[5]) {
        case 0xE0://命令Id
        {
            switch (buf[6]) {//WiFi连接路由器状态
                case 0x01://连接过程中
                    [statusDic setValue:[NSString stringWithFormat:@"%d",1] forKey:@"status"];
                    break;
                    
                case 0x02://连接成功
                    [statusDic setValue:[NSString stringWithFormat:@"%d",2] forKey:@"status"];
                    break;
                case 0x03://连接失败
                    [statusDic setValue:[NSString stringWithFormat:@"%d",3] forKey:@"status"];
                    break;
                defaulxt:
                    [statusDic setValue:[NSString stringWithFormat:@"%d",0] forKey:@"status"];
                    break;
            }
        }
            break;
            
        case 0xE1://共享WiFi信息失败
            //[[NSNotificationCenter defaultCenter] postNotificationName:shareWifiInfoFailedNotification object:nil];
            [statusDic setValue:[NSString stringWithFormat:@"%d",4] forKey:@"status"];
            break;
        case 0xE2://拒绝共享WiFi信息
             //[[NSNotificationCenter defaultCenter] postNotificationName:rejectWifiShareInfoNotification object:nil];
            [statusDic setValue:[NSString stringWithFormat:@"%d",5] forKey:@"status"];
            break;
        case 0xE3://苹果设备未连接WiFi,没有可共享的信息
             //[[NSNotificationCenter defaultCenter] postNotificationName:notConnectWifiNotification object:nil];
            [statusDic setValue:[NSString stringWithFormat:@"%d",6] forKey:@"status"];
            break;
        case 0xE4://共享WiFi信息过程中
             //[[NSNotificationCenter defaultCenter] postNotificationName:inShareWifiNotification object:nil];
            [statusDic setValue:[NSString stringWithFormat:@"%d",7]forKey:@"status"];
            break;
        default:
            [statusDic setValue:[NSString stringWithFormat:@"%d",0] forKey:@"status"];
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:inShareWifiNotification object:nil userInfo:statusDic];
}
@end
