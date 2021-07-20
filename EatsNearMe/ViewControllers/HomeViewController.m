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
#import "PriorityQueue.h"
@import YelpAPI;

@interface HomeViewController ()  <CLLocationManagerDelegate, PriorityQueueDelegate>

@property (strong, nonatomic) PFUser *user;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *curLocation;
@property (strong, nonatomic) YLPQuery *query;
@property (strong, nonatomic) SavedViewController *secondTab;
@property (nonatomic) bool firstTime;
@property (nonatomic) CGPoint cardCenter;
@property (nonatomic) int offset;

@property (strong, nonatomic) NSMutableArray *restaurants;
@property (nonatomic) int currentIndex;
@property (strong, nonatomic) PriorityQueue *queue; //delete this later?
@property (strong, nonatomic) NSMutableDictionary *swipes;
@property (strong, nonatomic) NSMutableArray *rightSwipes;
@property (strong, nonatomic) NSMutableDictionary *categoryDict;
@property (nonatomic) int totalSwipes;

//card view props
@property (weak, nonatomic) IBOutlet UIView *restaurantView;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImage;
@property (weak, nonatomic) IBOutlet UIImageView *restaurantImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation HomeViewController

//TODO: add spinner for loading
//or just fetch 20 restaurants and get more later to make fetch faster
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.user = [[PFUser currentUser] fetch];
    self.offset = [self.user[@"offset"] intValue];
    
    [self setUpLocation];
    
    self.firstTime = true;
    
    self.restaurantView.layer.cornerRadius = 10;
    self.restaurantView.layer.masksToBounds = true;
    //self.restaurantView.alpha = 0;
    
    self.cardCenter = self.restaurantView.center;
    
    self.currentIndex = 0;
    
    //might use swipes to only store restaurant names because Parse can't store YLPBusiness objects
    if (self.user[@"swipes"] != nil) {
        self.swipes = self.user[@"swipes"];
    }
    else {
        self.swipes = [[NSMutableDictionary alloc] initWithCapacity:10];
        [self.swipes setObject:[[NSMutableDictionary alloc] init] forKey:@"leftSwipes"];
        [self.swipes setObject:[[NSMutableDictionary alloc] init] forKey:@"rightSwipes"];
        self.categoryDict = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    
    if (self.user[@"categoryDict"] != nil) {
        self.categoryDict = self.user[@"categoryDict"];
    }
    else {
        self.categoryDict = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    
    NSMutableDictionary *leftSwipes = [self.swipes objectForKey:@"leftSwipes"];
    NSMutableDictionary *rightSwipes = [self.swipes objectForKey:@"rightSwipes"];
    self.totalSwipes = ((int) leftSwipes.count) + ((int) rightSwipes.count);
    
    //keep track of swipes locally
    self.rightSwipes = [[NSMutableArray alloc] init];
    self.restaurants = [[NSMutableArray alloc] init];
    self.queue = [[PriorityQueue alloc] initWithCapacity:50];
    self.queue.delegate = self;
    
    //to pass right swipes to Saved Tab
    UINavigationController *secondController = self.tabBarController.viewControllers[1];
    self.secondTab = secondController.viewControllers.firstObject;
    self.secondTab.restaurants = self.rightSwipes;
}

- (void)viewDidAppear:(BOOL)animated {
    int maxDist = [self.user[@"maxDistance"] intValue];
    int priceRangeLow = [self.user[@"priceRangeLow"] intValue];
    int priceRangeHigh = [self.user[@"priceRangeHigh"] intValue];
    self.user = [[PFUser currentUser] fetch];
    
    //update query and re-fetch if settings have changed
    if ([self.user[@"maxDistance"] intValue] != maxDist
        || [self.user[@"priceRangeHigh"] intValue] != priceRangeHigh
        || [self.user[@"priceRangeLow"] intValue] != priceRangeLow) {
        self.offset = 0; //not sure if I should update this on backend too
        
        //update query
        self.query.radiusFilter = [self.user[@"maxDistance"] doubleValue] * 1609.0;
        self.query.offset = 0;
        
        //set up price parameter
        int low = [self.user[@"priceRangeLow"] intValue];
        int high = [self.user[@"priceRangeHigh"] intValue];
        NSString *priceQuery = [NSString stringWithFormat:@"%d", low];
        for (int i = low + 1; i <= high; i++) {
            priceQuery = [priceQuery stringByAppendingString:@", "];
            priceQuery = [priceQuery stringByAppendingString:[NSString stringWithFormat:@"%d", i]];
        }
        self.query.price = priceQuery;
        
        [self fetchRestaurants];
    }
}

- (NSComparisonResult)compare:(YLPBusiness *)obj1 obj2:(YLPBusiness *)obj2 {
    if (self.totalSwipes == 0) {
        return (NSComparisonResult) NSOrderedSame;
    }
            
    double maxPercent1 = 0.0;
    double maxPercent2 = 0.0;
    
    //max percent for restaurant 1
    for (YLPCategory *category in obj1.categories) {
        double numSwipes = [[self.categoryDict valueForKey:category.name] doubleValue]; //this is giving me a weird warning
        double percent = numSwipes / self.totalSwipes;
        if (percent > maxPercent1) {
            maxPercent1 = percent;
         }
    }
            
    //max percent for restaurant 2
    for (YLPCategory *category in obj2.categories) {
        double numSwipes = [[self.categoryDict valueForKey:category.name] doubleValue];
        double percent = numSwipes / self.totalSwipes;
        if (percent > maxPercent2) {
            maxPercent2 = percent;
        }
    }
             
    if (maxPercent1 == maxPercent2) {
        return (NSComparisonResult) NSOrderedSame;
    }
    else if (maxPercent1 < maxPercent2) {
        return (NSComparisonResult) NSOrderedAscending;
    }
    return (NSComparisonResult) NSOrderedDescending;
}

- (IBAction)swipeRestaurant:(UIPanGestureRecognizer *)sender {
    if (sender.view == nil) {
        return;
    }
    
    UIView *restaurantCard = sender.view;
    CGPoint point = [sender translationInView:self.view];
    float centerX = self.view.center.x;
    restaurantCard.center = CGPointMake(centerX + point.x, self.view.center.y + point.y);
    float xFromCenter = restaurantCard.center.x - centerX;
    
    //sets up image for swipe left/right
    if (xFromCenter < 0) {
        self.checkMarkImage.image = [UIImage systemImageNamed:@"xmark.circle.fill"];
        self.checkMarkImage.tintColor = [UIColor redColor];
    }
    else {
        self.checkMarkImage.image = [UIImage systemImageNamed:@"checkmark.circle.fill"];
        self.checkMarkImage.tintColor = [UIColor greenColor];
    }
    
    self.checkMarkImage.alpha = fabsf(xFromCenter) / centerX;
    
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
    //increment total swipes
    self.totalSwipes = self.totalSwipes + 1;
    
    //move card off to the correct direction
    [UIView animateWithDuration:0.3 animations:^{
        self.restaurantView.center = CGPointMake(self.restaurantView.center.x + swipeDir, self.restaurantView.center.y);
    } completion:^(BOOL finished) {
        //TODO: poll here, peek earlier
        YLPBusiness *restaurant = [self.queue poll];
        //YLPBusiness *restaurant = self.restaurants[self.currentIndex - 1];
        if (isLeft) {
            NSMutableDictionary *leftSwipes = [self.swipes objectForKey:@"leftSwipes"];
            [leftSwipes setValue:restaurant.name forKey:restaurant.name];
        }
        else {
            NSMutableDictionary *rightSwipes = [self.swipes objectForKey:@"rightSwipes"];
            [rightSwipes setValue:restaurant.name forKey:restaurant.name];
            [self.rightSwipes addObject:restaurant];
            
            //update category count
            for (YLPCategory *category in restaurant.categories) {
                if ([self.categoryDict objectForKey:category.name] == nil) {
                    [self.categoryDict setValue:@(1) forKey:category.name];
                }
                else {
                    int catCount = [[self.categoryDict valueForKey:category.name] intValue] + 1;
                    [self.categoryDict setValue:@(catCount) forKey:category.name];
                }
            }
            [ParseUtil updateValue:self.categoryDict key:@"categoryDict"];
        }
   
        [ParseUtil updateValue:self.swipes key:@"swipes"];
        
        [self loadNextRestaurant];
    }];
}

- (void)loadNextRestaurant {
    sleep(0.25);
    
    //this makes sure my code is in bounds
    if ([self.queue isEmpty]) { //(self.currentIndex >= self.restaurants.count) {
        UIAlertController *alert = [self makeAlert];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    //YLPBusiness *restaurant = self.restaurants[self.currentIndex];
    YLPBusiness *restaurant = [self.queue peek];
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

- (UIAlertController *)makeAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Load more restaurants?"
        message:@"Load more restaurants?"
        preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes"
        style:UIAlertActionStyleDefault
        handler:^(UIAlertAction * _Nonnull action) {
            self.offset += 50;
            self.query.offset += 50; //probably need this bc int is not pointer
            self.currentIndex = 0;
        
            [ParseUtil updateValue:@(self.offset) key:@"offset"];
        
            [self fetchRestaurants];
        }];
    [alert addAction:yesAction];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No"
        style:UIAlertActionStyleDefault
        handler:nil];
    [alert addAction:noAction];
    
    return alert;
}

- (void)fetchRestaurants {
    //PFUser *user = [[PFUser currentUser] fetch];
    
    __weak HomeViewController *const weakSelf = self;
    HomeViewController *const strongSelf = weakSelf;
    
    //finally, the actual query
    [[AppDelegate sharedClient] searchWithQuery:self.query completionHandler:^(YLPSearch * _Nullable search, NSError * _Nullable error) {
        if (search != nil) {
            strongSelf.restaurants = [[NSMutableArray alloc] init]; //reset restaurants to save space
            //TODO: reinit queue here
            NSLog(@"successfully fetched restaurants");
            
            NSMutableDictionary *leftSwipes = [strongSelf.swipes objectForKey:@"leftSwipes"];
            NSMutableDictionary *rightSwipes = [strongSelf.swipes objectForKey:@"rightSwipes"];
            strongSelf.totalSwipes = ((int) leftSwipes.count) + ((int) rightSwipes.count); //keep track of total swipes
            
            for (YLPBusiness *restaurant in search.businesses) {
                if ([rightSwipes objectForKey:restaurant.name] != nil) {
                    [strongSelf.rightSwipes addObject:restaurant];
                }
                else if ([leftSwipes objectForKey:restaurant.name] == nil) {
                    //restuarant hasn't been seen before
                    [strongSelf.restaurants addObject:restaurant];
                    [strongSelf.queue add:restaurant];
                }
            }
            [strongSelf loadNextRestaurant];
            [strongSelf.restaurantView setNeedsDisplay];
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

    //set up/update query and store it
    double latitude = (double) self.curLocation.coordinate.latitude;
    double longitude = (double) self.curLocation.coordinate.longitude;
    YLPCoordinate *coord = [[YLPCoordinate alloc] initWithLatitude:latitude longitude:longitude];
    self.query = [[YLPQuery alloc] initWithCoordinate:coord];
    self.query.limit = 50;
    self.query.offset = self.offset;
    self.query.radiusFilter = [self.user[@"maxDistance"] doubleValue] * 1609.0;
    
    //set up price parameter
    int low = [self.user[@"priceRangeLow"] intValue];
    int high = [self.user[@"priceRangeHigh"] intValue];
    NSString *priceQuery = [NSString stringWithFormat:@"%d", low];
    for (int i = low + 1; i <= high; i++) {
        priceQuery = [priceQuery stringByAppendingString:@", "];
        priceQuery = [priceQuery stringByAppendingString:[NSString stringWithFormat:@"%d", i]];
    }
    self.query.price = priceQuery;
    
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
