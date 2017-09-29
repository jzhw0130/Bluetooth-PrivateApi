//
//  ConnectDeviceController.h
//  iHealthDemoCode
//
//  Created by zhiwei jing on 1/24/16.
//  Copyright © 2016 zhiwei jing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HealthHeader.h"

@interface ConnectDeviceController : NSObject{
    NSMutableDictionary *typeAndSerialNubDic;
}

+(ConnectDeviceController *)commandGetInstance;

/*
    Result:
    0. success
    1. Secret error
    2. invalidate parament
 */
-(int)commandContectDeviceWithDeviceType:(HealthDeviceType)tempDeviceType  andSerialNub:(NSString *)tempSerialNub appSecret:(NSString *)secret;

@end
