//
//  AlertUtil.m
//  EatsNearMe
//
//  Created by Abby Li on 7/12/21.
//

#import "AlertUtil.h"
#import <UIKit/UIKit.h>

@implementation AlertUtil

+ (UIAlertController *)makeAlert:(NSString *)title withMessage:(NSString *)message {
    //set up alert
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
        message:message
        preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
        style:UIAlertActionStyleDefault
        handler:^(UIAlertAction * _Nonnull action) {
        }];
    
    // add the OK action to the alert controller
    [alert addAction:okAction];
    
    return alert;
}

@end
