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
@property (nonatomic) bool firstTime;
@property (nonatomic) CGPoint cardCenter;

@property (weak, nonatomic) IBOutlet UIView *restaurantView;
@property (strong, nonatomic) IBOutlet UIView *contentView; //maybe delete this later, don't think I need it
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImage;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpLocation];
    self.firstTime = true;
    
    self.restaurantView.layer.cornerRadius = 10;
    self.restaurantView.layer.masksToBounds = true;
    self.cardCenter = self.restaurantView.center;
}

- (IBAction)swipeRestaurant:(UIPanGestureRecognizer *)sender {
    if (sender.view == nil) {
        return;
    }
    
    UIView *restaurantCard = sender.view; //swift had a ! at the end, not sure how to get that in objecitve-c
    CGPoint point = [sender translationInView:self.view];
    restaurantCard.center = CGPointMake(self.view.center.x + point.x, self.view.center.y + point.y);
    float xFromCenter = restaurantCard.center.x - self.view.center.x;
    
    //sets up image for swipe left/right
    if (xFromCenter < 0) {
        self.checkMarkImage.image = [UIImage systemImageNamed:@"xmark.circle.fill"];
        self.checkMarkImage.tintColor = [UIColor redColor];
    }
    else {
        self.checkMarkImage.image = [UIImage systemImageNamed:@"checkmark.circle.fill"];
        self.checkMarkImage.tintColor = [UIColor greenColor];
    }
    
    self.checkMarkImage.alpha = fabsf(xFromCenter) / self.view.center.x;
    
    //to make view bounce back after I let go
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (restaurantCard.center.x < 75) {
            //move card off to the left
            [UIView animateWithDuration:0.3 animations:^{
                restaurantCard.center = CGPointMake(restaurantCard.center.x - 200, restaurantCard.center.y);
            }];
            [self loadNextRestaurant];
            return;
        }
        else if (restaurantCard.center.x > self.view.frame.size.width - 75) {
            //move card off to the right
            [UIView animateWithDuration:0.3 animations:^{
                restaurantCard.center = CGPointMake(restaurantCard.center.x + 200, restaurantCard.center.y);
            }];
            [self loadNextRestaurant];
            return;
        }
        [UIView animateWithDuration:0.2 animations:^{
            restaurantCard.center = self.cardCenter;
            self.checkMarkImage.alpha = 0;
        }];
    }
}

- (void)loadNextRestaurant {
    sleep(1);
    [UIView animateWithDuration:0.3 animations:^{
        self.restaurantView.center = self.cardCenter;
        self.restaurantView.alpha = 1;
        self.checkMarkImage.alpha = 0;
    }];
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
        if (search != nil) {
            self.restaurants = search.businesses;
            NSLog(@"successfully fetched restaurants");
        }
        else {
            NSLog(@"%@", error.localizedDescription);
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
