//
//  MWMineViewController.m
//  WeChat
//
//  Created by caifeng on 16/10/1.
//  Copyright © 2016年 com.lingxian01. All rights reserved.
//

#import "MWMineViewController.h"
#import "AppDelegate.h"
#import "XMPPvCardTemp.h"

@interface MWMineViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *weChatNumLabel;

@end

@implementation MWMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 获取电子名片
    XMPPvCardTemp *vCardTemp = [MWXMPPTool sharedMWXMPPTool].vCardModule.myvCardTemp;
    if (vCardTemp.photo) {
        self.avatarImageView.image = [UIImage imageWithData:vCardTemp.photo];
    }
    
    self.weChatNumLabel.text = [@"微信号:" stringByAppendingString:[MWAccount shareAccount].loginUser];
    
}




- (IBAction)logoutBtnClick:(id)sender {
    
    [[MWXMPPTool sharedMWXMPPTool] xmppLogout];
    
    // 切换到登陆
    [UIStoryboard showInitialVCWithName:@"Login"];
}

@end
