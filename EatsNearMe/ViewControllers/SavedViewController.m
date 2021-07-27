//
//  SavedViewController.m
//  EatsNearMe
//
//  Created by Abby Li on 7/13/21.
//

#import "SavedViewController.h"
#import "RestaurantCell.h"
#import "DetailsViewController.h"
#import "AppDelegate.h"
#import "Parse/Parse.h"
@import YelpAPI;

@interface SavedViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *visitedSegment;

@property (strong, nonatomic) NSMutableArray *restaurantDicts;

@property (strong, nonatomic) NSMutableDictionary *unvisitedDict;
@property (strong, nonatomic) NSMutableArray *unvisitedKeys;

@property (strong, nonatomic) NSMutableDictionary *visitedDict;
@property (strong, nonatomic) NSMutableArray *visitedKeys;

@end

@implementation SavedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    PFUser *user = [PFUser currentUser];
    NSMutableDictionary *swipes = user[@"swipes"];
    self.restaurantIds = swipes[@"rightSwipes"];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.restaurantDicts = [[NSUserDefaults standardUserDefaults] objectForKey:user.username];
    
    //if user defaults returns nil
    if (self.restaurantDicts == nil) {
        self.restaurantDicts = [[NSMutableArray alloc] init];
        self.unvisitedDict = [[NSMutableDictionary alloc] init];
        self.visitedDict = [[NSMutableDictionary alloc] init];
        [self.restaurantDicts addObject:self.unvisitedDict];
        [self.restaurantDicts addObject:self.visitedDict];
        
        [self fetchRestaurants];
    }
    //if user defaults return empty dictionaries when Parse is not empty
    else if (self.unvisitedDict.count == 0
             && self.visitedDict.count == 0
             && self.restaurantIds.count != 0) {
        [self fetchRestaurants];
    }
    
    [self.tableView reloadData];
}

- (void)fetchRestaurants {
    self.restaurants = [[NSMutableArray alloc] init];
    for (NSString *key in [self.restaurantIds keyEnumerator]) {
        //query here to save runtime
        NSString *businessID = self.restaurantIds[key];
        [[AppDelegate sharedClient] businessWithId:businessID completionHandler:^(YLPBusiness * _Nullable business, NSError * _Nullable error) {
            if (business != nil) {
                [self.restaurants addObject:business];
                NSLog(business.name);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}

//table view methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.restaurantDicts != nil) {
        return self.restaurantDicts.count;
    }
    return self.restaurants.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RestaurantCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"RestaurantCell" forIndexPath:indexPath];
    cell.curLocation = self.curLocation;
    
    if (self.restaurantDicts == nil) {
        YLPBusiness *restaurant = [self.restaurants objectAtIndex:indexPath.row];
        cell.restaurant = restaurant;
    }
    else {
        NSDictionary *restaurantDict = [self.restaurantDicts objectAtIndex:indexPath.row];
        cell.restaurantDict = restaurantDict;
    }
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // TODO: also have a dictinary with Details method in Details view
    if ([[segue identifier] isEqualToString:@"detailsSegue"]) {
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        
        DetailsViewController *detailsViewController = [segue destinationViewController];
        RestaurantCell *restaurantCell = sender;
        detailsViewController.distString = restaurantCell.distanceLabel.text;
        
        if (self.restaurantDicts == nil) {
            YLPBusiness *restaurant = self.restaurants[indexPath.row];
            detailsViewController.restaurant = restaurant;
        }
        else {
            NSString *businessID = self.restaurantDicts[indexPath.row][@"identifier"];
            detailsViewController.businessID = businessID;
        }
    }
}


@end
