//
//  ImagCell.h
//  LivePhoto
//
//  Created by ugreen on 2021/11/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImagCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *badgeImageView;

@property (copy, nonatomic) NSString *representedAssetIdentifier;

@end

NS_ASSUME_NONNULL_END
