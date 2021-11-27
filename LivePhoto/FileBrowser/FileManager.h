//
//  FileManager.h
//  LivePhoto
//
//  Created by ugreen on 2021/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileManager : NSObject

+ (NSString *)baseFolder;

+ (NSString *)liveResourceFolder;

+ (NSString *)tempFolder;

+ (BOOL)isDirectory:(NSURL *)fileURL;

+ (BOOL)isWriteable:(NSURL *)fileURL;

/// 模拟云端路径
+ (NSString *)cloudFolder;

/// 使用此创建文件，使用文件句柄写数据
/// @param filePath 文件路径
/// @return 返回文件句柄
+ (NSFileHandle *)fileHandleWithFileWithFilePath:(NSString *)filePath;


/// 使用此创建文件夹
/// @param folderPath 文件夹路径
/// @return 文件夹路径
+ (NSString *)createFolderIfNeededWithFolderPath:(NSString *)folderPath;



/// 获取指定目录下的文件列表
/// @param fileURL 文件目录
+ (NSArray <NSURL *>*)fileContentsOfFileURL:(NSURL *)fileURL;


+ (BOOL)copyFile:(NSURL *)source toURL:(NSURL *)des;

+ (BOOL)removeAtPath:(NSString *)filePath;


+ (BOOL)createZipFileAtPath:(NSString *)path withContentsOfDirectory:(NSString *)directoryPath;

@end

NS_ASSUME_NONNULL_END
