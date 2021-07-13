//
//  HomeViewController.m
//  EatsNearMe
//
//  Created by Abby Li on 7/12/21.
//

#import "HomeViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "Parse/Parse.h"

@interface HomeViewController ()  <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *curLocation;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set up location services. code borrowed from https://stackoverflow.com/questions/4152003/how-can-i-get-current-location-from-user-in-ios
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    //self.locationManager.distanceFilter = kCLDistanceFilterNone;
    //self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
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
}

//I don't think I need this but I'll keep it for now
- (void)locationManager:(CLLocationManager *)manager didUpdateTo:(CLLocation *)newLocation from:(CLLocation *)oldLocation {
    NSLog(@"OldLocation %f %f", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
    NSLog(@"NewLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
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
