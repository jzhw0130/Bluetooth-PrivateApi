//
//  ScanDeviceController.m
//  iHealthDemoCode
//
//  Created by zhiwei jing on 1/24/16.
//  Copyright © 2016 zhiwei jing. All rights reserved.
//

#import "ScanDeviceController.h"
#import "BasicCommunicationObject.h"
#import "BTLEController.h"
#import "LXCommunicationEAControler.h"
#import "BPMacroFile.h"
#import "AMMacroFile.h"
#import "POMacroFile.h"
#import "HSMacroFile.h"
#import "BGMacroFile.h"
#import "Cloud4CommonToolClass.h"



@implementation ScanDeviceController{
    BTLEController *btleController;
    LXCommunicationEAControler *eaController;
    NSString *appSecret;
}


-(id)init {
    if (self = [super init]) {
        
    }

    appSecret = [Cloud4CommonToolClass getAppSecret];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(discoverDone:) name:DiscoverDone object:nil];

    return self;
}


+(ScanDeviceController *)commandGetInstance{
    static ScanDeviceController* scanDeviceController;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scanDeviceController = [[ScanDeviceController alloc]init];
    });
    
    return scanDeviceController;
}


-(int)commandScanDeviceType:(HealthDeviceType)tempDeviceType appSecret:(NSString *)secret{
    if ([secret isEqual:appSecret]) {
        //BT
        if (tempDeviceType == HealthDeviceType_BP5 || tempDeviceType == HealthDeviceType_BG5) {
            //Get device from bluetooth list
            [[BasicCommunicationObject basicCommunicationObject].eaCommunication getConnectedEAAccessoryWithType:tempDeviceType];
        }
        //BLE  start discover
        else {
            BtleType tempType = BtleType_BP3L;
            
            switch (tempDeviceType) {
                case HealthDeviceType_BP3L:
                    tempType = BtleType_BP3L;
                    break;
                    
                case HealthDeviceType_AM3S:
                    tempType = BtleType_AM3S;
                    break;
                    
                case HealthDeviceType_AM4:
                    tempType = BtleType_AM4;
                    break;
                
                case HealthDeviceType_PO3:
                    tempType = BtleType_PO3;
                    break;
                    
                case HealthDeviceType_HS4:
                    tempType = BtleType_HS4;
                    break;
                    
                default:
                    break;
            }
            
            [[BasicCommunicationObject basicCommunicationObject].btleController openSelDeviceFromType:tempType];
        }
    }
    else {
        return 1;
    }
    return 0;
}

-(int)commandStopScanDeviceType:(HealthDeviceType)tempDeviceType appSecret:(NSString *)secret{
    if ([secret isEqual:appSecret]) {
        //BT
        if (tempDeviceType == HealthDeviceType_BP5 || tempDeviceType == HealthDeviceType_BG5) {
            //Get device from bluetooth list
            
        }
        //BLE  start discover
        else {
            BtleType tempType = BtleType_BP3L;
            
            switch (tempDeviceType) {
                case HealthDeviceType_BP3L:
                    tempType = BtleType_BP3L;
                    break;
                    
                case HealthDeviceType_AM3S:
                    tempType = BtleType_AM3S;
                    break;
                    
                case HealthDeviceType_AM4:
                    tempType = BtleType_AM4;
                    break;
                    
                case HealthDeviceType_PO3:
                    tempType = BtleType_PO3;
                    break;
                    
                case HealthDeviceType_HS4:
                    tempType = BtleType_HS4;
                    break;
                    
                default:
                    break;
            }
            
            [[BasicCommunicationObject basicCommunicationObject].btleController closeSelDeviceFromType:tempType];
        }
    }
    else {
        return 1;
    }
    return 0;
}


-(void)discoverDone:(NSNotification *)tempNoti {
    NSDictionary *tempDeiveInfo = [tempNoti userInfo];
    NSString *deviceSerialNub = [tempDeiveInfo valueForKey:IDPS_SerialNumber];
    NSString *deviceName = [tempDeiveInfo valueForKey:IDPS_Name];

    
    NSMutableDictionary *discoverDic = [NSMutableDictionary dictionary];
    NSString *notiName = @"";
    if ([deviceName isEqual:BP5_NAME]) {
        notiName = DiscoverBP5;
    }
    else if ([deviceName isEqual:BG5_NAME]) {
        notiName = DiscoverBG5;
    }
    else if ([deviceName isEqual:BP3L_NAME]) {
        notiName = DiscoverBP3L;
    }
    else if ([deviceName isEqual:PO3_NAME]) {
        notiName = DiscoverPO3;
    }
    else if ([deviceName isEqual:HS4S_NAME]) {
        notiName = DiscoverHS4;
    }
    else if ([deviceName isEqual:AM4_NAME]) {
        notiName = DiscoverAM4;
    }
    else {
    
    }
    
    [discoverDic setValue:deviceName forKey:IDPS_Name];
    [discoverDic setValue:deviceSerialNub forKey:IDPS_SerialNumber];
    [[NSNotificationCenter defaultCenter]postNotificationName:notiName object:self userInfo:discoverDic];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
