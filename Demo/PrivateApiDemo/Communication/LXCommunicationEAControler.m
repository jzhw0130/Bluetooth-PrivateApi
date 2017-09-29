//
//  LXCommunicationEAControler.m
//  3he1-936CommunicationModule
//
//  Created by liuxin on 12-6-6.
//  Copyright (c) 2012年 lxyeslxlx13@163.com. All rights reserved.
//

#import "LXCommunicationEAControler.h"
#import "EASessionController.h"
#import "BasicCommunicationObject.h"

@implementation LXCommunicationEAControler

@synthesize EASessionControllers;
@synthesize delegate;
@synthesize defaultSessionController;
-(id)init
{
    if (self=[super init]) {
        sessionControllers=[[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_accessoryDidConnect:) name:EAAccessoryDidConnectNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_accessoryDidDisconnect:) name:EAAccessoryDidDisconnectNotification object:nil];
        [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
    }
    
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(bbSendData) userInfo:nil repeats:YES];
    
    NSLog(@"_____Accessories:%@", [[EAAccessoryManager sharedAccessoryManager] connectedAccessories]);
    
    return self;
}

-(void)getConnectedEAAccessoryWithType:(HealthDeviceType)tempDeviceType{
    for (EAAccessory *EAA in [[EAAccessoryManager sharedAccessoryManager] connectedAccessories])
    {
        if([EAA.protocolStrings count]){
            NSString *deviceModule = EAA.modelNumber;
            NSArray *moduleArray = [deviceModule componentsSeparatedByString:@" "];
            NSString *deviceName = nil;
            if (moduleArray.count) {
                deviceName = [moduleArray objectAtIndex:0];
            }
            
            BOOL isRightDevice = [self detectRightDeviceWithType:tempDeviceType andDeviceName:deviceName];
            if (isRightDevice == true) {
                NSMutableDictionary *discoverDic = [NSMutableDictionary dictionary];
                [discoverDic setValue:EAA.serialNumber forKey:IDPS_SerialNumber];
                [discoverDic setValue:deviceName forKey:IDPS_Name];
                
                [[NSNotificationCenter defaultCenter]postNotificationName:DiscoverDone object:self userInfo:discoverDic];
                
                
            }
            
        }
    }
}

-(BOOL)detectRightDeviceWithType:(HealthDeviceType)deviceType andDeviceName:(NSString *)deviceName{
    if (deviceType == HealthDeviceType_BP5 && [deviceName isEqual:BP5_NAME]) {
        return true;
    }
    else if (deviceType == HealthDeviceType_BG5 && [deviceName isEqual:BG5_NAME]) {
        return true;
    }
    return false;
}

-(NSString *)getValidProtocol:(NSArray *)proArr{
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSArray *infoProArray = [infoDictionary objectForKey:@"UISupportedExternalAccessoryProtocols"];
    for(NSString *pro in proArr){
        BOOL result = [infoProArray containsObject:pro];
        if(result==TRUE){
            return [pro copy];
            break;
        }
    }
    return @"";
}

-(void)bbSendData{
    for (EASessionController *EAS in sessionControllers) {
        NSString *eaConnectID = [NSString stringWithFormat:@"%d",EAS.accessory.connectionID];
        if([[BasicCommunicationObject basicCommunicationObject]needPersistent:eaConnectID]){
//            NSLog(@"bbbbbbbbbbbbbbbbb:%@",eaConnectID);
            uint8_t buf[7]={0xB0,0x04,0xA0,0x00,0xA1,0x00,0x00};
            [EAS writeData:[NSData dataWithBytes:buf length:7]];
        }
    }
}

-(BOOL)selectDefaultSession:(NSUInteger)connectID
{
    for (EASessionController *EAS in sessionControllers) {
        if (EAS.accessory.connectionID==connectID) {
            defaultSessionController=EAS;
            return YES;
        }
    }
    defaultSessionController = Nil;
    return NO;

}

-(NSArray *)getAllConnectDevice
{
    NSMutableArray *EASArray=[[NSMutableArray alloc] init];
    for (EASessionController *EAS in sessionControllers) {
        NSMutableDictionary *convertDic = [[NSMutableDictionary alloc]init];
        
        NSString *deviceName = [EAS.accessory.modelNumber substringToIndex:3];
        [convertDic setValue:deviceName forKey:IDPS_Name];
        
        if([[convertDic objectForKey:IDPS_Name]isEqualToString:@"HS3"]){
            if(EAS.accessory.serialNumber.length==12){
                [convertDic setValue:EAS.accessory.serialNumber forKey:IDPS_SerialNumber];
            }
            else{
                NSData *macData = [EAS.accessory.serialNumber dataUsingEncoding:NSUTF8StringEncoding];
                if(macData.length==6){
                    Byte buf[6] = {0};
                    [macData getBytes:buf length:6];
                    for(int i=0; i<3; i++){
                        Byte tempNub = buf[i];
                        buf[i] = buf[5-i];
                        buf[5-i] = tempNub;
                    }
                    NSString *serialNub = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X",buf[0],buf[1],buf[2],buf[3],buf[4],buf[5]];
                    [convertDic setValue:serialNub forKey:IDPS_SerialNumber];
                }
            }
        }
        else{
            [convertDic setValue:EAS.accessory.serialNumber forKey:IDPS_SerialNumber];
        }
        [convertDic setValue:[NSString stringWithFormat:@"%d",EAS.accessory.connectionID] forKey:IDPS_ID];
        [convertDic setValue:EAS.accessory.name forKey:IDPS_AccessoryName];
        [convertDic setValue:EAS.accessory.manufacturer forKey:IDPS_Manufacture];
        [convertDic setValue:EAS.accessory.firmwareRevision forKey:IDPS_FirmwareVersion];
        [convertDic setValue:EAS.accessory.hardwareRevision forKey:IDPS_HardwareVersion];
        [convertDic setValue:EAS.accessory.modelNumber forKey:IDPS_ModelNumber];
        [convertDic setValue:[self getValidProtocol:EAS.accessory.protocolStrings] forKey:IDPS_ProtocolString];
        [EASArray addObject:convertDic];
    }
    return EASArray;
}
-(void)sendData:(NSData *)data
{
    //NSLog(@"dataSend:%@",data);
    if(defaultSessionController != Nil){
        [defaultSessionController writeData:data];
    }
}
-(void)sendData:(NSData *)data Session:(NSString *)connectID
{
    NSInteger connnectedID = [connectID integerValue];
    BOOL send=NO;
    for (EASessionController *EAS in sessionControllers) {
        if(EAS.accessory.connectionID==connnectedID)
        {
            [self selectDefaultSession:connnectedID];
            NSLog(@"rightconnectID:%@",connectID);
            [EAS writeData:data];
            send=YES;
        }
       
    }
    
    if (!send) {
        NSLog(@"wrongconnectID:%@",connectID);
        [defaultSessionController writeData:data];
        NSLog(@"defaultSessionController:%d",defaultSessionController.accessory.connectionID);
    }
}
-(void)_accessoryDidConnect:(NSNotification *)noti
{
    NSLog(@"Connect device: %@", noti.userInfo);
    EAAccessory *connectedAccessory = [[noti userInfo] objectForKey:EAAccessoryKey];
    NSArray *protocolArray = [connectedAccessory protocolStrings];
    if([protocolArray containsObject:BG3_Protocol]){
        [self performSelector:@selector(accessoryDidConnect:) withObject:connectedAccessory afterDelay:2.5];
    }
    else{
        [self performSelector:@selector(accessoryDidConnect:) withObject:connectedAccessory afterDelay:0.5];
    }
}
-(void)accessoryDidConnect:(EAAccessory*)accessory
{
    if (accessory.protocolStrings.count) {
        NSString *deviceModule = accessory.modelNumber;
        NSArray *moduleArray = [deviceModule componentsSeparatedByString:@" "];
        NSString *deviceName = nil;
        if (moduleArray.count) {
            deviceName = [moduleArray objectAtIndex:0];
        }
        
        NSMutableDictionary *discoverDic = [NSMutableDictionary dictionary];
        [discoverDic setValue:accessory.serialNumber forKey:IDPS_SerialNumber];
        [discoverDic setValue:deviceName forKey:IDPS_Name];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:DiscoverDone object:self userInfo:discoverDic];
    }
}

#pragma mark - Connect by controller start

-(void)connectDeviceWithSerialNub:(NSString *)serialNub {
    EAAccessory *_accessory;
    BOOL isConnectedFlag = false;
    for (EASessionController *tempController in sessionControllers) {
        if ([tempController.accessory.serialNumber isEqual:serialNub]) {
            isConnectedFlag = true;
            _accessory = tempController.accessory;
        }
    }
    
    if (isConnectedFlag == false) {
        for (EAAccessory *EAA in [[EAAccessoryManager sharedAccessoryManager] connectedAccessories])
        {
            if([EAA.protocolStrings count] && [EAA.serialNumber isEqual:serialNub]){
                EASessionController *sessionController=[[EASessionController alloc] init];
                NSString *selPro = [self getValidProtocol:[EAA protocolStrings]];
                [sessionController setupControllerForAccessory:EAA withProtocolString:selPro];
                sessionController.delegate=self;
                BOOL flag = [sessionController openSession];
                if(flag == TRUE){
                    isConnectedFlag = true;
                    defaultSessionController=sessionController;
                    [sessionControllers  addObject:sessionController];
                }
                else{
                    //temp
                }
                break;
            }
        }
        if (isConnectedFlag == false) {
            NSMutableDictionary *failedDic = [NSMutableDictionary dictionary];
            [failedDic setValue:serialNub forKey:IDPS_SerialNumber];
            [[NSNotificationCenter defaultCenter]postNotificationName:DeviceConnectFailed object:self userInfo:failedDic];
        }
    }
    else {
        //已经建立过Session  1. 建Session 2. 跑认证 （可认为已经过认证）
        NSMutableDictionary *convertDic = [NSMutableDictionary dictionary];
        if(_accessory.modelNumber.length){
            NSArray *modelArray = [_accessory.modelNumber componentsSeparatedByString:@" "];
            [convertDic setValue:[modelArray objectAtIndex:0] forKey:IDPS_Name];
        }
        [convertDic setValue:_accessory.serialNumber forKey:IDPS_SerialNumber];
        [convertDic setValue:_accessory.name forKey:IDPS_AccessoryName];
        [convertDic setValue:_accessory.manufacturer forKey:IDPS_Manufacture];
        [convertDic setValue:_accessory.modelNumber forKey:IDPS_ModelNumber];
        [convertDic setValue:_accessory.firmwareRevision forKey:IDPS_FirmwareVersion];
        [convertDic setValue:_accessory.hardwareRevision forKey:IDPS_HardwareVersion];
        [convertDic setValue:[NSString stringWithFormat:@"%d",_accessory.connectionID] forKey:IDPS_ID];
        NSString *invalideProtocol = [self getValidProtocol:_accessory.protocolStrings];
        [convertDic setValue:invalideProtocol forKey:IDPS_ProtocolString];
        [convertDic setValue:[NSNumber numberWithInteger:DeviceUUIDType_BT] forKey:IDPS_Type];
    }
}

#pragma mark -


-(void)_accessoryDidDisconnect:(NSNotification *)noti
{
    EAAccessory *disconnectedAccessory = [[noti userInfo] objectForKey:EAAccessoryKey];
#ifdef DLog
    NSLog(@"__________accessoryDidDisconnectr:%@",[disconnectedAccessory description]);
#endif
    for (EASessionController *sessionController in sessionControllers) {
        if (sessionController.accessory.connectionID==disconnectedAccessory.connectionID) {
            [sessionController closeSession];
            sessionController.delegate=nil;
            [sessionControllers removeObject:sessionController];
            break;
        }
    }
//    [self performSelector:@selector(accessoryDidDisconnect:) withObject:disconnectedAccessory afterDelay:0.1];
}
-(void)accessoryDidDisconnect:(EAAccessory*)accessory
{
    for (EASessionController *sessionController in sessionControllers) {
        if (sessionController.accessory.connectionID==accessory.connectionID) {
            if (defaultSessionController==sessionController) {
                defaultSessionController=nil;
            }
            [sessionController closeSession];
            sessionController.delegate=nil;
            
            [sessionControllers removeObject:sessionController];
            if (defaultSessionController==nil) {
                if ([sessionControllers count]>=1) {
                    defaultSessionController=[sessionControllers lastObject];
                }
            }
            break;
        }
    }

}

-(void)receivedDataFromSession:(EASessionController *)sessionController
{
    NSData *data=[sessionController readData:[sessionController readBytesAvailable]];
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"Tip" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:data,@"Tip",nil]];
    NSString *str=[NSString stringWithFormat:@"%d",sessionController.accessory.connectionID];
    [delegate receivedData:data From:str Protocol:sessionController.protocolString];
}

-(void)dealloc{

}

@end
