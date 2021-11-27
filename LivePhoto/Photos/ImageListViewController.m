//
//  ViewController.m
//  LivePhoto
//
//  Created by ugreen on 2021/11/19.
//

#import "ImageListViewController.h"
#import "ImagCell.h"
#import "DetailViewController.h"



@interface ImageListViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,PHPhotoLibraryChangeObserver>

@property (weak, nonatomic) IBOutlet UICollectionView  *imageListView;

@property (strong, nonatomic) PHFetchResult<PHAsset *> *fetchResult;

@property (assign, nonatomic) CGSize thumbnailSize;

@end

@implementation ImageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
   UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.imageListView.collectionViewLayout;
    CGFloat size = 110;
//    flowLayout.estimatedItemSize = CGSizeMake(size, size);
    flowLayout.itemSize = CGSizeMake(size, size);
    CGFloat scale = UIScreen.mainScreen.scale;
    self.thumbnailSize = CGSizeMake(size * scale, size * scale);
    PHFetchOptions *options = [PHFetchOptions new];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    self.fetchResult = [PHAsset fetchAssetsWithOptions:options];
    
    [PHPhotoLibrary.sharedPhotoLibrary registerChangeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.toolbarHidden = YES;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toDetail"]) {
        ImagCell *cell = (ImagCell *)sender;
        NSIndexPath* index = [self.imageListView indexPathForCell:cell];
        DetailViewController *detailVC = segue.destinationViewController;
        detailVC.asset = self.fetchResult[index.item];
    }
}


//MARK: - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchResult.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImagCell *cell = (ImagCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ImagCell.class) forIndexPath:indexPath];
    
    PHAsset *asset = self.fetchResult[indexPath.item];
    if (asset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
        cell.badgeImageView.image = [PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent];
    }
    cell.representedAssetIdentifier = asset.localIdentifier;
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:self.thumbnailSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
            cell.imageView.image = result;
        }
    }];

    return cell;
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    [RACScheduler.mainThreadScheduler schedule:^{
        PHFetchResultChangeDetails *changes =  [changeInstance changeDetailsForFetchResult:self.fetchResult];
        if (changes) {
            self.fetchResult = [changes fetchResultAfterChanges];
            if (changes.removedIndexes) {
                NSMutableArray *array = @[].mutableCopy;
                [changes.removedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                    [array addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
                }];
                [self.imageListView deleteItemsAtIndexPaths:array];
            }else if (changes.insertedIndexes){
                NSMutableArray *array = @[].mutableCopy;
                [changes.removedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                    [array addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
                }];
                [self.imageListView insertItemsAtIndexPaths:array];
            }
            else {
                [self.imageListView reloadData];
            }
        }
        
    }];
    
}

@end
