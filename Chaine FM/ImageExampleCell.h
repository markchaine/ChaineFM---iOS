//
//  ImageExampleCell.h
//  ParseExample
//
//  Created by Nick Barrowclough on 7/25/13.
//  Copyright (c) 2013 Nicholas Barrowclough. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageExampleCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *parseImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;
@property (strong, nonatomic) IBOutlet UILabel *PresenterName;
@property (strong, nonatomic) IBOutlet UILabel *PresenterBlurb;

@end
