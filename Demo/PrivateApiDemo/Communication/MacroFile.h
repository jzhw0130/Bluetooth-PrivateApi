//
//  MacroFile.h
//  testShareCommunication
//
//  Created by zhiwei jing on 13-10-20.
//  Copyright (c) 2013年 my. All rights reserved.
//

#ifndef testShareCommunication_MacroFile_h
#define testShareCommunication_MacroFile_h

#define DeviceConnect         @"DeviceConnect"
#define DeviceDisconnect      @"DeviceDisconnect"
#define DeviceAuthenSuccess   @"DeviceAuthenSuccess"
#define DeviceOpenSession     @"DeviceOpenSession"
#define DeviceTimeOut         @"DeviceTimeOut"


#define IDPS_FirmwareVersion       @"FirmwareVersion"
#define IDPS_BTFirmwareVersion     @"BTFirmwareVersion"
#define IDPS_HardwareVersion       @"HardwareVersion"
#define IDPS_Manufacture           @"Manufacture"
#define IDPS_ModelNumber           @"ModelNumber"
#define IDPS_Name                  @"DeviceName"
#define IDPS_ProtocolString        @"ProtocolString"
#define IDPS_SerialNumber          @"SerialNumber"
#define IDPS_ID                    @"ID"
#define IDPS_Type                  @"Type"
#define IDPS_AccessoryName         @"AccessoryName"

#define IDPS_Data                  @"Data"
#define DeviceTimeOutCommand       @"DeviceTimeOutCommand"
#define BTPowerOff                 @"BTLEPowerOff"


#define AM3_SERVICE_UUID_24 @"180D"
#define AM3_CHRASTERISTIC_REC_UUID_24 @"2A37"
#define AM3_CHRASTERISTIC_SEND_UUID_24 @"2A39"

#define AM3_SERVICE_UUID @"636F6D2E-6A69-7561-6E2E-414D56313000"
#define AM3_CHRASTERISTIC_REC_UUID @"7365642E-6A69-7561-6E2E-414D56313000"
#define AM3_CHRASTERISTIC_SEND_UUID @"7265632E-6A69-7561-6E2E-414D56313000"

#define AM4_SERVICE_UUID @"636F6D2E-6A69-7561-6E2E-414D56313200"
#define AM4_CHRASTERISTIC_REC_UUID @"7365642E-6A69-7561-6E2E-414D56313200"
#define AM4_CHRASTERISTIC_SEND_UUID @"7265632E-6A69-7561-6E2E-414D56313200"

#define BG5L_SERVICE_UUID @"0xFF80"
#define BG5L_CHRASTERISTIC_REC_UUID @"0xFF81"
#define BG5L_CHRASTERISTIC_SEND_UUID @"0xFF81"

#define KS3_SERVICE_UUID @"636F6D2E-6A69-7561-6E2E-534356313000"
#define KS3_CHRASTERISTIC_REC_UUID @"7274782E-6A69-7561-6E2E-534356313000"
#define KS3_CHRASTERISTIC_SEND_UUID @"7274782E-6A69-7561-6E2E-534356313000"

#define HS4_SERVICE_UUID_24 @"FF60"
#define HS4_CHRASTERISTIC_REC_UUID_24 @"FF61"
#define HS4_CHRASTERISTIC_SEND_UUID_24 @"FF61"

#define HS4_SERVICE_UUID @"636F6D2E-6A69-7561-6E2E-425753563031"
#define HS4_CHRASTERISTIC_REC_UUID @"7274782E-6A69-7561-6E2E-425753563031"
#define HS4_CHRASTERISTIC_SEND_UUID @"7274782E-6A69-7561-6E2E-425753563031"

#define Temper_SERVICE_UUID @"4789"
#define Temper_CHRASTERISTIC_REC_UUID @"FF51"
#define Temper_CHRASTERISTIC_SEND_UUID @"FF51"

#define PO3_SERVICE_UUID @"FF70"
#define PO3_CHRASTERISTIC_REC_UUID @"FF71"
#define PO3_CHRASTERISTIC_SEND_UUID @"FF71"

#define PO3_SERVICE_UUID_128 @"636F6D2E-6A69-7561-6E2E-504F56313100"
#define PO3_CHRASTERISTIC_REC_UUID_128 @"7274782E-6A69-7561-6E2E-504F56313100"
#define PO3_CHRASTERISTIC_SEND_UUID_128 @"7274782E-6A69-7561-6E2E-504F56313100"

#define ECG_SERVICE_UUID @"636F6D2E-6A69-7561-6E2E-454347563130"
#define ECG_CHRASTERISTIC_REC_UUID @"7274782E-6A69-7561-6E2E-454347563130"
#define ECG_CHRASTERISTIC_SEND_UUID @"7274782E-6A69-7561-6E2E-454347563130"

/* 需要改动*/

#define PO7_SERVICE_UUID @"FF70"
#define PO7_CHRASTERISTIC_REC_UUID @"FF71"
#define PO7_CHRASTERISTIC_SEND_UUID @"FF71"

#define AM3S_SERVICE_UUID @"636F6D2E-6A69-7561-6E2E-414D56313100"
#define AM3S_CHRASTERISTIC_REC_UUID @"7365642E-6A69-7561-6E2E-414D56313100"
#define AM3S_CHRASTERISTIC_SEND_UUID @"7265632E-6A69-7561-6E2E-414D56313100"

#define BP3L_SERVICE_UUID @"636F6D2E-6A69-7561-6E2E-425056323400"
#define BP3L_CHRASTERISTIC_REC_UUID  @"7365642E-6A69-7561-6E2E-425056323400"
#define BP3L_CHRASTERISTIC_SEND_UUID @"7265632E-6A69-7561-6E2E-425056323400"


#define BP3_NAME @"BP3"
#define BP5_NAME @"BP5"
#define BP7_NAME @"BP7"
#define HS3_NAME @"HS3"
#define HS5_NAME @"HS5"
#define BG3_NAME @"BG3"
#define BG5_NAME @"BG5"
#define ABI_NAME @"BPS"
#define BP3L_NAME @"BP3L"

#define AM4_NAME     @"AM4"
#define AM3_NAME     @"AM3"
#define BG5L_NAME    @"BG5L"
#define KS3_NAME     @"KS3"
#define HS4_NAME     @"HS4"
#define Temper_NAME  @"TP3"
#define PO3_NAME     @"PO3"
#define ECG_NAME     @"ECG"
#define PO7_NAME     @"PO7"
#define HS6_NAME     @"HS6"
#define AM3S_NAME    @"AM3S"
#define HS4S_NAME    @"HS4S"

//#define AM3_NAME_24_B @"Activity Monitor"
//#define AM3_NAME_B @"Activity Monitor"
//#define BG5L_NAME_B @"BG Monitor"
//#define KS3_NAME_B @"Kitchen Scale"
//#define HS4_NAME_B @"Body Scale"
//#define HS4_NAME_24_B @"Body Scale"
//#define Temper_NAME_B @"Temperature"
//#define PO3_NAME_B @"Pulse Oximeter"
//#define ECG_NAME_B @"CESECG Monitor"
//#define PO7_NAME_B @"Pulse Oximeter"
//#define AM3S_NAME_B @"AM3S"


typedef enum {
    BtleType_AM3 = 1,
    BtleType_HS4 = 2,
    BtleType_PO3 = 4,
    BtleType_ECG = 8,
    BtleType_Temp = 16,
    BtleType_BG5L = 32,
    BtleType_KS3 = 64,
    BtleType_PO7 = 128,
    BtleType_AM3S = 256,
    BtleType_AM4 = 512,
    BtleType_BP3L = 1024,
    
    BtleType_All = 2018,
    
}BtleType;

#define BG1_Protocol        @"com.jiuan.BGV10"
#define HS5_Protocol        @"com.jiuan.BFSV01"
#define BP3_Protocol        @"com.jiuan.P930"
#define HS3_Protocol        @"com.ihealth.sc221"
#define BP5_Protocol        @"com.jiuan.BPV20"
#define BP7_Protocol        @"com.jiuan.BPV20"
#define BG3_Protocol        @"com.jiuan.BGV30"
#define MG_Protocol         @"com.jiuan.MGV10"
#define BG5_Protocol        @"com.jiuan.BGV31"
#define PO3_Protocol        @"com.jiuan.POV11"
#define ECG_Protocol        @"com.jiuan.ECGV01"
#define AM3_Protocol        @"com.jiuan.AMV10"
#define AM4_Protocol        @"com.jiuan.AMV12"
#define BG5L_Protocol       @"com.jiuan.BGV32"
#define KS3_Protocol        @"com.jiuan.SCV10"
#define TE3_Protocol        @"com.jiuan.TemperV01"
#define HS4_Protocol        @"com.jiuan.BWSV01"
#define BSW_Protocol        @"com.jiuan.BSWV01"
#define PO7_Protocol        @"com.jiuan.POV20"
#define AM3S_Protocol       @"com.jiuan.AMV11"
#define BP5_Protocol2        @"com.jiuan.BPV23"
#define ABI_Protocol        @"com.jiuan.BPV21"
#define BP3L_Protocol       @"com.jiuan.BPV24"
#define AM4_Protocol        @"com.jiuan.AMV12"


#define HS5_ProductType        0xA9
#define BP3_ProductType        0XA1
#define HS3_ProductType        0XA6
#define BP5_ProductType        0XA1
#define BP7_ProductType        0XA1
#define BG3_ProductType        0XA2
#define MG_ProductType         0XAF
#define BG5_ProductType        0XA2
#define PO3_ProductType        0XAC
#define ECG_ProductType        0XAB
#define AM3_ProductType        0XAA
#define AM4_ProductType        0XAA
#define BG5L_ProductType       0XA2
#define KS3_ProductType        0XA7
#define TE3_ProductType        0XAE
#define HS4_ProductType        0XA6
#define PO7_ProductType        0XAC
#define AM3S_ProductType       0XAA
#define ABI_ProductType        0XA1
#define BP3L_ProductType       0XA1



#define OpenLight()      [UIApplication sharedApplication].idleTimerDisabled = YES
#define CloseLight()      [UIApplication sharedApplication].idleTimerDisabled = NO


typedef enum {
    DeviceUUIDType_BT = 1,
    DeviceUUIDType_BLE = 2,
    DeviceUUIDType_Wifi = 3,
}DeviceUUIDType;

#define CTLCodeString @"02323c64323c01006400fa00e103016800f000f0015e025814012c0000a0002800a003d100320046005a006e0082009600aa00b400e601040118012c01400168017c0190064d05f905a8055c051304cf048f047103e803a203790353033202fc02e702d71027383d4e6f646464646464646464640319010b07011ba6"

#define StripCodeString @"02323C64323C01006400FA00E1030168003C003C01F4025814015E3200A0005A00A0032000320046005A006E0082009600AA00B400E60104011801400168017C0190019A04C604A8048B04700456043E0428041D03E803E803E803B303A3039D0399039810273D464E6F646464646464646464640319010B07010DC5"


//** BG5
#define GOD_Blood_CodeString_BG5 @"02323C64323C01006400FA00E1030168003C003C01F4025814015E3200A0005A00A0032000320046005A006E0082009600AA00B400E60104011801400168017C0190019A04C604A8048B04700456043E0428041D03E803E803E803B303A3039D0399039810273D464E6F646464646464646464640319010B07010DC5"
#define GOD_CTL_CodeString_BG5 @"02323C64323C01006400FA00E103016800F000F001F4025814012C0000A0002800A003D100320046005A006E0082009600AA00B400E601040118012C01400168017C0190064D05F905A8055C051304CF048F047103E803A203790353033202FC02E702D71027383D4E6F646464646464646464640319010B07010653"

#define GDH_Blood_CodeString_BG5 @"02323C46323C01006400FA00E103016800F000F001F4025814015E3200A0002800A003D100320046005A006E0082009600AA00B400E60104011801400168017C0190019A04CA04B10497047D046304490430042303E203BB03A2036E033A0321030702FA0C27383D4E6F2E4D6577B6144E6B91FA03FF010B070104F7"
#define GDH_CTL_CodeString_BG5 @"02323C46323C01006400FA00E103016800F000F001F4025814015E3200A0002800A003D100320046005A006E0082009600AA00B400E601040118012C01400168017C01900584054F051C04EB04BC04900467045303E803C903AD0393037B0353034303350C27383D4E6F2E4D6577B6144E6B91FA03FF010B0701061C"
//** /





#define DiscoverDone  @"DiscoverDone"
#define DeviceConnectFailed      @"DeviceConnectFailed"




#endif
