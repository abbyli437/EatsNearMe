//
//  SavedViewController.h
//  EatsNearMe
//
//  Created by Abby Li on 7/13/21.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SavedViewController : UIViewController

//probably don't need public restaurant info any more if I can use current user
@property (strong, nonatomic) NSMutableDictionary *restaurantIds;
@property (strong, nonatomic) NSMutableArray *restaurants;
@property (strong, nonatomic) CLLocation *curLocation;

@end

NS_ASSUME_NONNULL_END
