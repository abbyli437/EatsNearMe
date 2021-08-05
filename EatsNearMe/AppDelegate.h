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

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
 @property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
 @property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (YLPClient *)sharedClient;
- (NSURL *)applicationDocumentsDirectory;
- (void)enqueueCoreDataBlock:(void (^)(NSManagedObjectContext* context))block;

@end

