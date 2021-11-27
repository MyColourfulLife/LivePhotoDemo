//
//  ImagCell.m
//  LivePhoto
//
//  Created by ugreen on 2021/11/19.
//

#import "ImagCell.h"

@implementation ImagCell
- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    self.badgeImageView.image = nil;
}
@end
