//
//  RestaurantCell.m
//  EatsNearMe
//
//  Created by Abby Li on 7/12/21.
//

#import "RestaurantCell.h"
#import <CoreLocation/CoreLocation.h>
@import YelpAPI;

@implementation RestaurantCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setRestaurantDict:(NSMutableDictionary *)restaurantDict {
    _restaurantDict = restaurantDict;
    
    //selected
    self.hasVisitedButton.selected = [restaurantDict[@"hasVisited"] boolValue];
    
    //restaurant image
    if (restaurantDict[@"imageURL"] != nil) {
        NSURL *imageURL = [NSURL URLWithString:restaurantDict[@"imageURL"]];
        NSData *data = [[NSData alloc] initWithContentsOfURL:imageURL];
        UIImage *imageData = [[UIImage alloc] initWithData:data];
        self.restaurantImage.image = imageData;
    }
    else {
        self.restaurantImage.image = [UIImage imageNamed:@"comingSoon.png"];
    }
    
    self.nameLabel.text = restaurantDict[@"name"];
    
    //distance label
    double latitude = [restaurantDict[@"latitude"] doubleValue];
    double longitude = [restaurantDict[@"longitude"] doubleValue];
    CLLocation *restaurantLoc = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    [self commonSetUp:restaurantLoc];
}

- (void)commonSetUp:(CLLocation *)restaurantLoc {
    self.restaurantImage.layer.cornerRadius = 10;
    self.restaurantImage.clipsToBounds = YES;
    
    //this is in meters (COMMON SETUP)
    CLLocationDistance dist = [self.curLocation distanceFromLocation:restaurantLoc];
    //convert meters to miles
    double distMiles = dist / 1609.0;
    NSString *distStr = [NSString stringWithFormat:@"%.2f", distMiles];
    distStr = [distStr stringByAppendingString:@" miles away"];
    self.distanceLabel.text = distStr;
}

- (IBAction)tapSave:(id)sender {
    self.hasVisitedButton.selected = !self.hasVisitedButton.selected;
    
    [self.delegate updateVisit:self.restaurantDict hasVisited:self.hasVisitedButton.selected];
}

@end
