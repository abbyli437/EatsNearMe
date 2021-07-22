//
//  HomeViewController.m
//  EatsNearMe
//
//  Created by Abby Li on 7/12/21.
//

#import "HomeViewController.h"
#import "ProfileViewController.h"
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
@property (nonatomic) bool isFetching;
@property (nonatomic) CGPoint cardCenter;
@property (strong, nonatomic) UIAlertController *alert;

@property (nonatomic) int counter;
@property (strong, nonatomic) PriorityQueue *queue;
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

@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;

@end

@implementation HomeViewController

//TODO: add spinner for loading
//or just fetch 20 restaurants and get more later to make fetch faster
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.user = [[PFUser currentUser] fetch];
    
    [self setUpLocation];
    
    //set up Yes button
    [self setUpButton:self.yesButton];
    self.yesButton.imageView.tintColor = [UIColor greenColor];
    
    //set up No button
    [self setUpButton:self.noButton];
    self.noButton.imageView.tintColor = [UIColor redColor];
    
    self.firstTime = true;
    
    self.restaurantView.layer.cornerRadius = 10;
    self.restaurantView.layer.masksToBounds = true;
    //self.restaurantView.alpha = 0;
    
    self.cardCenter = self.restaurantView.center;
    
    self.counter = 0;
    
    self.alert = [self makeAlert];
    
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
    self.queue = [[PriorityQueue alloc] initWithCapacity:100]; //might make bigger depending on
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
        //update query
        self.query.radiusFilter = [self.user[@"maxDistance"] doubleValue] * 1609.0;
        self.query.offset = 0;
        self.query.limit = 50; //because we want a fresh batch of 50 to start out with
        
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
    double maxPercent1 = 0.0;
    double maxPercent2 = 0.0;
    
    //max percent for restaurant 1
    for (YLPCategory *category in obj1.categories) {
        double numSwipes = [[self.categoryDict valueForKey:category.name] doubleValue];
        if (numSwipes > maxPercent1) {
            maxPercent1 = numSwipes;
        }
    }
            
    //max percent for restaurant 2
    for (YLPCategory *category in obj2.categories) {
        double numSwipes = [[self.categoryDict valueForKey:category.name] doubleValue];
        if (numSwipes > maxPercent2) {
            maxPercent2 = numSwipes;
        }
    }
    
    //other things to compare: reviews, number of reviews
    if (maxPercent1 == maxPercent2 ||
        fmin(maxPercent1, maxPercent2) / fmax(maxPercent1, maxPercent2) >= 0.8) {
        if (obj1.rating > obj2.rating
            || (obj1.rating == obj2.rating && obj1.reviewCount > obj2.reviewCount)) {
            return (NSComparisonResult) NSOrderedAscending;
        }
        else if (obj1.rating == obj2.rating && obj1.reviewCount == obj2.reviewCount) {
            return (NSComparisonResult) NSOrderedSame;
        }
        return (NSComparisonResult) NSOrderedDescending;
    }
    /*
    if (maxPercent1 == maxPercent2) {
        return (NSComparisonResult) NSOrderedSame;
    } */
    else if (maxPercent1 < maxPercent2) {
        return (NSComparisonResult) NSOrderedDescending;
    }
    //bigger percentage is "smaller" because the queue takes the smallest priority first!
    return (NSComparisonResult) NSOrderedAscending;
}

- (void)setUpButton:(UIButton *)button {
    //set up Yes button
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    button.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    button.layer.cornerRadius  = self.yesButton.frame.size.width/2;
    button.clipsToBounds = YES;
}

- (IBAction)tapYes:(id)sender {
    [self afterSwipeAction:200 isLeft:false];
}

- (IBAction)tapNo:(id)sender {
    [self afterSwipeAction:-200 isLeft:true];
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
        YLPBusiness *restaurant = [self.queue poll];
        if (isLeft) {
            NSMutableDictionary *leftSwipes = [self.swipes objectForKey:@"leftSwipes"];
            [leftSwipes setValue:restaurant.name forKey:restaurant.name];
        }
        else {
            NSMutableDictionary *rightSwipes = [self.swipes objectForKey:@"rightSwipes"];
            //store phone number so I can use it in phone query in later fetches
            [rightSwipes setValue:restaurant.phone forKey:restaurant.name];
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
    NSLog([@([self.queue size]) stringValue]);
    
    //this makes sure my code is in bounds
    if ([self.queue isEmpty]) {
        self.counter = 0;
        if (!self.firstTime && !self.isFetching) {
            [self presentViewController:self.alert animated:YES completion:nil];
        }
        else {
            self.query.offset += 50;
            [self fetchRestaurants];
        }
        return;
    }
    
    self.isFetching = false;
    
    if (self.totalSwipes >= 20 && self.counter == 5) {
        //after the first 50 (to train the PQ) increment by 10's
        self.counter = 0;
        
        self.query.offset = self.query.offset + 5;
        self.query.limit = 5;
        [self fetchRestaurants];
    }

    YLPBusiness *restaurant = [self.queue peek];
    self.counter++;
    
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
            self.query.offset += self.query.limit;
            self.query.limit = 50;
            self.counter = 0;
        
            [self fetchRestaurants];
        }];
    [alert addAction:yesAction];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No"
        style:UIAlertActionStyleDefault
        handler:nil];
    [alert addAction:noAction];
    
    return alert;
}

//fetch code
- (void)fetchRestaurants {
    self.isFetching = true;
    __weak HomeViewController *const weakSelf = self;
    HomeViewController *const strongSelf = weakSelf;
    
    //finally, the actual query
    [[AppDelegate sharedClient] searchWithQuery:self.query completionHandler:^(YLPSearch * _Nullable search, NSError * _Nullable error) {
        if (search != nil) {
            NSLog(@"successfully fetched restaurants");
            
            NSMutableDictionary *leftSwipes = [strongSelf.swipes objectForKey:@"leftSwipes"];
            NSMutableDictionary *rightSwipes = [strongSelf.swipes objectForKey:@"rightSwipes"];
            strongSelf.totalSwipes = ((int) leftSwipes.count) + ((int) rightSwipes.count); //keep track of total swipes
            
            for (YLPBusiness *restaurant in search.businesses) {
                if ([leftSwipes objectForKey:restaurant.name] == nil && [rightSwipes objectForKey:restaurant.name] == nil) {
                    //restuarant hasn't been seen before
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

- (void)fetchSavedRestaurants {
    __weak HomeViewController *const weakSelf = self;
    HomeViewController *const strongSelf = weakSelf;
    
    NSMutableDictionary *rightSwipes = [self.swipes objectForKey:@"rightSwipes"];
    //loop through every restaurant in rightSwipes dict and fetch the corresponding YLPBusiness using the phone number
    for (NSString *key in rightSwipes.keyEnumerator) {
        NSString *phoneNumber = [rightSwipes valueForKey:key];
        [[AppDelegate sharedClient] businessWithPhoneNumber:phoneNumber completionHandler:^(YLPSearch * _Nullable search, NSError * _Nullable error) {
            if (search != nil) {
                for (YLPBusiness *restaurant in search.businesses) {
                    [strongSelf.rightSwipes addObject:restaurant];
                    NSLog(restaurant.name);
                }
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
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

    //set up/update main query and store it
    double latitude = (double) self.curLocation.coordinate.latitude;
    double longitude = (double) self.curLocation.coordinate.longitude;
    YLPCoordinate *coord = [[YLPCoordinate alloc] initWithLatitude:latitude longitude:longitude];
    self.query = [[YLPQuery alloc] initWithCoordinate:coord];
    self.query.limit = 50;
    self.query.offset = self.totalSwipes;
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
        [self fetchSavedRestaurants];
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
