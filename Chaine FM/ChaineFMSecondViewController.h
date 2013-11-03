//
//  ChaineFMSecondViewController.h
//  Chaine FM
//
//  Created by Mark McWhirter on 05/10/2013.
//  Copyright (c) 2013 Larne Community Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ParseExampleCell.h"

@interface ChaineFMSecondViewController: UIViewController <UITableViewDelegate> {
    NSArray *colorsArray;
    IBOutlet UILabel *titleText;
}
@property (weak, nonatomic) IBOutlet UITableView *colorsTable;
@end
