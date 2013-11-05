//
//  CompanyDetailViewController.m
//  BargainBurg
//
//  Created by Matt Dallmeyer on 11/4/13.
//  Copyright (c) 2013 Matt Dallmeyer. All rights reserved.
//

#import "CompanyDetailViewController.h"

@interface CompanyDetailViewController ()
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, retain) NSDictionary *companyInfo;
@property (nonatomic, retain) NSMutableArray *couponNames;
@property (nonatomic, retain) NSMutableArray *couponIds;
@property (nonatomic, retain) IBOutlet UITableView *companyTable;
@property (nonatomic) Boolean *oneResponse;
@property (nonatomic) Boolean *twoResponse;

@end

@implementation CompanyDetailViewController
@synthesize responseData = _responseData;
@synthesize companyInfo = _companyInfo;
@synthesize couponNames = _couponNames;
@synthesize couponIds = _couponIds;
@synthesize companyTable = _companyTable;

@synthesize companyId = _companyId;
@synthesize companyName = _companyName;
@synthesize oneResponse = _oneResponse;
@synthesize twoResponse = _twoResponse;

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
    self.title = self.companyName;
    
    self.oneResponse = false;
    
    self.companyInfo = [[NSDictionary alloc] init];
    self.couponNames = [[NSMutableArray alloc] init];
    self.couponIds = [[NSMutableArray alloc] init];
    
    self.responseData = [NSMutableData data];
    
    NSURLRequest *requestCompanyInfo = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:[NSString stringWithFormat:@"http://api.bargainburg.co/v1/merchants/%d", self.companyId]]];
    [[NSURLConnection alloc] initWithRequest:requestCompanyInfo delegate:self];

    NSURLRequest *requestCoupons = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:[NSString stringWithFormat:@"http://api.bargainburg.co/v1/merchants/%d/coupons", self.companyId]]];
    [[NSURLConnection alloc] initWithRequest:requestCoupons delegate:self];
    
    [super viewDidLoad];
    NSLog(@"viewdidload");

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    self.companyTable = tableView;
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"Company Info";
    }
    
    return @"Coupons";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.companyTable = tableView;

    if (!self.twoResponse)
    {
        return 0;
    }
    if (section == 0)
    {
        return 4;
    }
    else
    {
        return [self.couponNames count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.companyTable = tableView;
    static NSString *companyTableIdentifier = @"CompanyTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:companyTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:companyTableIdentifier];
    }
    
    if (indexPath.section == 0)
    {
        switch (indexPath.row) {
            case 0:
                cell.imageView.image = [UIImage imageNamed:@"phone"];
                cell.textLabel.text = [self.companyInfo valueForKey:@"phone"];
                break;
            case 1:
                cell.imageView.image = [UIImage imageNamed:@"email"];
                cell.textLabel.text = [self.companyInfo valueForKey:@"email"];
                break;
            case 2:
                cell.imageView.image = [UIImage imageNamed:@"hours"];
                cell.textLabel.text = [self.companyInfo valueForKey:@"hours"];
                break;
            case 3:
                cell.imageView.image = [UIImage imageNamed:@"price"];
                NSInteger num$ = [[self.companyInfo valueForKey:@"price_range"] intValue];
                cell.textLabel.text = @"";
                for (int i = 0; i < num$; i++)
                {
                    cell.textLabel.text = [cell.textLabel.text stringByAppendingString:@"$"];
                }
                break;
            default:
                break;
        }
    }
    else
    {
        cell.imageView.image = [UIImage imageNamed:@"coupon"];
        cell.textLabel.text = [self.couponNames objectAtIndex:[indexPath row]];
    }
    
    return cell;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    NSLog([NSString stringWithFormat:@"Connection failed: %@", [error description]]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[self.responseData length]);
    
    if ([self.responseData length] > 0)
    {
        // convert to JSON
        NSError *myError = nil;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
        
        if ([responseDict count] > 0) {
            for (id key in responseDict)
            {
                if ([key isKindOfClass:[NSString class]])
                {
                    //company info
                    
                    self.companyInfo = [NSDictionary dictionaryWithDictionary:responseDict];
                    break;
                }
                else
                {
                    //coupons
                    
                    id name = [key objectForKey:@"name"];
                    id idNum = [key objectForKey:@"id"];
                    [self.couponNames addObject:name];
                    [self.couponIds addObject:idNum];
                }
            }
        }
        
        //ensure that both responses have been received, i.e. all data is loaded
        if (self.oneResponse)
        {
            self.twoResponse = true;
            [self.companyTable reloadData];
        }
        else
        {
            self.oneResponse = true;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
