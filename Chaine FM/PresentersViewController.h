//
//  PresentersViewController.h
//  Chaine FM
//
//  Created by Mark McWhirter on 10/10/2013.
//  Copyright (c) 2013 Larne Community Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageExampleCell.h"
#import <Parse/Parse.h>

@interface PresentersViewController : UIViewController {

    IBOutlet UILabel *PresenterBlurb;
    IBOutlet UILabel *PresenterName;
    IBOutlet UILabel *titleLabel;
    NSArray *imageFilesArray;
    NSArray *presenterNameArray;
    NSArray *presenterBlurbArray;
    NSMutableArray *imagesArray;
}

@property (weak, nonatomic) IBOutlet UICollectionView *imagesCollection;


@end

