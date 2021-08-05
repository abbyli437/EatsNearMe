//
//  Unvisited+CoreDataProperties.m
//  
//
//  Created by Abby Li on 8/3/21.
//
//

#import "Unvisited+CoreDataProperties.h"

@implementation Unvisited (CoreDataProperties)

+ (NSFetchRequest<Unvisited *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Unvisited"];
}

@dynamic restaurants;

@end
