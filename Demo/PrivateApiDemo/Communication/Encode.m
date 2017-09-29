//
//  Encode.m
//  XxteaTest
//
//  Created by apple on 12-6-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Encode.h"

@implementation Encode

-(uint8_t *)generateRandomNub:(NSInteger)nub{
    uint8_t * randomSerialNub = (uint8_t *)calloc(nub+1,sizeof(uint8_t));
    memset(randomSerialNub, 0, nub+1);
    for(int i=0; i<nub; i++){
        *(randomSerialNub+i) = arc4random()%254 + 1;
    }
    return randomSerialNub;
}

-(uint8_t *)encode:(uint8_t *)buffer withLength:(NSInteger)length andKey:(uint32_t *)key{
    uint32_t y, z, sum;
    unsigned p, rounds, e;
    int32_t lengthModify = length/4 + (length%4?1:0);
    uint32_t * outBuffer = (uint32_t *)calloc(lengthModify*4+1,sizeof(uint8_t));
    memset(outBuffer, 0, lengthModify*4+1);
    memcpy(outBuffer, buffer, length);
    
    if (lengthModify > 1) {         
        rounds = 6 + 52/lengthModify;
        sum = 0;
        z = outBuffer[lengthModify-1];
        do {
            sum += 0x9e3779b9;
            e = (sum >> 2) & 3;
            for (p=0; p<lengthModify-1; p++)
                y = outBuffer[p+1], z = outBuffer[p] += MX;
            y = outBuffer[0];
            z = outBuffer[lengthModify-1] += MX;
        } while (--rounds);
    }
    return (uint8_t *)outBuffer;
}

-(uint8_t *)decode:(uint8_t *)buffer withLength:(NSInteger)length andKey:(uint32_t *)key{
    uint32_t y, z, sum;
    unsigned p, rounds, e;
    int32_t lengthModify = length/4 + (length%4?1:0);
    
    uint32_t * outBuffer = (uint32_t *)calloc(lengthModify*4+1,sizeof(Byte));
    memset(outBuffer, 0, lengthModify*4+1);
    memcpy(outBuffer, buffer, length);
    if (lengthModify > 1) {  
        rounds = 6 + 52/lengthModify;
        sum = rounds*0x9e3779b9;
        y = outBuffer[0];
        do {
            e = (sum >> 2) & 3;
            for (p=lengthModify-1; p>0; p--)
                z = outBuffer[p-1], y = outBuffer[p] -= MX;
            z = outBuffer[lengthModify-1];
            y = outBuffer[0] -= MX;
        } while ((sum -= 0x9e3779b9) != 0);
    }
    return (uint8_t *)outBuffer;
}

-(uint8_t *)generateKey:(uint32_t *)km andCommProcol:(NSString *)commProcol{
    uint8_t *tempBuffer = (uint8_t *)calloc(17,sizeof(Byte));
    memset(tempBuffer, 48, 16);
    *(tempBuffer+16) = 0;
    if(commProcol.length){
        if(commProcol.length>16){
            NSRange rage = {0,16};
            commProcol = [commProcol substringWithRange:rage];
        }
        memcpy(tempBuffer, [commProcol cStringUsingEncoding:NSUTF8StringEncoding], commProcol.length);
        printf("%s\n",tempBuffer);
        uint8_t *outBuffer = [self encode:(uint8_t*)tempBuffer withLength:16 andKey:km];
        return (uint8_t *)outBuffer;
    }
    else{
        return nil;
    }
}
-(uint32_t*)uint8ConvertToUint32:(uint8_t*)key{
    uint32_t *tempBuffer = (uint32_t *)calloc(20,sizeof(Byte));
    memset(tempBuffer, 0, 20);
    for(int i=0,j=0; i<16; i=i+4){
        *(tempBuffer+j) = *(key+i) + (*(key+i+1))*256 + (*(key+i+2))*256*256 + (*(key+i+3))*256*256*256;
        j++;
    }
    return tempBuffer;
}

@end
