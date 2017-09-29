//
//  BasicCommunicationObject.h
//  3he1-936CommunicationModule
//
//  Created by liuxin on 12-6-6.
//  Copyright (c) 2012年 lxyeslxlx13@163.com All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasiCommunicationDelegate.h"
#import "CommandDelegate.h"

#define InvalidateAuthenTimer(x) [[BasicCommunicationObject basicCommunicationObject]invalidateAuthenTimer:x];
#define StopSearchAM() [[BasicCommunicationObject basicCommunicationObject]stopAM]
#define StartSearchAM() [[BasicCommunicationObject basicCommunicationObject]startAM]

#define StopSearchPO3() [[BasicCommunicationObject basicCommunicationObject]stopPO3]
#define StartSearchPO3() [[BasicCommunicationObject basicCommunicationObject]startPO3]


#define StopSearchBtleDevice() [[BasicCommunicationObject basicCommunicationObject]stopAllBtleDevice]
#define StartSearchBtleDevice() [[BasicCommunicationObject basicCommunicationObject]startAllBtleDevice]

@class SCLXWifiTransmission;
@class LXCommunicationEAControler;
@class BTLEController;
@class ReceivedDataObject;

@interface BasicCommunicationObject : NSObject<BasiCommunicationDelegate,CommandDelegate>

{

    int _reSendTime;//重发标志位
    
    
    NSMutableDictionary *sendDictionary;
    NSMutableData *lastSendData;//最后一次得数据

    NSMutableDictionary *BufDic;//每包的缓存字典

    
    SCLXWifiTransmission *wifiCommunication;
    LXCommunicationEAControler *eaCommunication;
    BTLEController *btleController;

    
    NSArray *prtocolArray;//子协议名称数组
    NSArray *productTypeNum;//产品类型

    ReceivedDataObject *receivedDataObject;//操作的数据类
    NSMutableArray *authenticationDownDeviceList;//暂时认证通过的设备
    NSMutableArray *authenticationDeviceList;//认证通过设备
    
    NSMutableArray *connectedDeviceList;//所有EA连接的设备
    
    NSMutableDictionary *sendIndexDic;//发送顺序ID
    NSMutableDictionary *sendMaxLenDic;//发送每包最大长度
    //uint8_t lastRecvIndex;//接收到上一包顺序ID
    
    
    
    
    Boolean FBFlag;
    Boolean FDFlag;
    
    Boolean authenFlag;
    
    uint8_t m_ID[50];
    uint8_t R11[50];
    uint8_t R22[50];
    
    //NSMutableDictionary *lastRecIndexDic;
    NSMutableDictionary *totalDataBagDic;
    NSMutableDictionary *lastSendDic;//上层发送的最后一条命令
    NSMutableDictionary *reSendTimeOfDevice;//上层发送的命令重发次数
    //低功耗设备协议数组
    NSArray *btleProtocolArray;
    
    //需要持久化设备集合－－定时激活session
    NSMutableArray *persistantDevice;
    
    //当前连接设备集合
    NSMutableArray *connectDeviceArray;
    
    //认证定时器，定时清理认证失败设备，打开认证开关
    NSTimer *authenTimer;
    
    //缓存认证过的设备信息
    NSMutableArray *authenBTDeviceList;
    
}

@property(nonatomic,strong) BTLEController *btleController;
@property(nonatomic,strong) LXCommunicationEAControler *eaCommunication;

+ (BasicCommunicationObject *)basicCommunicationObject;


-(void)clearDisconnectScale:(NSString *)mac;
-(NSDictionary *)getScaleSavedAllInformation;

-(void)creatSessionStartAuthentication:(NSNotification *)tempNoti;
-(void)wifiStartAuthentication:(NSString *)To;

-(uint8_t)checkUint8:(uint8_t *)cbuf;//计算校验和
-(uint8_t)checkData:(NSData*)data;//计算校验和

//获取蓝牙连接设备
-(NSMutableArray *)getAllEAConnectDevice;
//获取wifi连接设备
-(NSMutableArray *)getAllWifiDevice;
//获取低功耗设备
-(NSMutableArray *)getAllBtleDevice;
//获取当前连接的所有设备-1.0
-(NSMutableArray *)getAllDevice;
//获取当前连接的所有设备-2.0
-(NSArray *)getAllConnectDevice;
//获取连接设备的idps信息
-(NSDictionary *)getIDPSInfoForDevice:(NSString *)connectID;

//搜索HS5
-(void)searchScale;
//开始扫瞄低功耗设备
-(void)startSearchBTLEDevice:(BtleType)btleType;
//停止扫瞄低功耗设备
-(void)stopSearchBTLEDevice:(BtleType)btleType;

-(void)startAM;
-(void)stopAM;
-(void)startPO3;
-(void)stopPO3;
-(void)startAllBtleDevice;
-(void)stopAllBtleDevice;

//清空主动断开的低功耗设备列表
-(void)clearDisconnectBTLEDeviceList;

//判断是不是低功耗设备，通过协议号
-(BOOL)isBtleDevice:(NSString *)protocolString;

-(NSData *)reMakeSendData:(NSData *)data To:(NSString *)IDOrMac Protocol:(NSString *)protocol IsNeedRespond:(BOOL)isNeedRespond MakeSureStatueID:(uint8_t)MakeSureStatueID MakeSureIndex:(uint8_t)MakeSureIndex isNotRespond:(BOOL)isNotRespond;//如果makeSureID为0则不是确认ID//封装发送数据
-(NSData *)reMakeSendData:(NSData *)data To:(NSString *)IDOrMac Chracteristic:(NSString *)chracteristic Protocol:(NSString *)protocol IsNeedRespond:(BOOL)isNeedRespond MakeSureStatueID:(uint8_t)MakeSureStatueID MakeSureIndex:(uint8_t)MakeSureIndex isNotRespond:(BOOL)isNotRespond;

-(NSData *)transMACFromStrToHex:(NSString *)macString;

-(void)sendData:(NSData *)data To:(NSString *)IDOrMac Protocol:(NSString *)protocol IsNeedRespond:(BOOL)isNeedRespond MakeSureStatueID:(uint8_t)makeSureStatueID MakeSureIndex:(uint8_t) makeSureIndex isNotRespond:(BOOL)isNotRespond;//如果makeSureID为0则不是确认ID
-(void)sendData:(NSData *)data To:(NSString *)IDOrMac Chracteristic:(NSString *)chracteristic Protocol:(NSString *)protocol IsNeedRespond:(BOOL)isNeedRespond MakeSureStatueID:(uint8_t)makeSureStatueID MakeSureIndex:(uint8_t) makeSureIndex isNotRespond:(BOOL)isNotRespond;
 
-(NSString *)dataFilePathNameLastR1To:(NSString *)to;//存储r1的位置
-(void)startAuthenticationTo:(NSString *)to IsNotEA:(BOOL)isNotEA ProductType:(uint8_t)productType;
-(void)startBtleAuthenticationTo:(NSString *)to ProductType:(uint8_t)productType Protocol:(NSString *)protocol;
-(void)sendAuthenticationR2:(NSData *)R2 To:(NSString *)to Protocol:(NSString *)protocol ProductType:(uint8_t)productType makeSureIndex:(uint8_t)makeSureIndex;
-(void)sendBtleAuthenticationR2:(NSData *)R2 To:(NSString *)to Protocol:(NSString *)protocol ProductType:(uint8_t)productType makeSureIndex:(uint8_t)makeSureIndex;
-(void)failedToAuthenticationTo:(NSString *)to Protocol:(NSString *)protocol ProductType:(uint8_t)productType makeSureIndex:(uint8_t)makeSureIndex;
-(void)failedToBtleAuthenticationTo:(NSString *)to Protocol:(NSString *)protocol ProductType:(uint8_t)productType makeSureIndex:(uint8_t)makeSureIndex;
//分两层无法加入产品类型


-(void)MakeSureMethod:(NSMutableDictionary *)dic;
//整条命令重发
-(void)totalCommandMakeSureMethod:(NSMutableDictionary *)dic;

//取消指定设备底重发
-(void)cancel:(uint8_t)index from:(NSString *)from;
//取消整条命令的重发
-(void)cancelTotalCommand:(NSString *)from;

//查询设备总接收包数,判断是否接收完毕
-(int)detectDataBag:(NSString *)deviceID;
//拼接小包数据为整包
-(NSData *)detectDataBagRec:(NSString *)deviceID;


-(NSData *)handleCommand:(NSData *)command From:(NSString *)from Protocol:(NSString *)protocol;
-(NSData *)handleCommand:(NSData *)command From:(NSString *)from Chracteristic:(NSString *)chracteristic Protocol:(NSString *)protocol;


//加密认证入口
-(void)_creatSessionStartAuthentication:(NSNotification *)tempNoti;


//App主动断开低功耗设备
-(void)cancelBtleDevice:(NSString *)uuidString;

//从主动断开设备列表中删除指定设备
-(void)clearBtleDeviceFromDisconnectedDeviceList:(NSString *)uuidString;

//判断蓝牙是否打开：不支持低功耗也返回蓝牙没打开
-(Boolean)isBtleSwitchOn;
//获取指定设备的idps信息
-(NSDictionary *)getSelDeviceFrom:(NSString *)from;

//获取认证成功的bg3、bg5列表
-(NSArray *)getAllBGDevice;

//1000台bug解决方案－存储最后连接时间路径
-(NSString *)backTimePath;


//判断是否需要激活session来持久
-(Boolean)needPersistent:(NSString *)from;
//增加需要persistent设备
-(void)addPersistentDevice:(NSString *)from;
//删除需要persistent设备
-(void)delPersistentDevice:(NSString *)from;

//设备断开消息处理方法
-(void)deviceDisconnect:(NSNotification *)notify;

//设备连接消息处理方法
-(void)deviceConnect:(NSNotification *)notify;

//清除指定设备从认证设备列表
-(void)delDeviceFromAuthenList:(NSString *)uuidString;

//休眠回来后重建udp链接
-(void)commandRebuildUdpLinker;

//获取认证通过的BT设备列表
-(NSArray *)commandGetAuthenBTDeviceList;

//获取指定设备的protocol
-(NSString *)getSelDeviceProtocol:(NSString *)uuidString;

@end
