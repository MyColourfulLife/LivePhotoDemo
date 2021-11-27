//
//  FileManager.m
//  LivePhoto
//
//  Created by ugreen on 2021/11/25.
//

#import "FileManager.h"
#import <SSZipArchive.h>

@implementation FileManager

+ (NSString *)baseFolder {
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
}

+ (NSString *)liveResourceFolder {
    return [[self baseFolder] stringByAppendingString:@"/LiveResource"];
}

+ (NSString *)cloudFolder {
    return [[self baseFolder] stringByAppendingString:@"/Cloud"];
}

+ (NSString *)tempFolder {
    return [[self baseFolder] stringByAppendingString:@"/Temp"];
}

/// 使用此创建文件，使用文件句柄写数据
/// @param filePath 文件路径
/// @return 返回文件句柄
+ (NSFileHandle *)fileHandleWithFileWithFilePath:(NSString *)filePath{
    // 读写文件，路径文件夹一定要在
    NSString *folder = [filePath stringByDeletingLastPathComponent];
    [self createFolderIfNeededWithFolderPath:folder];
    
    BOOL isDir;
    if ([NSFileManager.defaultManager fileExistsAtPath:filePath isDirectory:&isDir]) {
        if (isDir) {
            if (![NSFileManager.defaultManager createFileAtPath:filePath contents:nil attributes:nil]) {
                NSLog(@"文件创建失败");
                return nil;
            };
        }
    }else {
        if (![NSFileManager.defaultManager createFileAtPath:filePath contents:nil attributes:nil]) {
            NSLog(@"文件创建失败");
            return nil;
        };
    };
    return [NSFileHandle fileHandleForUpdatingAtPath:filePath];
}



/// 使用此创建文件夹
/// @param folderPath 文件夹名称
/// @return 文件夹路径
+ (NSString *)createFolderIfNeededWithFolderPath:(NSString *)folderPath {
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:folderPath isDirectory:&isDir]) {
        if (isDir) {
            return folderPath;
        }else {
            NSError *error;
            if (![[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&error]){
                NSLog(@"文件夹创建失败:%@",error);
                return nil;
            };
        }
    }else {
        NSError *error;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&error]){
            NSLog(@"文件夹创建失败:%@",error);
            return nil;
        };
    };
    return folderPath;
}

+ (NSArray <NSURL *>*)fileContentsOfFileURL:(NSURL *)fileURL {
    NSError *error;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:fileURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsSubdirectoryDescendants error:&error];
    if (error) {
        NSLog(@"错误:%@",error);
        return nil;
    }
    return contents;
}

+ (BOOL)removeAtPath:(NSString *)filePath {
    NSError *error;
    BOOL res = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    return res;
}

+ (BOOL)copyFile:(NSURL *)source toURL:(NSURL *)des {
    if ([NSFileManager.defaultManager fileExistsAtPath:des.path]) {
        [NSFileManager.defaultManager removeItemAtURL:des error:nil];
    }
    return [NSFileManager.defaultManager copyItemAtURL:source toURL:des error:nil];
}

+ (BOOL)isDirectory:(NSURL *)fileURL
{
  NSNumber *isDirectory;
  [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
  return isDirectory.boolValue;
}

+ (BOOL)isWriteable:(NSURL *)fileURL {
    NSNumber *canWrite;
    [fileURL getResourceValue:&canWrite forKey:NSURLIsWritableKey error:nil];
    return canWrite.boolValue;
}

+ (BOOL)createZipFileAtPath:(NSString *)path withContentsOfDirectory:(NSString *)directoryPath {
    return [SSZipArchive createZipFileAtPath:path withContentsOfDirectory:directoryPath];
}

@end
