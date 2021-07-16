//
//  HomeViewController.m
//  EatsNearMe
//
//  Created by Abby Li on 7/12/21.
//

#import "HomeViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "Parse/Parse.h"
#import "ParseUtil.h"
#import "AppDelegate.h"
#import "SavedViewController.h"
@import YelpAPI;

@interface HomeViewController ()  <CLLocationManagerDelegate>

@property (strong, nonatomic) PFUser *user;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *curLocation;
@property (strong, nonatomic) SavedViewController *secondTab;
@property (strong, nonatomic) NSMutableArray *restaurants;
@property (nonatomic) bool firstTime;
@property (nonatomic) CGPoint cardCenter;
@property (nonatomic) int offset;

@property (strong, nonatomic) NSMutableDictionary *swipes;
@property (strong, nonatomic) NSMutableArray *rightSwipes;

//card view props
@property (weak, nonatomic) IBOutlet UIView *restaurantView;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImage;
@property (weak, nonatomic) IBOutlet UIImageView *restaurantImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (nonatomic) int currentIndex;

@end

@implementation HomeViewController

//TODO: add spinner for loading
//or just fetch 20 restaurants and get more later to make fetch faster
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.user = [[PFUser currentUser] fetch];
    
    [self setUpLocation];
    self.firstTime = true;
    
    self.restaurantView.layer.cornerRadius = 10;
    self.restaurantView.layer.masksToBounds = true;
    //self.restaurantView.alpha = 0;
    
    self.cardCenter = self.restaurantView.center;
    self.currentIndex = 0;
    
    //might use swipes to only store restaurant names because Parse can't store YLPBusiness objects
    self.swipes = [[NSMutableDictionary alloc] initWithCapacity:10];
    [self.swipes setObject:[[NSMutableDictionary alloc] init] forKey:@"leftSwipes"];
    [self.swipes setObject:[[NSMutableDictionary alloc] init] forKey:@"rightSwipes"];
    
    //keep track of swipes locally
    self.rightSwipes = [[NSMutableArray alloc] init];
    
    self.restaurants = [[NSMutableArray alloc] init];
    
    //to pass right swipes to Saved Tab
    UINavigationController *secondController = self.tabBarController.viewControllers[1];
    self.secondTab = secondController.viewControllers.firstObject;
    self.secondTab.restaurants = self.rightSwipes;
}

- (IBAction)swipeRestaurant:(UIPanGestureRecognizer *)sender {
    if (sender.view == nil) {
        return;
    }
    
    UIView *restaurantCard = sender.view;
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
            [self afterSwipeAction:-200 isLeft:true];
            return;
        }
        else if (restaurantCard.center.x > self.view.frame.size.width - 75) {
            //move card off to the right
            [self afterSwipeAction:200 isLeft:false];
            return;
        }
        [UIView animateWithDuration:0.2 animations:^{
            restaurantCard.center = self.cardCenter;
            self.checkMarkImage.alpha = 0;
        }];
    }
}

- (void)afterSwipeAction:(int)swipeDir isLeft:(bool)isLeft {
    //move card off to the right
    [UIView animateWithDuration:0.3 animations:^{
        self.restaurantView.center = CGPointMake(self.restaurantView.center.x + swipeDir, self.restaurantView.center.y);
    } completion:^(BOOL finished) {
        YLPBusiness *restaurant = self.restaurants[self.currentIndex - 1];
        if (isLeft) {
            NSMutableDictionary *leftSwipes = [self.swipes objectForKey:@"leftSwipes"];
            [leftSwipes setValue:restaurant.name forKey:restaurant.name];
        }
        else {
            NSMutableDictionary *rightSwipes = [self.swipes objectForKey:@"rightSwipes"];
            [rightSwipes setValue:restaurant.name forKey:restaurant.name];
            //[rightSwipes addObject:restaurant.name];
            [self.rightSwipes addObject:restaurant];
        }
        
        NSArray *vals = [NSArray arrayWithObject:self.swipes];
        NSArray *keys = [NSArray arrayWithObject:@"swipes"];
        //this updates parse but I don't want to do it yet for testing
        [ParseUtil udpateValues:vals keys:keys];
        
        [self loadNextRestaurant];
    }];
    return;
}

- (void)loadNextRestaurant {
    sleep(0.25);
    
    if (self.currentIndex >= self.restaurants.count) {
        return; //makes sure things are in bounds, might add alert here later if I have time
    }
    YLPBusiness *restaurant = self.restaurants[self.currentIndex];
    self.currentIndex++;
    
    //restaurant image
    if (restaurant.imageURL != nil) {
        NSData *data = [[NSData alloc] initWithContentsOfURL:restaurant.imageURL];
        UIImage *imageData = [[UIImage alloc] initWithData:data];
        self.restaurantImage.image = imageData;
    }
    else {
        self.restaurantImage.image = [UIImage imageNamed:@"comingSoon.png"];
    }
    
    self.nameLabel.text = restaurant.name;
    self.descriptionLabel.text = restaurant.categories[0].name;
    self.priceLabel.text = restaurant.price;
    
    //distance label
    CLLocation *restaurantLoc = [[CLLocation alloc] initWithLatitude:restaurant.location.coordinate.latitude longitude:restaurant.location.coordinate.longitude];
    //this is in meters
    CLLocationDistance dist = [self.curLocation distanceFromLocation:restaurantLoc];
    //convert meters to miles
    double distMiles = dist / 1609.0;
    NSString *distStr = [NSString stringWithFormat:@"%.2f", distMiles];
    distStr = [distStr stringByAppendingString:@" miles away"];
    self.distanceLabel.text = distStr;
    
    self.restaurantView.center = self.cardCenter;
    self.restaurantView.alpha = 1;
    self.checkMarkImage.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.restaurantView.alpha = 1;
    }];
}

- (void)fetchRestaurants {
    //PFUser *user = [[PFUser currentUser] fetch];
    
    //set the swipe arrays
    if (self.user[@"swipes"] != nil) {
        self.swipes = self.user[@"swipes"];
    }
    
    //set up query
    double latitude = (double) self.curLocation.coordinate.latitude;
    double longitude = (double) self.curLocation.coordinate.longitude;
    YLPCoordinate *coord = [[YLPCoordinate alloc] init];
    coord = [coord initWithLatitude:latitude longitude:longitude];
    YLPQuery *query = [[YLPQuery alloc] init];
    query = [query initWithCoordinate:coord];
    query.limit = 50;
    query.offset = [self.user[@"offset"] intValue];
    query.radiusFilter = [self.user[@"maxDistance"] doubleValue] * 1609.0;
    int low = [self.user[@"priceRangeLow"] intValue];
    int high = [self.user[@"priceRangeHigh"] intValue];
    
    
    //set up price parameter
    NSString *priceQuery = [NSString stringWithFormat:@"%d", low];
    for (int i = low + 1; i <= high; i++) {
        priceQuery = [priceQuery stringByAppendingString:@", "];
        priceQuery = [priceQuery stringByAppendingString:[NSString stringWithFormat:@"%d", i]];
    }
    query.price = priceQuery;
    
    //finally, the actual query
    [[AppDelegate sharedClient] searchWithQuery:query completionHandler:^(YLPSearch * _Nullable search, NSError * _Nullable error) {
        if (search != nil) {
            //self.restaurants = [NSMutableArray arrayWithArray:search.businesses]; //delete this later
            NSLog(@"successfully fetched restaurants");
            
            for (YLPBusiness *restaurant in search.businesses) {
                NSMutableDictionary *leftSwipes = [self.swipes objectForKey:@"leftSwipes"];
                NSMutableDictionary *rightSwipes = [self.swipes objectForKey:@"rightSwipes"];
                if ([rightSwipes objectForKey:restaurant.name] != nil) {
                    [self.rightSwipes addObject:restaurant];
                }
                else if ([leftSwipes objectForKey:restaurant.name] == nil) {
                    //restuarant hasn't been seen before
                    [self.restaurants addObject:restaurant];
                }
            }
            [self loadNextRestaurant];
            [self.restaurantView setNeedsDisplay];
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
    self.secondTab.curLocation = self.curLocation;
    
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
