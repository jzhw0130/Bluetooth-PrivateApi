//
//  SCLXWifiTransmission.h
//  wifiModule
//
//  Created by liuxin on 12-4-18.
//  Copyright (c) 2012年 lxyeslxlx13@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasiCommunicationDelegate.h"
@class AsyncUdpSocket;

@interface SCLXWifiTransmission : NSObject
{
    AsyncUdpSocket * SCLXUdpSocket;
    NSMutableDictionary *SCLXMacAndIPDic;
    NSMutableDictionary *SCScaleInfoDic;
    NSMutableDictionary *SCSavedScaleInfoDic;
    id<BasiCommunicationDelegate>delegate;
}

@property (nonatomic,strong)id<BasiCommunicationDelegate>delegate;
-(uint8_t)check:(uint8_t *)cbuf;//计算校验和
-(id)init;
-(NSInteger)sendData:(NSData *)requestData MAC:(NSString *)mac;
-(void)searchScales;
-(void)clearDisconnectScale:(NSString *)mac;
-(NSMutableDictionary*)getScaleSavedAllInformation; //连接过的称的全部信息

//重建socket
-(void)remakeUdpSocket;

@end
