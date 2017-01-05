//
//  MWXMPPTool.h
//  WeChat
//
//  Created by caifeng on 16/10/5.
//  Copyright © 2016年 com.lingxian01. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "XMPPFramework.h"


static NSString *domain = @"mawei.local"; /**<服务器域名*/
static NSString *host   = @"127.0.0.1";   /**<服务器IP*/
static int  port        = 5222;           /**<端口号*/

typedef enum {
    
    mXMPPLoginResultTypeSuccess,/**<登录成功*/
    mXMPPLoginResultTypeFailure, /**<登录失败*/
    mXMPPRegisterResultTypeSuccess,/**<注册成功*/
    mXMPPRegisterResultTypeFailure /**<注册失败*/
} mXMPPResultType;

typedef void (^XMPPResultBlock) (mXMPPResultType resultType);

@interface MWXMPPTool : NSObject
singleton_interface(MWXMPPTool)

@property (nonatomic, strong, readonly) XMPPStream *xmppStream; /**<与服务器交互的核心类*/
@property (nonatomic, strong, readonly) XMPPvCardTempModule *vCardModule;/**<电子名片模块*/
@property (nonatomic, strong, readonly) XMPPvCardCoreDataStorage *vCardSrorage; /**<点子名片存储*/
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *vCardAvatarModule; /**<点子名片头像模块*/
@property (nonatomic, strong, readonly) XMPPRoster *roster;/**<花名册模块*/
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *rosterStorage;/**<花名册存储*/
@property (nonatomic, strong, readonly) XMPPMessageArchiving *msgArchiving;/**<消息模块*/
@property (nonatomic, strong, readonly) XMPPMessageArchivingCoreDataStorage *msgArchivingStorage;/**<消息存储*/

@property (nonatomic, assign , getter=isRegisterOperation) BOOL registerOperation;/**<YES 注册操作， NO登陆操作*/

/**
 登录服务器
 
 @param resultBlock 登陆结果回调
 */
- (void)xmppLoginWithResultBlock:(XMPPResultBlock) resultBlock;


/**
 注销
 */
- (void)xmppLogout;

/**
 注册
 */
- (void)xmppRegisterWithResultBlock:(XMPPResultBlock) resultBlock;

@end
