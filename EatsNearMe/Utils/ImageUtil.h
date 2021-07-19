//
//  ImageUtil.h
//  EatsNearMe
//
//  Created by Abby Li on 7/19/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageUtil : NSObject <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

+ (UIImagePickerController *)makeImagePicker;

+ (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
