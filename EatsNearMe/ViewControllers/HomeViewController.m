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
#import "RestaurantCardView.h"
@import YelpAPI;

@interface HomeViewController ()  <CLLocationManagerDelegate, RestaurantCardViewDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *curLocation;
@property (strong, nonatomic) NSMutableArray *restaurants;
@property (nonatomic) bool firstTime;
@property (nonatomic) CGPoint cardCenter;
@property (strong, nonatomic) NSMutableArray *rightSwipes;
@property (strong, nonatomic) NSMutableArray *leftSwipes;

//from dynamic views, delete later
@property (strong, nonatomic) NSMutableArray *loadedCards;
@property (nonatomic) int cardsLoadedIndex;
@property (strong, nonatomic) NSMutableArray *allCards; //github version had retain instead of strong

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

static const int MAX_BUFFER_SIZE = 2; //%%% max number of cards loaded at any given time, must be greater than 1
static const float CARD_HEIGHT = 500; //%%% height of the draggable card
static const float CARD_WIDTH = 340; //%%% width of the draggable card

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpLocation];
    self.firstTime = true;
    
    self.restaurantView.layer.cornerRadius = 10;
    self.restaurantView.layer.masksToBounds = true;
    self.restaurantView.alpha = 0;
    
    self.cardCenter = self.restaurantView.center;
    self.currentIndex = 0;
    self.leftSwipes = [[NSMutableArray alloc] init];
    self.rightSwipes = [[NSMutableArray alloc] init];
    
    //old code for buggy dynamic allocation
    self.loadedCards = [[NSMutableArray alloc] init];
    self.allCards = [[NSMutableArray alloc] init];
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
    //note to self: maybe make helper method because this code is almost identical
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (restaurantCard.center.x < 75) {
            //move card off to the left
            [UIView animateWithDuration:0.3 animations:^{
                restaurantCard.center = CGPointMake(restaurantCard.center.x - 200, restaurantCard.center.y);
            } completion:^(BOOL finished) {
                [self.leftSwipes addObject:self.restaurants[self.currentIndex - 1]];
                [self loadNextRestaurant];
            }];
            return;
        }
        else if (restaurantCard.center.x > self.view.frame.size.width - 75) {
            //move card off to the right
            [UIView animateWithDuration:0.3 animations:^{
                restaurantCard.center = CGPointMake(restaurantCard.center.x + 200, restaurantCard.center.y);
            } completion:^(BOOL finished) {
                [self.rightSwipes addObject:self.restaurants[self.currentIndex - 1]];
                [self loadNextRestaurant];
            }];
            return;
        }
        [UIView animateWithDuration:0.2 animations:^{
            restaurantCard.center = self.cardCenter;
            self.checkMarkImage.alpha = 0;
        }];
    }
}

//%%% creates a card and returns it.  This should be customized to fit your needs.
// use "index" to indicate where the information should be pulled.  If this doesn't apply to you, feel free
// to get rid of it (eg: if you are building cards from data from the internet)
-(RestaurantCardView *)makeRestaurantCard:(NSInteger)index
{
    RestaurantCardView *card = [[RestaurantCardView alloc] initWithFrame:CGRectMake(25, 127, CARD_WIDTH, CARD_HEIGHT) restaurant:self.restaurants[index] loc:self.curLocation];
    card.delegate = self;
    return card;
}

//%%% loads all the cards and puts the first x in the "loaded cards" array
-(void)loadCards
{
    if([self.restaurants count] > 0) {
        NSInteger numLoadedCardsCap =(([self.restaurants count] > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:[self.restaurants count]);
        //%%% if the buffer size is greater than the data size, there will be an array error, so this makes sure that doesn't happen
        
        //%%% loops through the exampleCardsLabels array to create a card for each label.  This should be customized by removing "exampleCardLabels" with your own array of data
        for (int i = 0; i<[self.restaurants count]; i++) {
            RestaurantCardView* newCard = [self makeRestaurantCard:i];
            [self.allCards addObject:newCard];
            
            if (i<numLoadedCardsCap) {
                //%%% adds a small number of cards to be loaded
                [self.loadedCards addObject:newCard];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //%%% displays the small number of loaded cards dictated by MAX_BUFFER_SIZE so that not all the cards
            // are showing at once and clogging a ton of data
            for (int i = 0; i<[self.loadedCards count]; i++) {
                if (i>0) {
                    [self.view insertSubview:[self.loadedCards objectAtIndex:i] belowSubview:[self.loadedCards objectAtIndex:i-1]];
                } else {
                    RestaurantCardView *cur = self.loadedCards[i];
                    [self.view addSubview:cur];
                }
                self.cardsLoadedIndex++; //%%% we loaded a card into loaded cards, so we have to increment
            }
        });
    }
}

#warning include own action here!
//%%% action called when the card goes to the left.
// This should be customized with your own action
-(void)cardSwipedLeft:(UIView *)card;
{
    //do whatever you want with the card that was swiped
    //    DraggableView *c = (DraggableView *)card;
    
    [self loadNextRestaurant];
}

#warning include own action here!
//%%% action called when the card goes to the right.
// This should be customized with your own action
-(void)cardSwipedRight:(UIView *)card
{
    //do whatever you want with the card that was swiped
    //    DraggableView *c = (DraggableView *)card;
    [self loadNextRestaurant];
}

- (void)loadNextRestaurant {
    sleep(0.25);
    
    if (self.currentIndex >= [self.restaurants count]) {
        return; //make sure things are in bounds, might add alert here later if I have time
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
    
    /*
    [self.loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    if (self.cardsLoadedIndex < [self.restaurants count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [self.loadedCards addObject:[self.restaurants objectAtIndex:self.cardsLoadedIndex]];
        self.cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self.view insertSubview:[self.loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[self.loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]]; //buggy
    }*/
}

- (void)fetchRestaurants {
    PFUser *user = [[PFUser currentUser] fetch];
    double latitude = (double) self.curLocation.coordinate.latitude;
    double longitude = (double) self.curLocation.coordinate.longitude;
    
    //set up query
    YLPCoordinate *coord = [[YLPCoordinate alloc] init];
    coord = [coord initWithLatitude:latitude longitude:longitude];
    YLPQuery *query = [[YLPQuery alloc] init];
    query = [query initWithCoordinate:coord];
    query.limit = 50; //for testing, change back to 50 later
    //convert miles to meters
    query.radiusFilter = [user[@"maxDistance"] doubleValue] * 1609.0;
    int low = [user[@"priceRangeLow"] intValue];
    int high = [user[@"priceRangeHigh"] intValue];
    
    //set up price parameter
    NSString *priceQuery = [NSString stringWithFormat:@"%d", low];
    for (int i = low + 1; i <= high; i++) {
        priceQuery = [priceQuery stringByAppendingString:@", "];
        priceQuery = [priceQuery stringByAppendingString:[NSString stringWithFormat:@"%d", high]];
    }
    query.price = priceQuery;
    
    //finally, the actual query
    [[AppDelegate sharedClient] searchWithQuery:query completionHandler:^(YLPSearch * _Nullable search, NSError * _Nullable error) {
        if (search != nil) {
            self.restaurants = [NSMutableArray arrayWithArray:search.businesses];
            NSLog(@"successfully fetched restaurants");
            [self loadNextRestaurant];
            [self.restaurantView setNeedsDisplay];
            //[self loadCards]; //new!!
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
