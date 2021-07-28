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

@protocol RestaurantCellDelegate <NSObject>

- (void)updateVisit:(NSMutableDictionary *)restaurantDict hasVisited:(bool)hasVisited;

- (void)presentAlert:(NSMutableDictionary *)restaurantDict;
@end

@interface RestaurantCell : UITableViewCell

@property id <RestaurantCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *restaurantImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *hasVisitedButton;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) YLPBusiness *restaurant;
@property (strong, nonatomic) NSMutableDictionary *restaurantDict;
@property (strong, nonatomic) CLLocation *curLocation;

@end

NS_ASSUME_NONNULL_END
