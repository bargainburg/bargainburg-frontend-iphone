//
//  CompaniesViewController.m
//  BargainBurg
//
//  Created by Matt Dallmeyer on 10/29/13.
//  Copyright (c) 2013 Matt Dallmeyer. All rights reserved.
//

#import "CompaniesViewController.h"
#import "CompanyDetailViewController.h"

@interface CompaniesViewController ()
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, retain) NSMutableArray *companiesNames;
@property (nonatomic, retain) NSMutableArray *companiesIds;
@property (nonatomic, retain) IBOutlet UITableView *companiesTable;
@end

@implementation CompaniesViewController
@synthesize responseData = _responseData;
@synthesize companiesIds = _companiesIds;
@synthesize companiesNames = _companiesNames;
@synthesize companiesTable = _companiesTable;

- (void)viewDidLoad
{
    self.responseData = [NSMutableData data];
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:@"http://api.bargainburg.co/v1/merchants"]];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [super viewDidLoad];
    NSLog(@"viewdidload");
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CompanyToDetailSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        CompanyDetailViewController *destViewController = segue.destinationViewController;
        destViewController.companyId = [[self.companiesIds objectAtIndex:indexPath.row] intValue];
        destViewController.companyName = [self.companiesNames objectAtIndex:indexPath.row];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    self.companiesTable = tableView;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.companiesTable = tableView;
    return [self.companiesNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.companiesTable = tableView;
    static NSString *companyTableIdentifier = @"CompanyTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:companyTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:companyTableIdentifier];
    }
    
    cell.textLabel.text = [self.companiesNames objectAtIndex:[indexPath row]];
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
    
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *companiesDict = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    self.companiesNames = [[NSMutableArray alloc] init];
    self.companiesIds = [[NSMutableArray alloc] init];
    
    for (id key in companiesDict)
    {
        id name = [key objectForKey:@"name"];
        id idNum = [key objectForKey:@"id"];
        [self.companiesNames addObject:name];
        [self.companiesIds addObject:idNum];
    }
    
    [self.companiesTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
