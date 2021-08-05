//
//  Visited+CoreDataProperties.h
//  
//
//  Created by Abby Li on 8/4/21.
//
//

#import "Visited+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface Visited (CoreDataProperties)

+ (NSFetchRequest<Visited *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSDictionary *restaurants;

@end

NS_ASSUME_NONNULL_END
