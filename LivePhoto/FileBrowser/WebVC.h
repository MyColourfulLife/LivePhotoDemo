//
//  WebVC.h
//  LivePhoto
//  浏览本地文件
//  Created by ugreen on 2021/11/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WebVC : UIViewController
- (instancetype)initWithFileURL:(NSURL *)fileURL;
@end

NS_ASSUME_NONNULL_END
