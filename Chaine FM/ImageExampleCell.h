//
//  ImageExampleCell.h
//  Chaine FM
//
//  Created by Mark McWhirter on 06/10/2013.
//  Copyright (c) 2013 Larne Community Media. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageExampleCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *parseImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;
@property (strong, nonatomic) IBOutlet UILabel *PresenterName;
@property (strong, nonatomic) IBOutlet UILabel *PresenterBlurb;

@end
