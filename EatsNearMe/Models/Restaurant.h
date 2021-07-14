//
//  Restaurant.h
//  EatsNearMe
//
//  Created by Abby Li on 7/14/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Restaurant : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *restaurantDescription;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *website;
@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) NSURL *imageURL;
@property (nonatomic) bool hasVisited;

@end

NS_ASSUME_NONNULL_END
