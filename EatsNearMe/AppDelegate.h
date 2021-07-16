//
//  AppDelegate.h
//  EatsNearMe
//
//  Created by Abby Li on 7/1/21.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@import YelpAPI;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) NSMutableArray *savedRestaurants;
@property (nonatomic) CLLocation *curLocation;

+ (YLPClient *)sharedClient;

@end

