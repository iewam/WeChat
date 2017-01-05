//
//  MWLoginViewController.m
//  WeChat
//
//  Created by caifeng on 16/9/30.
//  Copyright © 2016年 com.lingxian01. All rights reserved.
//

#import "MWLoginViewController.h"
#import "AppDelegate.h"

@interface MWLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;

@end

@implementation MWLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}



#pragma mark - Event Methods

#pragma mark 登陆
- (IBAction)loginBtnClick:(id)sender {
    
    // 将用户名和密码存在偏好设置
    [MWAccount shareAccount].loginUser = self.userTextField.text;
    [MWAccount shareAccount].loginPwd = self.pwdTextField.text;
    [[MWAccount shareAccount] saveToSandBox];
    
    [MWXMPPTool sharedMWXMPPTool].registerOperation = NO;
    
    // 通过appdelegate的方法连接服务器
    [MBProgressHUD showMessage:@"Logining..."];
    
    [[MWXMPPTool sharedMWXMPPTool] xmppLoginWithResultBlock:^(mXMPPResultType loginResultType) {
        
        [self handleLoginResultWithLoginResultType:loginResultType];
    }];
}


#pragma mark - Help Methods

- (void)handleLoginResultWithLoginResultType:(mXMPPResultType)resultType {

    dispatch_async(dispatch_get_main_queue(), ^{// 回到主线程切换根控制器
        
        [MBProgressHUD hideHUD];
        [NSThread sleepForTimeInterval:2.0];

        if (resultType == mXMPPLoginResultTypeSuccess) {
            [MBProgressHUD showSuccess:@"Login Success"];
            // 保存用户信息
            [MWAccount shareAccount].login = YES;
            [[MWAccount shareAccount] saveToSandBox];
            
            // 登陆成功切换到主界面
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [self changeRootViewController];
            });
            
        } else if (resultType == mXMPPLoginResultTypeFailure) {
            NSLog(@"登陆失败");
            [MBProgressHUD showError:@"用户名或密码错误"];
        }
        
    });

}

#pragma mark 切换根控制器
- (void)changeRootViewController {

//    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
//    
//    [UIApplication sharedApplication].keyWindow.rootViewController = vc;

    [UIStoryboard showInitialVCWithName:@"Main"];
}


- (void)dealloc {

    NSLog(@"%s", __func__);
    
}

@end
