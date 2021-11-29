//
//  DetailViewController.m
//  LivePhoto
//
//  Created by ugreen on 2021/11/19.
//

#import "DetailViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "FileManager.h"
#import "FileBrowserVC.h"

@interface DetailViewController ()
@property (strong, nonatomic) AVPlayerLayer *player;
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 上传
    UIBarButtonItem *saveOutItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"arrow.up.circle"] style:UIBarButtonItemStylePlain target:self action:@selector(saveOutAsset)];
    self.navigationController.toolbarHidden = NO;
    if (self.asset.mediaType == PHAssetMediaTypeVideo) {// 视频
        NSLog(@"视频类型");
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playAsset)];
        self.toolbarItems = @[item,saveOutItem];
        
    }else {
        self.toolbarItems = @[saveOutItem];
    }
    
    if (self.asset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
        PHLivePhotoRequestOptions *options = PHLivePhotoRequestOptions.new;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.networkAccessAllowed = YES;
        //即便如此，也不能保证我们生成的livephoto和图库原来的一摸一样
        options.version = PHImageRequestOptionsVersionCurrent;
        
//        options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
//            NSLog(@"进度:%f",progress);
//        };
        
        [PHImageManager.defaultManager requestLivePhotoForAsset:self.asset targetSize:CGSizeMake(self.asset.pixelWidth, self.asset.pixelHeight) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
            self.livePhotoView.livePhoto = livePhoto;
            self.livePhotoView.hidden = NO;
            self.imageView.hidden = YES;
        }];
    }else {
        PHImageRequestOptions *options = PHImageRequestOptions.new;
        options.networkAccessAllowed = YES;
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        [PHImageManager.defaultManager requestImageForAsset:self.asset targetSize:CGSizeMake(self.asset.pixelWidth, self.asset.pixelHeight) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            self.imageView.image = result;
            self.imageView.hidden = NO;
            self.livePhotoView.hidden = YES;
        }];
    };
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(removeAsset)];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)removeAsset {
    [PHPhotoLibrary.sharedPhotoLibrary performChanges:^{
        [PHAssetChangeRequest deleteAssets:@[self.asset]];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            [RACScheduler.mainThreadScheduler schedule:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
}


- (void)playAsset{
    if (self.player) {
        [self.player.player play];
    }else {
        PHVideoRequestOptions *options = PHVideoRequestOptions.new;
        options.networkAccessAllowed = YES;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        
        [PHImageManager.defaultManager requestPlayerItemForVideo:self.asset options:options resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
            [RACScheduler.mainThreadScheduler schedule:^{
                AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
                self.player = [AVPlayerLayer playerLayerWithPlayer:player];
                self.player.videoGravity = AVLayerVideoGravityResizeAspect;
                self.player.frame = self.view.layer.bounds;
                [self.view.layer addSublayer:self.player];
                [player play];
            }];
        }];
    }
}


- (void)saveOutAsset {
    RACSignal<PHAssetResource *> * signal = nil;
    
    if (self.asset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
        // 这是我们自己生成的livepohto当中的资源，除非从系统图库中选择livephoto，否则我们生成的 根 图库里面的会有些许差异，大小 尺寸 上的差异，体现在缩略图,及像素宽高上。直接从asset获取的原始的图片和视频，不一定是图库中livephoto的尺寸，通常要更大更清晰。
        // 通过livephoto获取的资源，不会有多余的资源。而通过asset获取的资源，包含很多不需要的资源，需要在下个环节过滤。
        signal = [PHAssetResource assetResourcesForLivePhoto:self.livePhotoView.livePhoto].rac_sequence.signal;
        
    }else {
        signal = [PHAssetResource assetResourcesForAsset:self.asset].rac_sequence.signal;
    }
    
    // 1.过滤
    if (self.asset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
        signal = [signal filter:^BOOL(PHAssetResource * _Nullable value) {
            return (value.type == PHAssetResourceTypePhoto) || (value.type == PHAssetResourceTypePairedVideo);
        }];
    }else if (self.asset.mediaType == PHAssetMediaTypeImage) {
        signal = [signal filter:^BOOL(PHAssetResource * _Nullable value) {
            return value.type == PHAssetResourceTypePhoto;
        }];
    }else if (self.asset.mediaType == PHAssetMediaTypeVideo) {
        signal = [signal filter:^BOOL(PHAssetResource * _Nullable value) {
            return value.type == PHAssetResourceTypeVideo;
        }];
    }
    
    // 2.保存文件
    __block NSString *folderPath;
    PHAssetResourceRequestOptions *options = [PHAssetResourceRequestOptions new];
    options.networkAccessAllowed = YES;
    signal = [signal flattenMap:^__kindof RACSignal * _Nullable(PHAssetResource * _Nullable x) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            NSLog(@"即将处理文件名:%@",x.originalFilename);
            __block NSFileHandle *fileHandle;
            if(self.asset.mediaSubtypes & PHAssetMediaSubtypePhotoLive){
                // 创建文件夹
                NSString *folderName = [x.originalFilename stringByDeletingPathExtension];
                folderPath = [[FileManager tempFolder] stringByAppendingFormat:@"/%@",folderName];
                [FileManager createFolderIfNeededWithFolderPath:folderPath];
                NSString *filePath = [folderPath stringByAppendingFormat:@"/%@",x.originalFilename];
                fileHandle = [FileManager fileHandleWithFileWithFilePath:filePath];
            }else{
                // 创建文件
                NSString *filePath = [[FileManager cloudFolder] stringByAppendingFormat:@"/%@",x.originalFilename];
                fileHandle = [FileManager fileHandleWithFileWithFilePath:filePath];
            }
            if (!fileHandle) {
                [subscriber sendError:[NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"文件创建失败"}]];
            }
            
            [[PHAssetResourceManager defaultManager] requestDataForAssetResource:x options:options dataReceivedHandler:^(NSData * _Nonnull data) {
                [fileHandle seekToEndOfFile];
                [fileHandle writeData:data];
            } completionHandler:^(NSError * _Nullable error) {
                [fileHandle closeFile];
                fileHandle = nil;
                if (error) {
                    [subscriber sendError:error];
                }else {
                    NSLog(@"文件传输完成:%@",x.originalFilename);
                    [subscriber sendCompleted];
                }
            }];
            
            return [RACDisposable disposableWithBlock:^{
            }];
        }];
    }];
    
    // 3. 生成live
    [[signal deliverOnMainThread]
     subscribeError:^(NSError * _Nullable error) {
        [Toast showToast:@"上传失败"];
    } completed:^{
        NSLog(@"所有文件已准备就绪");
        if (folderPath) {
            NSString *liveFilePath = [[FileManager cloudFolder] stringByAppendingFormat:@"/%@.live",folderPath.lastPathComponent];
            [FileManager createFolderIfNeededWithFolderPath:FileManager.cloudFolder];
            BOOL res =  [FileManager createZipFileAtPath:liveFilePath withContentsOfDirectory:folderPath];
            if (res) {
                [self showAlert];
                return;
            }else {
                [Toast showToast:@"上传失败"];
            }
        }
        [self showAlert];
    }];
    
}



- (void)showAlert{
    [RACScheduler.mainThreadScheduler schedule:^{
       UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"以上传至Documents/Cloud目录" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"前往查看" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            FileBrowserVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FileBrowserVC"];
            NSURL *fileURL = [NSURL fileURLWithPath:FileManager.cloudFolder];
            TreeNode *node = [[TreeNode alloc] initWithFileURL:fileURL];
            vc.node = node;
            [self.navigationController pushViewController:vc animated:YES];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

@end
