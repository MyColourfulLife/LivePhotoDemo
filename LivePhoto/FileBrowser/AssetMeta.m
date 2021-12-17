//
//  AssetMeta.m
//  LivePhoto
//
//  Created by ugreen on 2021/12/17.
//

#import "AssetMeta.h"

@implementation AssetMeta

+ (NSDictionary *)appleMakerMetaForURL:(NSURL *)fileURL {
    // 如果存在，并且包含17的话，可能是live photo
    return [self metaForAssetURL:fileURL][(__bridge_transfer NSString *)kCGImagePropertyMakerAppleDictionary];
}

+ (BOOL)isLivePhotoCheckBy:(NSURL *)fileURL {
    NSDictionary *appleInfo = [self appleMakerMetaForURL:fileURL];
    if (!appleInfo) {
        return NO;
    }
    return appleInfo[@"17"];
}


+ (NSDictionary *)metaForAssetURL:(NSURL *)fileURL{
    CGImageSourceRef source = CGImageSourceCreateWithURL((CFURLRef)fileURL, NULL);
    NSDictionary *meta = (__bridge_transfer NSDictionary *)CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
    CFRelease(source);
    return meta;
}

@end
