//
//  MWChatViewController.m
//  WeChat
//
//  Created by caifeng on 16/10/11.
//  Copyright © 2016年 com.lingxian01. All rights reserved.
//

#import "MWChatViewController.h"

@interface MWChatViewController ()<NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *resultContr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;/**<底部约束*/
@property (weak, nonatomic) IBOutlet UITextField *chatTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MWChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.friendJID.bare;

    [self obtainFriendMsgsFromSqlite];
    
    [self addKeyboardNotification];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self scrollToBottom];
    
}




#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultContr.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *chatCellID = @"CHAT_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:chatCellID];
    XMPPMessageArchiving_Message_CoreDataObject *msgObj = self.resultContr.fetchedObjects[indexPath.row];
    MWLog(@"%@", msgObj.message);
    /*   根据bodyType来区分消息的类型
     <message type="chat" to="zhangsan@mawei.local bodyType = @"image/text/sound/xls"">
     <body>for</body>
     <attachment>attachmentStr</attachment>
     </message>
     */
    XMPPMessage *msg = msgObj.message;
    NSString *bodyTypeStr = [msg attributeStringValueForName:@"bodyType"];
    if ([bodyTypeStr isEqualToString:@"image"]) {// 图片
        MWLog(@"image");
        
        for (XMPPElement *element in msg.children) {
            
            if ([[element name] isEqualToString:@"attachment"]) {
                
                NSString *base64Str = [element stringValue];// 获取节点内容
                NSData *imgData = [[NSData alloc] initWithBase64EncodedString:base64Str options:0];
                cell.imageView.image = [UIImage imageWithData:imgData];
            }
        }
    
        cell.textLabel.text = nil;
        
    } else if ([bodyTypeStr isEqualToString:@"sound"]) {// 声音
        MWLog(@"sound");
   
    } else {//文字
        MWLog(@"text");
        
        cell.textLabel.text = msgObj.body;
        
        cell.imageView.image = nil;
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return  cell;
}


#pragma mark - NSFetchedResultsControllerDelegate
#pragma mark **** 数据库内容改变调用
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {

    [self.tableView reloadData];
    
    // 让聊天表格滑动到底部
    [self scrollToBottom];
    
}



#pragma mark - UITextFieldDelegate

#pragma mark **** 发送文本数据
- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    // 发送文字消息
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJID];
    MWLog(@"%@", msg);
    
    [msg addBody:textField.text];
    [[MWXMPPTool sharedMWXMPPTool].xmppStream sendElement:msg];
    
    textField.text = nil;
    
    return  YES;
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {

    MWLog(@"%@", info);
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
//    NSData *imgData = UIImagePNGRepresentation(image);
    NSData *imgData = UIImageJPEGRepresentation(image, 0.01);
    [self sendAttachmentWithData:imgData bodyType:@"image"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Event Handles
#pragma mark **** 发送附件按钮点击
- (IBAction)sendAttachmentBtnClick:(id)sender {
    
    [self.view endEditing:NO];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    });
    
}


#pragma mark **** 滑动表格
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self.view endEditing:NO];
}

#pragma mark - Helper Methods

#pragma mark **** 发附件
- (void)sendAttachmentWithData:(NSData *)data bodyType:(NSString *)bodyType {

    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJID];
    
    [msg addBody:@"xxx"];// 必须有body
    
    //添加属性
    [msg addAttributeWithName:@"bodyType" stringValue:bodyType];
    
    NSString *base64Str = [data base64EncodedStringWithOptions:0];
    // 添加附件节点
    XMPPElement *attachment = [XMPPElement elementWithName:@"attachment" stringValue:base64Str];
    [msg addChild:attachment];
    
    [[MWXMPPTool sharedMWXMPPTool].xmppStream sendElement:msg];
    
}

#pragma mark **** 从数据库获取消息数据
- (void)obtainFriendMsgsFromSqlite {
    
    NSManagedObjectContext *context = [MWXMPPTool sharedMWXMPPTool].msgArchivingStorage.mainThreadManagedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    
    XMPPJID *loginUserJID = [MWXMPPTool sharedMWXMPPTool].xmppStream.myJID;
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ AND bareJidStr = %@", loginUserJID.bare, self.friendJID.bare];
    request.predicate = pre;
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[sort];
    
    
    _resultContr = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    _resultContr.delegate = self;
    NSError *error = nil;
    [_resultContr performFetch:&error];
    MWLog(@"%@", _resultContr.fetchedObjects);
    
    [self scrollToBottom];

}

#pragma mark **** 表格滚动到底部
- (void)scrollToBottom {
    
    if (self.resultContr.fetchedObjects.count == 0)  return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.resultContr.fetchedObjects.count -1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

#pragma mark **** 监听键盘
- (void)addKeyboardNotification {

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameDidChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)keyboardFrameDidChange:(NSNotification *)noti {
    MWLog(@"%@", noti);
    CGRect beginFrame = [noti.userInfo[@"UIKeyboardFrameBeginUserInfoKey"] CGRectValue];
    CGRect endFrame = [noti.userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    CGFloat changeY = beginFrame.origin.y - endFrame.origin.y;
    CGFloat duration = [noti.userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] floatValue];
    
    [UIView animateWithDuration:duration animations:^{
        _bottomConstraint.constant += changeY;
        [self.view layoutIfNeeded];// 改变的同时重新布局 解决view 和键盘间隙的出现
    }];
    
    [self scrollToBottom];
}


- (void)dealloc {

    MWLog(@"");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
