//
//  EASessionController.m
//  EATest2
//
//  Created by jiuan on 11-7-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EASessionController.h"
#import "MacroFile.h"

@implementation EASessionController

@synthesize accessory = _accessory;
@synthesize protocolString = _protocolString;
@synthesize delegate;

#pragma mark Internal

// low level write method - write data to the accessory while there is space available and data to write
- (void)_writeData {
    while (([[_session outputStream] hasSpaceAvailable]) && ([_writeData length] > 0))
    {
        
        NSInteger bytesWritten = [[_session outputStream] write:[_writeData bytes] maxLength:[_writeData length]];
        if (bytesWritten == -1)
        {
            //NSLog(@"write error");

            break;
        }
        else if (bytesWritten > 0)
        {
			[_writeData replaceBytesInRange:NSMakeRange(0, bytesWritten) withBytes:NULL length:0];
        }
    }
}

// low level read method - read data while there is data and space available in the input buffer
- (void)_readData {
#define EAD_INPUT_BUFFER_SIZE 1024
    uint8_t buf[EAD_INPUT_BUFFER_SIZE];
    while ([[_session inputStream] hasBytesAvailable])
    {
        NSInteger bytesRead = [[_session inputStream] read:buf maxLength:EAD_INPUT_BUFFER_SIZE];
        if (_readData == nil) {
            _readData = [[NSMutableData alloc] init];
        }
        [_readData appendBytes:(void *)buf length:bytesRead];

    }
    
    [delegate receivedDataFromSession:self];
}

#pragma mark Public Methods

+ (EASessionController *)sharedController
{
    static EASessionController *sessionController = nil;
    if (sessionController == nil) {
        sessionController = [[EASessionController alloc] init];
    }
	
    return sessionController;
}



// initialize the accessory with the protocolString
- (void)setupControllerForAccessory:(EAAccessory *)accessory withProtocolString:(NSString *)protocolString
{
    _accessory=accessory;
    _protocolString = [protocolString copy];
}

// open a session with the accessory and set up the input and output stream on the default run loop
- (BOOL)openSession
{
    _session = [[EASession alloc] initWithAccessory:_accessory forProtocol:_protocolString];
    
    if (_session)
    {
        [_accessory setDelegate:self];
        [[_session inputStream] setDelegate:self];
        [[_session inputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [[_session inputStream] open];
		
        [[_session outputStream] setDelegate:self];
        [[_session outputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [[_session outputStream] open];
        
        NSDictionary *deviceInfo = [self getDeviceInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:DeviceOpenSession object:self userInfo:deviceInfo];
        
        uint8_t buf[7]={0xB0,0x04,0xA0,0x00,0xA1,0x00,0x00};
        [self writeData:[NSData dataWithBytes:buf length:7]];
    }
    else
    {
        NSLog(@"creating session failed");
    }
	
    return (_session != nil);
}

// close the session with the accessory.
- (void)closeSession
{   
    NSDictionary *deviceInfo = [self getDeviceInfo];
    
    [[_session inputStream] close];
    [[_session inputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[_session inputStream] setDelegate:nil];
    [[_session outputStream] close];
    [[_session outputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[_session outputStream] setDelegate:nil];
	
    _session = nil;
    _writeData = nil;
    _readData = nil;
    [[NSNotificationCenter defaultCenter]postNotificationName:DeviceDisconnect object:self userInfo:deviceInfo];
    
}

-(NSDictionary *)getDeviceInfo{
    NSMutableDictionary *convertDic = [[NSMutableDictionary alloc]init];
    if(_accessory.name.length>0 || [_protocolString isEqualToString:BP3_Protocol]){
        BOOL badHS3Flag = FALSE;
        if([_protocolString isEqualToString:HS3_Protocol] && ![_accessory.modelNumber isEqualToString:@"HS3 11070"]){
            [convertDic setValue:HS3_NAME forKey:IDPS_Name];
            badHS3Flag = YES;
        }
        else if(_accessory.modelNumber.length){
            NSArray *modelArray = [_accessory.modelNumber componentsSeparatedByString:@" "];
            [convertDic setValue:[modelArray objectAtIndex:0] forKey:IDPS_Name];
        }
        
        if([[convertDic objectForKey:IDPS_Name]isEqualToString:@"HS3"]){
            if(_accessory.serialNumber.length==12){
                [convertDic setValue:_accessory.serialNumber forKey:IDPS_SerialNumber];
            }
            else{
                NSData *macData = [_accessory.serialNumber dataUsingEncoding:NSUTF8StringEncoding];
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
            [convertDic setValue:_accessory.serialNumber forKey:IDPS_SerialNumber];
        }
        
        if(badHS3Flag == YES){
            [convertDic setValue:@"HS3 11070" forKey:IDPS_ModelNumber];
        }
        else{
            [convertDic setValue:_accessory.modelNumber forKey:IDPS_ModelNumber];
        }
        [convertDic setValue:_accessory.name forKey:IDPS_AccessoryName];
        [convertDic setValue:_accessory.firmwareRevision forKey:IDPS_FirmwareVersion];
        [convertDic setValue:_accessory.hardwareRevision forKey:IDPS_HardwareVersion];
        [convertDic setValue:_accessory.manufacturer forKey:IDPS_Manufacture];
        [convertDic setValue:[NSString stringWithFormat:@"%d",_accessory.connectionID] forKey:IDPS_ID];
        [convertDic setValue:_protocolString forKey:IDPS_ProtocolString];
        [convertDic setValue:[NSNumber numberWithInteger:DeviceUUIDType_BT] forKey:IDPS_Type];
        
//        UIAlertView *alterView = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"_accessory:%@ convertDic:%@",_accessory,convertDic] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
//        [alterView show];
    }
    return convertDic;
}
// high level write data method
- (void)writeData:(NSData *)data
{
    if (_writeData == nil) {
        _writeData = [[NSMutableData alloc] init];
    }
    #ifdef DLog
    NSLog(@"send:%@ connectID:%d",data,_accessory.connectionID);
    #endif
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"Tip" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:data,@"Tip",nil]];
     //IHLog(@"send", @"baseicSendData==%@,connectID==%d",data,_accessory.connectionID);
    [_writeData appendData:data];
    [self _writeData];
}

// high level read method 
- (NSData *)readData:(NSUInteger)bytesToRead
{
    NSData *data = nil;
    if ([_readData length] >= bytesToRead) {
        NSRange range = NSMakeRange(0, bytesToRead);
        data = [_readData subdataWithRange:range];
        [_readData replaceBytesInRange:range withBytes:NULL length:0];
        
    }
    return data;
}

// get number of bytes read into local buffer
- (NSUInteger)readBytesAvailable
{
    return [_readData length];
}

//#pragma mark EAAccessoryDelegate
//- (void)accessoryDidDisconnect:(EAAccessory *)accessory
//{
//    
//}

#pragma mark NSStreamDelegateEventExtensions

// asynchronous NSStream handleEvent method
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventNone:
            break;
        case NSStreamEventOpenCompleted:
            break;
        case NSStreamEventHasBytesAvailable:
            [self _readData];
            break;
        case NSStreamEventHasSpaceAvailable:
            [self _writeData];
            break;
        case NSStreamEventErrorOccurred:
            break;
        case NSStreamEventEndEncountered:
            break;
        default:
            break;
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
}
@end