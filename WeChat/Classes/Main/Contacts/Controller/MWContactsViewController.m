//
//  MWContactsViewController.m
//  WeChat
//
//  Created by caifeng on 16/10/11.
//  Copyright © 2016年 com.lingxian01. All rights reserved.
//

#import "MWContactsViewController.h"
#import "MWChatViewController.h"

@interface MWContactsViewController ()<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSArray *friends;/**<好友数据*/

@property (nonatomic, strong) NSFetchedResultsController *resultContr;/**<查询结果控制器*/

@end

@implementation MWContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self obtainFriendsDataFormSqlite1];
}



#pragma mark - UITabelVIewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return  self.resultContr.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellID = @"CONTACTS_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    XMPPUserCoreDataStorageObject *friend = self.resultContr.fetchedObjects[indexPath.row];
    
    // kvo
//    [friend addObserver:self forKeyPath:@"sectionNum" options:NSKeyValueObservingOptionNew context:nil];
    
    if (friend.photo) {
        cell.imageView.image = friend.photo;
    } else {
        [[MWXMPPTool sharedMWXMPPTool].vCardAvatarModule photoDataForJID:friend.jid];
    }
    
    
    cell.textLabel.text = friend.displayName;
    
    switch ([friend.sectionNum integerValue]) {
        case 0:
            cell.detailTextLabel.text = @"在线";
            break;
        case 1:
            cell.detailTextLabel.text = @"离开";
            break;
        case 2:
            cell.detailTextLabel.text = @"离线";
            break;
            
        default:
            break;
    }
   
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    XMPPUserCoreDataStorageObject *friend = self.resultContr.fetchedObjects[indexPath.row];

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[MWXMPPTool sharedMWXMPPTool].roster removeUser:friend.jid];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    XMPPUserCoreDataStorageObject *friend = self.resultContr.fetchedObjects[indexPath.row];

    [self performSegueWithIdentifier:@"toChat" sender:friend.jid];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    id targetVC = segue.destinationViewController;
    if ([targetVC isKindOfClass:[MWChatViewController class]]) {
        MWChatViewController *chatVC = targetVC;
        chatVC.friendJID = sender;
    }
    
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {

    [self.tableView reloadData];
}

#pragma mark - KVO监听
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
//
//    MWLog(@"%@", change);
//    [self.tableView reloadData];
//}


#pragma mark - Helper Methods

- (void)obtainFriendsDataFormSqlite1 {
    // 获取coredata 上下文
    NSManagedObjectContext *contect = [MWXMPPTool sharedMWXMPPTool].rosterStorage.mainThreadManagedObjectContext;
    
    // 创建查询对象
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    request.sortDescriptors = @[sort];
    
    // 过滤没有响应的好友
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"subscription !=%@", @"none"];
    request.predicate = predicate;
    
//    NSError *error = nil;
//    NSArray *friends = [contect executeFetchRequest:request error:&error];
    
    _resultContr = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:contect sectionNameKeyPath:nil cacheName:nil];
    _resultContr.delegate = self;
    NSError *error =  nil;
    [_resultContr performFetch:&error];
    
    MWLog(@"%@", _resultContr.fetchedObjects);
}

@end
