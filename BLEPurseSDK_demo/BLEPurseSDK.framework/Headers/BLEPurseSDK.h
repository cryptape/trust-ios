//
//  BLEPurseSDK.h
//  BLEPurseSDK
//
//  Created by yang on 2018/10/12.
//  Copyright © 2018年 com.bluering. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BLEPurseSDK : NSObject
@property (nonatomic, assign) NSUInteger timeout;   //超时时间，默认25 * 10000（25秒）
+ (instancetype)shareInstance;


/**
 初始化SDK

 @param encKey ENC秘钥
 @param macKey MAC秘钥
 @param decKey DEC秘钥
 */
+ (void)initWithEncKey:(NSString*)encKey withMacKey:(NSString*)macKey withDecKey:(NSString*)decKey;

/**
 连接蓝牙
 
 @param manager CBCentralManager对象
 @param peripheral CBPeripheral对象
 @return 是否连接成功
 */
- (BOOL)connectPeripheral:(CBCentralManager *)manager withCBPeripheral:(CBPeripheral *)peripheral;

/**
 获取ID
 
 @return 蓝牙ID
 */
+(NSString *) getID;

/**
 解锁PIN

 @param pin PIN值
 @param puk puk值
 @return 是否修改成功
 */
+(NSInteger) unblockPIN:(NSString *)pin withPUK:(NSString *)puk;

/**
 校验PIN
 
 @param pin PIN值
 @return 是否校验通过
 */
+(NSInteger) verifyPIN:(NSString*)pin;

/**
 修改PIN
 
 @param newPIN PIN值
 @return 是否修改成功
 */
+(NSInteger) changePIN:(NSString*)newPIN;

/**
 生成秘钥
 
 @return 返回生成的密钥
 */
+(NSInteger) generateKey;

/**
 重置秘钥
 
 @return 是否重置成功
 */
+(NSInteger) resetKey;

/**
 导入秘钥
 
 @param privateKey 导入的密钥
 @return 是否导入成功
 */
+(NSInteger) importprivateKey:(NSString*)privateKey publicKey:(NSString *)publicKey;

/**
 读取公钥
 
 @return 返回公钥
 */
+(NSString*) getPublicKey;

/**
 数字签名
 
 @param hash 32字节的数据
 @return 数字签名
 */
+(NSString*)sign:(NSString*)hash;

/**
 关闭蓝牙钱包
 
 @return 返回0为成功，非0失败
 */
+ (NSInteger)closeBLEPurse;

@end
