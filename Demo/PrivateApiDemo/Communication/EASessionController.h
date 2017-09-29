//
//  EASessionController.h
//  EATest2
//
//  Created by jiuan on 11-7-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>
#import "EALXControllerDelegate.h"

extern NSString *EASessionDataReceivedNotification;

// NOTE: EADSessionController is not threadsafe, calling methods from different threads will lead to unpredictable results
@interface EASessionController : NSObject <EAAccessoryDelegate, NSStreamDelegate> {
    EAAccessory *__weak _accessory;
    EASession *_session;
    NSString *_protocolString;
	
    NSMutableData *_writeData;
    NSMutableData *_readData;
    
    id<EALXControllerDelegate>delegate;

}

+ (EASessionController *)sharedController;

- (void)setupControllerForAccessory:(EAAccessory *)accessory withProtocolString:(NSString *)protocolString;

- (BOOL)openSession;
- (void)closeSession;

- (void)writeData:(NSData *)data;

- (NSUInteger)readBytesAvailable;
- (NSData *)readData:(NSUInteger)bytesToRead;

@property (nonatomic,strong)id<EALXControllerDelegate>delegate;
@property (weak, nonatomic, readonly) EAAccessory *accessory;
@property (nonatomic, readonly) NSString *protocolString;

@end

