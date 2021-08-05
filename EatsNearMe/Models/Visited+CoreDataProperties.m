//
//  Visited+CoreDataProperties.m
//  
//
//  Created by Abby Li on 8/4/21.
//
//

#import "Visited+CoreDataProperties.h"

@implementation Visited (CoreDataProperties)

+ (NSFetchRequest<Visited *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Visited"];
}

@dynamic restaurants;

@end
