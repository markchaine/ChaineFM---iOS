//
//  ChaineFMFirstViewController.m
//  Chaine FM
//
//  Created by Mark McWhirter on 05/10/2013.
//  Copyright (c) 2013 Larne Community Media. All rights reserved.
//

#import "ChaineFMFirstViewController.h"
#import <Parse/Parse.h>


@interface ChaineFMFirstViewController ()



@end

@implementation ChaineFMFirstViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
  
    {
    NSDate *now = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:(NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSTimeZoneCalendarUnit) fromDate:now];
    [components setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSInteger hour = [components hour];
    if (hour == 01 || hour == 17) { // covers midnight - midday
        label.text = @"Hi There!";
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"SignikaNegative-Bold" size:22];
    } else { // If it's after 12pm then say Good Afternoon!
        label.text = @"Hey!";
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"SignikaNegative-Bold" size:22];
        
    }
    

   
    }

    
    PFQuery *query = [PFQuery queryWithClassName:@"AppText"];
    [query getObjectInBackgroundWithId:@"DmZc3aZLLA" block:^(PFObject *welcomeText, NSError *error)
    
    
    {
        // Do something with the returned PFObject in the gameScore variable.
        NSLog(@"%@", welcomeText);

    
            hometext.textAlignment = NSTextAlignmentCenter;
            hometext.numberOfLines = 0;
            hometext.text = [welcomeText objectForKey:@"TextValue"];
            hometext.font = [UIFont fontWithName:@"SignikaNegative-Regular" size:14];
       }];
        // The InBackground methods are asynchronous, so any code after this will run
        // immediately.  Any code that depends on the query result should be moved
        // inside the completion block above.
        
    

    // Display who is on air
    }
    
    


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
