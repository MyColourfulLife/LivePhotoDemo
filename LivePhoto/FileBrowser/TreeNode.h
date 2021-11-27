//
//  TreeNode.h
//  LivePhoto
//
//  Created by ugreen on 2021/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FILETYPE) {
    FILETYPE_FOLDER,
    FILETYPE_IMG,
    FILETYPE_LIVE,
    FILETYPE_VIDEO,
    FILETYPE_OTHER,
};

@interface TreeNode : NSObject
- (instancetype)initWithFileURL:(NSURL *)fileURL;

@property(nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) NSString *iconName;
@property(nonatomic, readonly) NSURL *fileURL;
@property(nonatomic, readonly) FILETYPE fileType;
@property(nonatomic, readonly) BOOL canWrite;
@property(nonatomic, getter=isLeaf, readonly) BOOL leaf;
@property(nonatomic, nullable, readonly, copy) NSArray<TreeNode *> *childNodes;
@property(nonatomic, nullable, readonly, weak) TreeNode *parentNode;
// 仅支持live格式
@property(nonatomic, nullable, readonly) NSArray<NSURL *> *liveResource;
@end

NS_ASSUME_NONNULL_END
