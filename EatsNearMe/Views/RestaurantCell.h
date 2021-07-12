//
//  RestaurantCell.h
//  EatsNearMe
//
//  Created by Abby Li on 7/12/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RestaurantCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *hasVisitedButton;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@end

NS_ASSUME_NONNULL_END
