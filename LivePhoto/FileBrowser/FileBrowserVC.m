//
//  FIleBrowserVC.m
//  LivePhoto
//
//  Created by ugreen on 2021/11/25.
//
#import <Photos/Photos.h>
#import "FileBrowserVC.h"
#import "FileManager.h"
#import "WebVC.h"

#import "PreviewVC.h"

@interface FileBrowserVC ()

@end

@implementation FileBrowserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self updateData];
    
    self.tableView.refreshControl = ({
        UIRefreshControl *refresh = [UIRefreshControl new];
        [[refresh rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(__kindof UIRefreshControl * _Nullable x) {
            [self updateData];
            [x endRefreshing];
        }];
        refresh;
    });
    
    
    
}

- (void)updateData {
    if (self.node == nil) {// 根目录
        NSURL *rootURL = [NSURL fileURLWithPath:NSHomeDirectory()];
        self.node = [[TreeNode alloc] initWithFileURL:rootURL];
    }else {
        TreeNode *node = [[TreeNode alloc] initWithFileURL:self.node.fileURL];
        [node setValue:self.node.parentNode forKey:@"parentNode"];
        self.node = node;
    }
    
    if ([self.node.fileURL.path isEqualToString:NSHomeDirectory()]) {
        self.navigationItem.title = @"沙盒根目录";
    }else {
        self.navigationItem.title = self.node.name;
    }
    
    [self.tableView reloadData];
    
//   UIBarButtonItem *uploadItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"square.and.arrow.up"] style:UIBarButtonItemStylePlain target:self action:@selector(shareOut)];
//    UIBarButtonItem *removeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(removeALL)];
//    self.navigationItem.rightBarButtonItems = @[uploadItem,removeItem];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.node.childNodes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    TreeNode *node = self.node.childNodes[indexPath.row];
    cell.imageView.image = [UIImage systemImageNamed:node.iconName];
    cell.textLabel.text = node.name;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    TreeNode *node = self.node.childNodes[indexPath.row];
    if (node.isLeaf) {
        self.hidesBottomBarWhenPushed = YES;
        PreviewVC *preview = [[PreviewVC alloc] initWithNode:node];
        [self.navigationController pushViewController:preview animated:YES];
        return;
    }

    if (!node.childNodes) {
        [Toast showToast:@"没有查看权限"];
        return;
    }

    FileBrowserVC *fileBrowser = [self.storyboard instantiateViewControllerWithIdentifier:@"FileBrowserVC"];
    fileBrowser.node = node;
    [self.navigationController pushViewController:fileBrowser animated:YES];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    TreeNode *node = self.node.childNodes[indexPath.row];
    UIContextualAction * deleteAction =  [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        BOOL res = [FileManager removeAtPath:node.fileURL.path];
        NSString *toast = res ? @"删除成功" : @"删除失败：无权限";
        if (res) {
            [self updateData];
        }
        [Toast showToast:toast];
        //执行操作
        completionHandler(YES);
    }];
    
    UIContextualAction * saveAction =  [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"保存" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [self saveActionWithNode:node];
        //执行操作
        completionHandler(YES);
    }];
    return [UISwipeActionsConfiguration configurationWithActions:@[
        deleteAction,
        saveAction
    ]];
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    TreeNode *node = self.node.childNodes[indexPath.row];
    return node.canWrite;
}

- (void)saveActionWithNode:(TreeNode *)node {
    NSURL *fileURL = node.fileURL;
    NSString *message = (node.fileType == FILETYPE_LIVE || node.fileType == FILETYPE_IMG) ? @"图片(含live)分享到其他平台时自动转换为兼容格式" :  nil;
    if (node.fileType == FILETYPE_LIVE) {
     fileURL = node.liveResource.firstObject;
       UIImage *image =  [UIImage imageWithContentsOfFile:fileURL.path];
       NSData *jpgData = UIImageJPEGRepresentation(image,0.8);
       NSString *fileName = [[node.name stringByDeletingPathExtension] stringByAppendingPathExtension:@"jpg"];
        NSString *filePath = [[FileManager tempFolder] stringByAppendingFormat:@"/%@/%@",node.fileURL.lastPathComponent,fileName];
        [FileManager createFolderIfNeededWithFolderPath:FileManager.tempFolder];
        fileURL = [NSURL fileURLWithPath:filePath];
        [jpgData writeToURL:fileURL atomically:YES];
    }
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleActionSheet];
    if ([self.node.name isEqualToString:@"Temp"]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"合成live到相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [Toast showLoadingOnView:nil];
            // 如果使用原来的资源，提示成功了，但是应该只是原来资源的副本，创建日期是没有变化的,看了看阿里云也是如此。
            [PHPhotoLibrary.sharedPhotoLibrary performChanges:^{
                PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
                PHAssetResourceCreationOptions *options = [PHAssetResourceCreationOptions new];
                for (TreeNode *subNode in node.childNodes) {
                    PHAssetResourceType type = subNode.fileType == FILETYPE_VIDEO ? PHAssetResourceTypePairedVideo : PHAssetResourceTypePhoto;
                    [request addResourceWithType:type fileURL:subNode.fileURL options:options];
                }
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                [Toast hideLoadingOnView:nil];
                if (success) {
                    [Toast showToast:@"保存成功"];
                    return;
                }
                if (error) {
                    NSLog(@"error:%@",error);
                    [Toast showToast:@"保存失败"];
                }
            }];
        }]];
    }
    
    
    if (node.fileType == FILETYPE_LIVE) {
        [alert addAction:[UIAlertAction actionWithTitle:@"存储为原生live到相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [Toast showLoadingOnView:nil];
            // 如果使用原来的资源，提示成功了，但是应该只是原来资源的副本，创建日期是没有变化的,看了看阿里云也是如此。
            [PHPhotoLibrary.sharedPhotoLibrary performChanges:^{
                PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
                PHAssetResourceCreationOptions *options = [PHAssetResourceCreationOptions new];
                for (NSURL *fileURL in node.liveResource) {
                    if ([fileURL.pathExtension.uppercaseString isEqualToString:@"MOV"]) {
                        [request addResourceWithType:PHAssetResourceTypePairedVideo fileURL:fileURL options:options];
                    }else {
                        [request addResourceWithType:PHAssetResourceTypePhoto fileURL:fileURL options:options];
                    }
                }
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                [Toast hideLoadingOnView:nil];
                if (success) {
                    [Toast showToast:@"保存成功"];
                    return;
                }
                if (error) {
                    NSLog(@"error:%@",error);
                    [Toast showToast:@"保存失败"];
                }
            }];
        }]];
    }
    
    if (node.fileType == FILETYPE_LIVE || node.fileType == FILETYPE_IMG) {
        [alert addAction:[UIAlertAction actionWithTitle:@"存储为兼容格式JPG到相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [Toast showLoadingOnView:nil];
            [PHPhotoLibrary.sharedPhotoLibrary performChanges:^{
                PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
                [request addResourceWithType:PHAssetResourceTypePhoto fileURL:fileURL options:nil];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                [Toast hideLoadingOnView:nil];
                if (success) {
                    [Toast showToast:@"保存成功"];
                    return;
                }
                if (error) {
                    [Toast showToast:error.localizedDescription];
                }
            }];
        }]];
    }
    
    if (node.fileType == FILETYPE_VIDEO) {
        [alert addAction:[UIAlertAction actionWithTitle:@"存储视频到相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [Toast showLoadingOnView:nil];
            [PHPhotoLibrary.sharedPhotoLibrary performChanges:^{
                PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
                [request addResourceWithType:PHAssetResourceTypeVideo fileURL:fileURL options:nil];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                [Toast hideLoadingOnView:nil];
                if (success) {
                    [Toast showToast:@"保存成功"];
                    return;
                }
                if (error) {
                    [Toast showToast:error.localizedDescription];
                }
            }];
        }]];
    }
    
 
    
    
    [alert addAction:[UIAlertAction actionWithTitle:@"分享到其他应用" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
       
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

@end
