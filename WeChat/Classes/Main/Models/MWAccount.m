//
//  MWAccount.m
//  WeChat
//
//  Created by caifeng on 16/9/30.
//  Copyright © 2016年 com.lingxian01. All rights reserved.
//

#import "MWAccount.h"

@implementation MWAccount

+ (instancetype)shareAccount {

    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {

    static MWAccount *account;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        account = [super allocWithZone:zone];
        
        // 获取沙盒个人账号信息
        account.loginUser = [[NSUserDefaults standardUserDefaults] objectForKey:mXMPPJIDKey];
        account.loginPwd = [[NSUserDefaults standardUserDefaults] objectForKey:mXMPPPwdKey];
        account.login = [[NSUserDefaults standardUserDefaults] boolForKey:mXMPPIsLoginKey];
        
    });
    return account;
}


- (void)saveToSandBox {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.loginUser forKey:mXMPPJIDKey];
    [defaults setObject:self.loginPwd forKey:mXMPPPwdKey];
    [defaults setBool:self.isLogin forKey:mXMPPIsLoginKey];
    [defaults synchronize];
}

@end
