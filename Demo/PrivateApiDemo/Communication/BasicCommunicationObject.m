//
//  BasicCommunicationObject.m
//  3he1-936CommunicationModule
//
//  Created by liuxin on 12-6-6.
//  Copyright (c) 2012年 lxyeslxlx13@163.com. All rights reserved.
//

#import "BasicCommunicationObject.h"
//#import "SCLXWifiTransmission.h"
#import "LXCommunicationEAControler.h"
#import "Encode.h"
#import "BTLEController.h"
#import "ReceivedDataObject.h"
//#import "ScanDeviceController.h"
//#import "ConnectDeviceController.h"


@implementation BasicCommunicationObject
@synthesize btleController,eaCommunication;


+ (BasicCommunicationObject *)basicCommunicationObject
{
    static BasicCommunicationObject *basicCommunicationObject = nil;
    if (basicCommunicationObject == nil) {
        basicCommunicationObject = [[BasicCommunicationObject alloc] init];
    }
	
    return basicCommunicationObject;
}
-(id)init
{
    if (self=[super init]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(creatSessionStartAuthentication:) name:DeviceOpenSession object:nil];
        //clearAllAuthenDevice
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearAllAuthenDevice) name:BTPowerOff object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceDisconnect:) name:DeviceDisconnect object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceConnect:) name:DeviceConnect object:nil];
        
        prtocolArray=[[NSArray alloc] initWithObjects:HS5_Protocol/*0*/,BP3_Protocol/*1*/,HS3_Protocol/*2*/,BP5_Protocol/*3*/,BG3_Protocol/*4*/,MG_Protocol/*5*/,@"authenticaitonEA"/*6*/,@"authenticaitonWifi"/*7*/,BSW_Protocol/*8*/,BG5_Protocol/*9*/,PO3_Protocol/*10*/,ECG_Protocol/*11*/,AM3_Protocol/*12*/,BG5L_Protocol/*13*/,KS3_Protocol/*14*/,TE3_Protocol/*15*/,HS4_Protocol/*16*/,PO7_Protocol/*17*/,AM3S_Protocol/*18*/,ABI_Protocol/*19*/,BP3L_Protocol/*20*/,BP5_Protocol2/*21*/,AM4_Protocol/*22*/,nil];
        btleProtocolArray = [[NSArray alloc] initWithObjects:PO3_Protocol,ECG_Protocol,AM3_Protocol,BG5L_Protocol,KS3_Protocol,TE3_Protocol,HS4_Protocol,PO7_Protocol,AM3S_Protocol,BP3L_Protocol,AM4_Protocol,nil];
        productTypeNum=[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:HS5_ProductType]/*0*/,[NSNumber numberWithInt:BP3_ProductType]/*1*/,[NSNumber numberWithInt:HS3_ProductType]/*2*/,[NSNumber numberWithInt:BP5_ProductType]/*3*/,[NSNumber numberWithInt:BG3_ProductType]/*4*/,[NSNumber numberWithInt:MG_ProductType]/*5*/, [NSNumber numberWithInt:0x00]/*6*/,[NSNumber numberWithInt:0x00]/*7*/,[NSNumber numberWithInt:0xA9]/*8*/,[NSNumber numberWithInt:BG5_ProductType]/*9*/,[NSNumber numberWithInt:PO3_ProductType]/*10*/,[NSNumber numberWithInt:ECG_ProductType]/*11*/,[NSNumber numberWithInt:AM3_ProductType]/*12*/,[NSNumber numberWithInt:BG5L_ProductType]/*13*/,[NSNumber numberWithInt:KS3_ProductType]/*14*/,[NSNumber numberWithInt:TE3_ProductType]/*15*/,[NSNumber numberWithInt:HS4_ProductType]/*16*/,[NSNumber numberWithInt:PO7_ProductType]/*17*/,[NSNumber numberWithInt:AM3S_ProductType]/*18*/,[NSNumber numberWithInt:ABI_ProductType]/*19*/,[NSNumber numberWithInt:BP3L_ProductType]/*20*/,[NSNumber numberWithInt:BP5_ProductType]/*21*/,[NSNumber numberWithInt:AM4_ProductType]/*22*/,nil];

        
        sendDictionary=[[NSMutableDictionary alloc] init];
        lastSendData=[[NSMutableData alloc] init];
        BufDic=[[NSMutableDictionary alloc] init];
        
        receivedDataObject=[[ReceivedDataObject alloc] init];//启用数据处理类
        receivedDataObject.delegate=self;//设置代理
        authenticationDeviceList=[[NSMutableArray alloc] init];
        authenticationDownDeviceList=[[NSMutableArray alloc] init];
        connectedDeviceList=[[NSMutableArray alloc] init];
        sendIndexDic=[[NSMutableDictionary alloc] init];
        sendMaxLenDic=[[NSMutableDictionary alloc] init];
        
        _reSendTime=0;
        totalDataBagDic = [[NSMutableDictionary alloc] init];
        lastSendDic = [[NSMutableDictionary alloc] init];
        reSendTimeOfDevice = [[NSMutableDictionary alloc] init];
        
        persistantDevice = [[NSMutableArray alloc] init];
        
        
        //当前连接设备集合
        connectDeviceArray = [[NSMutableArray alloc]init];
        
        //缓存认证过的设备信息
        authenBTDeviceList = [[NSMutableArray alloc]init];
        
        authenFlag = TRUE;
        
        eaCommunication=[[LXCommunicationEAControler alloc] init];
        eaCommunication.delegate=self;
//        wifiCommunication=[[SCLXWifiTransmission alloc] init];
//        wifiCommunication.delegate=self;
        btleController=[[BTLEController alloc]init];
        btleController.delegate=self;
        
//        [ScanDeviceController commandGetInstance];
//        [ConnectDeviceController commandGetInstance];
        
        
        // 初始化CloudCore
//        IHCloud4CoreClass *cloudInstance = [IHCloud4CoreClass getCloudCoreClassInstance];
//        [cloudInstance setConfigureInfoWithApp:IHAppType_Myvitals];
//        
//        [cloudInstance cloudCommandEqualSyncWithDataType:IHEqualSyncLowMachineTime];
//        cloudInstance.cloudEqualSyncDelegate = self;
//        
    }
    return self;
}


//搜索HS5
-(void)searchScale{
//    [wifiCommunication searchScales];
}

-(void)startAM{
    [btleController openSelDeviceFromType:BtleType_AM3|BtleType_AM3S];
}

-(void)stopAM{
    [btleController closeSelDeviceFromType:BtleType_AM3|BtleType_AM3S];
}

-(void)startPO3{
    [btleController openSelDeviceFromType:BtleType_PO3];
}

-(void)stopPO3{
    [btleController closeSelDeviceFromType:BtleType_PO3];
}

//开始扫瞄低功耗设备
-(void)startAllBtleDevice{
    BOOL flag = false;
    for(NSDictionary *deviceInfo in connectDeviceArray){
        if([[deviceInfo objectForKey:IDPS_Name]isEqualToString:AM3_NAME] && [[deviceInfo objectForKey:@"AM3User_state"]intValue]==1){
            flag = TRUE;
            break;
        }
    }
    if(flag == TRUE){
        NSLog(@"____________StartSearchAllBtleDevice,BtleType_HS4|BtleType_PO3");
        [btleController openSelDeviceFromType:(BtleType_HS4|BtleType_PO3|BtleType_AM3S|BtleType_BP3L)];
    }
    else{
         NSLog(@"____________StartSearchAllBtleDevice,BtleType_All");
        [btleController openSelDeviceFromType:(BtleType_AM3|BtleType_PO3|BtleType_HS4|BtleType_AM3S|BtleType_BP3L)];//BtleType_AM3|BtleType_HS4|BtleType_PO3
    }
}

//停止扫瞄低功耗设备
-(void)stopAllBtleDevice{
    NSLog(@"____________EndSearchAllBtleDevice,BtleType_All");
    [btleController closeSelDeviceFromType:BtleType_AM3|BtleType_HS4|BtleType_PO3|BtleType_AM3S|BtleType_BP3L];
}


//开始扫瞄低功耗设备
-(void)startSearchBTLEDevice:(BtleType)btleType{
    [btleController openSelDeviceFromType:btleType];
}
//停止扫瞄低功耗设备
-(void)stopSearchBTLEDevice:(BtleType)btleType{
    [btleController closeSelDeviceFromType:btleType];
}
//清空主动断开的低功耗设备列表
-(void)clearDisconnectBTLEDeviceList{
    [btleController clearDisconnectedDeviceList];
}

//判断是不是低功耗设备，通过协议号
-(BOOL)isBtleDevice:(NSString *)protocolString{
    if([btleProtocolArray containsObject:protocolString]){
        return true;
    }
    return false;
}

//获取蓝牙连接设备
-(NSMutableArray *)getAllEAConnectDevice{
    
    NSArray *tempConnectArray = [eaCommunication getAllConnectDevice];
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    for(int i=0; i<[tempConnectArray count];i++){
        NSString *deviceName = [[tempConnectArray objectAtIndex:i]objectForKey:IDPS_Name];
        if([deviceName isEqualToString:@"BP5"] || [deviceName isEqualToString:@"BP7"] || [deviceName isEqualToString:@"BG3"] || [deviceName isEqualToString:@"BG5"]){
            if([authenticationDeviceList indexOfObject:[[tempConnectArray objectAtIndex:i]objectForKey:IDPS_ID]]!=NSNotFound){
                [tempArray addObject:[tempConnectArray objectAtIndex:i]];
            }
        }
        else{
            [tempArray addObject:[tempConnectArray objectAtIndex:i]];
        }
    }
    return tempArray;
}

//获取wifi连接设备
-(NSMutableArray *)getAllWifiDevice{
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
//    NSDictionary *dic = [wifiCommunication getScaleSavedAllInformation];
//    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc]init];
//    NSArray *keyArray = [dic allKeys];
//    for(int i=0; i<[keyArray count]; i++){
//        tempDic = [dic objectForKey:[keyArray objectAtIndex:i]];
//        if(![tempArray containsObject:tempDic]){
//            [tempArray addObject:tempDic];
//        }
//    }
    return tempArray;
}

//获取低功耗设备
-(NSMutableArray *)getAllBtleDevice{
    NSArray *tempConnectArray = [btleController getConnectedPeripheralArray:BtleType_All];
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    for(int i=0; i<[tempConnectArray count];i++){
        CBPeripheral *selPeripherial = [tempConnectArray objectAtIndex:i];
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        NSString *uuid = BtleUUID(selPeripherial);
        if(uuid.length>0){
            if([btleController recIdpsOver:uuid] && [authenticationDeviceList containsObject:uuid]){
                NSMutableDictionary *idpsDic = [btleController getSelDeviceIdps:uuid];
                [tempDic setDictionary:idpsDic];
                [tempDic setValue:uuid forKey:IDPS_ID];
                if(![tempArray containsObject:tempDic]){
                    [tempArray addObject:tempDic];
                }
            }
        }
        
    }
    return tempArray;
}


//获取当前连接的所有设备-1.0
-(NSMutableArray *)getAllDevice{
    NSMutableArray *eaArray = [self getAllEAConnectDevice];
    NSMutableArray *wifiArray = [self getAllWifiDevice];
    NSMutableArray *btleArray = [self getAllBtleDevice];
    NSMutableArray *allArray = [NSMutableArray arrayWithArray:eaArray];
    [allArray addObjectsFromArray:wifiArray];
    [allArray addObjectsFromArray:btleArray];
    return allArray;
}

//获取当前连接的所有设备-2.0
-(NSArray *)getAllConnectDevice{
    return connectDeviceArray;
}

//获取连接设备的idps信息
-(NSDictionary *)getIDPSInfoForDevice:(NSString *)connectID{
    NSArray *connectDevice = [self getAllDevice];
    NSDictionary *deviceInfoReturn = nil;
    for (NSDictionary *deviceInfo in connectDevice)
    {
        NSString *connectDeviceID = [deviceInfo objectForKey:IDPS_ID];
        if ([connectDeviceID isEqualToString:connectID])
        {
            deviceInfoReturn = deviceInfo;
            break;
        }
    }
    return deviceInfoReturn;
}


-(void)clearDisconnectScale:(NSString *)mac{
//    [wifiCommunication clearDisconnectScale:mac];
}

-(NSDictionary *)getScaleSavedAllInformation{
//    NSDictionary *dic=[wifiCommunication getScaleSavedAllInformation];
    return nil;
}

//处理认证过程中，下位机不回复导致的超时
-(void)authenTimeout:(NSTimer *)tempTimer{
//    NSLog(@"authenTimeout--------");
    NSDictionary *userInfo = [tempTimer userInfo];
    NSString *deviceUUID = [userInfo objectForKey:IDPS_ID];
    if(deviceUUID.length>20){
        [self cancelBtleDevice:deviceUUID];
    }
    authenFlag = TRUE;
}

-(void)invalidateAuthenTimer:(NSString *)uuidString{
    if (authenTimer!=nil) {
        [authenTimer invalidate];
        authenTimer = nil;
    }
    if(uuidString.length>20){
        [self cancelBtleDevice:uuidString];
    }
    authenFlag = TRUE;
    
    if (uuidString.length) {
        BOOL isAuthenFalg = [authenticationDeviceList containsObject:uuidString];
        if (isAuthenFalg == false) {
            NSMutableDictionary *failedDic = [NSMutableDictionary dictionary];
            [failedDic setValue:uuidString forKey:IDPS_ID];
            NSDictionary *tempDeviceInfo = [self getIDPSInfoForDevice:uuidString];
            [failedDic setValue:[tempDeviceInfo valueForKey:IDPS_SerialNumber] forKey:IDPS_SerialNumber];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:DeviceConnectFailed object:self userInfo:failedDic];
            
        }
    }
    
}


-(void)creatSessionStartAuthentication:(NSNotification *)tempNoti
{
    NSDictionary *tempDic = [tempNoti userInfo];
    int indexProtocol=[prtocolArray indexOfObject:[tempDic objectForKey:IDPS_ProtocolString]];
    if(indexProtocol == NSNotFound){
        return;
    }
    else if(indexProtocol==1){
        
    }
    else if(indexProtocol==2){
        
    }
    else if ((indexProtocol>2&&indexProtocol<6) || indexProtocol==9 || indexProtocol==19 || indexProtocol == 21) {
        if(indexProtocol==3){
        }
        if(authenFlag == TRUE){
            authenFlag = FALSE;
//            NSLog(@"anthen start");
            if(indexProtocol == 9){
                [self performSelector:@selector(_creatSessionStartAuthentication:) withObject:tempNoti afterDelay:2.5];
                if (authenTimer!=nil) {
                    [authenTimer invalidate];
                    authenTimer = nil;
                }
                authenTimer = [NSTimer scheduledTimerWithTimeInterval:4.5 target:self selector:@selector(authenTimeout:) userInfo:tempDic repeats:NO];
            }
            else{
                [self performSelector:@selector(_creatSessionStartAuthentication:) withObject:tempNoti afterDelay:1];
                if (authenTimer!=nil) {
                    [authenTimer invalidate];
                    authenTimer = nil;
                }
                authenTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(authenTimeout:) userInfo:tempDic repeats:NO];
            }
        }
        else{
            [self performSelector:@selector(creatSessionStartAuthentication:) withObject:tempNoti afterDelay:1];
        }
    }
    else if(indexProtocol==8)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BluetoothSetWifiCreateSession" object:self userInfo:[tempNoti userInfo]];
        //字典函数key为protocol和from
    }
    else if(indexProtocol>9)
    {
        if(authenFlag == TRUE){
            authenFlag = FALSE;
//            NSLog(@"anthen start - btle");
            [self performSelector:@selector(_creatSessionStartAuthentication:) withObject:tempNoti afterDelay:0.5];
            if (authenTimer!=nil) {
                [authenTimer invalidate];
                authenTimer = nil;
            }
            authenTimer = [NSTimer scheduledTimerWithTimeInterval:4.5 target:self selector:@selector(authenTimeout:) userInfo:tempDic repeats:NO];
        }
        else{
            [self performSelector:@selector(creatSessionStartAuthentication:) withObject:tempNoti afterDelay:1];
        }

    }
    
}

//加密认证入口
-(void)_creatSessionStartAuthentication:(NSNotification *)tempNoti
{
    NSDictionary *tempInfo = [tempNoti userInfo];
    NSString *protocol = [tempInfo objectForKey:IDPS_ProtocolString];
    int i=[prtocolArray indexOfObject:protocol];
    if(i==NSNotFound){
        NSString *uuidString = [tempInfo objectForKey:IDPS_ID];
        InvalidateAuthenTimer(uuidString);
        NSLog(@"wrong protocol");
    }
    else if(i>9 && i!=19 && i!=21){
        [self startBtleAuthenticationTo:[tempInfo objectForKey:IDPS_ID] ProductType:(uint8_t)[[productTypeNum objectAtIndex:i] intValue] Protocol:[tempInfo objectForKey:IDPS_ProtocolString]];
    }
    else{
        [self startAuthenticationTo:[tempInfo objectForKey:IDPS_ID] IsNotEA:YES ProductType:(uint8_t)[[productTypeNum objectAtIndex:i] intValue]];
    }
}
-(void)wifiStartAuthentication:(NSString *)To 
{
    
    [self startAuthenticationTo:To IsNotEA:NO ProductType:0xA9];
}

-(uint8_t)checkUint8:(uint8_t *)cbuf//计算校验和
{
	uint8_t checkbuf=0x00;
	for (int i=2; i<cbuf[1]+2; i++) {
		checkbuf+=cbuf[i];
	}
	return checkbuf;
}
-(uint8_t)checkData:(NSData*)data//计算校验和
{
	uint8_t checkbuf=0x00;
    uint8_t len;
    [data getBytes:&len range:NSMakeRange(1, 1)];
	for (int i=2; i<len+2; i++) {
        uint8_t check=0x00;
        
		[data getBytes:(void *)&check range:NSMakeRange(i, 1)];
        checkbuf+=check;
	}
	return checkbuf;
}//计算校验和
#pragma mark send method
-(NSData *)reMakeSendData:(NSData *)data To:(NSString *)IDOrMac Protocol:(NSString *)protocol IsNeedRespond:(BOOL)isNeedRespond MakeSureStatueID:(uint8_t)MakeSureStatueID MakeSureIndex:(uint8_t)MakeSureIndex isNotRespond:(BOOL)isNotRespond
//封装发送数据
{
    NSMutableData *sendData=[[NSMutableData alloc] init];//释放对象，否则多次测量崩溃
    uint8_t statueID;
    uint8_t index;
    int indexProtocol=[prtocolArray indexOfObject:protocol];
    NSData *headData;
//    int i=[prtocolArray indexOfObject:protocol];
//    uint8_t productType=(uint8_t)[productTypeNum objectAtIndex:i];

    //未做分包处理
    
    
    if (isNeedRespond)
    {
        statueID=MakeSureStatueID;
    }
    else
    {
        statueID=0xF0;
    }
    
    if(isNotRespond)
    {
        //发送确认命令
        index=(MakeSureIndex+1)%256;
        statueID=MakeSureStatueID;
        int dataLen;
        if (data!=nil) {
            dataLen=[data length];
            
        }
        else 
        {
            dataLen=0;
        }
        if (indexProtocol!=0) {
            
            uint8_t headBuf[4]={0xB0,0x02+dataLen,statueID,index};
            headData=[[NSData alloc] initWithBytes:headBuf length:4];//释放对象
            [sendData appendData:headData];
//            NSData *productTypeUint8=[[NSData alloc] initWithBytes:&productType length:1];
//            [sendData appendData:productTypeUint8];
            [sendData appendData:data];
        }
        else
        {
            
            NSData *macData=[self transMACFromStrToHex:IDOrMac];

            uint8_t headBuf[4]={0xB0,0x08+dataLen,statueID,index};
            headData=[[NSData alloc] initWithBytes:headBuf length:4];//释放对象
            [sendData appendData:headData];
//            NSData *productTypeUint8=[[NSData alloc] initWithBytes:&productType length:1];
//            [sendData appendData:productTypeUint8];
            [sendData appendData:data];
            [sendData appendData:macData];
            
        }
        
        
    }
    else
    {
        //发送数据函数
        
        if (indexProtocol!=0&&indexProtocol!=7) {
            uint8_t len=[data length]+2;
            index=[[sendIndexDic objectForKey:IDOrMac] intValue];
            if(index==0){
                [sendIndexDic setObject:[NSNumber numberWithInt:1] forKey:IDOrMac];
                index = 1;
            }
            uint8_t headBuf[4]={0xB0,len,statueID,index};
            headData=[[NSData alloc] initWithBytes:headBuf length:4];//释放对象
            [sendData appendData:headData];
//            NSData *productTypeUint8=[[NSData alloc] initWithBytes:&productType length:1];
//            [sendData appendData:productTypeUint8];

            [sendData appendData:data];
        }
        else
        {
            
            NSData *macData=[self transMACFromStrToHex:IDOrMac];
            
            uint8_t len=[data length]+8;
            uint8_t index=[[sendIndexDic objectForKey:IDOrMac] intValue];
            if(index==0){
                [sendIndexDic setObject:[NSNumber numberWithInt:1] forKey:IDOrMac];
                index = 1;
            }
            uint8_t headBuf[4]={0xB0,len,statueID,index};
            headData=[[NSData alloc] initWithBytes:headBuf length:4];//释放对象
            [sendData appendData:headData];
//            NSData *productTypeUint8=[[NSData alloc] initWithBytes:&productType length:1];
//            [sendData appendData:productTypeUint8];

            [sendData appendData:data];
            [sendData appendData:macData];
            
        }
        
    }
    uint8_t check=[self checkData:sendData];
    NSData *checkData=[NSData dataWithBytes:&check length:1];
    [sendData appendData:checkData];

    return sendData;
}

-(NSData *)reMakeSendData:(NSData *)data To:(NSString *)IDOrMac Chracteristic:(NSString *)chracteristic Protocol:(NSString *)protocol IsNeedRespond:(BOOL)isNeedRespond MakeSureStatueID:(uint8_t)MakeSureStatueID MakeSureIndex:(uint8_t)MakeSureIndex isNotRespond:(BOOL)isNotRespond{
    NSMutableData *sendData=[[NSMutableData alloc] init];//释放对象，否则多次测量崩溃
    uint8_t index;
    //int indexProtocol=[prtocolArray indexOfObject:protocol];
    NSData *headData;
    
    if(isNotRespond)
    {
        //发送底层命令
        index=(MakeSureIndex+1)%256;
        int dataLen;
        if (data!=nil) {
            dataLen=[data length];
        }
        else
        {
            dataLen=0;
        }
        uint8_t headBuf[4]={0xB0,0x02+dataLen,MakeSureStatueID,index};
        headData=[[NSData alloc] initWithBytes:headBuf length:4];//释放对象
        [sendData appendData:headData];
        [sendData appendData:data];
        
    }
    else
    {
        //发送产品层命令
        uint8_t len=[data length]+2;
        index=[[sendIndexDic objectForKey:IDOrMac] intValue];
        if(index==0){
            [sendIndexDic setObject:[NSNumber numberWithInt:1] forKey:IDOrMac];
            index = 1;
        }
        uint8_t headBuf[4]={0xB0,len,MakeSureStatueID,index};
        headData=[[NSData alloc] initWithBytes:headBuf length:4];//释放对象
        [sendData appendData:headData];
        [sendData appendData:data];
    }
    
    uint8_t check=[self checkData:sendData];
    NSData *checkData=[NSData dataWithBytes:&check length:1];
    [sendData appendData:checkData];
    
    return sendData;
}


-(NSData *)transMACFromStrToHex:(NSString *)macString
{
    if (macString.length!=12) {
        return [NSData data];
    }
	//mac地址
	unsigned char bufG[6];
	NSRange fromto;
	fromto.location = 0;
	fromto.length = 2;
	for (int i=0;i<6; i++) {
		fromto.location = i*2;
		NSString *myString = [macString substringWithRange:fromto];
		bufG[i] = (unsigned char)strtol([myString UTF8String], 0, 16);
        
	}
	NSData *dataG = [[NSData alloc]initWithBytes:&bufG[0] length:6];
    
	return dataG;
}
-(void)sendData:(NSData *)data To:(NSString *)IDOrMac Protocol:(NSString *)protocol IsNeedRespond:(BOOL)isNeedRespond MakeSureStatueID:(uint8_t)makeSureStatueID MakeSureIndex:(uint8_t) makeSureIndex isNotRespond:(BOOL)isNotRespond//如果makeSureID为0则不是确认ID//makeSureStatureID是用来处理分包确认,一般情况上层确认使用0xA0
{
   
    if (IDOrMac!=nil) {
        int indexProtocol=[prtocolArray indexOfObject:protocol];
        NSData *sendData;
        if (indexProtocol==2) {
            if([eaCommunication selectDefaultSession:[IDOrMac intValue]]){
                [eaCommunication sendData:data];
            }
            else{
                return;
            }
        }
        else if ((indexProtocol>1&&indexProtocol<6) || indexProtocol==9 || indexProtocol==19 || indexProtocol==21)
        {
            uint8_t command;
            [data getBytes:&command length:1];
            if((indexProtocol == 3 || indexProtocol == 19 || indexProtocol == 21)  && command==0x31){
                [NSObject cancelPreviousPerformRequestsWithTarget:self];
            }
            //EA
            if([eaCommunication selectDefaultSession:[IDOrMac intValue]]){
                sendData=[self reMakeSendData:data To:IDOrMac Protocol:protocol IsNeedRespond:isNeedRespond MakeSureStatueID:makeSureStatueID MakeSureIndex:makeSureIndex isNotRespond:isNotRespond];
                [eaCommunication sendData:sendData];
            }
            else{
                return;
            }
        }
        else if(indexProtocol==0)
        {
            //wifi
            sendData=[self reMakeSendData:data To:IDOrMac Protocol:protocol IsNeedRespond:isNeedRespond MakeSureStatueID:makeSureStatueID MakeSureIndex:makeSureIndex isNotRespond:isNotRespond];
//            [wifiCommunication sendData:sendData MAC:IDOrMac];
        }
        else if (indexProtocol==1)
        {
            //KD-931
            if([eaCommunication selectDefaultSession:[IDOrMac intValue]]){
                [eaCommunication sendData:data];
            }
            else{
                return;
            }
        }
        else if(indexProtocol==6)
        {
            //EA认证命令
            if([eaCommunication selectDefaultSession:[IDOrMac intValue]]){
                sendData=[self reMakeSendData:data To:IDOrMac Protocol:protocol IsNeedRespond:isNeedRespond MakeSureStatueID:makeSureStatueID MakeSureIndex:makeSureIndex isNotRespond:isNotRespond];
                [eaCommunication sendData:sendData];
            }
            else{
                return;
            }
        }
        else if(indexProtocol==7)
        {
            //wifi认证命令
            sendData=[self reMakeSendData:data To:IDOrMac Protocol:protocol IsNeedRespond:isNeedRespond MakeSureStatueID:makeSureStatueID MakeSureIndex:makeSureIndex isNotRespond:isNotRespond];
//            [wifiCommunication sendData:sendData MAC:IDOrMac];
            
        }
        else if(indexProtocol==8)
        {
            //蓝牙设置wifi命令
            if([eaCommunication selectDefaultSession:[IDOrMac intValue]]){
                sendData=[self reMakeSendData:data To:IDOrMac Protocol:protocol IsNeedRespond:isNeedRespond MakeSureStatueID:makeSureStatueID MakeSureIndex:makeSureIndex isNotRespond:isNotRespond];
                [eaCommunication sendData:sendData];
            }
            else{
                return;
            }
        }
        else
        {
            //未知错误
            //蓝牙设置wifi命令
            if([eaCommunication selectDefaultSession:[IDOrMac intValue]]){
                sendData=[self reMakeSendData:data To:IDOrMac Protocol:protocol IsNeedRespond:isNeedRespond MakeSureStatueID:makeSureStatueID MakeSureIndex:makeSureIndex isNotRespond:isNotRespond];
                [eaCommunication sendData:sendData];
            }
            else{
                return;
            }
        }
        
        [lastSendData setData:data];
        
        //防止建立session失败
        NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithObjectsAndKeys:data,@"lastSendData",IDOrMac,@"to",protocol,@"protocol",[NSNumber numberWithBool:isNeedRespond],@"isNeedRespond",[NSNumber numberWithInt:makeSureStatueID],@"makeSureStatueID",[NSNumber numberWithInt:makeSureIndex],@"makeSureIndex",[NSNumber numberWithBool:isNotRespond],@"isNotRespond",nil];
        
        if (indexProtocol==0||indexProtocol>2){
            if (isNeedRespond) {
                [self performSelector:@selector(MakeSureMethod:) withObject:dic afterDelay:0.5];
            }
            
        }
        NSNumber *numTest=[sendIndexDic objectForKey:IDOrMac];
        NSMutableDictionary *totalSendDic = [NSMutableDictionary dictionaryWithDictionary:[sendDictionary objectForKey:IDOrMac]];
        if(totalSendDic==nil){
            NSDictionary *TempDic = [NSDictionary dictionaryWithObjectsAndKeys:dic,[NSString stringWithFormat:@"%@",numTest],nil];
            [sendDictionary setObject:TempDic forKey:IDOrMac];
        }
        else{
            [totalSendDic setObject:dic forKey:[NSString stringWithFormat:@"%@",numTest]];
            [sendDictionary setObject:totalSendDic forKey:IDOrMac];
        }
        
        [sendIndexDic setObject:[NSNumber numberWithInt:([numTest intValue]+2)%256] forKey:IDOrMac];
    }
    else{
        NSLog(@"IDOrMac == nil");
    }
}

-(void)sendData:(NSData *)data To:(NSString *)IDOrMac Chracteristic:(NSString *)chracteristic Protocol:(NSString *)protocol IsNeedRespond:(BOOL)isNeedRespond MakeSureStatueID:(uint8_t)makeSureStatueID MakeSureIndex:(uint8_t) makeSureIndex isNotRespond:(BOOL)isNotRespond{
    int indexProtocol=[prtocolArray indexOfObject:protocol];
    NSData *sendData;
    if(indexProtocol>=10 && IDOrMac.length)
    {
        chracteristic = @"0";
        if ([[BufDic allKeys] containsObject:IDOrMac] && makeSureStatueID/16!=0x0A) {
            [BufDic removeObjectForKey:IDOrMac];
        }
        //BTLE发送命令
        int dataLength = [data length];
        if(dataLength>=2 && makeSureStatueID==0){
            //总分包数
            int dataBag = (dataLength-1)%14?(dataLength-1)/14+1:(dataLength-1)/14;
            [totalDataBagDic setObject:[NSNumber numberWithInt:dataBag] forKey:IDOrMac];
            uint8_t productType = 0;
            [data getBytes:&productType range:NSMakeRange(0, 1)];
            for(int i=0; i<dataBag; i++){
                NSMutableData *tempData = [NSMutableData data];
                if(i==0 && dataBag>1){
                    //tempData = [data subdataWithRange:NSMakeRange(0,15)];
                    [tempData appendData:[data subdataWithRange:NSMakeRange(0,15)]];
                }
                else if(i<dataBag-1){
                    [tempData appendBytes:&productType length:1];
                    [tempData appendData:[data subdataWithRange:NSMakeRange(i*14+1,14)]];
                    //tempData = [data subdataWithRange:NSMakeRange(i*14+1,14)];
                }
                else{
                    [tempData appendBytes:&productType length:1];
                    [tempData appendData:[data subdataWithRange:NSMakeRange(i*14+1,dataLength-i*14-1)]];
                    //tempData = [data subdataWithRange:NSMakeRange(i*14+1,dataLength-i*14-1)];
                }
                uint8_t status = (dataBag-1)*16+dataBag-1-i;
                sendData=[self reMakeSendData:tempData To:IDOrMac Chracteristic:chracteristic Protocol:protocol IsNeedRespond:isNeedRespond MakeSureStatueID:status MakeSureIndex:makeSureIndex isNotRespond:isNotRespond];
                [btleController sendData:sendData to:IDOrMac characteristicUUID:chracteristic];
                
                //NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithObjectsAndKeys:data,@"lastSendData",sendData,@"singleData",IDOrMac,@"to",protocol,@"protocol",[sendIndexDic objectForKey:IDOrMac],@"sendIndex",chracteristic,@"chracteristic",@"0",@"reSenderTime",nil];
                //makeSureIndex
                NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithObjectsAndKeys:data,@"lastSendData",sendData,@"singleData",IDOrMac,@"to",protocol,@"protocol",[NSNumber numberWithBool:isNeedRespond],@"isNeedRespond",[NSNumber numberWithInt:makeSureStatueID],@"makeSureStatueID",[sendIndexDic objectForKey:IDOrMac],@"makeSureIndex",[sendIndexDic objectForKey:IDOrMac],@"sendIndex",[NSNumber numberWithBool:isNotRespond],@"isNotRespond",chracteristic,@"chracteristic",@"0",@"reSenderTime",nil];
                
                if (indexProtocol>9 && indexProtocol != 19 && indexProtocol != 21){
                    if(indexProtocol == 12 || indexProtocol == 10) {
                        [self performSelector:@selector(MakeSureMethod:) withObject:dic afterDelay:1];
                    }
                    else{
                        [self performSelector:@selector(MakeSureMethod:) withObject:dic afterDelay:0.5];
                    }
                    if (isNeedRespond) {
                        if(i == dataBag-1){
                            if(indexProtocol == 12 || indexProtocol == 10){
                                [self performSelector:@selector(totalCommandMakeSureMethod:) withObject:dic afterDelay:3.5];
                            }
                            else{
                                [self performSelector:@selector(totalCommandMakeSureMethod:) withObject:dic afterDelay:2];
                            }
                            //纪录上层发送的最后一条命令
                            [lastSendDic setObject:dic forKey:IDOrMac];
                        }
                    }
                }
                
                NSNumber *numTest=[sendIndexDic objectForKey:IDOrMac];
                //NSDictionary *TempDic = [NSDictionary dictionaryWithObjectsAndKeys:dic,[NSString stringWithFormat:@"%@",numTest],nil];
                NSMutableDictionary *totalSendDic = [NSMutableDictionary dictionaryWithDictionary:[sendDictionary objectForKey:IDOrMac]];
                if(totalSendDic==nil){
                    NSDictionary *TempDic = [NSDictionary dictionaryWithObjectsAndKeys:dic,[NSString stringWithFormat:@"%@",numTest],nil];
                    [sendDictionary setObject:TempDic forKey:IDOrMac];
                }
                else{
                    [totalSendDic setObject:dic forKey:[NSString stringWithFormat:@"%@",numTest]];
                    [sendDictionary setObject:totalSendDic forKey:IDOrMac];
                }

                
                [sendIndexDic setObject:[NSNumber numberWithInt:([numTest intValue]+2)%256] forKey:IDOrMac];
            }
        }
        else{
            sendData=[self reMakeSendData:data To:IDOrMac Chracteristic:chracteristic Protocol:protocol IsNeedRespond:isNeedRespond MakeSureStatueID:makeSureStatueID MakeSureIndex:makeSureIndex isNotRespond:isNotRespond];
            //BTLE发送命令
            [btleController sendData:sendData to:IDOrMac characteristicUUID:chracteristic];
            NSNumber *numTest=[sendIndexDic objectForKey:IDOrMac];
            [sendIndexDic setObject:[NSNumber numberWithInt:([numTest intValue]+2)%256] forKey:IDOrMac];
        }
    }
    else
    {
        NSLog(@"No indexProtocol");
    }
}


#pragma mark authentication
-(NSString *)dataFilePathNameLastR1To:(NSString *)to 
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@LastR1.plist",to]];
}
-(void)startAuthenticationTo:(NSString *)to IsNotEA:(BOOL)isNotEA ProductType:(uint8_t)productType
{
    Encode *encode=[[Encode alloc] init];//释放对象
    uint8_t *bufPointer;
    bufPointer=[encode generateRandomNub:16];
    uint8_t sendIndex;
    if ([[sendIndexDic allKeys] indexOfObject:to]==NSNotFound) {
        sendIndex=0x01;
        [sendIndexDic setObject:[NSNumber numberWithInt:sendIndex] forKey:to];

    }
    else
    {
        sendIndex=0x01;
        [sendIndexDic setObject:[NSNumber numberWithInt:sendIndex] forKey:to];
        //sendIndex=[[sendIndexDic objectForKey:to] intValue]%256;

    }

    uint8_t buf[18]={productType,0xFA,bufPointer[0],bufPointer[1],bufPointer[2],bufPointer[3],bufPointer[4],bufPointer[5],bufPointer[6],bufPointer[7],bufPointer[8],bufPointer[9],bufPointer[10],bufPointer[11],bufPointer[12],bufPointer[13],bufPointer[14],bufPointer[15]};
    
    FDFlag = TRUE;
    FBFlag = TRUE;
    if (buf)
    {
        if (isNotEA) {
            [self sendData:[NSData dataWithBytes:buf length:18] To:to Protocol:@"authenticaitonEA"IsNeedRespond:YES MakeSureStatueID:0x00 MakeSureIndex:0x00 isNotRespond:NO];

        }
        else
        {
            [self sendData:[NSData dataWithBytes:buf length:18] To:to Protocol:@"authenticaitonWifi" IsNeedRespond:YES MakeSureStatueID:0x00 MakeSureIndex:0x00 isNotRespond:NO];

        }
    } 
    
    NSData *dataPointer=[NSData dataWithBytes:bufPointer length:16];
    [dataPointer writeToFile:[self dataFilePathNameLastR1To:to] atomically:YES];
}
     
-(void)startBtleAuthenticationTo:(NSString *)to ProductType:(uint8_t)productType Protocol:(NSString *)protocol{
    Encode *encode=[[Encode alloc] init];//释放对象
    uint8_t *bufPointer;
    bufPointer=[encode generateRandomNub:16];
    uint8_t sendIndex;
    if ([[sendIndexDic allKeys] indexOfObject:to]==NSNotFound) {
        sendIndex=0x01;
        [sendIndexDic setObject:[NSNumber numberWithInt:sendIndex] forKey:to];
    }
    else
    {
        sendIndex=0x01;
        [sendIndexDic setObject:[NSNumber numberWithInt:sendIndex] forKey:to];
    }
    
    uint8_t buf[18]={productType,0xFA,bufPointer[0],bufPointer[1],bufPointer[2],bufPointer[3],bufPointer[4],bufPointer[5],bufPointer[6],bufPointer[7],bufPointer[8],bufPointer[9],bufPointer[10],bufPointer[11],bufPointer[12],bufPointer[13],bufPointer[14],bufPointer[15]};
    
    FDFlag = TRUE;
    FBFlag = TRUE;
    if (buf)
    {
        [self sendData:[NSData dataWithBytes:buf length:18] To:to Chracteristic:nil Protocol:protocol IsNeedRespond:YES MakeSureStatueID:0x00 MakeSureIndex:0x00 isNotRespond:NO];
    }
    
    NSData *dataPointer=[NSData dataWithBytes:bufPointer length:16];
    [dataPointer writeToFile:[self dataFilePathNameLastR1To:to] atomically:YES];
}
     
     
-(void)sendAuthenticationR2:(NSData *)R2 To:(NSString *)to Protocol:(NSString *)protocol ProductType:(uint8_t)productType makeSureIndex:(uint8_t)makeSureIndex
{

    uint8_t bufPointer[16];
    [R2 getBytes:bufPointer range:NSMakeRange(0, 16)];
    
    uint8_t buf[18]={productType,0xFC,bufPointer[0],bufPointer[1],bufPointer[2],bufPointer[3],bufPointer[4],bufPointer[5],bufPointer[6],bufPointer[7],bufPointer[8],bufPointer[9],bufPointer[10],bufPointer[11],bufPointer[12],bufPointer[13],bufPointer[14],bufPointer[15]};
//发送R2就停止R1三次重发
	if (buf)
    {
        [self sendData:[NSData dataWithBytes:buf length:18] To:to Protocol:protocol IsNeedRespond:YES MakeSureStatueID:0x00 MakeSureIndex:makeSureIndex isNotRespond:YES];
    } 
        
}
     
-(void)sendBtleAuthenticationR2:(NSData *)R2 To:(NSString *)to Protocol:(NSString *)protocol ProductType:(uint8_t)productType makeSureIndex:(uint8_t)makeSureIndex
{
        
        uint8_t bufPointer[16];
        [R2 getBytes:bufPointer range:NSMakeRange(0, 16)];
        
        uint8_t buf[18]={productType,0xFC,bufPointer[0],bufPointer[1],bufPointer[2],bufPointer[3],bufPointer[4],bufPointer[5],bufPointer[6],bufPointer[7],bufPointer[8],bufPointer[9],bufPointer[10],bufPointer[11],bufPointer[12],bufPointer[13],bufPointer[14],bufPointer[15]};
        if (buf)
        {
            [self sendData:[NSData dataWithBytes:buf length:18] To:to Chracteristic:nil Protocol:protocol IsNeedRespond:YES MakeSureStatueID:0x00 MakeSureIndex:makeSureIndex isNotRespond:NO];
        } 
        
}
     
-(void)failedToAuthenticationTo:(NSString *)to Protocol:(NSString *)protocol ProductType:(uint8_t)productType makeSureIndex:(uint8_t)makeSureIndex
{
    uint8_t buf[2]={productType,0xFE};
    if (buf)
    {
        [self sendData:[NSData dataWithBytes:buf length:2] To:to Protocol:protocol IsNeedRespond:NO MakeSureStatueID:0xA0 MakeSureIndex:makeSureIndex isNotRespond:YES];
    }
}

-(void)failedToBtleAuthenticationTo:(NSString *)to Protocol:(NSString *)protocol ProductType:(uint8_t)productType makeSureIndex:(uint8_t)makeSureIndex{
    uint8_t buf[2]={productType,0xFE};
    if (buf)
    {
        [self sendData:[NSData dataWithBytes:buf length:2] To:to Chracteristic:nil Protocol:protocol IsNeedRespond:YES MakeSureStatueID:0x00 MakeSureIndex:makeSureIndex isNotRespond:NO];
    }
}

#pragma mark resend
-(void)MakeSureMethod:(NSMutableDictionary *)dic
{
    if([[dic objectForKey:@"chracteristic"] length]){
        int btleReSendTime = [[dic objectForKey:@"reSenderTime"]intValue];
        switch (btleReSendTime) {
            case 0:
            {
                [btleController sendData:[dic objectForKey:@"singleData"] to:[dic objectForKey:@"to"] characteristicUUID:[dic objectForKey:@"chracteristic"]];
                [dic setValue:[NSNumber numberWithInt:(btleReSendTime+1)] forKey:@"reSenderTime"];
                
                //NSDictionary *TempDic = [NSDictionary dictionaryWithObjectsAndKeys:dic,[dic objectForKey:@"sendIndex"],nil];
                NSMutableDictionary *totalSendDic = [NSMutableDictionary dictionaryWithDictionary:[sendDictionary objectForKey:[dic objectForKey:@"to"]]];
                [totalSendDic setObject:dic forKey:[dic objectForKey:@"sendIndex"]];
                [sendDictionary setObject:totalSendDic forKey:[dic objectForKey:@"to"]];
                
                [self performSelector:@selector(MakeSureMethod:) withObject:dic afterDelay:0.5];
                
            }
                break;
            case 1:
            {
                [btleController sendData:[dic objectForKey:@"singleData"] to:[dic objectForKey:@"to"] characteristicUUID:[dic objectForKey:@"chracteristic"]];
                [dic setValue:[NSNumber numberWithInt:(btleReSendTime+1)] forKey:@"reSenderTime"];
                
                NSMutableDictionary *totalSendDic = [NSMutableDictionary dictionaryWithDictionary:[sendDictionary objectForKey:[dic objectForKey:@"to"]]];
                [totalSendDic setObject:dic forKey:[dic objectForKey:@"sendIndex"]];
                [sendDictionary setObject:totalSendDic forKey:[dic objectForKey:@"to"]];
                
                [self performSelector:@selector(MakeSureMethod:) withObject:dic afterDelay:0.5];
            }
                break;
            case 2:
            {
                uint8_t indexCommand = 0;
                uint8_t status = 0;
                NSRange range = {1,1};
                if([[dic objectForKey:@"lastSendData"]length]>=2){
                    [[dic objectForKey:@"lastSendData"] getBytes:&indexCommand range:range];
                }
                if([[dic objectForKey:@"singleData"]length]>=7){
                    [[dic objectForKey:@"singleData"] getBytes:&status range:NSMakeRange(2, 1)];
                }
#ifdef DLog
                NSLog(@"single-indexCommand:%x lastSendData:%@",indexCommand,[dic objectForKey:@"lastSendData"]);
#endif
            }
                break;
            default:
                break;
        }
    }
    else{
        int btleReSendTime = [[reSendTimeOfDevice objectForKey:[dic objectForKey:@"to"]]intValue];
        switch (btleReSendTime) {
            case 0:
            {
                NSNumber *num=[sendIndexDic objectForKey:[dic objectForKey:@"to"]];
                int numInt=[num intValue];
                numInt-=2;
                [sendIndexDic setObject:[NSNumber numberWithInt:numInt] forKey:[dic objectForKey:@"to"]];
                
                [self sendData:[dic objectForKey:@"lastSendData"] To:[dic objectForKey:@"to"] Protocol:[dic objectForKey:@"protocol"] IsNeedRespond:[[dic objectForKey:@"isNeedRespond"] boolValue] MakeSureStatueID:(uint8_t)[[dic objectForKey:@"makeSureStatueID"] intValue] MakeSureIndex:(uint8_t)[[dic objectForKey:@"makeSureIndex"] intValue] isNotRespond:[[dic objectForKey:@"isNotRespond"] boolValue]];
                [reSendTimeOfDevice setValue:[NSNumber numberWithInt:(btleReSendTime+1)] forKey:[dic objectForKey:@"to"]];
		}
                break;
            case 1:
            {
                
                NSNumber *num=[sendIndexDic objectForKey:[dic objectForKey:@"to"]];
                int numInt=[num intValue];
                numInt-=2;
                [sendIndexDic setObject:[NSNumber numberWithInt:numInt] forKey:[dic objectForKey:@"to"]];
                
                [self sendData:[dic objectForKey:@"lastSendData"] To:[dic objectForKey:@"to"] Protocol:[dic objectForKey:@"protocol"] IsNeedRespond:[[dic objectForKey:@"isNeedRespond"] boolValue] MakeSureStatueID:(uint8_t)[[dic objectForKey:@"makeSureStatueID"] intValue] MakeSureIndex:(uint8_t)[[dic objectForKey:@"makeSureIndex"] intValue] isNotRespond:[[dic objectForKey:@"isNotRespond"] boolValue]];
                 [reSendTimeOfDevice setValue:[NSNumber numberWithInt:(btleReSendTime+1)] forKey:[dic objectForKey:@"to"]];
            }
                break;
            case 2:
            {
                [reSendTimeOfDevice setValue:[NSNumber numberWithInt:0] forKey:[dic objectForKey:@"to"]];
                uint8_t indexCommand = 0;
                NSRange range = {1,1};
                if([[dic objectForKey:@"lastSendData"]length]>=2){
                    [[dic objectForKey:@"lastSendData"] getBytes:&indexCommand range:range];
                }
                if(indexCommand == 0xFA){
                    FBFlag = FALSE;
                    InvalidateAuthenTimer(nil);
//                    NSLog(@"anthen 0xFA time out");
                }
                if(indexCommand == 0xFC){
                    FDFlag = FALSE;
                    InvalidateAuthenTimer(nil);
//                    NSLog(@"anthen 0xFC time out");
                }
                
                NSDictionary *dicTimeOut=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:indexCommand],DeviceTimeOutCommand,[dic objectForKey:@"to"],IDPS_ID,nil];
                
//                NSLog(@"lastSendData:%@",lastSendData);
                [[NSNotificationCenter defaultCenter] postNotificationName:DeviceTimeOut object:self userInfo:dicTimeOut];
            }
                break;
                
            default:
                
                break;
        }
    }

}

//整条命令重发
-(void)totalCommandMakeSureMethod:(NSMutableDictionary *)dic{
    if([[dic objectForKey:@"chracteristic"] length]){
        int btleReSendTime = [[reSendTimeOfDevice objectForKey:[dic objectForKey:@"to"]]intValue];
        switch (btleReSendTime) {
            case 0:
            {
                [self sendData:[dic objectForKey:@"lastSendData"] To:[dic objectForKey:@"to"] Chracteristic:[dic objectForKey:@"chracteristic"] Protocol:[dic objectForKey:@"protocol"] IsNeedRespond:[[dic objectForKey:@"isNeedRespond"] boolValue]  MakeSureStatueID:(uint8_t)[[dic objectForKey:@"makeSureStatueID"] intValue] MakeSureIndex:(uint8_t)[[dic objectForKey:@"makeSureIndex"] intValue]  isNotRespond:[[dic objectForKey:@"isNotRespond"] boolValue]];
                [reSendTimeOfDevice setValue:[NSNumber numberWithInt:(btleReSendTime+2)] forKey:[dic objectForKey:@"to"]];
            }
                break;
            case 1:
            {
                [self sendData:[dic objectForKey:@"lastSendData"] To:[dic objectForKey:@"to"] Chracteristic:[dic objectForKey:@"chracteristic"] Protocol:[dic objectForKey:@"protocol"] IsNeedRespond:[[dic objectForKey:@"isNeedRespond"] boolValue]  MakeSureStatueID:(uint8_t)[[dic objectForKey:@"makeSureStatueID"] intValue] MakeSureIndex:(uint8_t)[[dic objectForKey:@"makeSureIndex"] intValue]  isNotRespond:[[dic objectForKey:@"isNotRespond"] boolValue]];
                [reSendTimeOfDevice setValue:[NSNumber numberWithInt:(btleReSendTime+1)] forKey:[dic objectForKey:@"to"]];
            }
                break;
            case 2:
            {
                [reSendTimeOfDevice setValue:[NSNumber numberWithInt:0] forKey:[dic objectForKey:@"to"]];
                
                uint8_t indexCommand = 0;
                NSRange range = {1,1};
                if([[dic objectForKey:@"lastSendData"]length]>=2){
                    [[dic objectForKey:@"lastSendData"] getBytes:&indexCommand range:range];
                }
                if(indexCommand == 0xFA){
                    FBFlag = FALSE;
                    InvalidateAuthenTimer([dic objectForKey:@"to"]);
                    NSLog(@"total anthen 0xFA time out");
                }
                else if(indexCommand == 0xFC){
                    FDFlag = FALSE;
                    InvalidateAuthenTimer([dic objectForKey:@"to"]);
                    NSLog(@"total anthen 0xFC time out");
                }
                else if(indexCommand == 0xD0){
                    NSDictionary *tempDic = [NSDictionary dictionaryWithObjectsAndKeys:@"201",@"downloadResult",nil];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"DownloadNewBinResult" object:self userInfo:tempDic];
                    NSLog(@"0xD0 time out");
                }
                else if(indexCommand == 0xD1 || indexCommand == 0xD6){
                    NSDictionary *tempDic = [NSDictionary dictionaryWithObjectsAndKeys:@"300",@"downloadResult",nil];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"DownloadNewBinResult" object:self userInfo:tempDic];
                    NSLog(@"0xD1 or 0xD2 time out");
                }
                else{
                    NSDictionary *dicTimeOut=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:indexCommand],DeviceTimeOutCommand,[dic objectForKey:@"to"],IDPS_ID,nil];
#ifdef DLog
                    NSLog(@"total-lastSendData:%@",[dic objectForKey:@"lastSendData"]);
#endif
                    [[NSNotificationCenter defaultCenter] postNotificationName:DeviceTimeOut object:self userInfo:dicTimeOut];
                }
                
            }
                break;
            default:{
                NSLog(@"default-lastSendData:%@",[dic objectForKey:@"lastSendData"]);

            }
                break;
        }
    }

}

//取消指定设备底重发
-(void)cancel:(uint8_t)index from:(NSString *)from
{
    NSDictionary *dic=[[NSDictionary alloc] init];//释放对象
    NSMutableDictionary *deviceSendDic = [NSMutableDictionary dictionaryWithDictionary:[sendDictionary objectForKey:from]];
    //NSLog(@"sendDictionary:%@",sendDictionary);
    if(deviceSendDic!=nil){
        if([[deviceSendDic allKeys]containsObject:[NSString stringWithFormat:@"%d",index]]){
            dic = [deviceSendDic objectForKey:[NSString stringWithFormat:@"%d",index]];
            if (dic!=nil) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(MakeSureMethod:) object:dic];
                //NSLog(@"index:%d dic:%@",index,dic);
                if([[dic objectForKey:@"chracteristic"]length]==0){
                    [reSendTimeOfDevice setValue:[NSNumber numberWithInt:0] forKey:from];
                }
                [deviceSendDic removeObjectForKey:[NSString stringWithFormat:@"%d",index]];
                [sendDictionary setObject:deviceSendDic forKey:from];
            }
        }
    }
}

//取消整条命令的重发
-(void)cancelTotalCommand:(NSString *)from{
    if(from!=nil){
        NSDictionary *dic=[[NSDictionary alloc] init];//释放对象
        dic=[lastSendDic objectForKey:from];
        if (dic!=nil) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(totalCommandMakeSureMethod:) object:dic];
            [reSendTimeOfDevice setObject:[NSNumber numberWithInt:0] forKey:from];
        }
        else{
            //NSLog(@"cancel -- dic==nil");
        }
    }
}


#pragma mark received
-(void)receivedData:(NSData *)data From:(NSString *)from Protocol:(NSString *)protocol;
{
    //接受数据函数
    #ifdef DLog
    NSLog(@"Received:%@ from:%@",data,from);
    #endif
    [receivedDataObject addBufData:data From:from];
    [receivedDataObject findRightCommandFrom:from Protocol:protocol];
}

-(void)receivedData:(NSData *)data From:(NSString *)from Chracteristic:(NSString *)chracteristic Protocol:(NSString *)protocol{
    #ifdef DLog
    NSLog(@"Btle Received:%@ from:%@",data,from);
    #endif
    [receivedDataObject addBufData:data From:from];
    [receivedDataObject findRightCommandFrom:from Chracteristic:chracteristic Protocol:protocol];
}

-(NSData *)handleCommand:(NSData *)command From:(NSString *)from Protocol:(NSString *)protocol
{
    //处理命令函数
    
    NSData *returnData=[NSMutableData data];
    uint8_t buf[512];
    [command getBytes:buf length:[command length]];
    if ([[[sendDictionary objectForKey:from]allKeys] indexOfObject:[NSString stringWithFormat:@"%d",(buf[3]-1)]]!=NSNotFound) {
        [self cancel:buf[3]-1 from:from];
    }
    int indexProtocol=[prtocolArray indexOfObject:protocol];
    int staute;
    staute=buf[2];
    if (staute>0xA0&&staute<0xA9) 
    {
        //分包各包确认

        
        return nil;//暂时
        
    }
    else if(staute==0x00)
    {
        //只有一包的命令
        if (indexProtocol==0) {
//            returnData=[command subdataWithRange:NSMakeRange(4, ([command length]-11))];
            //由于不能彻底完美剥离只能都传给上层
            returnData=command;
        }
        else
        {
//            returnData=[command subdataWithRange:NSMakeRange(4, 5)];
            //由于不能彻底完美剥离只能都传给上层

            returnData=command;

        }
        return returnData;
    }
    else if(staute%16==0&&0x00<staute&&staute<0xA0)
    {
        //不分包的命令和最后一包的命令
        if (indexProtocol==0) {
//            returnData=[command subdataWithRange:NSMakeRange(4, ([command length]-11))];
            //由于不能彻底完美剥离只能都传给上层
            returnData=command;

        }
        else
        {
//            returnData=[command subdataWithRange:NSMakeRange(4, 5)];
            //由于不能彻底完美剥离只能都传给上层
            returnData=command;

        }
        if ([[BufDic allKeys] indexOfObject:from]!=NSNotFound) {
            //错误数据
            return nil;
        }
        else
        {
            //有问题
            //多包情况
            NSMutableArray *commandArray;//分包命令和
            commandArray=[BufDic objectForKey:from];
            int lastIndex=[[[commandArray lastObject] objectForKey:@"dataIndex"] intValue];
            if (lastIndex+2==buf[3]) {
                if (staute/16==[commandArray count]+1) {
                    NSMutableData *returnBufData=[[NSMutableData alloc] init];
                    [returnBufData appendData:[command subdataWithRange:NSMakeRange(0, 4)]];
                    for (NSDictionary *forDic in commandArray) {
                        
                        [returnBufData appendData:[forDic objectForKey:@"saveData"]];
                    }
                    if (indexProtocol==0) {
                        [returnBufData appendData:[command subdataWithRange:NSMakeRange(10-7, 6)]];
                    }
                    return returnBufData;
                }
                else
                {
                    //少包
                    [BufDic removeObjectForKey:from];

                }
            }
            else
            {
                //顺序ID错误
                [BufDic removeObjectForKey:from];
            }
        }
        return nil;
    }
    else if(staute==0xA0)
    {
        //最后一包，一包的确认
        if (indexProtocol==0) {
//            returnData=[command subdataWithRange:NSMakeRange(4, ([command length]-11))];
            //分包情况扔存在问题
            //由于不能彻底完美剥离只能都传给上层
            returnData=command;
        }
        else
        {
//            returnData=[command subdataWithRange:NSMakeRange(4, 5)];
            //分包情况扔存在问题
            //由于不能彻底完美剥离只能都传给上层
            returnData=command;

        }
 
        return returnData;//暂时
        
        
    }
    else if(0x00<staute&&staute<0xA0)
    {
        //分包存在问题
        //分包命令
        int left=staute%16;//剩下的包数
        left+=16;//返回的状态ID
            
        [self sendData:nil To:from Protocol:protocol IsNeedRespond:NO MakeSureStatueID:(uint8_t)left MakeSureIndex:buf[3] isNotRespond:YES]; 
            
        //makeSure
        
        NSMutableArray *commandArray;//分包命令和
        if ([[BufDic allKeys] containsObject:from]) {
            commandArray=[[NSMutableArray alloc] init];
        }
        else
        {
            commandArray=[BufDic objectForKey:from];

        }
        NSData *middleData=[NSMutableData data];
        if (indexProtocol==0)            //是否为wifi
        {
            middleData=[command subdataWithRange:NSMakeRange(4, ([command length]-11))];
        }
        else
        {
            middleData=[command subdataWithRange:NSMakeRange(4, 5)];
        }
        
        if (buf[2]/16==buf[2]%16)//是否第一包
        {
            
            NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:middleData,@"saveData",[NSNumber numberWithInt:buf[3]],@"dataIndex", [NSNumber numberWithInt:buf[2]],@"dataStatus",nil];
            [commandArray addObject:dic];
            [BufDic setObject:commandArray forKey:from];
        }
        else
        {
            if ([[[commandArray lastObject] objectForKey:@"dataIndex"] intValue]==buf[3]-2) {
                if ([[[commandArray lastObject] objectForKey:@"dataStatus"] intValue]==buf[2]%16+1)
                {
                    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:middleData,@"saveData",[NSNumber numberWithInt:buf[3]],@"dataIndex", [NSNumber numberWithInt:buf[2]],@"dataStatus",nil];
                    [commandArray addObject:dic];
                    [BufDic setObject:commandArray forKey:from];
                }
                else
                {
                    [BufDic removeObjectForKey:from];

                    //状态ID错误
                }
            }
            else
            {
                [BufDic removeObjectForKey:from];
                //顺序ID错误
            }
        }
        
        
        
        return nil;
    
    }
    else if(buf[2]==0xF0)
    {
        //不需要回复确认
        returnData=command;
        return returnData;
    }
    
    return nil;
}

-(NSData *)handleCommand:(NSData *)command From:(NSString *)from Chracteristic:(NSString *)chracteristic Protocol:(NSString *)protocol
{
    //处理命令函数
    NSData *returnData=[NSMutableData data];
    uint8_t buf[512] = {0};
    [command getBytes:buf length:[command length]];
    
    int staute;
    staute=buf[2];
    if (staute>=0xA0&&staute<=0xA9)
    {
        if (![[BufDic allKeys] containsObject:from]){
            [self cancel:buf[3]-1 from:from];
            //分包各包确认
        }
        else{
            NSLog(@"recving command but rec A0-A9");
        }
        return nil;
    }
    else if(0x00<=staute&&staute<0xA0&&(staute%16<=staute/16))
    {
        uint8_t sendIndex = [[sendIndexDic objectForKey:from]intValue];
        int totalBag = staute/16+1;//总包数
        int left=staute%16;//剩下的包数
        if([[totalDataBagDic allKeys]containsObject:from] && sendIndex==(uint8_t)(buf[3]+left*2-totalBag*2+1)){
            [totalDataBagDic removeObjectForKey:from];
            for(int i=0;i<10;i++){
                [self cancel:sendIndex-i*2 from:from];
            }
        }
        if(![[totalDataBagDic allKeys]containsObject:from]){
            [self cancelTotalCommand:from];
            [sendIndexDic setObject:[NSNumber numberWithInt:(buf[3]+(buf[2]&0x0F)*2)+1] forKey:from];
            //分包命令
            
            left+=160;//返回的状态ID
            [self sendData:[NSData dataWithBytes:&buf[4] length:1] To:from Chracteristic:chracteristic Protocol:protocol IsNeedRespond:NO MakeSureStatueID:(uint8_t)left MakeSureIndex:buf[3] isNotRespond:YES];
            
            
            NSMutableArray *commandArray;//分包命令和
            if ([[BufDic allKeys] containsObject:from]) {
                commandArray=[BufDic objectForKey:from];
            }
            else{
                commandArray=[[NSMutableArray alloc] init];
            }
            
            NSData *middleData=[NSMutableData data];
            if (buf[2]/16==buf[2]%16)//是否第一包
            {
                middleData=[command subdataWithRange:NSMakeRange(0, buf[1]+2)];
            }
            else if(buf[2]%16==0){//是否最后一包
                middleData=[command subdataWithRange:NSMakeRange(5, buf[1]-3)];
            }
            else
            {
                middleData=[command subdataWithRange:NSMakeRange(5, buf[1]-3)];
            }
            NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:middleData,@"saveData",[NSNumber numberWithInt:buf[3]],@"dataIndex", [NSNumber numberWithInt:buf[2]],@"dataStatus",nil];
            if(![commandArray containsObject:dic]){
                [commandArray addObject:dic];
            }
            else{
                NSLog(@"commandArray containsObject - dic ");
            }
            
            [BufDic setObject:commandArray forKey:from];
            
            int recDataBag = [self detectDataBag:from];

            if(totalBag == recDataBag)
            {
                
                NSData *detectData = [self detectDataBagRec:from];
                if(detectData!=nil){
                    if ([[BufDic allKeys] containsObject:from]) {
                        [BufDic removeObjectForKey:from];
                    }
                }
                return detectData;
            }
        }
        else{
#ifdef DLog
            NSLog(@"in sending but rec wrong command");
#endif
            return nil;
        }
    }
    else if(buf[2]==0xF0)
    {
        //不需要回复确认
        returnData=command;
        [sendIndexDic setObject:[NSNumber numberWithInt:(buf[3]+1)] forKey:from];
        return returnData;
    }
    
    return nil;
}

//查询设备总接收包数,判断是否接收完毕
-(int)detectDataBag:(NSString *)deviceID{
    if ([[BufDic allKeys] containsObject:deviceID]) {
        NSMutableArray *commandArray=[BufDic objectForKey:deviceID];
        if([commandArray count]){
            int dataBagNub = [[[commandArray lastObject]objectForKey:@"dataStatus"]intValue]/16;
            int recDataBag = 0;
            for(int i=dataBagNub; i>=0; i--){
                for(NSDictionary *tempDic in commandArray){
                    if([[tempDic objectForKey:@"dataStatus"]intValue]%16 == i){
                        recDataBag++;
                        break;
                    }
                }
            }
            return recDataBag;
        }
        else{
            return 0;
        }
    }
    return 0;
}

//拼接小包数据为整包
-(NSData *)detectDataBagRec:(NSString *)deviceID{
    if ([[BufDic allKeys] containsObject:deviceID]) {
        NSMutableArray *commandArray=[BufDic objectForKey:deviceID];
        if([commandArray count]){
            uint8_t totalLength = 0;
            NSMutableData *combineData = [[NSMutableData alloc]init];
            int dataBagNub = [[[commandArray lastObject]objectForKey:@"dataStatus"]intValue]/16;
            for(int i=dataBagNub; i>=0; i--){
                Boolean dataStatusFlag = false;
                for(NSDictionary *tempDic in commandArray){
                    if([[tempDic objectForKey:@"dataStatus"]intValue]%16 == i){
                        NSData *tempData = [tempDic objectForKey:@"saveData"];
                        if(i==dataBagNub){
                            uint8_t subDataLength = 0;
                            [tempData getBytes:&subDataLength range:NSMakeRange(1, 1)];
                            totalLength += subDataLength;
                        }
                        else{
                            totalLength += tempData.length;
                        }
                        [combineData appendData:tempData];
                        //NSLog(@"tempData:%@",tempData);
                        dataStatusFlag = true;
                        break;
                    }
                }
                if(dataStatusFlag == false){
                    break;
                }
                else if(dataStatusFlag == true && i==0){
                    [combineData replaceBytesInRange:NSMakeRange(1, 1) withBytes:&totalLength];
                    return combineData;
                }
                else if(dataStatusFlag == true){
                    //NSLog(@"i=====%d",i);
                }
            }
        }
        else{
            return nil;
        }
    }
    return nil;
}

-(void)runCommand:(NSData *)command From:(NSString *)from Protocol:(NSString *)protocol
{
        //NSLog(@"Receivedjiaoyanhou:%@",command);
        int indexProtocol=[prtocolArray indexOfObject:protocol];
        if (indexProtocol==1 || indexProtocol==2) {
            [[NSNotificationCenter defaultCenter] postNotificationName:protocol object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:command,IDPS_Data,from,IDPS_ID, nil]];
            
        }
        else
        {
            uint8_t buf[512];
            [command getBytes:buf length:[command length]];
            if ([authenticationDeviceList indexOfObject:from]!=NSNotFound) 
            {
                [self cancel:buf[3]-1 from:from];
                //authenticated
                [[NSNotificationCenter defaultCenter] postNotificationName:protocol object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:command,IDPS_Data,from,IDPS_ID, nil]];
                
            }
            else
            {
                //由于需要兼容蓝牙设置wifi协议，在未加密认证的时候也需要接受相应的命令
                if (indexProtocol==8) {
                    
                    [self cancel:buf[3]-1 from:from];
                    [[NSNotificationCenter defaultCenter] postNotificationName:protocol object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:command,IDPS_Data,from,IDPS_ID,protocol,IDPS_ProtocolString, nil]];
                    
                }
                //no authentication
                switch (buf[5]) {
                    case 0xFB:
                    {
                        if(FBFlag){
                            [self cancel:buf[3]-1 from:from];
                            switch (buf[2]) {
                                case 0x11:
                                {
                                    for (int i=0; i<16; i++) //取出ID
                                    {
                                        m_ID[i]=buf[6+i];
                                    }
                                    for (int i=0; i<16; i++) //取出R11
                                    {
                                        R11[i]=buf[22+i];
                                    }
                                    NSMutableData *data1=[[NSMutableData alloc]init];
                                    [data1 appendBytes:&R11[0] length:16];
                                    [[NSNotificationCenter defaultCenter]postNotificationName:@"f1" object:nil userInfo:[[NSDictionary alloc]initWithObjectsAndKeys:data1,@"data", nil]];
                                    
                                    uint8_t sendCommand[2];
                                    sendCommand[0]=0xA2;//产品类型
                                    sendCommand[1]=0xFA;
                                    NSMutableData *data = [NSMutableData data];
                                    [data appendBytes:(void *)(&sendCommand[0]) length:sizeof(sendCommand)];
                                    
                                    [self sendData:data To:from Protocol:protocol IsNeedRespond:YES MakeSureStatueID:0XA1 MakeSureIndex:buf[3] isNotRespond:YES];
                                    
                                }
                                    break;
                                case 0x10:
                                {
                                    for (int i=0; i<16; i++) //取出R22
                                    {
                                        R22[i]=buf[6+i];
                                    }
                                    NSMutableData *data1=[[NSMutableData alloc]init];
                                    [data1 appendBytes:&R22[0] length:16];
                                    [[NSNotificationCenter defaultCenter]postNotificationName:@"f2" object:nil userInfo:[[NSDictionary alloc]initWithObjectsAndKeys:data1,@"data", nil]];
                                    
                                    uint8_t sendCommand[2];
                                    sendCommand[0]=0xA2;//产品类型
                                    sendCommand[1]=0xFA;
                                    NSMutableData *data = [NSMutableData data];
                                    [data appendBytes:(void *)(&sendCommand[0]) length:sizeof(sendCommand)];
                                    
                                    
                                    
                                    Encode *encode=[[Encode alloc] init];
                                    uint32_t keyA[4]={ 0x316814F5, 0xCCF19FA3, 0x308CA513, 0x71386B19};
                                    
                                    uint8_t *middleKey=[encode encode:m_ID withLength:16 andKey:keyA];
                                    uint32_t *key=[encode uint8ConvertToUint32:middleKey];
                                    //uint32_t key[4] = {0xf307ede4,0x4d2be795,0x0c77bd7c,0x82967be9};
                                    //需重新处理KEY值
                                    uint8_t *bufR1;
                                    uint8_t *bufR2;
                                    bufR1=[encode encode:R11 withLength:16 andKey:key];
                                    bufR2=[encode encode:R22 withLength:16 andKey:key];
                                    NSData *databufR1=[NSData dataWithBytes:bufR1 length:16];
                                    NSData *databufR2=[NSData dataWithBytes:bufR2 length:16];
                                    
                                    NSData *lastR1=[NSData dataWithContentsOfFile:[self dataFilePathNameLastR1To:from]];
                                    
                                    if ([lastR1 isEqualToData:databufR1]) {
                                        
                                        [authenticationDownDeviceList addObject:from];
                                        
                                        [self sendAuthenticationR2:databufR2 To:from Protocol:protocol ProductType:buf[4] makeSureIndex:buf[3]];
                                        //下位机认证成功加入下位机成功认证列表
                                        //发送下一步认证过程
                                    }
                                    
                                }
                                    break;
                                default:
                                {
                                    uint8_t bufIDDecodePointer[16];
                                    uint8_t bufR1DecodePointer[16];
                                    uint8_t bufR2DecodePointer[16];
                                    
                                    for (int i=0; i<16; i++) {
                                        bufIDDecodePointer[i]=buf[6+i];
                                        bufR1DecodePointer[i]=buf[22+i];
                                        bufR2DecodePointer[i]=buf[38+i];
                                    }
                                    
                                    
                                    Encode *encode=[[Encode alloc] init];
                                    uint32_t keyA[4]={ 0xB2DB8A30, 0x1E33E6BA, 0xC30D42D9, 0x4B26E853};
                                    if(indexProtocol == 3){
                                        keyA[0]=0x7EAE8738;
                                        keyA[1]=0x82622823;
                                        keyA[2]=0x0CD4BAE0;
                                        keyA[3]=0x97B6C503;
                                    }
                                    else if(indexProtocol == 9){
                                        keyA[0]=0xFFD57A65;
                                        keyA[1]=0x75487E71;
                                        keyA[2]=0x63CDED4B;
                                        keyA[3]=0x5D93119C;
                                    }
                                    //ABI
                                    else if(indexProtocol == 19){
                                        keyA[0]=0x2A64BA19;
                                        keyA[1]=0x4F51505B;
                                        keyA[2]=0x26B7E305;
                                        keyA[3]=0xFEA5917F;
                                        
                                    }else if(indexProtocol == 20){
                                        //bp3L
                                        keyA[0]=0xFF2C525A;
                                        keyA[1]=0x5A3CD3E8;
                                        keyA[2]=0xC7D9B591;
                                        keyA[3]=0xA6ADCB34;
                                        
                                    }
                                    else if(indexProtocol == 21){
                                        //bp5 Wechat
                                        keyA[0]=0x92E0835B;
                                        keyA[1]=0xF97FC9A3;
                                        keyA[2]=0xAABD466A;
                                        keyA[3]=0x1898E983;
                                    }
                                    
                                    
                                    
                                    uint8_t *middleKey=[encode encode:bufIDDecodePointer withLength:16 andKey:keyA];
                                    uint32_t *key=[encode uint8ConvertToUint32:middleKey];
                                    
                                    //需重新处理KEY值
                                    uint8_t *bufR1;
                                    uint8_t *bufR2;
                                    bufR1=[encode encode:bufR1DecodePointer withLength:16 andKey:key];
                                    bufR2=[encode encode:bufR2DecodePointer withLength:16 andKey:key];
                                    NSData *databufR1=[NSData dataWithBytes:bufR1 length:16];
                                    NSData *databufR2=[NSData dataWithBytes:bufR2 length:16];
                                    
                                    NSData *lastR1=[NSData dataWithContentsOfFile:[self dataFilePathNameLastR1To:from]];
                                    
                                    if ([lastR1 isEqualToData:databufR1]) {
                                        [authenticationDownDeviceList addObject:from];
                                        [self sendAuthenticationR2:databufR2 To:from Protocol:protocol ProductType:buf[4] makeSureIndex:buf[3]];
                                        //下位机认证成功加入下位机成功认证列表
                                        //发送下一步认证过程
                                    }
                                    else
                                    {
                                        //authentication failed
                                        NSLog(@"send R1:%@",[lastR1 description]);
                                        NSRange rage = {22,16};
                                        NSLog(@"R1-R1'-recv:%@",[[command subdataWithRange:rage ] description]);
                                        uint8_t lastR1Buf[16];
                                        [lastR1 getBytes:lastR1Buf length:16];
                                        uint8_t *decodeBuf;
                                        Encode *encode=[[Encode alloc] init];
                                        decodeBuf = [encode decode:lastR1Buf withLength:16 andKey:key];
                                        NSData *decodeData = [[NSData alloc]initWithBytes:decodeBuf length:16];
                                        NSLog(@"R1-R1'-Self:%@",[decodeData description]);
                                        uint8_t decodeBufSelf[16];
                                        [decodeData getBytes:decodeBufSelf length:16];
                                        uint8_t *encodeBufSelf = [encode encode:decodeBufSelf withLength:16 andKey:key];
                                        NSData *encodeData = [[NSData alloc]initWithBytes:encodeBufSelf length:16];
                                        NSLog(@"R1-R1'-R1-self:%@",[encodeData description]);
                                        NSLog(@"R1-R1'-R1-mcu:%@",[databufR1 description]);
                                        [self failedToAuthenticationTo:from Protocol:protocol ProductType:buf[4] makeSureIndex:buf[3]];
                                        InvalidateAuthenTimer(nil);
                                        [[NSNotificationCenter defaultCenter]postNotificationName:@"authenticationFailed" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:command,IDPS_Data,from,IDPS_ID,protocol,IDPS_ProtocolString, nil]];
                                    }
                                }
                                    break;
                                    
                            }
                        }
                        else{
                            NSLog(@"delay FB");
                        }
                    }
                        break;
                    case 0xFD:
                    {
                        if(FDFlag){
                            //认证成功
                            [self cancel:buf[3]-1 from:from];
                            InvalidateAuthenTimer(nil);
#ifdef DLog
                            NSLog(@"anthen success");
#endif
                            if ([authenticationDownDeviceList indexOfObject:from]!=NSNotFound) {
                                [authenticationDeviceList addObject:from];
                                [authenticationDownDeviceList removeObject:from];

                                NSDictionary *tempDeviceInfo = [self getIDPSInfoForDevice:from];
                                NSMutableDictionary *deviceInfo = [NSMutableDictionary dictionaryWithDictionary:tempDeviceInfo];
                                [deviceInfo setValue:protocol forKey:IDPS_ProtocolString];
                                
                                //加入认证缓存列表
                                [authenBTDeviceList addObject:deviceInfo];
                                
                                [[NSNotificationCenter defaultCenter]postNotificationName:DeviceAuthenSuccess object:self userInfo:deviceInfo];
                            }
                        }
                        else{
                            NSLog(@"delay FD");
                        }
                        
                    }
                        break;
                    case 0xFE:
                    {
                        if(FDFlag){
                            //认证失败
                            [self cancel:buf[3]-1 from:from];
                            InvalidateAuthenTimer(nil);
                            NSLog(@"anthen failed");
                            if ([authenticationDownDeviceList indexOfObject:from]!=NSNotFound) {
                                [authenticationDownDeviceList removeObject:from];
                                [[NSNotificationCenter defaultCenter]postNotificationName:@"authenticationFailed" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:command,IDPS_Data,from,IDPS_ID,protocol,IDPS_ProtocolString, nil]];
                                
                                NSLog(@"Failed");
                            }
                        }
                        else{
                            NSLog(@"delay FE");
                        }
                        
                    }
                        break;
                    case 0xFF:
                    {
                        //请求认证
                        int i=[prtocolArray indexOfObject:protocol];
                        if ([prtocolArray indexOfObject:protocol]!=NSNotFound ) {
                            if (i>1&&i<6) {
                                [self startAuthenticationTo:from IsNotEA:YES ProductType:buf[4]];
                                
                            }
                            else if(i==0)
                            {
                                [self startAuthenticationTo:from IsNotEA:NO ProductType:buf[4]];
                            }
                        }
                    }
                        break;
                    case 0xEF:
                    {
                        //秤忙
                        [self cancel:buf[3]-1 from:from];
                        NSDictionary*dic=[NSDictionary dictionaryWithObjectsAndKeys:from,@"Mac",from,@"CurrentUUID", nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"HS5RemoveMacFromArray" object:self userInfo:dic];
                    }
                    default:
                        break;
                }
            }
            
            
        }

}

-(void)runCommand:(NSData *)command From:(NSString *)from Chracteristic:(NSString *)chracteristic Protocol:(NSString *)protocol{
    int indexProtocol=[prtocolArray indexOfObject:protocol];
    NSData *recTotalData = [self handleCommand:command From:from Chracteristic:chracteristic Protocol:protocol];
    uint8_t buf[512];
    [recTotalData getBytes:buf length:[recTotalData length]];
    //if (0){
    if ([authenticationDeviceList indexOfObject:from]==NSNotFound){
        if (recTotalData==nil) {
            //无返回值
        }
        else{
            switch (buf[5]) {
                case 0xFB:
                {
                    if(FBFlag){
                        uint8_t bufIDDecodePointer[16];
                        uint8_t bufR1DecodePointer[16];
                        uint8_t bufR2DecodePointer[16];
                        
                        for (int i=0; i<16; i++) {
                            bufIDDecodePointer[i]=buf[6+i];
                            bufR1DecodePointer[i]=buf[22+i];
                            bufR2DecodePointer[i]=buf[38+i];
                        }
                        
                        
                        Encode *encode=[[Encode alloc] init];
                        uint32_t keyA[4]={ 0xB2DB8A30, 0x1E33E6BA, 0xC30D42D9, 0x4B26E853};
                        if(indexProtocol == 3){
                            //BP5
                            keyA[0]=0x7EAE8738;
                            keyA[1]=0x82622823;
                            keyA[2]=0x0CD4BAE0;
                            keyA[3]=0x97B6C503;
                        }
                        if(indexProtocol == 10){
                            //PO3
                            keyA[0]=0xFAA35392;
                            keyA[1]=0xCD6F290F;
                            keyA[2]=0x33594BCC;
                            keyA[3]=0x15BFC725;
                        }
                        else if(indexProtocol == 11){
                            //ECG
                            keyA[0]=0x460773F1;
                            keyA[1]=0x07D00605;
                            keyA[2]=0x9A50EA1A;
                            keyA[3]=0x2C5DB5B0;
                        }

                        else if(indexProtocol == 12){
                            //AM3
                            keyA[0]=0x460773F1;
                            keyA[1]=0x07D00605;
                            keyA[2]=0x9A50EA1A;
                            keyA[3]=0x2C5DB5B0;
                        }
                        else if(indexProtocol == 13){
                            //BG5L
                            keyA[0]=0xB87D445A;
                            keyA[1]=0xD2A5EA68;
                            keyA[2]=0x219876C2;
                            keyA[3]=0xA0C6D3F8;
                        }
                        else if(indexProtocol == 14){
                            //KS3
                            keyA[0]=0x8D8BB597;
                            keyA[1]=0x9D0AEC14;
                            keyA[2]=0x8DBE6103;
                            keyA[3]=0x8084CFDB;
                        }
                        else if(indexProtocol == 16){
                            //HS4
                            keyA[0]=0x8AF0C35D;
                            keyA[1]=0x7EABBD82;
                            keyA[2]=0x84EBCF78;
                            keyA[3]=0xA32BD98E;
                        }
                        else if(indexProtocol == 17){
                            //PO7
                            keyA[0]=0xFAA35392;
                            keyA[1]=0xCD6F290F;
                            keyA[2]=0x33594BCC;
                            keyA[3]=0x15BFC725;
                        }
                        else if(indexProtocol == 18){
                            //AM3S
                            keyA[0]=0x376AD1A9;
                            keyA[1]=0x227CE32C;
                            keyA[2]=0xFF03EE31;
                            keyA[3]=0xBDEC6F5E;
                            
                        }else if(indexProtocol == 20){
                            //bp3L
                            keyA[0]=0xFF2C525A;
                            keyA[1]=0x5A3CD3E8;
                            keyA[2]=0xC7D9B591;
                            keyA[3]=0xA6ADCB34;
        
                        }
                        else if(indexProtocol == 22){
                            //AM4
                            keyA[0]=0x995A085C;
                            keyA[1]=0x06EAA5DC;
                            keyA[2]=0xF2F4DA07;
                            keyA[3]=0x5DF4804B;
                        }
                        
                        
                        uint8_t *middleKey=[encode encode:bufIDDecodePointer withLength:16 andKey:keyA];
//                        for(int i=0; i<16; i++){
//                            NSLog(@"%02x",middleKey[i]);
//                        }
                        uint32_t *key=[encode uint8ConvertToUint32:middleKey];
                        //需重新处理KEY值
                        uint8_t *bufR1;
                        uint8_t *bufR2;
                        //NSData *R1Data = [NSData dataWithBytes:bufR1DecodePointer length:16];
                        //NSLog(@"R1Data:%@",R1Data);
                        bufR1=[encode encode:bufR1DecodePointer withLength:16 andKey:key];
                        bufR2=[encode encode:bufR2DecodePointer withLength:16 andKey:key];
                        NSData *databufR1=[NSData dataWithBytes:bufR1 length:16];
                        NSData *databufR2=[NSData dataWithBytes:bufR2 length:16];
                        
                        NSData *lastR1=[NSData dataWithContentsOfFile:[self dataFilePathNameLastR1To:from]];
                        
                        if ([lastR1 isEqualToData:databufR1]) {
                            [authenticationDownDeviceList addObject:from];
                            [self sendBtleAuthenticationR2:databufR2 To:from  Protocol:protocol ProductType:buf[4] makeSureIndex:buf[3]];                            //下位机认证成功加入下位机成功认证列表
                            //发送下一步认证过程
                        }
                        else
                        {
                            //authentication failed
                            NSLog(@"send R1:%@",[lastR1 description]);
                            
                            NSRange rage = {22,16};
                            NSLog(@"R1-R1'-recv:%@",[[recTotalData subdataWithRange:rage ] description]);

                            
                            uint8_t lastR1Buf[16];
                            [lastR1 getBytes:lastR1Buf length:16];
                            uint8_t *decodeBuf;
                            Encode *encode=[[Encode alloc] init];
                            decodeBuf = [encode decode:lastR1Buf withLength:16 andKey:key];
                            NSData *decodeData = [[NSData alloc]initWithBytes:decodeBuf length:16];
                            NSLog(@"R1-R1'-Self:%@",[decodeData description]);

                            
                            uint8_t decodeBufSelf[16];
                            [decodeData getBytes:decodeBufSelf length:16];
                            uint8_t *encodeBufSelf = [encode encode:decodeBufSelf withLength:16 andKey:key];
                            NSData *encodeData = [[NSData alloc]initWithBytes:encodeBufSelf length:16];
                            NSLog(@"R1-R1'-R1-self:%@",[encodeData description]);
                            NSLog(@"R1-R1'-R1-mcu:%@",[databufR1 description]);


                            [self failedToBtleAuthenticationTo:from Protocol:protocol ProductType:buf[4] makeSureIndex:buf[3]];
                            InvalidateAuthenTimer(from);
                            NSLog(@"anthen r1 failed");
                            
                            [[NSNotificationCenter defaultCenter]postNotificationName:@"authenticationFailed" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:recTotalData,IDPS_Data,from,IDPS_ID,protocol,IDPS_ProtocolString, nil]];
                        }
                    }
                    else{
                        NSLog(@"delay FB");
                    }
                }
                    break;
                case 0xFD:
                {
                    if(FDFlag){
                        //认证成功
                        InvalidateAuthenTimer(nil);
#ifdef DLog
                        NSLog(@"anthen success");
#endif
                        if ([authenticationDownDeviceList indexOfObject:from]!=NSNotFound) {
                            [authenticationDeviceList addObject:from];
                            [authenticationDownDeviceList removeObject:from];
                            
                            NSDictionary *tempDeviceInfo = [self getIDPSInfoForDevice:from];
                            NSMutableDictionary *deviceInfo = [NSMutableDictionary dictionaryWithDictionary:tempDeviceInfo];
                            [deviceInfo setValue:protocol forKey:IDPS_ProtocolString];
                            [[NSNotificationCenter defaultCenter]postNotificationName:DeviceAuthenSuccess object:self userInfo:deviceInfo];
                            
                        }
                    }
                    else{
                        NSLog(@"delay FD");
                    }
                    
                }
                    break;
                case 0xFE:
                {
                    if(FDFlag){
                        //认证失败
                        InvalidateAuthenTimer(from);
#ifdef DLog
                        NSLog(@"anthen failed");
#endif
                        if ([authenticationDownDeviceList indexOfObject:from]!=NSNotFound) {
                            [authenticationDownDeviceList removeObject:from];
                            [[NSNotificationCenter defaultCenter]postNotificationName:@"authenticationFailed" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:recTotalData,IDPS_Data,from,IDPS_ID,protocol,IDPS_ProtocolString, nil]];
                        }
                    }
                    else{
                        NSLog(@"delay FE");
                    }
                    
                }
                    break;
                case 0xFF:
                {
                    //请求认证
                    if ([prtocolArray indexOfObject:protocol]!=NSNotFound ) {
                        [self startBtleAuthenticationTo:from ProductType:buf[4] Protocol:protocol];
                        
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }
    }
    else{
        if (recTotalData==nil) {
            //无返回值
        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:protocol object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:recTotalData,IDPS_Data,from,IDPS_ID, chracteristic,@"Chracteristic",nil]];
        }
    }
}

//设备断开消息处理方法
-(void)deviceDisconnect:(NSNotification *)notify
{
    //从连接设备表中清空断开的设备
    NSString *from=[[notify userInfo]objectForKey:IDPS_ID];
    for(NSDictionary *deviceInfo in connectDeviceArray){
        NSString *connectID = [deviceInfo objectForKey:IDPS_ID];
        if([connectID isEqualToString:from]){
            [connectDeviceArray removeObject:deviceInfo];
            break;
        }
    }
    //从认证列表中删除
    if ([authenticationDeviceList indexOfObject:from]!=NSNotFound) {
        [authenticationDeviceList removeObject:from];
    }
    //从发送顺序id列表中删除
    if ([[sendIndexDic allKeys] indexOfObject:from]!=NSNotFound) {
        [sendIndexDic removeObjectForKey:from];
    }
    //从发送数据缓存包中删除
    if ([[totalDataBagDic allKeys] indexOfObject:from]!=NSNotFound) {
        [totalDataBagDic removeObjectForKey:from];
    }
    //从BT认证缓存列表里清除
    for (int i=0; i<authenBTDeviceList.count; i++) {
        NSDictionary *authenBTDevice = [authenBTDeviceList objectAtIndex:i];
        NSString *currentUUID = [authenBTDevice valueForKey:IDPS_ID];
        if ([currentUUID isEqual:from]) {
            [authenBTDeviceList removeObject:authenBTDevice];
            break;
        }
    }
}

//设备连接消息处理方法
-(void)deviceConnect:(NSNotification *)notify{
    NSDictionary *deviceInfo = [notify userInfo];
    if([deviceInfo allKeys].count>0){
        NSString *deviceName = [deviceInfo objectForKey:IDPS_Name];
        if ([deviceName isEqualToString:HS3_NAME]||[deviceName isEqualToString:HS4_NAME]||[deviceName isEqualToString:HS4S_NAME]) {
//            NSString *deviceSerialNub = [deviceInfo objectForKey:IDPS_SerialNumber];
//            [[IHCloud4CoreClass getCloudCoreClassInstance]cloudCommandAddAnomityDataType:IHDataAnomityWeight WithSerialNub:deviceSerialNub];
        }
        else if ([deviceName isEqualToString:PO3_NAME]) {
//            NSString *deviceSerialNub = [deviceInfo objectForKey:IDPS_SerialNumber];
//            [[IHCloud4CoreClass getCloudCoreClassInstance]cloudCommandAddAnomityDataType:IHDataAnomityBO WithSerialNub:deviceSerialNub];
        }
        if(![connectDeviceArray containsObject:deviceInfo]){
            [connectDeviceArray addObject:deviceInfo];
        }
    }
}

//清空所有缓存数组
-(void)clearAllAuthenDevice{
    int deviceCount = [connectDeviceArray count];
    for (int i=deviceCount-1; i>=0; i--) {
        NSDictionary *tempDic = [connectDeviceArray objectAtIndex:i];
        NSString *protocol = [tempDic objectForKey:IDPS_ProtocolString];
        NSString *connectID = [tempDic objectForKey:IDPS_ID];
        if(![protocol isEqual:HS5_Protocol] && connectID.length>0){
            [authenticationDeviceList removeObject:connectID];
            [authenticationDownDeviceList removeObject:connectID];
            [connectDeviceArray removeObjectAtIndex:i];
        }
    }
//    if ([authenticationDeviceList count]) {
//        [authenticationDeviceList removeAllObjects];
//    }
//    if ([authenticationDownDeviceList count]) {
//        [authenticationDownDeviceList removeAllObjects];
//    }
//    if([connectDeviceArray count]){
//        [connectDeviceArray removeAllObjects];
//    }
    InvalidateAuthenTimer(nil);
}

-(NSString *)getSelBGDevice:(NSString *)tempConnectedID{
    NSArray *tempArray = [self getAllEAConnectDevice];
    for(NSDictionary *dic in tempArray){
        if([[dic objectForKey:IDPS_ID]isEqual:tempConnectedID]){
            return [dic objectForKey:IDPS_SerialNumber];
        }
    }
    return @"000000";
}

//App主动断开低功耗设备
-(void)cancelBtleDevice:(NSString *)uuidString{
    if(uuidString.length){
        [btleController cancelSelDevice:uuidString];
    }
}

//从主动断开设备列表中删除指定设备
-(void)clearBtleDeviceFromDisconnectedDeviceList:(NSString *)uuidString{
    [btleController clearDisconnectedDevice:uuidString];
}

//判断蓝牙是否打开：不支持低功耗也返回蓝牙没打开
-(Boolean)isBtleSwitchOn{
    return btleController.btleIsOn;
}

-(NSDictionary *)getSelDeviceFrom:(NSString *)from{
    NSArray *accessories = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
    for (EAAccessory *obj in accessories)
    {
        if (obj.connectionID == from.intValue)
        {
            NSString *name = [[obj.modelNumber substringToIndex:3]copy];
            NSString *serialNumber = [obj.serialNumber copy];
            NSString *connectID = [NSString stringWithFormat:@"%d",obj.connectionID];
            NSString *firmwareVersion = [NSString stringWithFormat:@"%@",obj.firmwareRevision];
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:name,IDPS_Name,serialNumber,IDPS_SerialNumber,connectID,IDPS_ID,firmwareVersion,IDPS_FirmwareVersion, nil];
            return dic;
            break;
        }
    }
    return nil;
}

//获取认证成功的bg3、bg5列表
-(NSArray *)getAllBGDevice{
    NSArray *tempConnectArray = [eaCommunication getAllConnectDevice];
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    for(int i=0; i<[tempConnectArray count];i++){
        if([[[tempConnectArray objectAtIndex:i]objectForKey:IDPS_Name]isEqualToString:@"BG3"]|| [[[tempConnectArray objectAtIndex:i]objectForKey:IDPS_Name]isEqualToString:@"BG5"]){
            if([authenticationDeviceList indexOfObject:[[tempConnectArray objectAtIndex:i]objectForKey:IDPS_ID]]!=NSNotFound){
                [tempArray addObject:[tempConnectArray objectAtIndex:i]];
            }
        }
    }
    return tempArray;
}

//1000台bug解决方案－存储最后连接时间路径
-(NSString *)backTimePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *pathDir = [paths objectAtIndex:0];
    return [pathDir stringByAppendingPathComponent:@"backTime.plist"];

}

//判断是否需要激活session来持久
-(Boolean)needPersistent:(NSString *)from{
    if(from!=nil){
        if([persistantDevice containsObject:from]){
            return false;
        }
    }
    return true;
}
//增加需要persistent设备
-(void)addPersistentDevice:(NSString *)from{
    if(from!=nil){
        if(![persistantDevice containsObject:from]){
            [persistantDevice addObject:from];
        }
    }
    
}
//删除需要persistent设备
-(void)delPersistentDevice:(NSString *)from{
    if(from!=nil){
        if([persistantDevice containsObject:from]){
            [persistantDevice removeObject:from];
        }
    }
    
}

//清除指定设备从认证设备列表
-(void)delDeviceFromAuthenList:(NSString *)uuidString{
    if(uuidString.length>0){
        if([authenticationDeviceList containsObject:uuidString]){
            [authenticationDeviceList removeObject:uuidString];
        }
        if([authenticationDownDeviceList containsObject:uuidString]){
            [authenticationDownDeviceList removeObject:uuidString];
        }
    }
}

//休眠回来后重建udp链接
-(void)commandRebuildUdpLinker{
//    [wifiCommunication remakeUdpSocket];
}

//获取认证通过的BT设备列表
-(NSArray *)commandGetAuthenBTDeviceList{
    return authenBTDeviceList;
}


//对等同步类代理
#pragma mark - IHCloudEqualSyncDelegate <NSObject>

//执行云端动作列表
-(void)runCloudActionLogForDataArray:(NSArray *)actionLogArray withDataType:(NSNumber *)dataType{
    // NSLog(@"Set sync time success");
}


//获取指定设备的protocol
-(NSString *)getSelDeviceProtocol:(NSString *)uuidString{
    
    if(uuidString.length){
        
        NSMutableDictionary*idpsDic=[btleController getSelDeviceIdps:uuidString];
        
        if([[idpsDic allValues]containsObject:uuidString]){
            
            return [idpsDic valueForKey:IDPS_ProtocolString];
        }
    }
    return @"";
    
}

@end
