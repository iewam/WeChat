//
//  MWProfilesViewController.m
//  WeChat
//
//  Created by caifeng on 16/10/8.
//  Copyright © 2016年 com.lingxian01. All rights reserved.
//

#import "MWProfilesViewController.h"
#import "XMPPvCardTemp.h"
#import "MWEditProfilesViewController.h"

@interface MWProfilesViewController ()<MWEditProfilesViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;/**<昵称*/
@property (weak, nonatomic) IBOutlet UILabel *weChatNumLabel;/**<微信号*/
@property (weak, nonatomic) IBOutlet UILabel *orgLabel;/**<公司*/
@property (weak, nonatomic) IBOutlet UILabel *departmentLabel;/**<部门*/
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;/**<职位*/
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;/**<电话*/
@property (weak, nonatomic) IBOutlet UILabel *emaillabel;/**<邮箱*/

@end

@implementation MWProfilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"个人信息";
    
    XMPPvCardTemp *vCardTemp = [MWXMPPTool sharedMWXMPPTool].vCardModule.myvCardTemp;
    if (vCardTemp.photo) {
        _avatarImageView.image = [UIImage imageWithData:vCardTemp.photo];
    }
    _nickNameLabel.text = vCardTemp.nickname;
    _weChatNumLabel.text = [MWAccount shareAccount].loginUser;
    _orgLabel.text = vCardTemp.orgName;
    _departmentLabel.text = vCardTemp.orgUnits[0];
    _titleLabel.text = vCardTemp.title;
    if (vCardTemp.telecomsAddresses.count > 0) {
        _phoneLabel.text = vCardTemp.telecomsAddresses[0];
    }
    if (vCardTemp.emailAddresses.count > 0) {
        
        _emaillabel.text = vCardTemp.emailAddresses[0];
    }
    

}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    switch (cell.tag) {
        case 1:
            MWLog(@"换头像");
            [self chooseAvatar];
            break;
        case 2:
            MWLog(@"进入下个界面");
            [self performSegueWithIdentifier:@"ToEditVCardSegue" sender:cell];
            
            break;
        case 3:
            MWLog(@"没有任何操作");
            
            break;
            
        default:
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.destinationViewController isKindOfClass:[MWEditProfilesViewController class]]) {
        MWEditProfilesViewController *editVC = segue.destinationViewController;
        editVC.navigationItem.hidesBackButton = YES;
        
        editVC.profilesCell = sender;
        editVC.delegate = self;
    }
}


#pragma mark - 更换头像
- (void)chooseAvatar {

    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"更换头像" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        MWLog(@"拍照");
    }];
    UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MWLog(@"相册");
        
        [self chooseVatarFromLibrary];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alertVC addAction:cameraAction];
    [alertVC addAction:libraryAction];
    [alertVC addAction:cancelAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark 从相册选择头像
- (void)chooseVatarFromLibrary {

    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    pickerController.allowsEditing = YES;
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:pickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {

    MWLog(@"%@", info);
    _avatarImageView.image = info[UIImagePickerControllerEditedImage];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self editProfilesViewControllerL:nil didFinishedSave:nil];
}



#pragma mark - MWEditProfilesViewControllerDelegate

- (void)editProfilesViewControllerL:(MWEditProfilesViewController *)editVC didFinishedSave:(id)sender {

    XMPPvCardTemp *vCardTemp = [MWXMPPTool sharedMWXMPPTool].vCardModule.myvCardTemp;
    
    vCardTemp.photo = UIImageJPEGRepresentation(_avatarImageView.image, 0.75);
    
    if (self.departmentLabel.text.length != 0) {
        
        vCardTemp.orgUnits = @[self.departmentLabel.text];
    }
    vCardTemp.title = _titleLabel.text;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[MWXMPPTool sharedMWXMPPTool].vCardModule updateMyvCardTemp:vCardTemp];
    });
}


- (void)dealloc {

    NSLog(@"%s", __func__);
}

@end
