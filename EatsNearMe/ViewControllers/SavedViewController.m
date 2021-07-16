//
//  SavedViewController.m
//  EatsNearMe
//
//  Created by Abby Li on 7/13/21.
//

#import "SavedViewController.h"
#import "RestaurantCell.h"
#import "DetailsViewController.h"

@interface SavedViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

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
