//
//  AppDelegate.m
//  WeChat
//
//  Created by caifeng on 16/9/30.
//  Copyright © 2016年 com.lingxian01. All rights reserved.
//

#import "AppDelegate.h"

#import "DDLog.h"
#import "DDTTYLogger.h"


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    
    if ([MWAccount shareAccount].isLogin) {
        NSLog(@"已经登陆了");
        UIViewController *rootVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
        self.window.rootViewController = rootVC;
        
        [[MWXMPPTool sharedMWXMPPTool] xmppLoginWithResultBlock:nil];
    }
    
    return YES;
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    MWLog(@"%@", [NSDate date]);
}

@end
