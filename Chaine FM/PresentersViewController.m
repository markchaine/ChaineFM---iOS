//
//  PresentersViewController.m
//  Chaine FM
//
//  Created by Mark McWhirter on 10/10/2013.
//  Copyright (c) 2013 Larne Community Media. All rights reserved.
//

#import "PresentersViewController.h"
#import "PresenterDetailViewController.h"
#include "ChaineFMAppDelegate.h"

@interface PresentersViewController ()


@end

@implementation PresentersViewController

@synthesize imagesCollection;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    titleLabel.font = [UIFont fontWithName:@"SignikaNegative-Bold"  size:20];

    [self queryParseMethod];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//user selects folder to add tag to





- (void)queryParseMethod {
    NSLog(@"start query");
    PFQuery *query = [PFQuery queryWithClassName:@"Presenters"];
                [query orderByAscending:@"Priority"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            imageFilesArray = [[NSArray alloc] initWithArray:objects];
            NSLog(@"%@", imageFilesArray);
            
            [imagesCollection reloadData];

        }
    }];
}



#pragma mark - UICollectionView data source

- (void)collectionView:(UICollectionView *)imagesCollection didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
  
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    // saving an NSString
    [prefs setObject:titleLabel.text forKey:@"PresenterFName"];
    
    [prefs synchronize];
    

}




-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [imageFilesArray count];
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"imageCell";
    ImageExampleCell *cell = (ImageExampleCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    PFObject *imageObject = [imageFilesArray objectAtIndex:indexPath.row];
    PFFile *imageFile = [imageObject objectForKey:@"BannerImage"];
    NSString *presenterFNamez = [imageObject objectForKey:@"PresenterName"];
        NSString *presenterFBlurbz = [imageObject objectForKey:@"PresenterBlurb"];
    
    
    cell.loadingSpinner.hidden = NO;
    [cell.loadingSpinner startAnimating];
    
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            cell.parseImage.image = [UIImage imageWithData:data];
            cell.PresenterName.text = presenterFNamez;
            cell.PresenterName.font = [UIFont fontWithName:@"SignikaNegative-Bold"  size:19];
            cell.PresenterBlurb.font = [UIFont fontWithName:@"SignikaNegative-Regular"  size:15];
            cell.PresenterBlurb.text = presenterFBlurbz;
            [cell.loadingSpinner stopAnimating];
            cell.loadingSpinner.hidden = YES;
        }
        
      
        
    }];
    
    return cell;
}

@end
