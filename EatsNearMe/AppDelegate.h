//
//  AppDelegate.h
//  EatsNearMe
//
//  Created by Abby Li on 7/1/21.
//

#import <UIKit/UIKit.h>
@import YelpAPI;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

+ (YLPClient *)sharedClient;

@end

