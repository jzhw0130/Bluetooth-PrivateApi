//
//  ViewController.m
//  PrivateApiDemo
//
//  Created by jingzhiwei on 29/9/17.
//  Copyright © 2017 jingzhiwei. All rights reserved.
//

#import "ViewController.h"
#import "BluetoothDevice.h"
#import "BluetoothManagerHandler.h"
#import "BasicCommunicationObject.h"

@interface ViewController ()
@property BluetoothDevice* currentDeivce;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [BasicCommunicationObject basicCommunicationObject];
    [BluetoothManagerHandler sharedInstance];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(noti:) name:@"BluetoothAvailabilityChangedNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(noti:) name:@"BluetoothPowerChangedNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(noti:) name:@"BluetoothDeviceDiscoveredNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(noti:) name:@"BluetoothDeviceConnectSuccessNotification" object:nil];
    //
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(noti:) name:@"ConnectionStatusChanged" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(noti:) name:@"DeviceDisconnectSuccess" object:nil];
    
    
    // global notification explorer
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(),
                                    NULL,
                                    MyCallBack,
                                    NULL,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    
}

// global notification callback
void MyCallBack (CFNotificationCenterRef center,
                 void *observer,
                 CFStringRef name,
                 const void *object,
                 CFDictionaryRef userInfo) {
    NSLog(@"CFN Name:%@ Data:%@", name, userInfo);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)scanPressed:(id)sender {
    NSLog(@"scanPressed");
    [[BluetoothManagerHandler sharedInstance]startScan];
}

- (IBAction)connectPressed:(id)sender {
    NSLog(@"connectPressed");
    if (_currentDeivce != nil) {
        [[BluetoothManagerHandler sharedInstance]connect:_currentDeivce];
    }
}
- (IBAction)stopScanPressed:(id)sender {
    [[BluetoothManagerHandler sharedInstance]stopScan];
}

- (void)noti: (NSNotification* )notification {
    NSLog(@"notification.info:%@", notification);
    if ([notification.name  isEqual: @"BluetoothDeviceDiscoveredNotification"]) {
        BluetoothDevice *tempDevice = notification.object;
        NSString* deviceName = tempDevice.name;
        if ([deviceName containsString:@"BP5"]) {
            _currentDeivce = tempDevice;
        }
        
    } else if ([notification.name  isEqual: @"BluetoothDeviceConnectSuccessNotification"]) {
        
    } else if ([notification.name  isEqual: @"BluetoothAvailabilityChangedNotification"]) {
        NSLog(@"start scan");
        [[BluetoothManagerHandler sharedInstance]startScan];
    }
    //
}


@end
