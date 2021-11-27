//
//  Toast.m
//  LivePhoto
//
//  Created by ugreen on 2021/11/26.
//

#import "Toast.h"
#import <UIKit/UIKit.h>
@implementation Toast
+ (void)showToast:(NSString *)toast {
    return [self showToast:toast onView: nil];
}

+ (void)showToast:(NSString *)toast onView:(UIView *)view {
    __block  UIView *parentView = view;
    [RACScheduler.mainThreadScheduler schedule:^{
        UILabel *label = [UILabel new];
        label.backgroundColor = UIColor.systemBackgroundColor;
        label.textColor = UIColor.whiteColor;
        label.text = toast;
        label.font = [UIFont boldSystemFontOfSize:20];
        label.layoutMargins = UIEdgeInsetsMake(10, 20, 20, 10);
        label.layer.cornerRadius = 8;
        label.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner | kCALayerMaxXMinYCorner;
        if (!parentView) {
            parentView = UIApplication.sharedApplication.keyWindow;
        }
        [parentView addSubview:label];
        
        label.translatesAutoresizingMaskIntoConstraints = NO;
        
        [NSLayoutConstraint activateConstraints:@[
            [label.centerXAnchor constraintEqualToAnchor:parentView.centerXAnchor],
            [label.centerYAnchor constraintEqualToAnchor:parentView.centerYAnchor],
        ]];
        
        [parentView bringSubviewToFront:label];
        
        [RACScheduler.mainThreadScheduler afterDelay:2 schedule:^{
            if (label) {
                [label removeFromSuperview];
            }
        }];
    }];
}

+ (void)showLoadingOnView:(UIView *)view {
    __block  UIView *parentView = view;
    [RACScheduler.mainThreadScheduler schedule:^{
        UIActivityIndicatorView *indicaotr = [UIActivityIndicatorView new];
        indicaotr.activityIndicatorViewStyle = UIActivityIndicatorViewStyleLarge;
        indicaotr.translatesAutoresizingMaskIntoConstraints = NO;
        indicaotr.tag = 1000;
        if (!parentView) {
            parentView = UIApplication.sharedApplication.keyWindow;
        }
        [parentView addSubview:indicaotr];
        [parentView bringSubviewToFront:indicaotr];
        [NSLayoutConstraint activateConstraints:@[
            [indicaotr.centerXAnchor constraintEqualToAnchor:parentView.centerXAnchor],
            [indicaotr.centerYAnchor constraintEqualToAnchor:parentView.centerYAnchor],
        ]];
        [indicaotr layoutIfNeeded];
        indicaotr.hidden = NO;
        [indicaotr startAnimating];
    }];
}

+ (void)hideLoadingOnView:(UIView *)view {
    
    [RACScheduler.mainThreadScheduler schedule:^{
        UIView *parentView = view;
        if (!parentView) {
            parentView = UIApplication.sharedApplication.keyWindow;
        }
        UIView *indicaotr = [parentView viewWithTag:1000];
        if ([indicaotr isKindOfClass:UIActivityIndicatorView.class]) {
            indicaotr.hidden = YES;
            [indicaotr removeFromSuperview];
        }
    }];
}

@end
