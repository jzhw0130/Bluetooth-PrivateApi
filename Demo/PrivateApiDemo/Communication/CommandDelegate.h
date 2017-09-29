//
//  CommandDelegate.h
//  wifiModule
//
//  Created by liuxin on 11-12-27.
//  Copyright (c) 2011年 lxyeslxlx13@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CommandDelegate <NSObject>
@required
-(void)runCommand:(NSData *)command From:(NSString *)from Protocol:(NSString *)protocol;

@optional
-(void)runCommand:(NSData *)command From:(NSString *)from Chracteristic:(NSString *)chracteristic Protocol:(NSString *)protocol;

@end
