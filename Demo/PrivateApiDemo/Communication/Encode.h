//
//  Encode.h
//  XxteaTest
//
//  Created by apple on 12-6-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MX ((z>>5^y<<2) +(y>>3^z<<4))^((sum^y) + (key[(p&3)^e]^z));

@interface Encode : NSObject

-(uint8_t *)generateRandomNub:(NSInteger)nub;

-(uint8_t *)encode:(uint8_t *)buffer withLength:(NSInteger)length andKey:(uint32_t *)key;

-(uint8_t *)decode:(uint8_t *)buffer withLength:(NSInteger)length andKey:(uint32_t *)key;

-(uint8_t *)generateKey:(uint32_t *)km andCommProcol:(NSString *)commProcol;
-(uint32_t*)uint8ConvertToUint32:(uint8_t*)key;
@end
