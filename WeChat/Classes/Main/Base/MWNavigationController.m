//
//  MWNavigationController.m
//  WeChat
//
//  Created by caifeng on 16/10/8.
//  Copyright © 2016年 com.lingxian01. All rights reserved.
//

#import "MWNavigationController.h"
#import "MWProfilesViewController.h"

@interface MWNavigationController ()

@end

@implementation MWNavigationController

+ (void)initialize {

    [self setUpTheme];
}

+ (void)setUpTheme {

    UINavigationBar *navigationBar = [UINavigationBar appearance];
    [navigationBar setBackgroundImage:[UIImage imageNamed:@"topbarbg_ios7"] forBarMetrics:UIBarMetricsDefault];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    NSMutableDictionary *titleAttri = [NSMutableDictionary dictionary];
    titleAttri[NSFontAttributeName] = [UIFont systemFontOfSize:20];
    titleAttri[NSForegroundColorAttributeName] = [UIColor whiteColor];
    [navigationBar setTitleTextAttributes:titleAttri];
    
    
    [navigationBar setTintColor:[UIColor whiteColor]];
    
    NSMutableDictionary *itemAttri = [NSMutableDictionary dictionary];
    itemAttri[NSFontAttributeName] = [UIFont systemFontOfSize:15];
    itemAttri[NSForegroundColorAttributeName] = [UIColor whiteColor];
    UIBarButtonItem *barItem = [UIBarButtonItem appearance];
    [barItem setTitleTextAttributes:itemAttri forState:UIControlStateNormal];
    
}


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {

    viewController.hidesBottomBarWhenPushed = YES;
        
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    
    return [super popViewControllerAnimated:animated];
}


@end
