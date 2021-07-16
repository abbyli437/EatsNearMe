//
//  ParseManager.h
//  EatsNearMe
//
//  Created by Abby Li on 7/13/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ParseUtil : NSObject

+ (void)updateValues:(NSArray *)vals keys:(NSArray *)keys;
+ (void)updateValue:(NSObject *)val key:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
