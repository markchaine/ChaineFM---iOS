//
//  PresenterDetailViewController.m
//  Chaine FM
//
//  Created by Mark McWhirter on 11/10/2013.
//  Copyright (c) 2013 Larne Community Media. All rights reserved.
//

#import "PresenterDetailViewController.h"
#import <Parse/Parse.h>
#include "ChaineFMAppDelegate.h"

@interface PresenterDetailViewController ()


@end

@implementation PresenterDetailViewController


@synthesize PresenterName;
@synthesize PresenterFName;
@synthesize PresenterDetail;
@synthesize PresenterPicture;


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

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    // getting an NSString
    NSString *myString = [prefs stringForKey:@"PresenterFName"];
    

    
    
    PresenterName.text = myString;
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)closeButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
     
@end
