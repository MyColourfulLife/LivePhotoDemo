//
//  PreviewVC.m
//  LivePhoto
//
//  Created by ugreen on 2021/11/25.
//

#import "PreviewVC.h"
#import <AVKit/AVkit.h>
#import <PhotosUI/PhotosUI.h>
#import "FileManager.h"
#import "WebVC.h"

@interface PreviewVC ()
@property (nonatomic, strong) TreeNode *node;
@property (strong, nonatomic) AVPlayerLayer *player;
@end

@implementation PreviewVC

- (instancetype)initWithNode:(TreeNode *)node; {
    self = [super init];
    if (self) {
        self.node = node;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"文件预览";
    
    if (self.node.fileType == FILETYPE_VIDEO) {// 视频格式
        AVPlayer *player = [AVPlayer playerWithURL:self.node.fileURL];
        self.player = [AVPlayerLayer playerLayerWithPlayer:player];
        self.player.videoGravity = AVLayerVideoGravityResizeAspect;
        self.player.frame = self.view.layer.bounds;
        [self.view.layer addSublayer:self.player];
        [player play];
        return;
    }
    
    if (self.node.fileType == FILETYPE_LIVE) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveToAlubum)];
        
        PHLivePhotoView *liveView = [[PHLivePhotoView alloc] init];
        [self.view addSubview:liveView];
        liveView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [liveView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
            [liveView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
            [liveView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
            [liveView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        ]];
        
        [self.view layoutIfNeeded];
        
        CGSize targetSize = liveView.frame.size;
        targetSize.width = targetSize.width * UIScreen.mainScreen.scale;
        targetSize.height = targetSize.height * UIScreen.mainScreen.scale;
        
        // 临时用一下
       NSArray *resouces = [FileManager fileContentsOfFileURL:[self.node.liveResource.firstObject URLByDeletingLastPathComponent]  options:NSDirectoryEnumerationSkipsSubdirectoryDescendants];
        [PHLivePhoto requestLivePhotoWithResourceFileURLs:resouces placeholderImage:nil targetSize:targetSize contentMode:PHImageContentModeAspectFit resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nonnull info) {
            liveView.livePhoto = livePhoto;
        }];
        
        return;
    }
    
    
    // 图片
    if (self.node.fileType == FILETYPE_IMG) {
        //图片
        UIImageView *imageView = [UIImageView new];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        RAC(imageView,image) = [[
            [NSData rac_readContentsOfURL:self.node.fileURL options:NSDataReadingMappedIfSafe scheduler:RACScheduler.scheduler]
            map:^UIImage * _Nullable(NSData * _Nullable value) {
            return [UIImage imageWithData:value];
        }] deliverOnMainThread];
        
//        imageView.image = [[UIImage alloc] initWithContentsOfFile:self.node.fileURL.path];
        
        [self.view addSubview:imageView];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [imageView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
            [imageView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
            [imageView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
            [imageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        ]];
        [self.view layoutIfNeeded];
        return;
    }
    
    // 其他文件,使用Webview播放视频在iOS15.1上会崩溃.... 以上均使用原生控件
    WebVC *webVC = [[WebVC alloc] initWithFileURL:self.node.fileURL];
    [self addChildViewController:webVC];
    [self.view addSubview:webVC.view];
    
    webVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [webVC.view.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
        [webVC.view.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
        [webVC.view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [webVC.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
    
}

- (void)saveToAlubum{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        NSArray<NSURL *> *resouces = [FileManager fileContentsOfFileURL:[self.node.liveResource.firstObject URLByDeletingLastPathComponent]  options:NSDirectoryEnumerationSkipsSubdirectoryDescendants];
        PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
        
        for (NSURL *fileURL in resouces) {
            if ([fileURL.pathExtension.uppercaseString isEqualToString:@"MOV"]) {
                PHAssetResourceCreationOptions *options = PHAssetResourceCreationOptions.new;
                options.shouldMoveFile = YES;
               NSURL *tempURL = [FileManager copyToThenUnHideTempURL:fileURL];
                [request addResourceWithType:PHAssetResourceTypePairedVideo fileURL:tempURL options:options];
            }else {
                PHAssetResourceCreationOptions *options = PHAssetResourceCreationOptions.new;
                [request addResourceWithType:PHAssetResourceTypePhoto fileURL:fileURL options:options];
            }
        }
        
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            NSLog(@"保存结果:%d, error:%@",success, error);
            if (success) {
                [Toast showToast:@"保存成功"];
            }else {
                [Toast showToast:@"保存失败"];
            }
        }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
