//
//  TreeNode.m
//  LivePhoto
//
//  Created by ugreen on 2021/11/25.
//

#import "TreeNode.h"
#import "FileManager.h"
#import <SSZipArchive.h>

@interface TreeNode ()
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSURL *fileURL;
@property(nonatomic, copy) NSString *iconName;
@property(nonatomic, assign) BOOL canWrite;
@property(nonatomic, assign) BOOL leaf;
@property(nonatomic, assign) FILETYPE fileType;
@property(nonatomic, nullable, copy) NSArray<TreeNode *> *childNodes;
@property(nonatomic, nullable, weak) TreeNode *parentNode;
@property(nonatomic, nullable) NSArray<NSURL *> *liveResource;
@end

@implementation TreeNode

+ (NSArray<NSString *>*) ImgTypes {
    return @[@"HEIC",@"PNG",@"JPG"];
}

+ (NSArray<NSString *>*) VedioTypes {
    return @[@"MOV",@"MP4"];
}

+ (NSArray<NSString *>*) LiveTypes {
    return @[@"LIVE"];
}

- (instancetype)initWithFileURL:(NSURL *)fileURL {
    self = [super init];
    if (self) {
        [self createNodeWithFileURL:fileURL];
    }
    return self;
}

- (void)createNodeWithFileURL:(NSURL *)fileURL {
    self.fileURL = fileURL;
    BOOL isFolder = [FileManager isDirectory:fileURL];
    self.canWrite = [FileManager isWriteable:fileURL];
    if (!isFolder) {
        self.leaf = YES;
        NSString *lastPath = fileURL.lastPathComponent;
        self.name = lastPath;// 文件显示后缀名
        NSString *fileExtention = lastPath.pathExtension.uppercaseString;
        
        if ([TreeNode.VedioTypes containsObject:fileExtention]) {
            self.iconName = @"video";
            self.fileType = FILETYPE_VIDEO;
        }else if ([TreeNode.ImgTypes containsObject:fileExtention]){
            self.iconName = @"photo";
            self.fileType = FILETYPE_IMG;
        }else if ([TreeNode.LiveTypes containsObject:fileExtention]){
            self.iconName = @"livephoto";
            self.fileType = FILETYPE_LIVE;
        }else {
            self.iconName = @"doc";
            self.fileType = FILETYPE_OTHER;
        }
        
        self.childNodes = nil;
        if ([fileURL.pathExtension isEqualToString:@"live"]) {
          NSString *unzipPath =  [[FileManager liveResourceFolder] stringByAppendingFormat:@"/%@",fileURL.lastPathComponent];
             [SSZipArchive unzipFileAtPath:fileURL.path toDestination:unzipPath];
           self.liveResource = [FileManager fileContentsOfFileURL:[NSURL fileURLWithPath:unzipPath]];
        }
        return;
    }
    
    self.iconName = @"folder";
    self.fileType = FILETYPE_FOLDER;
    NSString *lastPath = fileURL.lastPathComponent;
    self.name = [lastPath stringByDeletingPathExtension];
    self.leaf = NO;
    
    NSArray<NSURL *> *contents = [FileManager fileContentsOfFileURL:fileURL];
    if (contents) {
        NSMutableArray * childs = @[].mutableCopy;
        for (NSURL *file in contents) {
            TreeNode *sub = [[TreeNode alloc] initWithFileURL:file];
            sub.parentNode = self;
            [childs addObject:sub];
        }
        self.childNodes = childs;
    }
}





@end
