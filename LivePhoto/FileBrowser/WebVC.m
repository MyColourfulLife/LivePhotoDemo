//
//  WebVC.m
//  LivePhoto
//
//  Created by ugreen on 2021/11/25.
//

#import "WebVC.h"
#import <WebKit/WebKit.h>

@interface WebVC ()
@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, strong) WKWebView *web;
@end

@implementation WebVC

- (instancetype)initWithFileURL:(NSURL *)fileURL {
    self = [super init];
    if (self) {
        self.fileURL = fileURL;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.web = [[WKWebView alloc] initWithFrame:CGRectZero configuration:({
        WKWebViewConfiguration *config = [WKWebViewConfiguration new];
        config.allowsInlineMediaPlayback = YES;
        config.allowsAirPlayForMediaPlayback = YES;
        config.allowsPictureInPictureMediaPlayback = YES;
        config;
    })];
    self.web.allowsLinkPreview = YES;
    
    [self.view addSubview:self.web];
    self.web.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.web.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
        [self.web.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
        [self.web.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.web.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
    [self.web loadFileURL:self.fileURL allowingReadAccessToURL:self.fileURL];
}


@end
