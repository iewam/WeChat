//
//  MWAddFriendViewController.m
//  WeChat
//
//  Created by caifeng on 16/10/11.
//  Copyright © 2016年 com.lingxian01. All rights reserved.
//

#import "MWAddFriendViewController.h"

extern NSString *domain;

@interface MWAddFriendViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;

@end

@implementation MWAddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"添加好友";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(add:)];
    
}


- (void)add:(id)sender {

    // 不能添加自己
    if ([_userNameTextField.text isEqualToString:[MWAccount shareAccount].loginUser]) {
        
        [self showMessage:@"不可以添加自己为好友"];
        return;
    }
    
    // 不可以添加已存在的好友
    XMPPJID *addUserJid = [XMPPJID jidWithUser:_userNameTextField.text domain:domain resource:nil];
    BOOL isExist = [[MWXMPPTool sharedMWXMPPTool].rosterStorage userExistsWithJID:addUserJid xmppStream:[MWXMPPTool sharedMWXMPPTool].xmppStream];
    if (isExist) {
        [self showMessage:@"好友已存在"];
        return;
    }
    
    // 添加好友
    [[MWXMPPTool sharedMWXMPPTool].roster subscribePresenceToUser:addUserJid];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showMessage:(NSString *)msg {

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alertView show];
}

@end
