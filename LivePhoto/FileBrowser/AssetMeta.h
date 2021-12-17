//
//  AssetMeta.h
//  LivePhoto
//
//  Created by ugreen on 2021/12/17.
//

#import <Foundation/Foundation.h>

@interface AssetMeta : NSObject
+ (NSDictionary *)metaForAssetURL:(NSURL *)fileURL;

+ (NSDictionary *)appleMakerMetaForURL:(NSURL *)fileURL;

+ (BOOL)isLivePhotoCheckBy:(NSURL *)fileURL;

@end
