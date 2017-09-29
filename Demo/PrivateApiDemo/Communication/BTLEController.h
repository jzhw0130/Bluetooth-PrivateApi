//
//  BTLEController.h
//  UpdateBasicCom
//
//  Created by zhiwei jing on 12-11-14.
//  Copyright (c) 2012年 zhiwei jing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasiCommunicationDelegate.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define IDPS_SERVICE_UUID @"180A"
#define IDPS_CHRASTERISTIC_SYSTEMID_UUID @"2A23"//系统ID
#define IDPS_CHRASTERISTIC_MODEL_UUID @"2A24"//附件型号
#define IDPS_CHRASTERISTIC_SERIAL_UUID @"2A25"//序列号
#define IDPS_CHRASTERISTIC_FIRMWARE_UUID @"2A26"//固件版本
#define IDPS_CHRASTERISTIC_HARDWARE_UUID @"2A27"//硬件版本
#define IDPS_CHRASTERISTIC_BT_UUID @"2A28"//蓝牙版本
#define IDPS_CHRASTERISTIC_MANUFACTURE_UUID @"2A29"//
#define IDPS_CHRASTERISTIC_PRO_UUID @"2A30"//协议版本
#define IDPS_CHRASTERISTIC_NAME_UUID @"2A31"//附件署名
#define IDPS_CHRASTERISTIC_PRO128_UUID @"FF01"//协议版本
#define IDPS_CHRASTERISTIC_NAME128_UUID @"FF02"//附件署名




#define BtleUUID(periphreal) [BTLEController getUUIDString:periphreal];
#define IOS7Flag   (([UIDevice currentDevice].systemVersion.intValue>=7)?YES:NO)
 
#define AM3SDelayTimeInterval  5


@interface BTLEController : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>{
    id<BasiCommunicationDelegate>delegate;
    CBPeripheral *defaultPeripheral;
    CBCentralManager *centralManager;
    NSMutableArray *connectedPeripheralArray;
    NSMutableArray *discoveredPeripheralArray;
    
    NSMutableDictionary *idpsDic;
    NSTimer *scanTimer;

    
    Boolean btleIsOn;
    
    NSMutableArray *disconnectUUIDArray;
    
    //设备名称列表
//    NSArray *nameArray;
    //设备服务列表
    NSArray *serviceArray;
    //设备接收属性列表
    NSArray *characterRecArray;
    //设备发送属性列表
    NSArray *characterSendArray;
    //不同设备开关
    NSMutableArray *allCanDiscoverDevice;
    //连接定时器
    NSTimer *connectTimer;
    //存储指定版本固件的设备的uuuid
    NSMutableArray *lowFirmwareDeviceArray;
    //ios系统版本
    NSNumber *iosVsersion;
    
    Boolean btlePowerToOff;
    Boolean couldConnectFlag;
    
    //App激活时间
    NSDate *appActiveTime;
    
    //是否可以连接别人的AM3S标示
    BOOL canConnectOtherAM3SFlag;
    
    //是否正在连接ble设备标示
    BOOL isConnectBLEDeviceFlag;
    
    //优先连接的设备mac列表
    NSMutableArray *firstConnectDeviceIDArray;
    
    
    //ios8 bug
    NSMutableArray *deviceConnectPeripheral;
    
    //记录Peripheral 与 serialNub 关系
    NSMutableDictionary *peripheralAndSerialDic;
    //记录Peripheral UUID 与 serialNub关系
    NSMutableDictionary *peripherialUUIDAndSerialDic;
}

@property (nonatomic,strong)id<BasiCommunicationDelegate>delegate;
@property Boolean btleIsOn;
@property (nonatomic,strong)CBPeripheral *binedPeripheral;



-(id)init;
-(uint8_t)check:(uint8_t *)cbuf;//计算校验和

//搜索btle设备
-(void)startSearchBtleDevice;
-(Boolean)searchBTLEDevice:(int)searchSecond;
//停止搜索btle设备
-(Boolean)stopSearchBTLEDevice;

//连接指定设备
-(void)connectedSelPeripherial:(NSString *)uuidString;
//获取搜索到的设备
-(NSArray *)getDiscoveredPeripheralArray:(BtleType)btleType;
//获取连接上的设备
-(NSArray *)getConnectedPeripheralArray:(BtleType)btleType;


//清空发现设备表
-(void)clearDiscoverDeviceList:(BtleType)btleType;
//清空连接设备表
-(void)clearConnectedDeviceList:(BtleType)btleType;
//清空主动断开的设备列表
-(void)clearDisconnectedDeviceList;

//处理接收到的数据
-(void)handleData:(NSData *)recData peripheralUUID:(NSString *)peripheralUUID characteristicUIID:(NSString *)characteristicUIID protocal:(NSString *)protocalString;

//发送数据给特定属性
-(void)sendData:(NSData *)data to:(NSString *)uuidString characteristicUUID:(NSString *)characteristic;

//接收特定属性数据
-(void)recData:(NSString *)uuidString forCharacteristicUUID:(NSString *)characteristic;

//设置当前默认通讯外设
-(void)setDefaultPeripheral:(NSString *)peripheralUUID;

//断开指定设备
-(void)cancelSelDevice:(NSString *)uuidString;

//判断IDPS信息是否接收完毕
-(BOOL)recIdpsOver:(NSString *)uuidString;

//处理接收到的IDPS信息
-(void)handleIdpsInfo:(NSString *)uuidString key:(NSString *)keyString value:(NSString *)valueString;

//获取指定设备的IDPS信息
-(NSMutableDictionary *)getSelDeviceIdps:(NSString *)uuidString;

//清空认证列表中的低功耗设备
-(void)clearAuthenDevice;

//uuid比较
- (int)UUIDSAreEqual:(CFUUIDRef)u1 u2:(CFUUIDRef)u2;
- (int)UUIDSAreEqual:(CBPeripheral *)u1 u2Str:(NSString *)u2;
-(UInt16) CBUUIDToInt:(CBUUID *) UUID;
-(NSString *) CBUUIDToString:(CBUUID *) UUID;
-(CBUUID *)IntToCBUUID:(UInt16) UUID;
-(int)compareCBUUIDToInt:(CBUUID *)UUID1 UUID2:(UInt16)UUID2;
-(UInt16) swap:(UInt16)s;

//显示时间到毫秒
-(NSString *)getTime:(NSDate *)selDate;

//断开所有连接的设备
-(void)cancelAllDevice;

//从主动断开的设备列表中清楚指定设备
-(void)clearDisconnectedDevice:(NSString *)uuidString;

//打开指定设备扫瞄开关
-(void)openSelDeviceFromName:(NSString *)deviceName;
//关闭指定设备扫瞄开关
-(void)closeSelDeviceFromName:(NSString *)deviceName;

//获取btle设备uuid字符串
+(NSString *)getUUIDString:(CBPeripheral *)peripheral;

//获取设备名字
-(NSString *)getDeviceName:(BtleType )btleType;

//关闭指定设备扫瞄开关
-(void)closeSelDeviceFromType:(BtleType )deviceType;

//打开指定设备扫瞄开关
-(void)openSelDeviceFromType:(BtleType )deviceType;

//关闭收数据始能，200ms后断开设备
-(void)commandSetNotiDisForUUID:(NSString *)tempUUID;

//添加优先连接的设备mac
-(void)commandAddFirstConnectionDevice:(NSString *)tempDeviceID;

//
-(void)connectDeviceWithSerialNub:(NSString *)serialNub;

-(void)connectFailedNoti:(CBPeripheral *)tempPeripheral;

@end
