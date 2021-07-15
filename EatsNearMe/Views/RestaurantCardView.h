//
//  RestaurantCardView.h
//  EatsNearMe
//
//  Created by Abby Li on 7/15/21.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@import YelpAPI;

NS_ASSUME_NONNULL_BEGIN

@protocol RestaurantCardViewDelegate <NSObject>

-(void)cardSwipedLeft:(UIView *)card;
-(void)cardSwipedRight:(UIView *)card;
-(void)afterSwipeAction:(UIView *)card;

@end

@interface RestaurantCardView : UIView

@property id <RestaurantCardViewDelegate> delegate;


//UI elements on view
@property (strong, nonatomic) UIImageView *restaurantImage;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UILabel *priceLabel;
@property (strong, nonatomic) UILabel *distanceLabel;
@property (strong, nonatomic) UIImageView *checkMarkImage;

@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic) CGPoint originalPoint;
@property (strong, nonatomic) YLPBusiness *restaurant;
@property (strong, nonatomic) CLLocation *curLocation;

@end

NS_ASSUME_NONNULL_END
