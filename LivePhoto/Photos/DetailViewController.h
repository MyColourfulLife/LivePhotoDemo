//
//  DetailViewController.h
//  LivePhoto
//
//  Created by ugreen on 2021/11/19.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>


NS_ASSUME_NONNULL_BEGIN

@interface DetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet PHLivePhotoView *livePhotoView;

@property (strong, nonatomic) PHAsset *asset;

@end

NS_ASSUME_NONNULL_END
