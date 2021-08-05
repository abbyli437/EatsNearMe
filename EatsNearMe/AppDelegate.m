//
//  AppDelegate.m
//  EatsNearMe
//
//  Created by Abby Li on 7/1/21.
//

#import "AppDelegate.h"
#import "Parse/Parse.h"
@import YelpAPI;
@import CoreData;

@interface AppDelegate ()
@property (strong, nonatomic) YLPClient *client;
@property (strong, nonatomic) NSPersistentContainer *persistentContainer;
@property (strong, nonatomic) NSOperationQueue *persistentContainerQueue;
@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

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
    
    //set up core data stack
    self.persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Model"];
    [self.persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *description, NSError *error) {
        if (error != nil) {
            NSLog(@"Failed to load Core Data stack: %@", error);
            abort();
        }
        else {
            self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true;
            _managedObjectContext = self.persistentContainer.viewContext;
        }
    }];
    
    self.persistentContainerQueue = [[NSOperationQueue alloc] init];
    self.persistentContainerQueue.maxConcurrentOperationCount = 1;
    
    return YES;
}

//CoreData methods, found on https://stackoverflow.com/questions/2032818/adding-core-data-to-existing-iphone-project
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];

    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {

        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _persistentStoreCoordinator;
}

- (void)enqueueCoreDataBlock:(void (^)(NSManagedObjectContext* context))block {
  void (^blockCopy)(NSManagedObjectContext*) = [block copy];
    
  [self.persistentContainerQueue addOperation:[NSBlockOperation blockOperationWithBlock:^{
    NSManagedObjectContext* context = self.persistentContainer.viewContext;
    [context performBlockAndWait:^{
        if (blockCopy != nil) {
            blockCopy(context);
        }
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        else {
            NSLog(@"Finished saving in queue");
        }
     }];
  }]];
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory{
   return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
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
