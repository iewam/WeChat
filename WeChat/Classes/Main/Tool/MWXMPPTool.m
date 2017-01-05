//
//  MWXMPPTool.m
//  WeChat
//
//  Created by caifeng on 16/10/5.
//  Copyright © 2016年 com.lingxian01. All rights reserved.
//

#import "MWXMPPTool.h"


@interface MWXMPPTool ()<XMPPStreamDelegate, XMPPvCardTempModuleDelegate>{

    XMPPResultBlock _resultBlock;/**<登陆结果回调block*/
    
}



@end

@implementation MWXMPPTool
singleton_implementation(MWXMPPTool)


#pragma mark - private

#pragma mark 创建xmppstream
- (void)setupXMPPStream {
    
    _xmppStream = [[XMPPStream alloc] init];
    
    // 开启电子名牌模块
    _vCardSrorage = [XMPPvCardCoreDataStorage sharedInstance];
    _vCardModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:_vCardSrorage];
    [_vCardModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [_vCardModule activate:_xmppStream];
    // 开启头像模块
    _vCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_vCardModule];
    [_vCardAvatarModule activate:_xmppStream];
    
    
    // 添加花名册模块
    _rosterStorage = [XMPPRosterCoreDataStorage sharedInstance];
    _roster = [[XMPPRoster alloc] initWithRosterStorage:_rosterStorage];
    [_roster activate:_xmppStream];
    
    // 添加消息模块
    _msgArchivingStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    _msgArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:_msgArchivingStorage];
    [_msgArchiving activate:_xmppStream];
    
    
#warning 代理中的操作都在子线程 如果需要更新UI要切换到主线程
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

#pragma mark 释放资源
- (void)teardownStream {
    //移除代理
    [_xmppStream removeDelegate:self];
    [_vCardModule removeDelegate:self];
    
    // 移除模块
    [_vCardModule deactivate];
    [_vCardAvatarModule deactivate];
    [_roster deactivate];
    [_msgArchiving deactivate];
    
    [_xmppStream disconnect];
    
    _vCardSrorage = nil;
    _vCardAvatarModule = nil;
    _vCardModule = nil;
    _xmppStream = nil;
    _roster = nil;
    _rosterStorage = nil;
    _msgArchiving = nil;
    _msgArchivingStorage = nil;
}


#pragma mark 连接服务器
- (void)connectToHost {
    
    if (!_xmppStream) {
        [self setupXMPPStream];
    }
    
    XMPPJID *myJID = nil;
    if (self.isRegisterOperation) {//注册
        
        NSString *registerUser = [MWAccount shareAccount].registerUser;
        myJID = [XMPPJID jidWithUser:registerUser domain:domain resource:@"iphone"];
    } else {// 登陆
    
        NSString *loginUser = [[NSUserDefaults standardUserDefaults] objectForKey:mXMPPJIDKey];
        myJID = [XMPPJID jidWithUser:loginUser domain:domain resource:@"iphone"];
    }
    
    _xmppStream.myJID = myJID;
    _xmppStream.hostName = host;
    _xmppStream.hostPort = port;
    
    NSError *error = nil;
    [_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    if (error) {
        MWLog(@"连接失败%@", error);
    } else {
        MWLog(@"发起连接成功");
    }
}


#pragma mark 向服务器发送密码
- (void)sendPwdToHost {
    
    NSError *error = nil;
    
    NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:mXMPPPwdKey];
    
    [_xmppStream authenticateWithPassword:pwd error:&error];
    if (error) {
        MWLog(@"密码错误%@",error);
    }
}


#pragma mark 向服务器发送上线指令
- (void)sendOnline {
    
    XMPPPresence *presence = [XMPPPresence presence];
    [_xmppStream sendElement:presence];
}

#pragma mark 向服务器发送离线指令
- (void)sendOffline {
    
    XMPPPresence *offline = [XMPPPresence presenceWithType:@"unavilable"];
    [_xmppStream sendElement:offline];
    
    // 改变用户的登陆状态
    [MWAccount shareAccount].login = NO;
    [[MWAccount shareAccount] saveToSandBox];
}


#pragma mark - XMPPStreamDelegate

#pragma mark  连接成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    
    if (self.isRegisterOperation) {
        
        NSString *registerPwd = [MWAccount shareAccount].registerPwd;
        NSError *error = nil;
        [_xmppStream registerWithPassword:registerPwd error:&error];
        
        if (error) {
            MWLog(@"注册失败%@", error);
        }
        
    } else {
    
        [self sendPwdToHost];
    }
}


#pragma mark  登陆成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    MWLog(@"登陆成功");
    //登陆成功block回调
    if (_resultBlock) {
        _resultBlock(mXMPPLoginResultTypeSuccess);
        
        _resultBlock = nil;// 清空block解决循环引用问题 （系统block实现的方法）
    }
    
    [self sendOnline];
}

#pragma mark 登陆失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    MWLog(@"登陆失败%@", error);
    //登陆失败block回调
    if (_resultBlock) {
        _resultBlock(mXMPPLoginResultTypeFailure);
    }
}

#pragma mark 注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    MWLog(@"注册成功");
    
    if (_resultBlock) {
        _resultBlock(mXMPPRegisterResultTypeSuccess);
    }
}

#pragma mark 注册失败
-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error {
    MWLog(@"注册失败%@", error);
    if (_resultBlock) {
        _resultBlock(mXMPPRegisterResultTypeFailure);
    }
}


- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule {

    MWLog(@"更新成功");
}

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToUpdateMyvCard:(NSXMLElement *)error {

    MWLog(@"%@", error);
}

#pragma mark - Public methods
#pragma mark 登陆服务器
- (void)xmppLoginWithResultBlock:(XMPPResultBlock)resultBlock {
    
    // 断开连接
    [_xmppStream disconnect];
    
    _resultBlock = resultBlock;
    
    [self connectToHost];
}

#pragma mark 注销
- (void)xmppLogout {
    
    [self sendOffline];
    [_xmppStream disconnect];
}

#pragma mark 注册
- (void)xmppRegisterWithResultBlock:(XMPPResultBlock)resultBlock {

    [_xmppStream disconnect];
    
    _resultBlock = resultBlock;
    
    [self connectToHost];
}



- (void)dealloc {

    [self teardownStream];
    
    MWLog(@"%@", [NSDate date]);
}


@end
