//
//  Toast.h
//  LivePhoto
//
//  Created by ugreen on 2021/11/26.
//

#import <Foundation/Foundation.h>
@class UIView;
NS_ASSUME_NONNULL_BEGIN

@interface Toast : NSObject

+ (void)showToast:(NSString *)toast;

+ (void)showToast:(NSString *)toast onView:(UIView *)view;

+ (void)showLoading;

+ (void)showLoadingOnView:(UIView *)view;

+ (void)hideLoadingOnView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
