//
//  SearchViewController.m
//  BargainBurg
//
//  Created by Matt Dallmeyer on 10/29/13.
//  Copyright (c) 2013 Matt Dallmeyer. All rights reserved.
//

#import "SearchViewController.h"
#import "CompanyDetailViewController.h"
#import "CouponViewController.h"

extern NSString *apiUrl;

@interface SearchViewController ()
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) IBOutlet UITableView *searchTable;
@property (nonatomic, strong) NSMutableArray *resultTypes;
@property (nonatomic, strong) NSMutableArray *resultNames;
@property (nonatomic, strong) NSMutableArray *resultIds;

@end

@implementation SearchViewController
@synthesize responseData  = _responseData;
@synthesize searchTable = _searchTable;
@synthesize resultTypes = _resultTypes;
@synthesize resultNames = _resultNames;
@synthesize resultIds = _resultIds;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.resultTypes = [[NSMutableArray alloc] init];
    self.resultNames = [[NSMutableArray alloc] init];
    self.resultIds = [[NSMutableArray alloc] init];
    
    NSLog(@"viewdidload");
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (![searchText  isEqual: @""])
    {
        self.responseData = [NSMutableData data];
        
        [self.resultTypes removeAllObjects];
        [self.resultNames removeAllObjects];
        [self.resultIds removeAllObjects];
        
        NSURLRequest *requestCompanyInfo = [NSURLRequest requestWithURL:
                                            [NSURL URLWithString:[NSString stringWithFormat:@"%@search?query=%@", apiUrl, searchText]]];
        [[NSURLConnection alloc] initWithRequest:requestCompanyInfo delegate:self];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    self.searchTable = tableView;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.searchTable = tableView;
    return [self.resultNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.searchTable = tableView;
    
    if ([[self.resultTypes objectAtIndex:[indexPath row]] isEqualToString:@"coupon"])
    {
        static NSString *searchTableIdentifier = @"ResultCellCoupon";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:searchTableIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchTableIdentifier];
        }
        
        cell.textLabel.text = [self.resultNames objectAtIndex:[indexPath row]];
        cell.imageView.image = [UIImage imageNamed:@"coupon"];
        
        return cell;
    }
    else
    {
        static NSString *searchTableIdentifier = @"ResultCellCompany";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:searchTableIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchTableIdentifier];
        }
        
        cell.textLabel.text = [self.resultNames objectAtIndex:[indexPath row]];
        cell.imageView.image = [UIImage imageNamed:@"companies"];
        
        return cell;
    }
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
    
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    for (id key in responseDict)
    {
        id type = [key objectForKey:@"type"];
        id name = [key objectForKey:@"name"];
        id idNum = [key objectForKey:@"id"];
        [self.resultTypes addObject:type];
        [self.resultNames addObject:name];
        [self.resultIds addObject:idNum];
    }
    
    [self.searchTable reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SearchCouponSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        CouponViewController *destViewController = segue.destinationViewController;
        destViewController.couponId = [[self.resultIds objectAtIndex:indexPath.row] intValue];
        destViewController.couponName = [self.resultNames objectAtIndex:indexPath.row];
    }
    else if ([segue.identifier isEqualToString:@"SearchCompanySegue"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        CompanyDetailViewController *destViewController = segue.destinationViewController;
        destViewController.companyId = [[self.resultIds objectAtIndex:indexPath.row] intValue];
        destViewController.companyName = [self.resultNames objectAtIndex:indexPath.row];
    }
}


@end
