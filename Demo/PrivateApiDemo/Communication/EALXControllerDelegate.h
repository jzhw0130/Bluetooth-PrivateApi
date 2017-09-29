//
//  EALXControllerDelegate.h
//  3he1-936CommunicationModule
//
//  Created by liuxin on 12-6-13.
//  Copyright (c) 2012年 lxyeslxlx13@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EASessionController.h"
@protocol EALXControllerDelegate <NSObject>
-(void)receivedDataFromSession:(id)sessionController;
@end
