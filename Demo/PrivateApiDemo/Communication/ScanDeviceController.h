//
//  ScanDeviceController.h
//  iHealthDemoCode
//
//  Created by zhiwei jing on 1/24/16.
//  Copyright © 2016 zhiwei jing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HealthHeader.h"



@interface ScanDeviceController : NSObject

+(ScanDeviceController *)commandGetInstance;

/*
 Result:
 0. success
 1. Secret error
 */
-(int)commandScanDeviceType:(HealthDeviceType)tempDeviceType appSecret:(NSString *)secret;

/*
 Result:
 0. success
 1. Secret error
 */
-(int)commandStopScanDeviceType:(HealthDeviceType)tempDeviceType appSecret:(NSString *)secret;

@end
