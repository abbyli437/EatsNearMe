//
//  AppDelegate.m
//  EatsNearMe
//
//  Created by Abby Li on 7/1/21.
//

#import "AppDelegate.h"
#import "Parse/Parse.h"
@import YelpAPI;

@interface AppDelegate ()
@property (strong, nonatomic) YLPClient *client;
@end

@implementation AppDelegate

+ (YLPClient *)sharedClient {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return appDelegate.client;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Sets up parse backend
    ParseClientConfiguration *config = [ParseClientConfiguration  configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"ELzPSa3MblR0bQ8QTCQBM1Sl3cVnwI7tLrV3zRrc";
        configuration.clientKey = @"UkysAGRP1JU4mX4e0K1yEHbG0VtvtqWXSu6N2YAe";
        configuration.server = @"https://parseapi.back4app.com";
    }];

    [Parse initializeWithConfiguration:config];
    
    //Sets up Yelp API
    NSString *filePath = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSString *clientId = plistData[@"clientId"];
    NSString *apiKey = plistData[@"apiKey"];
    self.client = [[YLPClient alloc] initWithAPIKey:apiKey];
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
