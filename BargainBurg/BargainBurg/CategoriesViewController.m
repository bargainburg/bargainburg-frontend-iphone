//
//  CategoriesViewController.m
//  BargainBurg
//
//  Created by Matt Dallmeyer on 10/29/13.
//  Copyright (c) 2013 Matt Dallmeyer. All rights reserved.
//

#import "CategoriesViewController.h"
#import "CategoryDetailViewController.h"

@interface CategoriesViewController ()
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, retain) NSMutableArray *categoriesNames;
@property (nonatomic, retain) NSMutableArray *categoriesIds;
@property (nonatomic, retain) IBOutlet UITableView *categoriesTable;
@end

@implementation CategoriesViewController
@synthesize responseData = _responseData;
@synthesize categoriesNames = _categoriesNames;
@synthesize categoriesIds = _categoriesIds;
@synthesize categoriesTable = _categoriesTable;

- (void)viewDidLoad
{    
    self.responseData = [NSMutableData data];
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:@"http://api.bargainburg.co/v1/categories"]];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [super viewDidLoad];
    NSLog(@"viewdidload");
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showCategoryDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        CategoryDetailViewController *destViewController = segue.destinationViewController;
        destViewController.categoryId = [[self.categoriesIds objectAtIndex:indexPath.row] intValue];
        destViewController.categoryName = [self.categoriesNames objectAtIndex:indexPath.row];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    self.categoriesTable = tableView;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.categoriesTable = tableView;
    return [self.categoriesNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.categoriesTable = tableView;
    static NSString *categoryTableIdentifier = @"CategoryTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:categoryTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:categoryTableIdentifier];
    }
    
    cell.textLabel.text = [self.categoriesNames objectAtIndex:[indexPath row]];
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
    NSDictionary *categoriesDict = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    self.categoriesNames = [[NSMutableArray alloc] init];
    self.categoriesIds = [[NSMutableArray alloc] init];
    
    for (id key in categoriesDict)
    {
        id name = [key objectForKey:@"name"];
        id idNum = [key objectForKey:@"id"];
        [self.categoriesNames addObject:name];
        [self.categoriesIds addObject:idNum];
    }
    
    [self.categoriesTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
