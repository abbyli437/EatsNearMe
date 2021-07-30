//
//  RouteViewController.m
//  EatsNearMe
//
//  Created by Abby Li on 7/29/21.
//  Most of this code is from https://www.techotopia.com/index.php/Using_MKDirections_to_get_iOS_7_Map_Directions_and_Routes

#import "RouteViewController.h"
#import <MapKit/MapKit.h>
#import "DirectionsCell.h"

@interface RouteViewController () <MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *steps;

@end

@implementation RouteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //table view set up
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.steps = [[NSMutableArray alloc] init];
    
    //map view set up
    self.mapView.showsUserLocation = YES;
    [self.mapView addAnnotation:self.destination.placemark];
    
    MKUserLocation *userLocation = self.mapView.userLocation;
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate,
             5000, 5000);
    [self.mapView setRegion:region animated:NO];
    self.mapView.delegate = self;
    [self getDirections];
}

- (void)getDirections
{
    MKDirectionsRequest *request =
           [[MKDirectionsRequest alloc] init];

    request.source = [MKMapItem mapItemForCurrentLocation];

    request.destination = self.destination;
    request.requestsAlternateRoutes = NO;
        MKDirections *directions =
           [[MKDirections alloc] initWithRequest:request];

        [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             NSLog(error.localizedDescription);
         } else {
             [self showRoute:response];
         }
     }];
}

-(void)showRoute:(MKDirectionsResponse *)response
{
    for (MKRoute *route in response.routes) {
        [self.mapView
           addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
        for (MKRouteStep *step in route.steps) {
            NSLog(@"%@", step.instructions);
            if (step.instructions != nil) {
                [self.steps addObject:step];
            }
        }
    }
    [self.mapView reloadInputViews];
    [self.tableView reloadData];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        [renderer setStrokeColor:[UIColor blueColor]];
        [renderer setLineWidth:5.0];
        return renderer;
    }
    return nil;
}

//table view methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.steps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DirectionsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DirectionsCell" forIndexPath:indexPath];
    MKRouteStep *step = self.steps[indexPath.row];
    cell.directionsLabel.text = step.instructions;
    return cell;
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
