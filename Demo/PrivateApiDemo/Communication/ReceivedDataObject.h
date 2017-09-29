//
//  ReceivedDataObject.h
//  wifiModule
//
//  Created by liuxin on 11-12-27.
//  Copyright (c) 2011年 lxyeslxlx13@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandDelegate.h"

@interface ReceivedDataObject : NSObject
{
    id<CommandDelegate>delegate;
//    NSMutableData *bufData;
//    NSMutableArray *BufFromList;
    NSMutableDictionary *BufList;
    NSString *firmwareRevision;
    NSMutableDictionary *sendIndexDic;
}
//@property(nonatomic,retain)NSMutableData *bufData;
@property(nonatomic,strong)id<CommandDelegate>delegate;
-(id)init;
-(uint8_t)check:(NSData*)data;//计算校验和
-(void)addBufData:(NSData *)data From:(NSString *)IDOrMac;

-(NSMutableData *)cleanWrongData:(NSMutableData *)bufData;//清除缓存，确定缓存第一位为0xa0
-(int)findHead:(NSMutableData *)bufData;//寻找头文件中的命令长度
-(void)findRightCommandFrom:(NSString *)from Protocol:(NSString *)protocol;//寻找并返回命令
-(void)findRightCommandFrom:(NSString *)from Chracteristic:(NSString *)chracteristic Protocol:(NSString *)protocol;

@end
