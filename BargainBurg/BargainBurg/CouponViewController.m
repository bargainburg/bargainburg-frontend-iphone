//
//  CouponViewController.m
//  BargainBurg
//
//  Created by Matt Dallmeyer on 11/6/13.
//  Copyright (c) 2013 Matt Dallmeyer. All rights reserved.
//

#import "CouponViewController.h"

extern NSString *apiUrl;

@interface CouponViewController ()
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) IBOutlet UITextView *couponDetails;

@end

@implementation CouponViewController
@synthesize responseData = _responseData;
@synthesize couponDetails = _couponDetails;
@synthesize couponId = _couponId;
@synthesize couponName = _couponName;

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
    [super viewDidLoad];
    self.title = self.couponName;
    
    self.responseData = [[NSMutableData alloc] init];
    
    NSURLRequest *requestCompanyInfo = [NSURLRequest requestWithURL:
                                        [NSURL URLWithString:[NSString stringWithFormat:@"%@coupons/%d", apiUrl, self.couponId]]];
    [[NSURLConnection alloc] initWithRequest:requestCompanyInfo delegate:self];
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
        
        self.couponDetails.text = [responseDict valueForKey:@"description"];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
