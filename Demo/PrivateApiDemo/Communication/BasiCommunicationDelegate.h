//
//  BasiCommunicationDelegate.h
//  3he1-936CommunicationModule
//
//  Created by liuxin on 12-6-6.
//  Copyright (c) 2012年 lxyeslxlx13@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MacroFile.h"

@protocol BasiCommunicationDelegate <NSObject>
@required
-(void)receivedData:(NSData *)data From:(NSString *)from Protocol:(NSString *)protocol;
@optional
-(void)receivedData:(NSData *)data From:(NSString *)from Chracteristic:(NSString *)chracteristic Protocol:(NSString *)protocol;
@end
