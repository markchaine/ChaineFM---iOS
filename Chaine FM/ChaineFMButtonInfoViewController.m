//
//  ChaineFMButtonInfoViewController.m
//  ChaineFM
//
//  Created by Mark McWhirter on 08/11/2014.
//  Copyright (c) 2014 Larne Community Media. All rights reserved.
//

#import "ChaineFMButtonInfoViewController.h"
#import <Parse/Parse.h>

@interface ChaineFMButtonInfoViewController ()
@property (strong, nonatomic) IBOutlet UITextView *infotextView;
@property (strong, nonatomic) IBOutlet UIWebView *webViewer;

@end

@implementation ChaineFMButtonInfoViewController
- (IBAction)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PFQuery *query = [PFQuery queryWithClassName:@"AppText"];
    [query getObjectInBackgroundWithId:@"x1xD6Lo69n" block:^(PFObject *welcomeText, NSError *error)
     
     
     {

    
         NSString *address = [welcomeText valueForKey:@"TextValue"];
    
    
    // Build the url and loadRequest
    NSString *urlString = [NSString stringWithFormat:@"%@",address];
    [self.webViewer loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    
     }];
     
    /*
    
    PFQuery *query = [PFQuery queryWithClassName:@"AppText"];
    [query getObjectInBackgroundWithId:@"DmZc3aZLLA" block:^(PFObject *welcomeText, NSError *error)
     
     
     {
         // Do something with the returned PFObject in the gameScore variable.
         NSLog(@"%@", welcomeText);
         
         
         _infotextView.textAlignment = NSTextAlignmentCenter;
       //  _infotextView.numberOfLines = 0;
         _infotextView.text = [welcomeText objectForKey:@"TextValue"];
         _infotextView.font = [UIFont fontWithName:@"SignikaNegative-Regular" size:14];
     }];
    
    */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
