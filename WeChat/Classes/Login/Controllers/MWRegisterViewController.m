//
//  MWRegisterViewController.m
//  WeChat
//
//  Created by caifeng on 16/10/5.
//  Copyright © 2016年 com.lingxian01. All rights reserved.
//

#import "MWRegisterViewController.h"

@interface MWRegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *registerUserTextField;
@property (weak, nonatomic) IBOutlet UITextField *registerPwdTextField;

@end

@implementation MWRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}


- (IBAction)cancelBtnClick:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)registerBtnClick:(id)sender {
    
    [MWAccount shareAccount].registerUser = self.registerUserTextField.text;
    [MWAccount shareAccount].registerPwd = self.registerPwdTextField.text;
    
    [MWXMPPTool sharedMWXMPPTool].registerOperation = YES;
    
    [MBProgressHUD showMessage:@"registering..."];
    [[MWXMPPTool sharedMWXMPPTool] xmppRegisterWithResultBlock:^(mXMPPResultType resultType) {
        
        [self handleRegisterResultWithResultType:resultType];
    }];
    
}

- (void)handleRegisterResultWithResultType:(mXMPPResultType)resultType {

    dispatch_async(dispatch_get_main_queue(), ^{

        [MBProgressHUD hideHUD];
        
        if (resultType == mXMPPRegisterResultTypeSuccess) {
            NSLog(@"注册成功");
            [MBProgressHUD showSuccess:@"注册成功"];
            
        } else if (resultType == mXMPPRegisterResultTypeFailure){
            NSLog(@"注册失败");
            [MBProgressHUD showError:@"帐号或密码不正确"];
        }
    });
}



@end
