//
//  Unvisited+CoreDataProperties.h
//  
//
//  Created by Abby Li on 8/3/21.
//
//

#import "Unvisited+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface Unvisited (CoreDataProperties)

+ (NSFetchRequest<Unvisited *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSDictionary *restaurants;

@end

NS_ASSUME_NONNULL_END
