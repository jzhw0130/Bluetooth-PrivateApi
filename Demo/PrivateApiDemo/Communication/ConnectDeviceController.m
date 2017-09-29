//
//  ConnectDeviceController.m
//  iHealthDemoCode
//
//  Created by zhiwei jing on 1/24/16.
//  Copyright © 2016 zhiwei jing. All rights reserved.
//

#import "ConnectDeviceController.h"
#import "BTLEController.h"
#import "LXCommunicationEAControler.h"
#import "BasicCommunicationObject.h"
#import "BPMacroFile.h"
#import "AMMacroFile.h"
#import "POMacroFile.h"
#import "HSMacroFile.h"
#import "BGMacroFile.h"
#import "Cloud4CommonToolClass.h"



@implementation ConnectDeviceController{
    BTLEController *btleController;
    LXCommunicationEAControler *eaController;
    NSString *appSecret;
}

-(id)init {
    if (self = [super init]) {
        
    }
    
    typeAndSerialNubDic = [NSMutableDictionary dictionary];
    appSecret = [Cloud4CommonToolClass getAppSecret];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceConnectFailed:) name:DeviceConnectFailed object:nil];
    
    return self;
}


+(ConnectDeviceController *)commandGetInstance{
    static ConnectDeviceController* connectDeviceController;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        connectDeviceController = [[ConnectDeviceController alloc]init];
    });
    
    return connectDeviceController;
}

-(int)commandContectDeviceWithDeviceType:(HealthDeviceType)tempDeviceType  andSerialNub:(NSString *)tempSerialNub appSecret:(NSString *)secret{
    if ([secret isEqual:appSecret]) {
        if (tempSerialNub.length) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [typeAndSerialNubDic setValue:[NSNumber numberWithInt:tempDeviceType] forKey:tempSerialNub];
                //BT
                if (tempDeviceType == HealthDeviceType_BP5 || tempDeviceType == HealthDeviceType_BG5) {
                    //Get device from bluetooth list
                    [[BasicCommunicationObject basicCommunicationObject].eaCommunication connectDeviceWithSerialNub:tempSerialNub];
                }
                //BLE  start discover
                else {
                    [[BasicCommunicationObject basicCommunicationObject].btleController connectDeviceWithSerialNub:tempSerialNub];
                }
            });
        }
        else {
            //        NSLog(@"invalidate tempSerialNub");
            return 2;
        }
    }
    else {
        return 1;
    }
    return 0;
}


-(void)deviceConnectFailed:(NSNotification *)tempNoti{
    NSDictionary *tempDic = [tempNoti userInfo];
    NSString *deviceSerialNub = [tempDic valueForKey:IDPS_SerialNumber];
    NSNumber *deviceType = [typeAndSerialNubDic valueForKey:deviceSerialNub];
    
    NSString *deviceName = nil;
    NSString *notiName = @"";
    NSMutableDictionary *connectFiledDic = [NSMutableDictionary dictionary];
    switch (deviceType.integerValue) {
        case HealthDeviceType_BP5:
            deviceName = BP5_NAME;
            notiName = DeviceConnectBP5Failed;
            break;
        case HealthDeviceType_BG5:
            deviceName = BG5_NAME;
            notiName = DeviceConnectBG5Failed;
            break;
        case HealthDeviceType_BP3L:
            deviceName = BP3L_NAME;
            notiName = DeviceConnectBP3LFailed;
            break;
        case HealthDeviceType_AM4:
            deviceName = AM4_NAME;
            notiName = DeviceConnectAM4Failed;
            break;
        case HealthDeviceType_PO3:
            deviceName = PO3_NAME;
            notiName = DeviceConnectPO3Failed;
            break;
        case HealthDeviceType_HS4:
            deviceName = HS4S_NAME;
            notiName = DeviceConnectHS4Failed;
            break;
        default:
            break;
    }
    
    [connectFiledDic setValue:deviceName forKey:IDPS_Name];
    [connectFiledDic setValue:deviceSerialNub forKey:IDPS_SerialNumber];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:notiName object:self userInfo:connectFiledDic];
    
}



@end
