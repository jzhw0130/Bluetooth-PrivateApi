//
//  BTLEController.m
//  UpdateBasicCom
//
//  Created by zhiwei jing on 12-11-14.
//  Copyright (c) 2012年 zhiwei jing. All rights reserved.
//

#import "BTLEController.h"
//#import "iConsole.h"
#import <UIKit/UIKit.h>

#define BP3L_ModelNumber  @"BP3L 11070"

@implementation BTLEController
@synthesize delegate;
@synthesize btleIsOn;
@synthesize binedPeripheral;


-(id)init
{
    self = [super init];
    if (self)
    {
        connectedPeripheralArray=[[NSMutableArray alloc] init];
        discoveredPeripheralArray=[[NSMutableArray alloc] init];

        //设备名称列表(6)
//        nameArray = [[NSArray alloc] initWithObjects:AM3_NAME_24_B,AM3_NAME_B,BG5L_NAME_B,KS3_NAME_B,HS4_NAME_B,HS4_NAME_24_B,Temper_NAME_B,PO3_NAME_B,ECG_NAME_B,AM3S_NAME_B, nil];
        //设备服务列表(6)
        serviceArray = [[NSArray alloc] initWithObjects:AM3_SERVICE_UUID_24,AM3_SERVICE_UUID,BG5L_SERVICE_UUID,KS3_SERVICE_UUID,HS4_SERVICE_UUID,HS4_SERVICE_UUID_24,Temper_SERVICE_UUID,PO3_SERVICE_UUID,ECG_SERVICE_UUID,AM3S_SERVICE_UUID,BP3L_SERVICE_UUID,PO3_SERVICE_UUID_128,AM4_SERVICE_UUID, nil];
        //设备接收属性列表(6)
        characterRecArray = [[NSArray alloc] initWithObjects:AM3_CHRASTERISTIC_REC_UUID_24,AM3_CHRASTERISTIC_REC_UUID,BG5L_CHRASTERISTIC_REC_UUID,KS3_CHRASTERISTIC_REC_UUID,HS4_CHRASTERISTIC_REC_UUID,HS4_CHRASTERISTIC_REC_UUID_24,Temper_CHRASTERISTIC_REC_UUID,PO3_CHRASTERISTIC_REC_UUID,ECG_CHRASTERISTIC_REC_UUID,AM3S_CHRASTERISTIC_REC_UUID,BP3L_CHRASTERISTIC_REC_UUID,PO3_CHRASTERISTIC_REC_UUID_128,AM4_CHRASTERISTIC_REC_UUID, nil];
        //设备发送属性列表(6)
        characterSendArray = [[NSArray alloc] initWithObjects:AM3_CHRASTERISTIC_SEND_UUID_24,AM3_CHRASTERISTIC_SEND_UUID,BG5L_CHRASTERISTIC_SEND_UUID,KS3_CHRASTERISTIC_SEND_UUID,HS4_CHRASTERISTIC_SEND_UUID,HS4_CHRASTERISTIC_SEND_UUID_24,Temper_CHRASTERISTIC_SEND_UUID,PO3_CHRASTERISTIC_SEND_UUID,ECG_CHRASTERISTIC_SEND_UUID,AM3S_CHRASTERISTIC_SEND_UUID,BP3L_CHRASTERISTIC_SEND_UUID,PO3_CHRASTERISTIC_SEND_UUID_128,AM4_CHRASTERISTIC_SEND_UUID, nil];
        disconnectUUIDArray = [[NSMutableArray alloc]init];
        allCanDiscoverDevice = [[NSMutableArray alloc]init];
        lowFirmwareDeviceArray = [[NSMutableArray alloc]init];
        firstConnectDeviceIDArray = [[NSMutableArray alloc]init];
        
        peripheralAndSerialDic = [NSMutableDictionary dictionary];
        peripherialUUIDAndSerialDic = [NSMutableDictionary dictionary];
        
        btleIsOn = false;
        btlePowerToOff = false;
        couldConnectFlag = false;
        canConnectOtherAM3SFlag = false;
        isConnectBLEDeviceFlag = false;
        
        idpsDic = [[NSMutableDictionary alloc]init];
        //jing 20150708
        if (IOS7Flag) {
            NSDictionary *tempDic = [NSDictionary dictionaryWithObjectsAndKeys:@NO,CBCentralManagerOptionShowPowerAlertKey, nil];
            centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:tempDic];
        }
        else{
            centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
        }
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(recDisconnectAMuuid:) name:@"DisconnectAMuuid" object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];

        
    }
    UIDevice *currentDevice = [UIDevice currentDevice];
    NSArray *systemVersionArray = [currentDevice.systemVersion componentsSeparatedByString:@"."];
    if(systemVersionArray.count){
        iosVsersion = [NSNumber numberWithInt:[[systemVersionArray objectAtIndex:0]intValue]];
    }
    else{
        iosVsersion = [NSNumber numberWithInt:7];
    }
    return self;
}

//存储最后断开设备的uuid
-(void)recDisconnectAMuuid:(NSNotification *)tempNoti{
    NSDictionary *tempDic = [tempNoti userInfo];
    NSString *uuidString = [tempDic objectForKey:@"UUID"];
    if([disconnectUUIDArray indexOfObject:uuidString]==NSNotFound && uuidString!=nil){
        [disconnectUUIDArray addObject:uuidString];
    }
}

-(void)appDidBecomeActive:(NSNotification *)tempNoti{
    isConnectBLEDeviceFlag = false;
//    appActiveTime = [NSDate date];
//    [self performSelector:@selector(reDiscoverPeripheral) withObject:nil afterDelay:AM3SDelayTimeInterval];
    
//    [self commandDetectAlreadyConnectBLEDevice];
}

-(void)appDidEnterBackground:(NSNotification *)tempNoti{
    isConnectBLEDeviceFlag = false;
//    appActiveTime = [NSDate date];
    
//        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(commandDetectAlreadyConnectBLEDevice) object:nil];
}


-(void)commandDetectAlreadyConnectBLEDevice{
    if (IOS7Flag == false) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(commandDetectAlreadyConnectBLEDevice) object:nil];
    NSArray *tmpServiceArray = [NSArray arrayWithObjects:[CBUUID UUIDWithString:HS4_SERVICE_UUID],[CBUUID UUIDWithString:AM3S_SERVICE_UUID],[CBUUID UUIDWithString:AM3_SERVICE_UUID_24],[CBUUID UUIDWithString:AM3_SERVICE_UUID],[CBUUID UUIDWithString:AM4_SERVICE_UUID], nil];
    if (centralManager.state == CBCentralManagerStatePoweredOn) {
        NSArray *peripheralArray = [centralManager retrieveConnectedPeripheralsWithServices:tmpServiceArray];
        deviceConnectPeripheral = [NSMutableArray arrayWithArray:peripheralArray];
        for (CBPeripheral *tempPeripheral in deviceConnectPeripheral) {
            
            if(IOS7Flag)
            {
                if (tempPeripheral.state == CBPeripheralStateDisconnected) {
                    [self stopSearchBTLEDevice];
                    NSLog(@"------------Detect already connect device");
                    [centralManager connectPeripheral:tempPeripheral options:nil];
                }
            }
            else
            {

            }

        }
        [self performSelector:@selector(commandDetectAlreadyConnectBLEDevice) withObject:nil afterDelay:4.0];
    }
    else{
        [self performSelector:@selector(commandDetectAlreadyConnectBLEDevice) withObject:nil afterDelay:2.0];
    }
}


//搜索btle设备
-(void)startSearchBtleDevice{
    if(centralManager.state == CBCentralManagerStatePoweredOn && couldConnectFlag == TRUE){
        NSMutableArray *selServiceArray = [[NSMutableArray alloc]init];
        for (NSString *tempUUID in allCanDiscoverDevice) {
            [selServiceArray addObject:[CBUUID UUIDWithString:tempUUID]];
        }
        [centralManager scanForPeripheralsWithServices:selServiceArray options:nil];
        
        
        //556334F8-D798-6DBA-95D7-CD1FF791C9B8
        //FE672C1D-CC55-6A12-1429-5E3DC7934D26    phone5
        //A223B95E-DD54-CE17-FDCD-5C56E05EAE21    pad
//        CBUUID *uuid= [CBUUID UUIDWithString:@"A223B95E-DD54-CE17-FDCD-5C56E05EAE21"];
//        if(IOS7Flag==TRUE){
//            NSArray *deviceArray = [centralManager retrievePeripheralsWithIdentifiers:[NSArray arrayWithObject:uuid]];
//            if (deviceArray.count>0) {
//                binedPeripheral = [deviceArray objectAtIndex:0];
//                [centralManager connectPeripheral:binedPeripheral options:nil];
//            }
//        }
//        else{
//            CFUUIDRef ref = CFUUIDCreateFromString(nil,(CFStringRef)@"A223B95E-DD54-CE17-FDCD-5C56E05EAE21");
//            [centralManager retrievePeripherals:[NSArray arrayWithObjects:CFBridgingRelease(ref), nil]];
//        }
    }
}
-(Boolean)searchBTLEDevice:(int)searchSecond{
    if(centralManager.state == CBCentralManagerStatePoweredOn){
        [self startSearchBtleDevice];
        scanTimer = [NSTimer scheduledTimerWithTimeInterval:searchSecond target:self selector:@selector(stopSearchBTLEDevice) userInfo:nil repeats:NO];
        return true;
    }
    return false;
}

//停止搜索btle设备
-(Boolean)stopSearchBTLEDevice{
    if([scanTimer isValid]){
        [scanTimer invalidate];
        scanTimer = nil;
    }
    if(centralManager.state == CBCentralManagerStatePoweredOn){
        [centralManager stopScan];
        return true;
    }
    return false;
}

//连接指定设备
-(void)connectedSelPeripherial:(NSString *)uuidString{
    if(centralManager.state == CBCentralManagerStatePoweredOn){
        for(int i=0; i<[discoveredPeripheralArray count]; i++){
            CBPeripheral *peripherial = [discoveredPeripheralArray objectAtIndex:i];
            if([self UUIDSAreEqual:peripherial u2Str:uuidString]){
                NSLog(@"--%@Begin connect: %@",[NSDate date],uuidString);
                [centralManager connectPeripheral:peripherial options:nil];
            }
        }
    }
    
}

//获取搜索到的设备
-(NSArray *)getDiscoveredPeripheralArray:(BtleType)btleType{
    NSMutableArray *tempArray = [NSMutableArray array];
    switch (btleType) {
        case BtleType_All:
            tempArray = discoveredPeripheralArray;
            break;
        default:
            break;
    }
    return tempArray;
}
//获取连接上的设备
-(NSArray *)getConnectedPeripheralArray:(BtleType)btleType{
    NSMutableArray *tempArray = [NSMutableArray array];
    switch (btleType) {
        case BtleType_All:
            tempArray = [connectedPeripheralArray copy];
            break;
        default:
            break;
    }
    return tempArray;
}

//清空发现设备表
-(void)clearDiscoverDeviceList:(BtleType)btleType{
    if([discoveredPeripheralArray count]){
        [discoveredPeripheralArray removeAllObjects];
    }
}

//清空连接设备表
-(void)clearConnectedDeviceList:(BtleType)btleType{
    if([connectedPeripheralArray count]){
        [connectedPeripheralArray removeAllObjects];
    }
}

//清空认证列表中的低功耗设备
-(void)clearAuthenDevice{
    //清空idps缓存列表
    if (idpsDic) {
        [idpsDic removeAllObjects];
    }
    for(CBPeripheral *tempPeripheral in connectedPeripheralArray){
        NSString *uuid = BtleUUID(tempPeripheral);
        NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:uuid,IDPS_ID, nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:DeviceDisconnect object:self userInfo:dic];
    }
}

//清空主动断开的设备列表
-(void)clearDisconnectedDeviceList{
    if([disconnectUUIDArray count]){
        [disconnectUUIDArray removeAllObjects];
    }
}

//处理接收到的数据
-(void)handleData:(NSData *)recData peripheralUUID:(NSString *)peripheralUUID characteristicUIID:(NSString *)characteristicUIID protocal:(NSString *)protocalString{
    if(recData!=nil && peripheralUUID.length){
        if(recData.length<=6){
            //NSLog(@"______rec:%@",recData);
            //IHLog(AM_Translate, @"RecData:%@ uuidString:%@",recData,peripheralUUIDString);
        }
        else{
            //NSLog(@"rec:%@",recData);
            //IHLog(AM_Translate, @"RecData:%@ uuidString:%@",recData,peripheralUUIDString);
        }
        [delegate receivedData:recData From:peripheralUUID Chracteristic : characteristicUIID Protocol:protocalString];
    }
    else{
        NSLog(@"handleData -- No data");
    }
}

//发送数据给特定属性
-(void)sendData:(NSData *)data to:(NSString *)uuidString characteristicUUID:(NSString *)characteristic{
    if(uuidString.length && characteristic.length){
        if(data.length<=6){
#ifdef DLog
            NSLog(@"______sendData:%@ uuidString:%@",data,uuidString);
#endif
            //IHLog(AM_Translate, @"______sendData:%@ uuidString:%@",data,uuidString);
        }
        else{
#ifdef DLog
            NSLog(@"sendData:%@ uuidString:%@",data,uuidString);
#endif
            //IHLog(AM_Translate, @"sendData:%@ uuidString:%@",data,uuidString);
        }
        [self setDefaultPeripheral:uuidString];
        if(defaultPeripheral!=nil){
            for(CBService *service in defaultPeripheral.services){
                Boolean findFlag = false;
                if([service.UUID isEqual:[CBUUID UUIDWithString:IDPS_SERVICE_UUID]]){
                    continue;
                }
                
                for(CBCharacteristic *characteristicTemp in service.characteristics){
                    for(NSString *tempC in characterSendArray){
                        CBUUID *tempUUID = [CBUUID UUIDWithString:tempC];
                        if([tempUUID isEqual:characteristicTemp.UUID]){
                            if((characteristicTemp.properties&0x04) == 0x04){
                                [defaultPeripheral writeValue:data forCharacteristic:characteristicTemp type:CBCharacteristicWriteWithoutResponse];
//                                NSLog(@"WriteWithoutResponse已发送");
                                findFlag = true;
                                break;
                            }
                            else if((characteristicTemp.properties&0x08) == 0x08){
                                [defaultPeripheral writeValue:data forCharacteristic:characteristicTemp type:CBCharacteristicWriteWithResponse];
//                                NSLog(@"WithoutResponse已发送");
                                findFlag = true;
                                break;
                            }
                        }
                    }
                    if(findFlag == true){
                        break;
                    }
                }
                if(findFlag == true){
                    break;
                }
            }
        }
        else{
            NSLog(@"defaultPeripheral==nil");
        }
    }
    else{
        NSLog(@"invalidate uuidstring or characteristic");
    }
}

//接收特定属性数据
-(void)recData:(NSString *)uuidString forCharacteristicUUID:(NSString *)characteristic{
    [self setDefaultPeripheral:uuidString];
    CBUUID *characteristicUIID = [CBUUID UUIDWithString:characteristic];
    if(defaultPeripheral!=nil){
        for(CBService *service in defaultPeripheral.services){
            for(CBCharacteristic *characteristic in service.characteristics){
                if([characteristic.UUID isEqual:characteristicUIID]){
                    [defaultPeripheral readValueForCharacteristic:characteristic];
                }
            }
        }
    }
    else{
        NSLog(@"defaultPeripheral==nil");
    }
}

//设置当前默认通讯外设
-(void)setDefaultPeripheral:(NSString *)peripheralUUID{
    for(CBPeripheral *peripherial in connectedPeripheralArray){
        if([self UUIDSAreEqual:peripherial u2Str:peripheralUUID]){
            defaultPeripheral = peripherial;
        }
    }
}

//断开指定设备
-(void)cancelSelDevice:(NSString *)uuidString{
    if(uuidString.length){
        for(CBPeripheral *peripherial in connectedPeripheralArray){
            if([self UUIDSAreEqual:peripherial u2Str:uuidString]){
                [centralManager cancelPeripheralConnection:peripherial];
            }
        }

    }
    else{
        NSLog(@"cancelSelDevice:uuidString==nil");
    }
}

//判断IDPS信息是否接收完毕
-(BOOL)recIdpsOver:(NSString *)uuidString{
    if([[idpsDic allKeys]containsObject:uuidString]){
        NSDictionary *tempDic = [idpsDic objectForKey:uuidString];
        if(tempDic != nil){
            if([[tempDic allKeys]count]>=8){
                return true;
            }
        }
    }
    return false;
}

//处理接收到的IDPS信息
-(void)handleIdpsInfo:(NSString *)uuidString key:(NSString *)keyString value:(NSString *)valueString{
    //IHLog(AM_Translate, @"IDPS %@:%@",keyString,valueString);
#ifdef DLog
    NSLog(@"%@:%@",keyString,valueString);
#endif
    if([[idpsDic allKeys]containsObject:uuidString]){
        NSMutableDictionary *tempDic = [idpsDic objectForKey:uuidString];
        [tempDic setObject:valueString forKey:keyString];
        [idpsDic setObject:tempDic forKey:uuidString];
    }
    else{
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        [tempDic setObject:valueString forKey:keyString];
        [idpsDic setObject:tempDic forKey:uuidString];
    }
}


//获取指定设备的IDPS信息
-(NSMutableDictionary *)getSelDeviceIdps:(NSString *)uuidString{
    if([[idpsDic allKeys]containsObject:uuidString]){
        return [idpsDic objectForKey:uuidString];
    }
    return [NSMutableDictionary dictionary];
}



//
-(void)delaySendConnectedMessage:(NSMutableDictionary *)tempDic{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delaySendConnectedMessage:) object:tempDic];
    NSString *uuidString = [tempDic objectForKey:IDPS_ID];
    if([self recIdpsOver:uuidString]){
        NSDictionary *tempInfo = [idpsDic objectForKey:uuidString];
        NSString *modelNub = [tempInfo objectForKey:IDPS_ModelNumber];
        NSMutableDictionary *deviceIDPS = [NSMutableDictionary dictionaryWithDictionary:tempInfo];
        NSArray *modelArray = [modelNub componentsSeparatedByString:@" "];
        if(modelArray.count>0){
            [deviceIDPS setValue:[modelArray objectAtIndex:0] forKey:IDPS_Name];
        }
        [deviceIDPS setValue:uuidString forKey:IDPS_ID];
        [deviceIDPS setValue:[NSNumber numberWithInteger:DeviceUUIDType_BLE] forKey:IDPS_Type];
        [idpsDic setValue:deviceIDPS forKey:uuidString];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:DeviceOpenSession object:self userInfo:deviceIDPS];
    }
    else{
        [self performSelector:@selector(delaySendConnectedMessage:) withObject:tempDic afterDelay:0.1];
    }
}

//显示时间到毫秒
-(NSString *)getTime:(NSDate *)selDate{
    static NSDateFormatter *dateFormatter;
    if(dateFormatter == nil){
        dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    }
    NSString *dateString = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:[NSDate date]]];
    return dateString;
}

//uuid比较
- (int)UUIDSAreEqual:(CFUUIDRef)u1 u2:(CFUUIDRef)u2 {
    if(u1==nil || u2==nil){
        return 0;
    }
    CFUUIDBytes b1 = CFUUIDGetUUIDBytes(u1);
    CFUUIDBytes b2 = CFUUIDGetUUIDBytes(u2);
    if (memcmp(&b1, &b2, 16) == 0) {
        return 1;
    }
    else
        return 0;
}
- (int)UUIDSAreEqual:(CBPeripheral *)u1 u2Str:(NSString *)u2{
    NSString *uuidStr1 = BtleUUID(u1);
    if(uuidStr1.length == 0 || u2.length == 0){
        return 0;
    }
    else if([uuidStr1 isEqualToString:u2]){
        return 1;
    }
    return 0;
}

-(UInt16) CBUUIDToInt:(CBUUID *) UUID {
    char b1[16];
    [UUID.data getBytes:b1];
    return ((b1[0] << 8) | b1[1]);
}

-(NSString *) CBUUIDToString:(CBUUID *) UUID {
    unsigned char b1[16];
    [UUID.data getBytes:b1];
    return [NSString stringWithFormat:@"%02X%02X",b1[0],b1[1]];
}

-(CBUUID *)IntToCBUUID:(UInt16) UUID{
    UInt16 swapUUID = [self swap:UUID];
    NSData *data = [NSData dataWithBytes:(char*)&swapUUID length:2];
    CBUUID *convertUUID = [CBUUID UUIDWithData:data];
    return convertUUID;
}

-(int)compareCBUUIDToInt:(CBUUID *)UUID1 UUID2:(UInt16)UUID2 {
    char b1[16];
    [UUID1.data getBytes:b1];
    UInt16 b2 = [self swap:UUID2];
    if (memcmp(b1, (char *)&b2, 2) == 0) return 1;
    else return 0;
}

-(UInt16) swap:(UInt16)s {
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}

-(uint8_t)check:(uint8_t *)cbuf//计算校验和
{
	uint8_t checkbuf=0x00;
	for (int i=2; i<cbuf[1]+2; i++) {
		checkbuf+=cbuf[i];
	}
	return checkbuf;
}

-(NSString *)commandGetUUIDStringFromCBUUID:(CBUUID *)tempUUID{
    NSData *uuidData = [tempUUID data];
    uint8_t tempBuf[20] = {0};
    [uuidData getBytes:tempBuf length:uuidData.length];
    NSUUID *uuidTemp = [[NSUUID alloc]initWithUUIDBytes:tempBuf];
    NSMutableString *comBinedUUID = [NSMutableString stringWithFormat:@"%@",[uuidTemp UUIDString]];
    [comBinedUUID replaceOccurrencesOfString:@"0000-0000-0000-0000-000000000000" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, comBinedUUID.length)];
    return comBinedUUID;
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSString *tip= nil;
    switch ([central state])
    {
        case CBCentralManagerStateUnsupported:
            tip = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            btleIsOn = false;
            break;
        case CBCentralManagerStateUnauthorized:
            tip = @"The app is not authorized to use Bluetooth Low Energy.";
            btleIsOn = false;
            break;
        case CBCentralManagerStatePoweredOff:{
            btleIsOn = false;
            [self clearAuthenDevice];
            [self clearConnectedDeviceList:BtleType_All];
            [self clearDiscoverDeviceList:BtleType_All];
            [self stopSearchBTLEDevice];
            tip = @"Bluetooth is currently powered off.";
            if(btlePowerToOff == TRUE){
                btlePowerToOff = false;
                [[NSNotificationCenter defaultCenter]postNotificationName:BTPowerOff object:self];
            }
            }
            break;
        case CBCentralManagerStatePoweredOn:{
            if (allCanDiscoverDevice.count > 0) {
                couldConnectFlag = true;
            }
            btlePowerToOff = TRUE;
            btleIsOn = TRUE;
            [self startSearchBtleDevice];
            tip = @"Bluetooth is currently powered on.";
            }
            break;
        case CBCentralManagerStateUnknown:
            btleIsOn = false;
            tip = @"CBCentralManagerStateUnknown";
            break;
        case CBCentralManagerStateResetting:
            btleIsOn = false;
            [self clearAuthenDevice];
            [self clearConnectedDeviceList:BtleType_All];
            [self clearDiscoverDeviceList:BtleType_All];
            [self stopSearchBTLEDevice];
            tip = @"CBCentralManagerStateResetting";
            [[NSNotificationCenter defaultCenter]postNotificationName:@"BTLEStateReset" object:self];
            break;
        default:
            btleIsOn = false;
            tip = @"Bluetooth Unknown status.";
            break;
    }
#ifdef DLog
    NSLog(@"centralManagerDidUpdateState-%@",tip);
#endif
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals{
    if (peripherals.count>0) {
        binedPeripheral = [peripherals objectAtIndex:0];
        [centralManager connectPeripheral:binedPeripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals{
    for(CBPeripheral *selPeripheral in peripherals){
        [centralManager cancelPeripheralConnection:selPeripheral];
    }
}

-(NSString *)commandDetectUUID:(NSArray *)UUIDArray{
    NSString *validateUUID = nil;
    for (CBUUID *tempUUID in UUIDArray) {
        for (NSString *tempStr in serviceArray) {
            if ([tempUUID isEqual:[CBUUID UUIDWithString:tempStr]]) {
                return tempStr;
                break;
            }
        }
    }
    return validateUUID;
}

#pragma mark - DiscoverPeripheral

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    NSString *peripheralName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];

    if (RSSI.intValue < 0 && RSSI.intValue > -90) {
//        NSLog(@"name:%@,UUID:%@,RSSI:%@,peripheralName:%@",peripheral.name,peripheral.identifier,RSSI,peripheralName);
    }
    
    //
    NSArray *deviceServiceArray = [advertisementData valueForKey:CBAdvertisementDataServiceUUIDsKey];
    if (deviceServiceArray.count>0 && peripheralName.length>0 && RSSI.intValue < 0 && RSSI.intValue > -90) {
        
        //AM3S
        if ([deviceServiceArray containsObject:[CBUUID UUIDWithString:AM3S_SERVICE_UUID]] || [deviceServiceArray containsObject:[CBUUID UUIDWithString:BP3L_SERVICE_UUID]] || [deviceServiceArray containsObject:[CBUUID UUIDWithString:PO3_SERVICE_UUID]] || [deviceServiceArray containsObject:[CBUUID UUIDWithString:HS4_SERVICE_UUID]] ||[deviceServiceArray containsObject:[CBUUID UUIDWithString:PO3_SERVICE_UUID_128]] ||[deviceServiceArray containsObject:[CBUUID UUIDWithString:AM4_SERVICE_UUID]]) {
            NSData *macData = [advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey];
            uint8_t buf[7] = {0};
            NSString *macStr = @"FFFFFFFFFFFF";
            if(macData.length>=8){
                [macData getBytes:buf range:NSMakeRange(macData.length-6, 6)];
                macStr = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X",buf[0],buf[1],buf[2],buf[3],buf[4],buf[5]];
            }
            else {
                macStr = [self commandGetSerialNubFormPeripherial:peripheral];
            }
            
            if ([macStr isEqual:@"FFFFFFFFFFFF"] && peripheral.identifier) {
                macStr = peripheral.identifier.UUIDString;
            }
            
            NSString *deviceName = nil;
            if ([deviceServiceArray containsObject:[CBUUID UUIDWithString:AM3S_SERVICE_UUID]]) {
                deviceName = AM3S_NAME;
            }
            else if ([deviceServiceArray containsObject:[CBUUID UUIDWithString:AM4_SERVICE_UUID]]) {
                deviceName = AM4_NAME;
            }
            else if ([deviceServiceArray containsObject:[CBUUID UUIDWithString:BP3L_SERVICE_UUID]]) {
                deviceName = BP3L_NAME;
            }
            else if ([deviceServiceArray containsObject:[CBUUID UUIDWithString:PO3_SERVICE_UUID]] ||[deviceServiceArray containsObject:[CBUUID UUIDWithString:PO3_SERVICE_UUID_128]]) {
                deviceName = PO3_NAME;
            }
            else if ([deviceServiceArray containsObject:[CBUUID UUIDWithString:HS4_SERVICE_UUID]]) {
                deviceName = HS4S_NAME;
            }
            
            NSMutableDictionary *discoverDic = [NSMutableDictionary dictionary];
            [discoverDic setValue:macStr forKey:IDPS_SerialNumber];
            [discoverDic setValue:deviceName forKey:IDPS_Name];
            
            [peripheralAndSerialDic setValue:peripheral forKey:macStr];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:DiscoverDone object:self userInfo:discoverDic];
            
        }
        else {
            NSLog(@"Other Device");
        }
    }
}

#pragma mark - Connect by controller

-(void)connectDeviceWithSerialNub:(NSString *)serialNub {
    [self stopSearchBTLEDevice];
    
    CBPeripheral *tempPeripheral = [peripheralAndSerialDic valueForKey:serialNub];
    
    BOOL isConnected = false;
    if (tempPeripheral && tempPeripheral.identifier.UUIDString) {
        for (CBPeripheral *connectedPeripherial in connectedPeripheralArray) {
            if ([tempPeripheral.identifier isEqual:connectedPeripherial.identifier]) {
                isConnected = true;
                break;
            }
        }
    }
    
    if (tempPeripheral) {
        if (isConnected==false) {
            [centralManager connectPeripheral:tempPeripheral options:nil];
            [self performSelector:@selector(connectFailed:) withObject:tempPeripheral afterDelay:4.0];
        }
        else {
            if ([self recIdpsOver:tempPeripheral.identifier.UUIDString]) {
                NSDictionary *tempidpsDic = [idpsDic valueForKey:tempPeripheral.identifier.UUIDString];
                [[NSNotificationCenter defaultCenter]postNotificationName:DeviceAuthenSuccess object:self userInfo:tempidpsDic];
            }
            else {
                [self connectFailedNoti:tempPeripheral];
            }
        }
    }
    else {//不存在
        NSString *uuidString = [self commandGetPeripherialUUIDFormSerialNub:serialNub];
        if (uuidString) {
            NSUUID *uuid = [[NSUUID alloc]initWithUUIDString:uuidString];
            if (uuid) {
                NSArray *cachePeripherialArray = [centralManager retrievePeripheralsWithIdentifiers:[NSArray arrayWithObject:uuid]];
                if (cachePeripherialArray.count) {
#ifdef DLog
                    NSLog(@"direct connect:%@ ",serialNub);
#endif
                    CBPeripheral *selPeripherial = [cachePeripherialArray objectAtIndex:0];
                    [peripheralAndSerialDic setValue:selPeripherial forKey:serialNub];
                    [centralManager connectPeripheral:selPeripherial options:nil];
                    [self performSelector:@selector(connectFailed:) withObject:selPeripherial afterDelay:4.0];
                    return;
                }
            }
        }

        NSMutableDictionary *failedDic = [NSMutableDictionary dictionary];
        [failedDic setValue:serialNub forKey:IDPS_SerialNumber];
        [[NSNotificationCenter defaultCenter]postNotificationName:DeviceConnectFailed object:self userInfo:failedDic];
    }
}
#pragma mark -


-(void)connectFailed:(CBPeripheral *)peripheral{
#ifdef DLog
    NSLog(@"connectFailed:%@",peripheral);
#endif
    if([discoveredPeripheralArray containsObject:peripheral]){
        [centralManager cancelPeripheralConnection:peripheral];
        [discoveredPeripheralArray removeObject:peripheral];
    }
    isConnectBLEDeviceFlag = false;
    [self connectFailedNoti:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    isConnectBLEDeviceFlag = false;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectFailed:) object:peripheral];
#ifdef DLog
    NSLog(@"didConnectPeripheral:%@, service:%@",[peripheral description],peripheral.services);
#endif
    if(![connectedPeripheralArray containsObject:peripheral]){
        [connectedPeripheralArray addObject:peripheral];
        [peripheral setDelegate:self];
        
//        NSMutableArray *addServiceArray = [[NSMutableArray alloc]init];
//        [addServiceArray addObject:[CBUUID UUIDWithString:IDPS_SERVICE_UUID]];
//        for (NSString *tempUUID in allCanDiscoverDevice) {
//            [addServiceArray addObject:[CBUUID UUIDWithString:tempUUID]];
//        }
        [peripheral discoverServices:nil];

    }
    if([discoveredPeripheralArray containsObject:peripheral]){
        [discoveredPeripheralArray removeObject:peripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    isConnectBLEDeviceFlag = false;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectFailed:) object:peripheral];
    NSString *uuid = BtleUUID(peripheral);
#ifdef DLog
    NSLog(@"didFailToConnectPeripheral:%@",uuid);
#endif
    if(uuid.length>0){
        if([[idpsDic allKeys]containsObject:uuid]){
            [idpsDic removeObjectForKey:uuid];
        }
    }
    if([discoveredPeripheralArray containsObject:peripheral]){
        [discoveredPeripheralArray removeObject:peripheral];
    }
    [self connectFailedNoti:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSString *uuid = BtleUUID(peripheral);
#ifdef DLog
    NSLog(@"didDisconnectPeripheral:%@",uuid);
#endif
    if([connectedPeripheralArray containsObject:peripheral]){
        [connectedPeripheralArray removeObject:peripheral];
    }
    if([discoveredPeripheralArray containsObject:peripheral]){
        [discoveredPeripheralArray removeObject:peripheral];
    }
    
    if(uuid.length>0){
        if([lowFirmwareDeviceArray containsObject:uuid]){
            [lowFirmwareDeviceArray removeObject:uuid];
        }
        if([self recIdpsOver:uuid]){
            NSDictionary *deviceIDPS = [idpsDic objectForKey:uuid];
            NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:deviceIDPS];
            [mDic setValue:uuid forKey:IDPS_ID];
            [[NSNotificationCenter defaultCenter]postNotificationName:DeviceDisconnect object:self userInfo:mDic];
            if([[idpsDic allKeys]containsObject:uuid]){
                [idpsDic removeObjectForKey:uuid];
            }
        }
        else {
            [self connectFailedNoti:peripheral];
        }
    }
}



#pragma mark - CBPeripheralDelegate

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral NS_AVAILABLE(NA, 6_0){
    NSLog(@"peripheralDidUpdateName:%@",peripheral.name);
}

- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral NS_AVAILABLE(NA, 6_0);{
    NSLog(@"peripheralDidInvalidateServices:%@",peripheral.name);
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error{
    if(error == nil){
        
    }
    else{
        NSLog(@"peripheralDidUpdateRSSI error:%@",error);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if(error == nil){
        for (CBService *aService in peripheral.services)
        {
#ifdef DLog
            NSLog(@"aService.uuid:%@",aService.UUID);
#endif
            NSString *uuidStr = [self commandGetUUIDStringFromCBUUID:aService.UUID];
            NSInteger uuidIndex = [serviceArray indexOfObject:uuidStr];
            if (uuidIndex == NSNotFound && [aService.UUID isEqual:[CBUUID UUIDWithString:IDPS_SERVICE_UUID]]) {
                [peripheral discoverCharacteristics:[NSArray arrayWithObjects:[CBUUID UUIDWithString:IDPS_CHRASTERISTIC_MODEL_UUID],[CBUUID UUIDWithString:IDPS_CHRASTERISTIC_SERIAL_UUID],[CBUUID UUIDWithString:IDPS_CHRASTERISTIC_FIRMWARE_UUID],[CBUUID UUIDWithString:IDPS_CHRASTERISTIC_HARDWARE_UUID],[CBUUID UUIDWithString:IDPS_CHRASTERISTIC_BT_UUID],[CBUUID UUIDWithString:IDPS_CHRASTERISTIC_MANUFACTURE_UUID],[CBUUID UUIDWithString:IDPS_CHRASTERISTIC_PRO_UUID],[CBUUID UUIDWithString:IDPS_CHRASTERISTIC_NAME_UUID],[CBUUID UUIDWithString:IDPS_CHRASTERISTIC_PRO128_UUID],[CBUUID UUIDWithString:IDPS_CHRASTERISTIC_NAME128_UUID],nil] forService:aService];
            }
            else if (uuidIndex != NSNotFound && uuidIndex<[serviceArray count]){
                [peripheral discoverCharacteristics:[NSArray arrayWithObjects:[CBUUID UUIDWithString:[characterRecArray objectAtIndex:uuidIndex]],[CBUUID UUIDWithString:[characterSendArray objectAtIndex:uuidIndex]],nil] forService:aService];
            }
        }
    }
    else{
#ifdef DLog
        NSLog(@"didDiscoverServices error:%@",error);
#endif
        [self connectFailedNoti:peripheral];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if(error == nil){
        NSString *uuidStr = [self commandGetUUIDStringFromCBUUID:service.UUID];
        NSInteger uuidIndex = [serviceArray indexOfObject:uuidStr];
        if([service.UUID isEqual:[CBUUID UUIDWithString:IDPS_SERVICE_UUID]]){
            for (CBCharacteristic *aChar in service.characteristics)
            {
                NSString *uuidString = [self CBUUIDToString:aChar.UUID];
                if([uuidString isEqualToString:IDPS_CHRASTERISTIC_FIRMWARE_UUID] || [uuidString isEqualToString:IDPS_CHRASTERISTIC_HARDWARE_UUID] || [uuidString isEqualToString:IDPS_CHRASTERISTIC_MANUFACTURE_UUID] ||[uuidString isEqualToString:IDPS_CHRASTERISTIC_MODEL_UUID] ||[uuidString isEqualToString:IDPS_CHRASTERISTIC_NAME_UUID] ||[uuidString isEqualToString:IDPS_CHRASTERISTIC_PRO_UUID] ||[uuidString isEqualToString:IDPS_CHRASTERISTIC_SERIAL_UUID] ||[uuidString isEqualToString:IDPS_CHRASTERISTIC_BT_UUID]||[uuidString isEqualToString:IDPS_CHRASTERISTIC_PRO128_UUID]||[uuidString isEqualToString:IDPS_CHRASTERISTIC_NAME128_UUID]){
                    [peripheral readValueForCharacteristic:aChar];
                }
            }
        }
        else if(uuidIndex != NSNotFound){
            for (CBCharacteristic *aChar in service.characteristics)
            {
                /* Set notification */
                if ([aChar.UUID isEqual:[CBUUID UUIDWithString:[characterRecArray objectAtIndex:uuidIndex]]]){
                    [peripheral setNotifyValue:YES forCharacteristic:aChar];
                    break;
                }
            }
        }
        
        
    }
    else{
        NSLog(@"didDiscoverCharacteristicsForService error:%@",error);
        [self connectFailedNoti:peripheral];
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSString *uuidString = BtleUUID(peripheral);
    if(error == nil){
        int8_t bufff[500] = {0};
        [characteristic.value getBytes:bufff];
        
        if([characteristic.UUID isEqual:[CBUUID UUIDWithString:IDPS_CHRASTERISTIC_FIRMWARE_UUID]]){
//            NSString *firmwareVersion = [[NSString alloc]initWithBytes:bufff length:strlen((char *)bufff) encoding:NSUTF8StringEncoding];
            NSString *firmwareVersion=[[NSString alloc]initWithFormat:@"%c.%c.%c",bufff[0],bufff[1],bufff[2]];
            [self handleIdpsInfo:uuidString key:IDPS_FirmwareVersion value:firmwareVersion];
        }
        else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:IDPS_CHRASTERISTIC_BT_UUID]]){
//            NSString *btFirmwareVersion = [[NSString alloc]initWithBytes:bufff length:strlen((char *)bufff) encoding:NSUTF8StringEncoding];
            NSString *btFirmwareVersion=[[NSString alloc]initWithFormat:@"%c.%c.%c",bufff[0],bufff[1],bufff[2]];
            [self handleIdpsInfo:uuidString key:IDPS_BTFirmwareVersion value:btFirmwareVersion];
        }
        else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:IDPS_CHRASTERISTIC_HARDWARE_UUID]]){
//            NSString *hardwareVersion = [[NSString alloc]initWithBytes:bufff length:strlen((char *)bufff) encoding:NSUTF8StringEncoding];
            NSString *hardwareVersion=[[NSString alloc]initWithFormat:@"%c.%c.%c",bufff[0],bufff[1],bufff[2]];
            [self handleIdpsInfo:uuidString key:IDPS_HardwareVersion value:hardwareVersion];
        }
        else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:IDPS_CHRASTERISTIC_MANUFACTURE_UUID]]){
            NSString *manufacture = [[NSString alloc]initWithBytes:bufff length:strlen((char *)bufff) encoding:NSUTF8StringEncoding];
            [self handleIdpsInfo:uuidString key:IDPS_Manufacture value:manufacture];
        }
        else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:IDPS_CHRASTERISTIC_MODEL_UUID]]){
            NSString *modelNumber = [[NSString alloc]initWithBytes:bufff length:strlen((char *)bufff) encoding:NSUTF8StringEncoding];
            [self handleIdpsInfo:uuidString key:IDPS_ModelNumber value:modelNumber];
        }
        else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:IDPS_CHRASTERISTIC_NAME_UUID]]){
            NSString *name = [[NSString alloc]initWithBytes:bufff length:strlen((char *)bufff) encoding:NSUTF8StringEncoding];
            [self handleIdpsInfo:uuidString key:IDPS_AccessoryName value:name];
        }
        else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:IDPS_CHRASTERISTIC_NAME128_UUID]]){
            NSString *name = [[NSString alloc]initWithBytes:bufff length:strlen((char *)bufff) encoding:NSUTF8StringEncoding];
            [self handleIdpsInfo:uuidString key:IDPS_AccessoryName value:name];
        }
        else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:IDPS_CHRASTERISTIC_PRO_UUID]]){
            NSString *protocolString = [[NSString alloc]initWithBytes:bufff length:strlen((char *)bufff) encoding:NSUTF8StringEncoding];
            [self handleIdpsInfo:uuidString key:IDPS_ProtocolString value:protocolString];
        }
        else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:IDPS_CHRASTERISTIC_PRO128_UUID]]){
            NSString *protocolString = [[NSString alloc]initWithBytes:bufff length:strlen((char *)bufff) encoding:NSUTF8StringEncoding];
            [self handleIdpsInfo:uuidString key:IDPS_ProtocolString value:protocolString];
        }
        else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:IDPS_CHRASTERISTIC_SERIAL_UUID]]){
//            uint8_t macBuf[6] = {0};
//            if(characteristic.value.length == 6){
//                [characteristic.value getBytes:macBuf length:6];
//            }
//            NSString *serialNumber = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X",macBuf[0],macBuf[1],macBuf[2],macBuf[3],macBuf[4],macBuf[5]];
//            [self handleIdpsInfo:uuidString key:IDPS_SerialNumber value:serialNumber];
            
            uint8_t macBuf[12] = {0};
            NSString *serialNumber = @"000000000000";
            if(characteristic.value.length == 6){
                [characteristic.value getBytes:macBuf length:6];
                serialNumber = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X",macBuf[0],macBuf[1],macBuf[2],macBuf[3],macBuf[4],macBuf[5]];
            }
            else if(characteristic.value.length == 12){
                [characteristic.value getBytes:macBuf length:12];
                serialNumber = [NSString stringWithFormat:@"%c%c%c%c%c%c%c%c%c%c%c%c",macBuf[0],macBuf[1],macBuf[2],macBuf[3],macBuf[4],macBuf[5],macBuf[6],macBuf[7],macBuf[8],macBuf[9],macBuf[10],macBuf[11]];
            }
            //记录连接设备 MAC 与 UUID 对应关系
            [self commandSavePeripherial:peripheral withSerialNub:serialNumber];
            [self handleIdpsInfo:uuidString key:IDPS_SerialNumber value:serialNumber];
            
        }
        else{
            if([self recIdpsOver:uuidString]){
                NSDictionary *singleIdpsDic = [idpsDic objectForKey:uuidString];
               
                [self handleData:characteristic.value peripheralUUID:uuidString characteristicUIID:[self CBUUIDToString:characteristic.UUID] protocal:[singleIdpsDic objectForKey:IDPS_ProtocolString]];
                  
            }
            else{
                NSLog(@"Not enough IDPS Info");
            }
        }
        
    }
    else{
        NSLog(@"didUpdateValueForCharacteristic error:%@",error);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if(error==nil){
        
    }
    else{
        NSLog(@"didWriteValueForCharacteristic error:%@",error);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if(error == nil){
        
        NSString *uuid = BtleUUID(peripheral);
        if(uuid.length>0){
            NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:uuid,IDPS_ID,peripheral.name,IDPS_Name,nil];
            if([self recIdpsOver:[tempDic objectForKey:IDPS_ID]]){
                
                NSDictionary *tempInfo = [idpsDic objectForKey:uuid];
                NSString *modelNub = [tempInfo objectForKey:IDPS_ModelNumber];
                NSMutableDictionary *deviceIDPS = [NSMutableDictionary dictionaryWithDictionary:tempInfo];
                NSArray *modelArray = [modelNub componentsSeparatedByString:@" "];
                if(modelArray.count>0){
                    [deviceIDPS setValue:[modelArray objectAtIndex:0] forKey:IDPS_Name];
                }
                [deviceIDPS setValue:uuid forKey:IDPS_ID];
                [deviceIDPS setValue:[NSNumber numberWithInteger:DeviceUUIDType_BLE] forKey:IDPS_Type];
                [idpsDic setValue:deviceIDPS forKey:uuid];
                
                [[NSNotificationCenter defaultCenter]postNotificationName:DeviceOpenSession object:self userInfo:deviceIDPS];
            }
            else{
                [self performSelector:@selector(delaySendConnectedMessage:) withObject:tempDic afterDelay:0.1];
            }
        }
        
    }
    else{
        NSLog(@"didUpdateNotificationStateForCharacteristic error:%@",error);
        [self connectFailedNoti:peripheral];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    
}


//断开所有连接的设备
-(void)cancelAllDevice{
    if(IOS7Flag==TRUE){
        NSMutableArray *selServiceArray = [[NSMutableArray alloc]init];
        for(NSString *uuidStr in allCanDiscoverDevice){
            [selServiceArray addObject:[CBUUID UUIDWithString:uuidStr]];
        }
        NSArray *tempArray = [centralManager retrieveConnectedPeripheralsWithServices:selServiceArray];
        for (CBPeripheral *tempPeripheral in tempArray) {
            [centralManager cancelPeripheralConnection:tempPeripheral];
        }
    }
    else{
       // [centralManager retrieveConnectedPeripherals];
    }
    
    for(CBPeripheral *peripheral in connectedPeripheralArray){
        [centralManager cancelPeripheralConnection:peripheral];
    }
    for(CBPeripheral *peripheral in discoveredPeripheralArray){
        [centralManager cancelPeripheralConnection:peripheral];
    }
    //[self clearDiscoverCacheDeviceList:BTLE_ALL];
    [self clearDiscoverDeviceList:BtleType_All];
    [self clearConnectedDeviceList:BtleType_All];
}

//从主动断开的设备列表中清楚指定设备
-(void)clearDisconnectedDevice:(NSString *)uuidString{
    if([disconnectUUIDArray containsObject:uuidString]){
        [disconnectUUIDArray removeObject:uuidString];
    }
}

//打开指定设备扫瞄开关
-(void)openSelDeviceFromName:(NSString *)deviceName{
    if(deviceName!=nil){
        if(![allCanDiscoverDevice containsObject:deviceName]){
            [allCanDiscoverDevice addObject:deviceName];
        }
        if(allCanDiscoverDevice.count > 0){
            [self stopSearchBTLEDevice];
            couldConnectFlag = TRUE;
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self startSearchBtleDevice];
            });
        }
    }

}

//关闭指定设备扫瞄开关
-(void)closeSelDeviceFromName:(NSString *)deviceName{
    if(deviceName!=nil){
        if([allCanDiscoverDevice containsObject:deviceName]){
            [allCanDiscoverDevice removeObject:deviceName];
        }
        if(allCanDiscoverDevice.count == 0){
            couldConnectFlag = false;
            [self stopSearchBTLEDevice];
        }
    }
}

//打开指定设备扫瞄开关
-(void)openSelDeviceFromType:(BtleType )deviceType{
    if((deviceType & BtleType_AM3) == 1){
        if(![allCanDiscoverDevice containsObject:AM3_SERVICE_UUID]){
            [allCanDiscoverDevice addObject:AM3_SERVICE_UUID];
        }
        if(![allCanDiscoverDevice containsObject:AM3_SERVICE_UUID_24]){
            [allCanDiscoverDevice addObject:AM3_SERVICE_UUID_24];
        }
    }
    if((deviceType & BtleType_HS4) == 2){
        if(![allCanDiscoverDevice containsObject:HS4_SERVICE_UUID]){
            [allCanDiscoverDevice addObject:HS4_SERVICE_UUID];
        }
        if(![allCanDiscoverDevice containsObject:HS4_SERVICE_UUID_24]){
            [allCanDiscoverDevice addObject:HS4_SERVICE_UUID_24];
        }
    }
    if((deviceType & BtleType_PO3) == 4){
        if(![allCanDiscoverDevice containsObject:PO3_SERVICE_UUID]){
            [allCanDiscoverDevice addObject:PO3_SERVICE_UUID];
        }
        if(![allCanDiscoverDevice containsObject:PO3_SERVICE_UUID_128]){
            [allCanDiscoverDevice addObject:PO3_SERVICE_UUID_128];
        }
    }
    if((deviceType & BtleType_ECG) == 8){
        if(![allCanDiscoverDevice containsObject:ECG_SERVICE_UUID]){
            [allCanDiscoverDevice addObject:ECG_SERVICE_UUID];
        }
    }
    if((deviceType & BtleType_Temp) == 16){
        if(![allCanDiscoverDevice containsObject:Temper_SERVICE_UUID]){
            [allCanDiscoverDevice addObject:Temper_SERVICE_UUID];
        }
    }
    if((deviceType & BtleType_BG5L) == 32){
        if(![allCanDiscoverDevice containsObject:BG5L_SERVICE_UUID]){
            [allCanDiscoverDevice addObject:BG5L_SERVICE_UUID];
        }
    }
    if((deviceType & BtleType_KS3) == 64){
        if(![allCanDiscoverDevice containsObject:KS3_SERVICE_UUID]){
            [allCanDiscoverDevice addObject:KS3_SERVICE_UUID];
        }
    }
    if((deviceType & BtleType_PO7) == 128){
        if(![allCanDiscoverDevice containsObject:PO7_SERVICE_UUID]){
            [allCanDiscoverDevice addObject:PO7_SERVICE_UUID];
        }
    }
    if((deviceType & BtleType_AM3S) == 256){
        if(![allCanDiscoverDevice containsObject:AM3S_SERVICE_UUID]){
            [allCanDiscoverDevice addObject:AM3S_SERVICE_UUID];
        }
    }
    if((deviceType & BtleType_AM4) == 512){
        if(![allCanDiscoverDevice containsObject:AM4_SERVICE_UUID]){
            [allCanDiscoverDevice addObject:AM4_SERVICE_UUID];
        }
    }
    if((deviceType & BtleType_BP3L) == 1024){
        if(![allCanDiscoverDevice containsObject:BP3L_SERVICE_UUID]){
            [allCanDiscoverDevice addObject:BP3L_SERVICE_UUID];
        }
    }
    

    if(allCanDiscoverDevice.count > 0){
        [self stopSearchBTLEDevice];
        couldConnectFlag = TRUE;
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self startSearchBtleDevice];
        });
    }
}

//关闭指定设备扫瞄开关
-(void)closeSelDeviceFromType:(BtleType )deviceType{
    if((deviceType & BtleType_AM3) == 1){
        if([allCanDiscoverDevice containsObject:AM3_SERVICE_UUID]){
            [allCanDiscoverDevice removeObject:AM3_SERVICE_UUID];
        }
        if([allCanDiscoverDevice containsObject:AM3_SERVICE_UUID_24]){
            [allCanDiscoverDevice removeObject:AM3_SERVICE_UUID_24];
        }
    }
    if((deviceType & BtleType_HS4) == 2){
        if([allCanDiscoverDevice containsObject:HS4_SERVICE_UUID]){
            [allCanDiscoverDevice removeObject:HS4_SERVICE_UUID];
        }
        if([allCanDiscoverDevice containsObject:HS4_SERVICE_UUID_24]){
            [allCanDiscoverDevice removeObject:HS4_SERVICE_UUID_24];
        }
    }
    if((deviceType & BtleType_PO3) == 4){
        if([allCanDiscoverDevice containsObject:PO3_SERVICE_UUID]){
            [allCanDiscoverDevice removeObject:PO3_SERVICE_UUID];
        }
        if([allCanDiscoverDevice containsObject:PO3_SERVICE_UUID_128]){
            [allCanDiscoverDevice removeObject:PO3_SERVICE_UUID_128];
        }
    }
    if((deviceType & BtleType_ECG) == 8){
        if([allCanDiscoverDevice containsObject:ECG_SERVICE_UUID]){
            [allCanDiscoverDevice removeObject:ECG_SERVICE_UUID];
        }
    }
    if((deviceType & BtleType_Temp) == 16){
        if([allCanDiscoverDevice containsObject:Temper_SERVICE_UUID]){
            [allCanDiscoverDevice removeObject:Temper_SERVICE_UUID];
        }
    }
    if((deviceType & BtleType_BG5L) == 32){
        if([allCanDiscoverDevice containsObject:BG5L_SERVICE_UUID]){
            [allCanDiscoverDevice removeObject:BG5L_SERVICE_UUID];
        }
    }
    if((deviceType & BtleType_KS3) == 64){
        if([allCanDiscoverDevice containsObject:KS3_SERVICE_UUID]){
            [allCanDiscoverDevice removeObject:KS3_SERVICE_UUID];
        }
    }
    if((deviceType & BtleType_PO7) == 128){
        if([allCanDiscoverDevice containsObject:PO7_SERVICE_UUID]){
            [allCanDiscoverDevice removeObject:PO7_SERVICE_UUID];
        }
    }
    if((deviceType & BtleType_AM3S) == 256){
        if([allCanDiscoverDevice containsObject:AM3S_SERVICE_UUID]){
            [allCanDiscoverDevice removeObject:AM3S_SERVICE_UUID];
        }
    }
    if((deviceType & BtleType_AM4) == 512){
        if([allCanDiscoverDevice containsObject:AM4_SERVICE_UUID]){
            [allCanDiscoverDevice removeObject:AM4_SERVICE_UUID];
        }
    }
    if((deviceType & BtleType_BP3L) == 1024){
        if([allCanDiscoverDevice containsObject:BP3L_SERVICE_UUID]){
            [allCanDiscoverDevice removeObject:BP3L_SERVICE_UUID];
        }
    }

    if(allCanDiscoverDevice.count == 0){
        couldConnectFlag = false;
        [self stopSearchBTLEDevice];
    }
}

//获取btle设备uuid字符串
+(NSString *)getUUIDString:(CBPeripheral *)peripheral{
    NSString *uuidString = @"";
    if(peripheral){
        if(IOS7Flag==TRUE){
            if(peripheral.identifier){
                uuidString = [peripheral.identifier UUIDString];
            }
        }
        else{
//            if(peripheral.UUID){
//                uuidString = (NSString *)CFBridgingRelease(CFUUIDCreateString(nil, peripheral.UUID));
//            }
        }
    }
    return uuidString;
}

//获取设备名字
-(NSString *)getDeviceName:(BtleType )btleType{
    NSString *deviceName = Nil;
    switch (btleType) {
        default:
            break;
    }
    return deviceName;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

//关闭收数据始能，200ms后断开设备
-(void)commandSetNotiDisForUUID:(NSString *)tempUUID{
    for (CBPeripheral *tempPeripheral in connectedPeripheralArray) {
        NSString *currentUUID = [BTLEController getUUIDString:tempPeripheral];
        if ([currentUUID isEqualToString:tempUUID]) {
            for (CBService *tempService in tempPeripheral.services) {
                for (CBCharacteristic *tempharacteristics in tempService.characteristics) {
                    for (NSString *recStr in characterRecArray) {
                        if ([tempharacteristics.UUID isEqual:[CBUUID UUIDWithString:recStr]]){
                            [tempPeripheral setNotifyValue:NO forCharacteristic:tempharacteristics];
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [centralManager cancelPeripheralConnection:tempPeripheral];
                            });
                            break;
                        }
                    }
                }
            }
        }
    }
}

//添加优先连接的设备mac
-(void)commandAddFirstConnectionDevice:(NSString *)tempDeviceID{
    if (tempDeviceID.length==12) {
        NSString *upperMac = [tempDeviceID uppercaseString];
        if (![firstConnectDeviceIDArray containsObject:upperMac]) {
            [firstConnectDeviceIDArray addObject:upperMac];
        }
    }
}

-(void)connectFailedNoti:(CBPeripheral *)tempPeripheral{
    NSString *serialNub = nil;
    for (NSString *tempSerialNub in peripheralAndSerialDic.allKeys) {
        CBPeripheral *discoverPeripheral = [peripheralAndSerialDic valueForKey:tempSerialNub];
        if ([tempPeripheral.identifier isEqual:discoverPeripheral.identifier]) {
            serialNub = tempSerialNub;
            break;
        }
    }
    NSMutableDictionary *failedDic = [NSMutableDictionary dictionary];
    [failedDic setValue:serialNub forKey:IDPS_SerialNumber];
    if (tempPeripheral.identifier) {
        [failedDic setValue:tempPeripheral.identifier.UUIDString forKey:IDPS_ID];
        [centralManager cancelPeripheralConnection:tempPeripheral];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:DeviceConnectFailed object:self userInfo:failedDic];
}


-(void)commandSavePeripherial:(CBPeripheral *)tempPeripheral withSerialNub:(NSString *)serialNub{
    if (tempPeripheral.identifier && serialNub) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *peripherialDic = [NSMutableDictionary dictionaryWithDictionary:[userDefault valueForKey:@"iHealthDeviceCache"]];
        [peripherialDic setValue:tempPeripheral.identifier.UUIDString forKey:serialNub];
        [userDefault setValue:peripherialDic forKey:@"iHealthDeviceCache"];
        [userDefault synchronize];
    }
}

-(NSString *)commandGetPeripherialUUIDFormSerialNub:(NSString *)serialNub {
    if (serialNub) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *peripherialDic = [userDefault valueForKey:@"iHealthDeviceCache"];
        NSString *uuid = [peripherialDic valueForKey:serialNub];
        return uuid;
    }
    return nil;
}

-(NSString *)commandGetSerialNubFormPeripherial:(CBPeripheral *)tempPeripheral {
    if (tempPeripheral.identifier) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *peripherialDic = [userDefault valueForKey:@"iHealthDeviceCache"];
        for (NSString *serialNub in peripherialDic.allKeys) {
            NSString *uuid = [peripherialDic valueForKey:serialNub];
            if ([uuid isEqual:tempPeripheral.identifier.UUIDString]) {
                return serialNub;
                break;
            }
        }
    }
    return @"FFFFFFFFFFFF";
}

@end
