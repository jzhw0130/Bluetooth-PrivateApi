//
//  SCLXWifiTransmission.m
//  wifiModule
//
//  Created by liuxin on 12-4-18.
//  Copyright (c) 2012年 lxyeslxlx13@163.com. All rights reserved.
//

#import "SCLXWifiTransmission.h"
#import "AsyncUdpSocket.h"

@implementation SCLXWifiTransmission
@synthesize delegate;

-(id)init
{
    self = [super init];
    if (self) 
    {
        SCLXUdpSocket=[[AsyncUdpSocket alloc] initWithDelegate:self];
        NSError *error;
        [SCLXUdpSocket enableBroadcast:YES error:&error];
        [SCLXUdpSocket bindToPort:8000 error:&error];
        [SCLXUdpSocket receiveWithTimeout:-1 tag:0]; 
        
        SCLXMacAndIPDic=[[NSMutableDictionary alloc] init];
        SCScaleInfoDic = [[NSMutableDictionary alloc] init];
        SCSavedScaleInfoDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}
//重建socket
-(void)remakeUdpSocket{
    SCLXUdpSocket=[[AsyncUdpSocket alloc] initWithDelegate:self];
    NSError *error;
    [SCLXUdpSocket enableBroadcast:YES error:&error];
    [SCLXUdpSocket bindToPort:8000 error:&error];
    [SCLXUdpSocket receiveWithTimeout:-1 tag:0];
}

-(id)initWithPort:(UInt16)port EnableBroadcast:(BOOL)enableBroadcast Timeout:(NSTimeInterval)timeout Tag:(long)tag
{
    self = [super init];
    if (self) 
    {
        SCLXUdpSocket=[[AsyncUdpSocket alloc] initWithDelegate:self];
        NSError *error;
        [SCLXUdpSocket enableBroadcast:enableBroadcast error:&error];
        [SCLXUdpSocket bindToPort:port error:&error];
        [SCLXUdpSocket receiveWithTimeout:timeout tag:tag]; 
        
        SCLXMacAndIPDic=[[NSMutableDictionary alloc] init];
        SCScaleInfoDic = [[NSMutableDictionary alloc] init];
        SCSavedScaleInfoDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}
-(NSInteger)sendData:(NSData *)requestData MAC:(NSString *)mac
{
    if ([SCLXMacAndIPDic objectForKey:mac]!=nil) {
        NSString *sendIPAddress=[[NSString alloc] initWithString:[SCLXMacAndIPDic objectForKey:mac]];
        if ([SCLXUdpSocket sendData:requestData toHost:sendIPAddress port:10000 withTimeout:-1 tag:0]) 
        {
#ifdef DLog
            NSLog(@"Send==%@",[requestData description]);
#endif
            [SCLXUdpSocket receiveWithTimeout:-1 tag:0];
            return 1;
        }
        else
        {
            return -1;
        }

    }
    else
    {
        NSLog(@"The wrong mac/you do not scan the scale");
        return -1;
    }
    
}
-(NSInteger)sendData:(NSData *)requestData MAC:(NSString *)mac Port:(UInt16)port SendTimeout:(NSTimeInterval)sendTimeout ReceivedTimeout:(NSTimeInterval)receivedTimeout Tag:(long)tag
{
    if ([SCLXMacAndIPDic objectForKey:mac]!=nil) {
        NSString *sendIPAddress=[[NSString alloc] initWithString:[SCLXMacAndIPDic objectForKey:mac]];
        if ([SCLXUdpSocket sendData:requestData toHost:sendIPAddress port:port withTimeout:sendTimeout tag:tag]) 
        {
            [SCLXUdpSocket receiveWithTimeout:receivedTimeout tag:tag];

            return 1;
        }
        else
        {

            return -1;
        }
        
    }
    else
    {
        NSLog(@"The wrong mac/you do not scan the scale");
        return -1;
    }
}
-(NSInteger)sendData:(NSData *)requestData IP:(NSString *)ip
{
    if ([SCLXUdpSocket sendData:requestData toHost:ip port:10000 withTimeout:-1 tag:0]) 
    {
//        NSLog(@"ScanWifi==%@",[requestData description]);
        [SCLXUdpSocket receiveWithTimeout:-1 tag:0];
        return 1;
    }
    else
    {
        return -1;
        NSLog(@"can not send data useIP");
    }

}
-(NSInteger)sendData:(NSData *)requestData IP:(NSString *)ip Port:(UInt16)port SendTimeout:(NSTimeInterval)sendTimeout ReceivedTimeout:(NSTimeInterval)receivedTimeout Tag:(long)tag
{
        if ([SCLXUdpSocket sendData:requestData toHost:ip port:port withTimeout:sendTimeout tag:tag]) 
        {
            [SCLXUdpSocket receiveWithTimeout:receivedTimeout tag:tag];
            return 1;
        }
        else
        {
            return -1;
        }
        
}

-(void)searchScales
{
    //清空上次扫描秤的列表
    static Boolean flag = FALSE;
    NSArray *keyArray = [SCScaleInfoDic allKeys];
    NSArray *savedKeyArray = [SCSavedScaleInfoDic allKeys];
    NSMutableDictionary *disConnectedMac = [[NSMutableDictionary alloc]init];
    for(int i=0; i<[savedKeyArray count]; i++){
        if([keyArray indexOfObject:[savedKeyArray objectAtIndex:i]]==NSNotFound){
            int number = [[[SCSavedScaleInfoDic objectForKey:[savedKeyArray objectAtIndex:i]] objectForKey:@"Number"]intValue];
            if(number<=0){
                disConnectedMac = [SCSavedScaleInfoDic objectForKey:[savedKeyArray objectAtIndex:i]];
//                [disConnectedMac setObject:[savedKeyArray objectAtIndex:i] forKey:@"Mac"];
                [SCSavedScaleInfoDic removeObjectForKey:[savedKeyArray objectAtIndex:i]];
                savedKeyArray = [SCSavedScaleInfoDic allKeys];
                
            }
            else{
                NSMutableDictionary *tempDic = [SCSavedScaleInfoDic objectForKey:[savedKeyArray objectAtIndex:i]];
                [tempDic setObject:[NSString stringWithFormat:@"%d",number-1] forKey:@"Number"];
                [SCSavedScaleInfoDic setObject:tempDic forKey:[savedKeyArray objectAtIndex:i]];
            }
        }
    }
    
    if(flag == TRUE && [savedKeyArray count]<=0){
        flag = FALSE;
        //jingzhiwei for scale;
        [[NSNotificationCenter defaultCenter]postNotificationName:DeviceDisconnect object:nil userInfo:disConnectedMac];
    }
    if(flag == FALSE && [savedKeyArray count]){
        flag = TRUE;
        //[[NSNotificationCenter defaultCenter]postNotificationName:@"IFindScaleAgain" object:nil userInfo:disConnectedMac];
    }
    if([savedKeyArray count]){
        flag = TRUE;
    }
    if([SCScaleInfoDic count]){
        [SCScaleInfoDic removeAllObjects];
    }
    
    uint8_t buf[6]={0xB0,0x04,0x00,0x00,0xFF,0xD0};
    uint8_t check=0x00;
    check=[self check:&buf[0]];
    uint8_t buf1[7]={0xB0,0x04,0x00,0x00,0xFF,0xD0,check};
    int i;
    i=[self sendData:[NSData dataWithBytes:&buf1 length:7] IP:@"255.255.255.255"];
//    i=[self sendData:[NSData dataWithBytes:&buf1 length:7] IP:@"192.168.0.100"];

    if (i<0) {
        NSLog(@"send scan fail");
    }
}

-(void)clearDisconnectScale:(NSString *)mac{
    if([[SCSavedScaleInfoDic allKeys]containsObject:mac]){
        [SCSavedScaleInfoDic removeObjectForKey:mac];
    }
}

-(NSMutableDictionary*)getScaleSavedAllInformation{
    return SCSavedScaleInfoDic;
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)socket didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    [SCLXUdpSocket receiveWithTimeout:-1 tag:0];

    if (![host isEqualToString:@"255.255.255.255"]) {
        uint8_t head;
        [data getBytes:&head range:NSMakeRange(0, 1)];
        if (head==0XA0) {
            int bufCount=[data length];
            uint8_t buf[512];
            [data getBytes:&buf[0] range:NSMakeRange(0,bufCount)];
            uint8_t check;
            check=[self check:&buf[0]];
            if (buf[bufCount-1]==check) {
                uint8_t command;
                [data getBytes:&command range:NSMakeRange(5, 1)];
                if (command==0XF0) {
                    
                    //协议版本
                    uint8_t protocalVersionBuf[16];
                    [data getBytes:&protocalVersionBuf[0] range:NSMakeRange(6, 16)];
                    NSString *protocalVersion=[[NSString alloc]initWithBytes:&protocalVersionBuf[0] length:16 encoding:NSUTF8StringEncoding];
//                    NSLog(@"protocalVersion:%@",protocalVersion);
                    //附件署名
                    uint8_t accesoryNameBuf[16];
                    [data getBytes:&accesoryNameBuf[0] range:NSMakeRange(22, 16)];
//                    NSString *accesoryName=[[NSString alloc]initWithBytes:&accesoryNameBuf[0] length:16 encoding:NSUTF8StringEncoding];
//                    NSLog(@"accesoryName:%@",accesoryName);
                    //附件固件版本
                    uint8_t accesoryVersionBuf[3];
                    [data getBytes:&accesoryVersionBuf[0] range:NSMakeRange(38, 3)];
                    NSString *accesoryVersion=[[NSString alloc]initWithFormat:@"%c.%c.%c",accesoryVersionBuf[0],accesoryVersionBuf[1],accesoryVersionBuf[2]];
//                    NSString *accesoryVersion=[[NSString alloc]initWithBytes:&accesoryVersionBuf[0] length:3 encoding:NSUTF8StringEncoding];
//                    NSLog(@"accesoryVersion:%@",accesoryVersion);
                    //附件硬件版本
                    uint8_t accesoryHardwareVersionBuf[3];
                    [data getBytes:&accesoryHardwareVersionBuf[0] range:NSMakeRange(41, 3)];
                    NSString *accesoryHardwareVersion=[[NSString alloc]initWithFormat:@"%c.%c.%c",accesoryHardwareVersionBuf[0],accesoryHardwareVersionBuf[1],accesoryHardwareVersionBuf[2]];
//                    NSString *accesoryHardwareVersion=[[NSString alloc]initWithBytes:&accesoryHardwareVersionBuf[0] length:3 encoding:NSUTF8StringEncoding];
//                    NSLog(@"accesoryHardwareVersion:%@",accesoryHardwareVersion);
                    //附件生产商
                    uint8_t accesoryCompanyBuf[16];
                    [data getBytes:&accesoryCompanyBuf[0] range:NSMakeRange(44, 16)];
                    NSString *accesoryCompany=[[NSString alloc]initWithBytes:&accesoryCompanyBuf[0] length:16 encoding:NSUTF8StringEncoding];
//                    NSLog(@"accesoryCompany:%@",accesoryCompany);
                    //附件型号
                    uint8_t accesorytypeBuf[16];
                    [data getBytes:&accesorytypeBuf[0] range:NSMakeRange(60, 16)];
                    NSString *accesorytype=[[NSString alloc]initWithBytes:&accesorytypeBuf[0] length:16 encoding:NSUTF8StringEncoding];
//                    NSLog(@"accesorytype:%@",accesorytype);
                    //附件序列号
                    uint8_t accesorySeriousBuf[16];
                    [data getBytes:&accesorySeriousBuf[0] range:NSMakeRange(76, 16)];
                    NSString *accesorySerious=[[NSString alloc]initWithBytes:&accesorySeriousBuf[0] length:12 encoding:NSUTF8StringEncoding];
//                    NSLog(@"accesorySerious:%@",accesorySerious);
                    //秤名字
                    uint8_t scaleName[32];
                    [data getBytes:&scaleName[0] range:NSMakeRange(92, 32)];
                    NSString *scaleNamestr=[[NSString alloc]initWithBytes:&scaleName[0] length:32 encoding:NSUTF8StringEncoding];
//                    NSLog(@"scaleName:%@",scaleNamestr);
                    //IP
                    uint8_t IPBuf[4];
                    [data getBytes:&IPBuf range:NSMakeRange(92+32, 4)];
                    NSString *IPStr=[[NSString alloc] initWithFormat:@"%d.%d.%d.%d",IPBuf[0],IPBuf[1],IPBuf[2],IPBuf[3]];
                    //MAC
                    uint8_t macbuf[6];
                    [data getBytes:&macbuf[0] range:NSMakeRange(96+32, 6)];
                    NSString *macStr=[[NSString alloc] initWithFormat:@"%02X%02X%02X%02X%02X%02X",macbuf[0],macbuf[1],macbuf[2],macbuf[3],macbuf[4],macbuf[5]];
                    if (scaleNamestr==nil) {
                        scaleNamestr=@"ffffffff";
                    }
                    NSMutableDictionary *scaleInfo  = [[NSMutableDictionary alloc]initWithObjectsAndKeys:protocalVersion,IDPS_ProtocolString,HS5_NAME,IDPS_Name,accesoryVersion,IDPS_FirmwareVersion,accesoryHardwareVersion,IDPS_HardwareVersion,accesoryCompany,IDPS_Manufacture,accesorytype,IDPS_ModelNumber,accesorySerious,IDPS_SerialNumber,scaleNamestr,@"ScaleName",IPStr,@"IP",@"5",@"Number",macStr,IDPS_ID,nil];

                    [SCScaleInfoDic setObject:scaleInfo forKey:macStr];
                    
                    [SCSavedScaleInfoDic setObject:scaleInfo forKey:macStr];
                    
                    [SCLXMacAndIPDic setObject:IPStr forKey:macStr];
                 
                    [[NSNotificationCenter defaultCenter]postNotificationName:DeviceOpenSession object:nil userInfo:scaleInfo];
#ifdef DLog
                    NSLog(@"find out scale:ip=%@",IPStr);
#endif
                }
                else
                {
                    uint8_t macbuf[6];
                    int macLoc=[data length]-7;
                    [data getBytes:&macbuf[0] range:NSMakeRange(macLoc, 6)];
                    NSString *macStr=[[NSString alloc] initWithFormat:@"%02X%02X%02X%02X%02X%02X",macbuf[0],macbuf[1],macbuf[2],macbuf[3],macbuf[4],macbuf[5]];
                    [self resetScaleNub:macStr];
                    [delegate receivedData:data From:macStr Protocol:HS5_Protocol];

                }
                return YES;
            }
            else
            {
                //校验和不过
                return NO;
            }
            
        }
        else
        {
            //头命令不对
            return NO;
        }
        
    }
    else
    {
        //收到广播
        return NO;

    }
}

//接收到hs5数据后，重置此台hs5的应用计数
-(void)resetScaleNub:(NSString *)macString{
    if([[SCSavedScaleInfoDic allKeys]containsObject:macString]){
        NSMutableDictionary *singleHS5Info = [SCSavedScaleInfoDic objectForKey:macString];
        [singleHS5Info setObject:@"5" forKey:@"Number"];
        [SCSavedScaleInfoDic setObject:singleHS5Info forKey:macString];
    }
}

-(uint8_t)check:(uint8_t *)cbuf//计算校验和
{
	uint8_t checkbuf=0x00;
	for (int i=2; i<cbuf[1]+2; i++) {
		checkbuf+=cbuf[i];
	}
	return checkbuf;
}
@end
