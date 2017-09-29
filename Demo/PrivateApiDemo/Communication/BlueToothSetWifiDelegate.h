//
//  BlueToothSetWifiDelegate.h
//  iHealth
//
//  Created by apple on 12-7-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BlueToothSetWifiDelegate <NSObject>
@required
//解析下位机的回复
-(void)processReceivedCommand:(NSData*)data;
@end
