//
//  FIleBrowserVC.h
//  LivePhoto
//
//  Created by ugreen on 2021/11/25.
//

#import <UIKit/UIKit.h>
#import "TreeNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface FileBrowserVC : UITableViewController
@property (nullable, nonatomic, strong) TreeNode *node;
@end

NS_ASSUME_NONNULL_END
