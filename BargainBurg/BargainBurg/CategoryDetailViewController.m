//
//  CategoryDetailViewController.m
//  BargainBurg
//
//  Created by Matt Dallmeyer on 11/4/13.
//  Copyright (c) 2013 Matt Dallmeyer. All rights reserved.
//

#import "CategoryDetailViewController.h"
#import "CompanyDetailViewController.h"

@interface CategoryDetailViewController ()
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, retain) NSMutableArray *companiesNames;
@property (nonatomic, retain) NSMutableArray *companiesIds;
@property (nonatomic, retain) IBOutlet UITableView *companiesTable;

@end

@implementation CategoryDetailViewController
@synthesize responseData = _responseData;
@synthesize companiesIds = _companiesIds;
@synthesize companiesNames = _companiesNames;
@synthesize companiesTable = _companiesTable;

@synthesize categoryId = _categoryId;
@synthesize categoryName = _categoryName;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    self.title = self.categoryName;
    self.responseData = [NSMutableData data];
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:[NSString stringWithFormat:@"http://api.bargainburg.co/v1/categories/%d/merchants", self.categoryId]]];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [super viewDidLoad];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CategoryToCompanySegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        CompanyDetailViewController *destViewController = segue.destinationViewController;
        destViewController.companyId = [[self.companiesIds objectAtIndex:indexPath.row] intValue];
        destViewController.companyName = [self.companiesNames objectAtIndex:indexPath.row];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
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
    static NSString *companyTableIdentifier = @"CategoryCompanyTableItem";
    
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

@end
