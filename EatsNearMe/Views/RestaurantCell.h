//
//  RestaurantCell.h
//  EatsNearMe
//
//  Created by Abby Li on 7/12/21.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@import YelpAPI;

NS_ASSUME_NONNULL_BEGIN

@interface RestaurantCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *restaurantImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *hasVisitedButton;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) YLPBusiness *restaurant;
@property (strong, nonatomic) CLLocation *curLocation;

@end

NS_ASSUME_NONNULL_END
