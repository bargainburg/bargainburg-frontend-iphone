//
//  CategoryDetailViewController.h
//  BargainBurg
//
//  Created by Matt Dallmeyer on 11/4/13.
//  Copyright (c) 2013 Matt Dallmeyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryDetailViewController : UITableViewController
@property (nonatomic) NSInteger *categoryId;
@property (nonatomic, strong) NSString *categoryName;

@end
