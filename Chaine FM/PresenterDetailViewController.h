//
//  PresenterDetailViewController.h
//  Chaine FM
//
//  Created by Mark McWhirter on 11/10/2013.
//  Copyright (c) 2013 Larne Community Media. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PresenterDetailViewController : UIViewController {

NSString *PresenterFName;
}
@property (nonatomic, retain) NSString  *PresenterFName;

@property (nonatomic, strong) IBOutlet UILabel *PresenterName;
@property (nonatomic, strong) IBOutlet UILabel *PresenterDetail;
@property (strong, nonatomic) IBOutlet UIImageView *PresenterPicture;
@property (nonatomic, strong) NSString *CPrresenterName;
@property (strong, nonatomic)          NSString *PresentKey;


@end

