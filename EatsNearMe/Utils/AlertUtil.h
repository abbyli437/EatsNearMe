//
//  AlertUtil.h
//  EatsNearMe
//
//  Created by Abby Li on 7/12/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlertUtil : NSObject

+ (UIAlertController *)makeAlert:(NSString *)title withMessage:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
