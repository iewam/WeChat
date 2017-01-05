//
//  MWAccount.h
//  WeChat
//
//  Created by caifeng on 16/9/30.
//  Copyright © 2016年 com.lingxian01. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MWAccount : NSObject

// 登陆
@property (nonatomic, copy) NSString *loginUser;/**<用户名*/
@property (nonatomic, copy) NSString *loginPwd;/**<密码*/
@property (nonatomic, assign, getter=isLogin) BOOL login;/**<是否登陆*/

// 注册
@property (nonatomic, copy) NSString *registerUser;/**<注册用户名*/
@property (nonatomic, copy) NSString *registerPwd;/**<注册密码*/

+ (instancetype)shareAccount;

- (void)saveToSandBox;

@end
