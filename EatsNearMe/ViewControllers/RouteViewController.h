//
//  RouteViewController.h
//  EatsNearMe
//
//  Created by Abby Li on 7/29/21.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RouteViewController : UIViewController

@property (strong, nonatomic) MKMapItem *destination;

@end

NS_ASSUME_NONNULL_END
