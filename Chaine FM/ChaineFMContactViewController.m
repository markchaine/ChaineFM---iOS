//
//  ChaineFMContactViewController.m
//  Chaine FM
//
//  Created by Mark McWhirter on 10/10/2013.
//  Copyright (c) 2013 Larne Community Media. All rights reserved.
//

#import "ChaineFMContactViewController.h"

@interface ChaineFMContactViewController ()
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation ChaineFMContactViewController
@synthesize webview;

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
    
    _titleLabel.font = [UIFont fontWithName:@"SignikaNegative-Bold"  size:20];
    
    NSString *address = @"http://m.chainefm.com/contact2.php";
    
    
    // Build the url and loadRequest
    NSString *urlString = [NSString stringWithFormat:@"%@",address];
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
