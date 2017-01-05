//
//  MWEditProfilesViewController.m
//  WeChat
//
//  Created by caifeng on 16/10/9.
//  Copyright © 2016年 com.lingxian01. All rights reserved.
//

#import "MWEditProfilesViewController.h"

@interface MWEditProfilesViewController ()

@property (weak, nonatomic) IBOutlet UITextField *editTextField;

@end

@implementation MWEditProfilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    
    self.title = self.profilesCell.textLabel.text;
    self.editTextField.text = self.profilesCell.detailTextLabel.text;
    
}

- (void)save {

    if ([self.delegate respondsToSelector:@selector(editProfilesViewControllerL:didFinishedSave:)]) {
        [self.delegate editProfilesViewControllerL:self didFinishedSave:nil];
        
        self.profilesCell.detailTextLabel.text = self.editTextField.text;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)cancel {

    [self.navigationController popViewControllerAnimated:YES];
}

@end
