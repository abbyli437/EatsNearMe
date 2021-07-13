//
//  HomeViewController.m
//  EatsNearMe
//
//  Created by Abby Li on 7/12/21.
//

#import "HomeViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "Parse/Parse.h"
#import "AppDelegate.h"
@import YelpAPI;

@interface HomeViewController ()  <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *curLocation;
@property (strong, nonatomic) NSArray *restaurants;
@property (nonatomic) YLPSearch *search; //what is this lol
@property (nonatomic) bool firstTime;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpLocation];
    self.firstTime = true;
    /*[[AppDelegate sharedClient] searchWithLocation:@"San Francisco, CA" term:nil limit:5 offset:0 sort:YLPSortTypeDistance completionHandler:^
        (YLPSearch *search, NSError* error) {
        self.search = search;
        NSLog(@"successfully called api");
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self.tableView reloadData];
        });
    }];*/
}

- (void)fetchRestaurants {
    PFUser *user = [[PFUser currentUser] fetch];
    double latitude = (double) self.curLocation.coordinate.latitude;
    double longitude = (double) self.curLocation.coordinate.longitude;
    
    //this is ugly code but the methods aren't public but it'll do
    YLPCoordinate *coord = [[YLPCoordinate alloc] init];
    coord = [coord initWithLatitude:latitude longitude:longitude];
    YLPQuery *query = [[YLPQuery alloc] init];
    query = [query initWithCoordinate:coord];
    query.limit = 50;
    //convert miles to meters
    query.radiusFilter = [user[@"maxDistance"] doubleValue] * 1609.0;
    int low = [user[@"priceRangeLow"] intValue];
    int high = [user[@"priceRangeHigh"] intValue];
    NSString *priceQuery = [NSString stringWithFormat:@"%d", low];
    for (int i = low + 1; i <= high; i++) {
        priceQuery = [priceQuery stringByAppendingString:@", "];
        priceQuery = [priceQuery stringByAppendingString:[NSString stringWithFormat:@"%d", high]];
    }
    query.price = priceQuery;
    
    //finally, the actual query
    [[AppDelegate sharedClient] searchWithQuery:query completionHandler:^(YLPSearch * _Nullable search, NSError * _Nullable error) {
        if (error) {
            NSLog(error.debugDescription);
        }
        else {
            //note: I might not need self.search
            self.search = search;
            self.restaurants = search.businesses;
        }
    }];
}

//location methods start here
- (void)setUpLocation {
    //set up location services. code borrowed from https://stackoverflow.com/questions/4152003/how-can-i-get-current-location-from-user-in-ios
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //lastObject is the most recent location
    NSLog(@"%@", [locations lastObject]);
    self.curLocation = [locations lastObject];
    
    //this is so I get the location first before I call the API
    if (self.firstTime) {
        self.firstTime = false;
        [self fetchRestaurants];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
