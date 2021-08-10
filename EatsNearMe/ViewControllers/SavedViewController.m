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
#import "ParseUtil.h"
@import YelpAPI;

@interface SavedViewController () <UITableViewDelegate, UITableViewDataSource, RestaurantCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *visitedSegment;

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSMutableArray *restaurantDicts;

@property (strong, nonatomic) NSMutableDictionary *unvisitedDict;
@property (strong, nonatomic) NSArray *unvisitedVals;

@property (strong, nonatomic) NSMutableDictionary *visitedDict;
@property (strong, nonatomic) NSArray *visitedVals;

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
    self.restaurantDicts = [[[NSUserDefaults standardUserDefaults] objectForKey:user.username] mutableCopy];
    self.unvisitedDict = [self.restaurantDicts[0] mutableCopy];
    self.unvisitedVals = [self.unvisitedDict allValues];
    
    self.visitedDict = [self.restaurantDicts[1] mutableCopy];
    self.visitedVals = [self.visitedDict allValues];
    
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

- (void)updateVisit:(NSMutableDictionary *)restaurantDict hasVisited:(bool)hasVisited {
    NSString *name = restaurantDict[@"name"];
    
    if (hasVisited) {
        NSMutableDictionary *res = self.unvisitedDict[name];
        [self.unvisitedDict removeObjectForKey:name];
        [self.visitedDict setObject:res forKey:name];
    }
    else {
        NSMutableDictionary *res = self.visitedDict[name];
        [self.visitedDict removeObjectForKey:name];
        [self.unvisitedDict setObject:res forKey:name];
    }
    
    self.unvisitedVals = [self.unvisitedDict allValues];
    self.visitedVals = [self.visitedDict allValues];
    
    self.restaurantDicts[0] = self.unvisitedDict;
    self.restaurantDicts[1] = self.visitedDict;
    
    [[NSUserDefaults standardUserDefaults] setObject:self.restaurantDicts forKey:self.username];
}

- (IBAction)toggleVisit:(id)sender {
    [self.tableView reloadData];
}

//table view methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.visitedSegment.selectedSegmentIndex == 0) {
        return self.unvisitedDict.count;
    }
    return self.visitedDict.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RestaurantCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"RestaurantCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.curLocation = self.curLocation;
    
    if (self.visitedSegment.selectedSegmentIndex == 0) {
        NSDictionary *restaurantDict = self.unvisitedVals[indexPath.row];
        cell.restaurantDict = [restaurantDict mutableCopy];
    }
    else {
        NSDictionary *restaurantDict = self.visitedVals[indexPath.row];
        cell.restaurantDict = [restaurantDict mutableCopy];
        cell.hasVisitedButton.selected = true;
    }
    return cell;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIContextualAction *delete = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        NSMutableString *alertTitle = [@"Delete " mutableCopy];
        
        NSMutableDictionary *restaurantDict = [[NSMutableDictionary alloc] init];
        if (self.visitedSegment.selectedSegmentIndex == 0) {
            restaurantDict = self.unvisitedVals[indexPath.row];
        }
        else {
            restaurantDict = self.visitedVals[indexPath.row];
        }
        
        [alertTitle appendString:restaurantDict[@"name"]];
        [alertTitle appendString:@"?"];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle
            message:nil
            preferredStyle:(UIAlertControllerStyleAlert)];
        
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes"
            style:UIAlertActionStyleDefault
            handler:^(UIAlertAction * _Nonnull action) {
            [self deleteRestaurant:restaurantDict];
            completionHandler(true);
            }];
        [alert addAction:yesAction];
        
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            completionHandler(false);
        }];
        [alert addAction:noAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }];
    
    delete.image = [UIImage systemImageNamed:@"trash.fill"];
    
    return [UISwipeActionsConfiguration configurationWithActions:@[delete]];
}

- (void)deleteRestaurant:(NSMutableDictionary *)restaurantDict {
    //first update parse
    PFUser *user = [PFUser currentUser];
    NSMutableDictionary *swipes = user[@"swipes"];
    NSMutableDictionary *leftSwipes = swipes[@"leftSwipes"];
    NSMutableDictionary *rightSwipes = swipes[@"rightSwipes"];
    
    NSString *name = restaurantDict[@"name"];
    [leftSwipes setValue:name forKey:name];
    [rightSwipes removeObjectForKey:name];
    
    [ParseUtil updateValue:swipes key:@"swipes"];
    
    //update user defaults
    if (self.visitedSegment.selectedSegmentIndex == 0) {
        [self.unvisitedDict removeObjectForKey:name];
        self.unvisitedVals = [self.unvisitedDict allValues];
        self.restaurantDicts[0] = self.unvisitedDict;
    }
    else {
        [self.visitedDict removeObjectForKey:name];
        self.visitedVals = [self.visitedDict allValues];
        self.restaurantDicts[1] = self.visitedDict;
    }
    [[NSUserDefaults standardUserDefaults] setObject:self.restaurantDicts forKey:self.username];
    [self.tableView reloadData];
    
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
