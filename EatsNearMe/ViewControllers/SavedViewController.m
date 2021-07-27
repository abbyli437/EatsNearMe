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

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSMutableArray *restaurantDicts;

@property (strong, nonatomic) NSMutableDictionary *unvisitedDict;
@property (strong, nonatomic) NSMutableArray *unvisitedVals;

@property (strong, nonatomic) NSMutableDictionary *visitedDict;
@property (strong, nonatomic) NSMutableArray *visitedVals;

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
    self.username = user.username;
    NSMutableDictionary *swipes = user[@"swipes"];
    self.restaurantIds = swipes[@"rightSwipes"];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //set up user default data
    self.restaurantDicts = [[NSUserDefaults standardUserDefaults] objectForKey:user.username];
    self.unvisitedDict = self.restaurantDicts[0];
    self.unvisitedVals = [[self.unvisitedDict allValues] mutableCopy];
    
    self.visitedDict = self.restaurantDicts[1];
    self.visitedVals = [[self.visitedDict allValues] mutableCopy];
    
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
    for (NSString *key in [self.restaurantIds keyEnumerator]) {
        //query here to save runtime
        NSString *businessID = self.restaurantIds[key];
        [[AppDelegate sharedClient] businessWithId:businessID completionHandler:^(YLPBusiness * _Nullable business, NSError * _Nullable error) {
            if (business != nil) {
                //update defaults
                NSMutableDictionary *restaurantDictForm = [YLPBusiness restaurantToDict:business];
                [self.unvisitedDict setObject:restaurantDictForm forKey:business.name];
                [[NSUserDefaults standardUserDefaults] setObject:self.restaurantDicts forKey:self.username];
                self.unvisitedVals = [[self.unvisitedDict allValues] mutableCopy];
                
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

//table view methods TODO: update these to reflect the 2 arrays
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.visitedSegment.selectedSegmentIndex == 0) {
        return self.unvisitedDict.count;
    }
    return self.visitedDict.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RestaurantCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"RestaurantCell" forIndexPath:indexPath];
    cell.curLocation = self.curLocation;
    
    if (self.visitedSegment.selectedSegmentIndex == 0) {
        NSDictionary *restaurantDict = self.unvisitedVals[indexPath.row];
        cell.restaurantDict = [restaurantDict mutableCopy];
    }
    else {
        NSDictionary *restaurantDict = self.visitedVals[indexPath.row];
        cell.restaurantDict = [restaurantDict mutableCopy];
    }
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"detailsSegue"]) {
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        
        DetailsViewController *detailsViewController = [segue destinationViewController];
        RestaurantCell *restaurantCell = sender;
        detailsViewController.distString = restaurantCell.distanceLabel.text;
        
        if (self.visitedSegment.selectedSegmentIndex == 0) {
            NSString *businessID = self.unvisitedVals[indexPath.row][@"identifier"];
            detailsViewController.businessID = businessID;
        }
        else {
            NSString *businessID = self.visitedVals[indexPath.row][@"identifier"];
            detailsViewController.businessID = businessID;
        }
    }
}


@end
