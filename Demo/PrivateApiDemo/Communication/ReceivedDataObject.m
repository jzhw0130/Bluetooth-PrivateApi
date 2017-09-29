//
//  ReceivedDataObject.m
//  wifiModule
//
//  Created by liuxin on 11-12-27.
//  Copyright (c) 2011年 lxyeslxlx13@163.com. All rights reserved.
//

#import "ReceivedDataObject.h"
#import "BasicCommunicationObject.h"


@implementation ReceivedDataObject
//@synthesize bufData;
@synthesize delegate;
-(id)init
{
    if (self=[super init]) {
//        bufData=[[NSMutableData alloc] init];
//        BufFromList=[[NSMutableArray alloc] init];
        BufList=[[NSMutableDictionary alloc] init];
        firmwareRevision = [[NSString alloc]init];
        sendIndexDic = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(uint8_t)check:(NSData*)data//计算校验和
{
	uint8_t checkbuf=0x00;
    int dataLen=[data length];
	for (int i=2; i<dataLen-1; i++) {
        uint8_t check=0x00;
		[data getBytes:(void *)&check range:NSMakeRange(i, 1)];
        checkbuf+=check;
	}
	return checkbuf;
}//计算校验和
-(NSMutableData *)cleanWrongData:(NSMutableData *)bufData
{
    uint8_t findhead[1];
    NSMutableData *data=[NSMutableData dataWithData:bufData];
    findhead[0]=0x00;
    [data getBytes:(void *)&findhead[0] range:NSMakeRange(0,1)];
    while ([data length]>1&&findhead[0]!=0xA0)
    {
        NSRange range2=NSMakeRange(0, 1);
        
        [data replaceBytesInRange:range2 withBytes:NULL length:0];
        [data getBytes:(void *)&findhead[0] range:NSMakeRange(0,1)];
    }
    return data;
}//清除缓存，确定缓存第一位为0xa0
-(int)findHead:(NSMutableData *)bufData
{
    uint8_t head[2];
    int len=0;
    if ([bufData length]>2) {
        [bufData getBytes:(void *)&head[0] range:NSMakeRange(0, 2)];
        len=head[1];
    }
    return len;
}//寻找头文件中的命令长度
-(void)addBufData:(NSData *)data From:(NSString *)IDOrMac
{
    NSArray *arrayFromList=[BufList allKeys];
    if ([arrayFromList indexOfObject:IDOrMac]!=NSNotFound) {
        NSMutableData *bufData=[BufList objectForKey:IDOrMac];
        [bufData appendData:data];
        [BufList setObject:bufData forKey:IDOrMac];
    }
    else
    {
        NSMutableData *mutableData=[NSMutableData dataWithData:data];
        [BufList setObject:mutableData forKey:IDOrMac];
        
    }
}
-(void)findRightCommandFrom:(NSString *)from Protocol:(NSString *)protocol
{
    NSMutableData *bufData=[BufList objectForKey:from];
    
    if (![protocol isEqualToString:BP3_Protocol]) {
        int len=0;
        bufData=[self cleanWrongData:bufData];//清除错误数据,直到发现0xA0
        len=[self findHead:bufData];//获得第一条命令的长度如果为空则返回0
        //NSLog(@"bufData:%@,bufdatalength:%i,len:%i",bufData,[bufData length],len);
        while ([bufData length]>=(len+3)&&len>=3)  
            //数据包长度要大于3，暂时不考虑mac地址的长度，如果长度为0说明无有效数据
        {
            uint8_t check[1];
            [bufData getBytes:&check[0] range:NSMakeRange(len+2, 1)];//取出校验和
            NSData *testCommand=[bufData subdataWithRange:NSMakeRange(0, len+3)];
            //取出测试命令，检验和是否正确
            
            if (check[0]==[self check:testCommand])
            {
                //如果校验和正确
                NSRange range=NSMakeRange(0, len+3);
                NSData *command=[bufData subdataWithRange:range];
                //取出正确命令
                [bufData replaceBytesInRange:range withBytes:NULL length:0];//删除已取出命令
                //剔除重复的命令
                if([protocol isEqualToString:BP5_Protocol]){
                    NSDictionary *idpsDic = [[BasicCommunicationObject basicCommunicationObject]getSelDeviceFrom:from];
                    if(idpsDic!=nil){
                        firmwareRevision = [idpsDic objectForKey:IDPS_FirmwareVersion];
                        if([firmwareRevision isEqualToString:@"2.1.0"] || [firmwareRevision isEqualToString:@"2.1.1"]){
                            NSRange commandRange = {5,1};
                            uint8_t commandStr;
                            [command getBytes:&commandStr range:commandRange];
                            if(commandStr == 0x36 || commandStr == 0x38 || commandStr == 0x3B){
                                [delegate runCommand:command From:from Protocol:protocol];//调用代理方法执行命令
                                
                            }
                            else{
                                NSRange indexRange = {3,1};
                                uint8_t index;
                                [command getBytes:&index range:indexRange];
                                
                                if([[sendIndexDic objectForKey:from]intValue] != index){
                                    [sendIndexDic setObject:[NSNumber numberWithInt:index] forKey:from];
                                    [delegate runCommand:command From:from Protocol:protocol];//调用代理方法执行命令
                                }
                                else{
                                    NSLog(@"1reCommand warning!");
                                }
                                
                            }
                            
                        }
                        else{
                            NSRange indexRange = {3,1};
                            uint8_t index;
                            [command getBytes:&index range:indexRange];
                            if([[sendIndexDic objectForKey:from]intValue] != index){
                                [sendIndexDic setObject:[NSNumber numberWithInt:index] forKey:from];
                                [delegate runCommand:command From:from Protocol:protocol];//调用代理方法执行命令
                            }
                            else{
#ifdef DLog
                                NSLog(@"2reCommand warning!");
#endif
                            }
                        }
                    }
                    else{
                        NSRange indexRange = {3,1};
                        uint8_t index;
                        [command getBytes:&index range:indexRange];
                        if([[sendIndexDic objectForKey:from]intValue] != index){
                            [sendIndexDic setObject:[NSNumber numberWithInt:index] forKey:from];
                            [delegate runCommand:command From:from Protocol:protocol];//调用代理方法执行命令
                        }
                        else{
#ifdef DLog
                            NSLog(@"3reCommand warning!");
#endif
                        }
                        
                    }
                }
                else if([protocol isEqualToString:HS3_Protocol]){
                    NSRange indexRange = {4,1};
                    uint8_t index;
                    uint8_t index1;
                    NSRange indexRange1 = {3,1};
                    [command getBytes:&index range:indexRange];
                    [command getBytes:&index1 range:indexRange1];
                    if([[sendIndexDic objectForKey:from]intValue] != index || index1==0x21){
                        
                        [sendIndexDic setObject:[NSNumber numberWithInt:index] forKey:from];
                        [delegate runCommand:command From:from Protocol:protocol];//调用代理方法执行命令
                    }
                    else{
                        NSLog(@"2reCommand warning!");
                        
                        uint8_t i,check = 0;
                        uint8_t sendSettedChannel[6] = { 0xb0, /*上位机发送*/
                            0x03,  /*数据长度*/
                            0xa6,  /*产品类型*/
                            0xff,  /*命令字*/
                        };

                        sendSettedChannel[4] = index;
                        //计算校验位并赋值。
                        for (i=2; i<5;i++) {
                            check += sendSettedChannel[i];
                        }
                        sendSettedChannel[5] = check;
                        NSMutableData *data = [NSMutableData data];
                        [data appendBytes:(void *)(&sendSettedChannel[0]) length:6*sizeof(char)];
                        [[BasicCommunicationObject basicCommunicationObject] sendData:data To:from Protocol:protocol IsNeedRespond:NO MakeSureStatueID:0x00 MakeSureIndex:0x00 isNotRespond:YES];
                        
                    }
                }
                else if([protocol isEqualToString:BG3_Protocol]){
                    NSRange commandRange = {5,1};
                    uint8_t commandStr;
                    NSRange indexRange = {3,1};
                    uint8_t index;
                    [command getBytes:&index range:indexRange];
                    [command getBytes:&commandStr range:commandRange];
                    if(commandStr == 0xfb || commandStr == 0xfd){
                        if([[sendIndexDic objectForKey:from]intValue] != index){
                            [sendIndexDic setObject:[NSNumber numberWithInt:index] forKey:from];                         
			    [delegate runCommand:command From:from Protocol:protocol];//调用代理方法执行命令
                        }
                        else{
                            NSLog(@"fb or fd recommand");
                        }
                    }
                    else{
                        [delegate runCommand:command From:from Protocol:protocol];//调用代理方法执行命令
                    }
                }
                else if([protocol isEqualToString:@"com.jiuan.BPV21"]){
                    NSRange commandRange = {5,1};
                    uint8_t commandStr;
                    NSRange indexRange = {3,1};
                    uint8_t index;
                    [command getBytes:&index range:indexRange];
                    [command getBytes:&commandStr range:commandRange];
                    if(commandStr == 0xfb || commandStr == 0xfd){
                        if([[sendIndexDic objectForKey:from]intValue] != index){
                            [sendIndexDic setObject:[NSNumber numberWithInt:index] forKey:from];                          [delegate runCommand:command From:from Protocol:protocol];//调用代理方法执行命令
                        }
                        else{
                            NSLog(@"fb or fd recommand");
                        }
                    }
                    else{
                        NSRange indexRange = {3,1};
                        uint8_t index;
                        [command getBytes:&index range:indexRange];
                        if([[sendIndexDic objectForKey:from]intValue] != index){
                            [sendIndexDic setObject:[NSNumber numberWithInt:index] forKey:from];                          
                            [delegate runCommand:command From:from Protocol:protocol];//调用代理方法执行命令
                        }
                        else{
                            NSLog(@"5reCommand warning!");
                        }
                    }
                }
                else if([protocol isEqualToString:HS5_Protocol]){
                    NSRange commandRange = {5,1};
                    uint8_t commandStr;
                    NSRange indexRange = {3,1};
                    uint8_t index;
                    [command getBytes:&index range:indexRange];
                    [command getBytes:&commandStr range:commandRange];
                    if(commandStr == 0xfb || commandStr == 0xfd){
                        [sendIndexDic setObject:[NSNumber numberWithInt:index] forKey:from];
                        [delegate runCommand:command From:from Protocol:protocol];//调用代理方法执行命令
                    }
                    else{
                        NSRange indexRange = {3,1};
                        uint8_t index;
                        [command getBytes:&index range:indexRange];
                        if([[sendIndexDic objectForKey:from]intValue] != index){
                            [sendIndexDic setObject:[NSNumber numberWithInt:index] forKey:from];
                            [delegate runCommand:command From:from Protocol:protocol];//调用代理方法执行命令
                        }
                        else{
                            if(commandStr == 0x34 || commandStr == 0x38){
                                NSMutableData *data = [NSMutableData data];
                                uint8_t sendCommand[2];
                                sendCommand[0]=0xA9;
                                sendCommand[1]=commandStr;
                                [data appendBytes:(void *)(&sendCommand[0]) length:sizeof(sendCommand)];
                                
                                [[BasicCommunicationObject basicCommunicationObject] sendData:data To:from Protocol:HS5_Protocol IsNeedRespond:NO MakeSureStatueID:0x00 MakeSureIndex:index isNotRespond:YES];
                            }
#ifdef DLog
                            NSLog(@"6reCommand warning!");
#endif
                        }
                    }
                }
                else{
                    
                    NSRange indexRange = {3,1};
                    uint8_t index;
                    [command getBytes:&index range:indexRange];
                    if([[sendIndexDic objectForKey:from]intValue] != index){
                        [sendIndexDic setObject:[NSNumber numberWithInt:index] forKey:from];
                        [delegate runCommand:command From:from Protocol:protocol];//调用代理方法执行命令
                    }
                    else{
                        #ifdef DLog
                        NSLog(@"3reCommand warning!");
                        #endif
                    }
                }
                
            }
            else
            {
                //如果校验和不通过
                [bufData replaceBytesInRange:NSMakeRange(0, 1) withBytes:NULL length:0];
                //删除错误命令第一个字节
                
            }
            if ([bufData length]>3) {
                bufData=[self cleanWrongData:bufData];
                //删除错误数据
                len=[self findHead:bufData];
                //获得命令长度
            }
            
            
        }
        if ([bufData length]==0) {
            [BufList removeObjectForKey:from];
            
        }
        else
        {
            [BufList setObject:bufData forKey:from];
            
        }
    }
    else
    {
        NSData *command=bufData;
        [delegate runCommand:command From:from Protocol:protocol];//调用代理方法执行命令
        
        [BufList removeObjectForKey:from];
        
    }
    
}

-(void)findRightCommandFrom:(NSString *)from Chracteristic:(NSString *)chracteristic Protocol:(NSString *)protocol{
    NSMutableData *bufData=[BufList objectForKey:from];
    
    int len=0;
    bufData=[self cleanWrongData:bufData];//清除错误数据,直到发现0xA0
    len=[self findHead:bufData];//获得第一条命令的长度如果为空则返回0
    while ([bufData length]>=(len+2)&&len>=2)
        //数据包长度要大于2，暂时不考虑mac地址的长度，如果长度为0说明无有效数据
    {
        uint8_t check[1];
        [bufData getBytes:&check[0] range:NSMakeRange(len+2, 1)];//取出校验和
        NSData *testCommand=[bufData subdataWithRange:NSMakeRange(0, len+3)];
        //取出测试命令，检验和是否正确
        if (check[0]==[self check:testCommand])
        {
            //如果校验和正确
            NSRange range=NSMakeRange(0, len+3);
            NSData *command=[bufData subdataWithRange:range];
            //取出正确命令
            [bufData replaceBytesInRange:range withBytes:NULL length:0];//删除已取出命令
            if(command.length<=5){
                //NSLog(@"_______received:%@",command);
            }
            else{
//                NSLog(@"received:%@",command);

            }
            [delegate runCommand:command From:from Chracteristic:chracteristic Protocol:protocol];//调用代理方法执行命令
        }
        else
        {
            //如果校验和不通过
            [bufData replaceBytesInRange:NSMakeRange(0, 1) withBytes:NULL length:0];
            //删除错误命令第一个字节
            
        }
        if ([bufData length]>3) {
            bufData=[self cleanWrongData:bufData];
            //删除错误数据
            len=[self findHead:bufData];
            //获得命令长度
        }
        
        
    }
    if ([bufData length]==0) {
        [BufList removeObjectForKey:from];
        
    }
    else
    {
        [BufList setObject:bufData forKey:from];
        
    }
}

@end
