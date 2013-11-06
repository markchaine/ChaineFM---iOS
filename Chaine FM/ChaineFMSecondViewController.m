//
//  ChaineFMSecondViewController.m
//  Chaine FM
//
//  Created by Mark McWhirter on 05/10/2013.
//  Copyright (c) 2013 Larne Community Media. All rights reserved.
//

#import "ChaineFMSecondViewController.h"
#include "ChaineFMAppDelegate.h"

@interface ChaineFMSecondViewController ()

@end

@implementation ChaineFMSecondViewController

@synthesize colorsTable;

- (void)viewDidLoad
{
    [super viewDidLoad];

    {
    
    titleText.font = [UIFont fontWithName:@"SignikaNegative-Bold"  size:22];
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
        [self performSelector:@selector(retrieveFromParse)];
}
- (void) retrieveFromParse {

 
    
    
    PFQuery *retrieveColors = [PFQuery queryWithClassName:@"Guests"];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
       [retrieveColors findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            colorsArray = [[NSArray alloc] initWithArray:objects];
        }
        [colorsTable reloadData];
    }];
}



//get number of rows by counting number of folders
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return colorsArray.count;
}

//setup cells in tableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //setup cell
    static NSString *CellIdentifier = @"colorsCell";
    ParseExampleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    PFObject *tempObject = [colorsArray objectAtIndex:indexPath.row];
    
    cell.cellTitle.text = [tempObject objectForKey:@"GuestInformation"];
    cell.cellTitle.font = [UIFont fontWithName:@"SignikaNegative-Regular"  size:15];
    cell.guestInfo.text = [NSString stringWithFormat:@"In The Studio at, %@", [tempObject objectForKey:@"GuestTime"]];
    cell.guestInfo.font = [UIFont fontWithName:@"SignikaNegative-Regular"  size:14];


    return cell;
}


//user selects folder to add tag to
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cell tapped");
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"Your Push Notification for this guest has been set.", @"alert",
                          nil];
    PFPush *push = [[PFPush alloc] init];
    [push setChannels:[NSArray arrayWithObjects:@"Mets", nil]];
    [push setData:data];
    [push sendPushInBackground];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
