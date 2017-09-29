//
//  LXCommunicationEAControler.h
//  3he1-936CommunicationModule
//
//  Created by liuxins on 12-6-6.
//  Copyright (c) 2012年 lxyeslxlx13@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>
#import "BasiCommunicationDelegate.h"
#import "EASessionController.h"
#import "EALXControllerDelegate.h"
#import "HealthHeader.h"


@interface LXCommunicationEAControler : NSObject<EALXControllerDelegate>
{
    NSMutableArray *sessionControllers;
    id<BasiCommunicationDelegate>delegate;
    EASessionController *defaultSessionController;//采取默认发送模式，发送之前需确认默认发送通道
}
@property (nonatomic ,strong) NSMutableArray *EASessionControllers;
@property (nonatomic ,strong)id<BasiCommunicationDelegate>delegate;
@property (nonatomic ,strong)EASessionController *defaultSessionController;
-(id)init;
-(void)_accessoryDidConnect:(NSNotification *)not;
-(void)accessoryDidConnect:(EAAccessory*)accessory;
-(void)_accessoryDidDisconnect:(NSNotification *)not;
-(void)accessoryDidDisconnect:(EAAccessory*)accessory;

-(BOOL)selectDefaultSession:(NSUInteger)connectID;
-(NSArray *)getAllConnectDevice;

-(void)sendData:(NSData *)data;
-(void)sendData:(NSData *)data Session:(NSString *)connectID;  


-(void)receivedDataFromSession:(EASessionController *)sessionController;

//
-(void)connectDeviceWithSerialNub:(NSString *)serialNub;
-(void)getConnectedEAAccessoryWithType:(HealthDeviceType)tempDeviceType;

@end
