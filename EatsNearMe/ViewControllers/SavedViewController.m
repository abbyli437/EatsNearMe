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
@import YelpAPI;

@interface SavedViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *idArr;
@property (strong, nonatomic) NSMutableArray *restaurants;

@end

@implementation SavedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    for (NSString *key in [self.restaurantDict keyEnumerator]) {
        [self.idArr addObject:self.restaurantDict[key]];
        //query here to save runtime
        NSString *businessID = self.restaurantDict[key];
        [[AppDelegate sharedClient] businessWithId:businessID completionHandler:^(YLPBusiness * _Nullable business, NSError * _Nullable error) {
            if (business != nil) {
                [self.restaurants addObject:business];
                NSLog(business.name);
                [self.tableView reloadData];
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
    
    [self.tableView reloadData];
}
//table view methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.restaurants.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RestaurantCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"RestaurantCell" forIndexPath:indexPath];
    
    YLPBusiness *restaurant = [self.restaurants objectAtIndex:indexPath.row];
    cell.curLocation = self.curLocation;
    cell.restaurant = restaurant;
    NSString *businessID = [self.idArr objectAtIndex:indexPath.row];
    
    /*
    [[AppDelegate sharedClient] businessWithId:businessID completionHandler:^(YLPBusiness * _Nullable business, NSError * _Nullable error) {
        if (business != nil) {
            [self.restaurants addObject:business];
            NSLog(business.name);
        }
        else {
            NSLog(@"%@", error.localizedDescription);
        }
    }]; */
    
    //this is problematic because the cell is probably nil at this point since the call is async- but I can't put return in completion block because that's bad :(
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"detailsSegue"]) {
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell]; //this is nil?
        YLPBusiness *restaurant = self.restaurants[indexPath.row];
        
        DetailsViewController *detailsViewController = [segue destinationViewController];
        RestaurantCell *restaurantCell = sender;
        detailsViewController.distString = restaurantCell.distanceLabel.text;
        detailsViewController.restaurant = restaurant;
    }
}


@end
