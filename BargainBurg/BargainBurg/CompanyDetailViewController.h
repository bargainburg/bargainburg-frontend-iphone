//
//  CompanyDetailViewController.h
//  BargainBurg
//
//  Created by Matt Dallmeyer on 11/4/13.
//  Copyright (c) 2013 Matt Dallmeyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompanyDetailViewController : UITableViewController
@property (nonatomic) NSInteger *companyId;
@property (nonatomic, strong) NSString *companyName;

@end
