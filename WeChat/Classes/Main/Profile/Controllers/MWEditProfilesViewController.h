//
//  MWEditProfilesViewController.h
//  WeChat
//
//  Created by caifeng on 16/10/9.
//  Copyright © 2016年 com.lingxian01. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MWEditProfilesViewController;
@protocol MWEditProfilesViewControllerDelegate <NSObject>

- (void)editProfilesViewControllerL:(MWEditProfilesViewController *)editVC didFinishedSave:(id)sender;

@end

@interface MWEditProfilesViewController : UITableViewController

@property (nonatomic, strong) UITableViewCell *profilesCell;

@property (nonatomic, weak) id <MWEditProfilesViewControllerDelegate> delegate;

@end
