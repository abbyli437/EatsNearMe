//
//  DetailsViewController.h
//  EatsNearMe
//
//  Created by Abby Li on 7/13/21.
//

#import <UIKit/UIKit.h>
@import YelpAPI;

NS_ASSUME_NONNULL_BEGIN

@interface DetailsViewController : UIViewController

@property (strong, nonatomic) YLPBusiness *restaurant;
@property (strong, nonatomic) NSString *distString;

@end

NS_ASSUME_NONNULL_END
