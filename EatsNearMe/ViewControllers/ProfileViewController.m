//
//  ProfileViewController.m
//  EatsNearMe
//
//  Created by Abby Li on 7/12/21.
//

#import "ProfileViewController.h"
#import "Parse/Parse.h"
#import "SceneDelegate.h"
#import "LoginViewController.h"
#import "ImageUtil.h"
@import Parse;

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet PFImageView *pfpImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) UIImagePickerController *imagePickerVC;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PFUser *user = [PFUser currentUser];
    self.nameLabel.text = user.username;
    
    [self getPFP];
    
    //sets up image picker
    self.imagePickerVC = [ImageUtil makeImagePicker];
    self.imagePickerVC.delegate = self;
}

- (IBAction)logoutTap:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // PFUser.current() will now be nil
        SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        sceneDelegate.window.rootViewController = loginViewController;
    }];
}

- (void)getPFP {
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:[PFUser currentUser].objectId
                               block:^(PFObject *user, NSError *error) {
        self.pfpImage.file = user[@"pfp"];
        [self.pfpImage loadInBackground];
        
        self.pfpImage.layer.cornerRadius  = self.pfpImage.frame.size.width/2;
        self.pfpImage.clipsToBounds = YES;
        
        NSLog(@"successfully retrieved pfp");
   }];
}

- (IBAction)changePfp:(id)sender {
    [self presentViewController:self.imagePickerVC animated:YES completion:nil];
}

- (void)updatePfp {
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    PFUser *user = [PFUser currentUser];
    
    //resize object and convert object to PFFile
    UIImage *img = [ImageUtil resizeImage:self.pfpImage.image withSize:CGSizeMake(300, 300)];
    NSData *imageData = UIImagePNGRepresentation(img);
    // get image data and check if that is not nil
    if (!imageData) {
        return;
    }
    
    PFFileObject *pfpObject = [PFFileObject fileObjectWithName:@"image.png" data:imageData];

     // Retrieve the object by id
    [query getObjectInBackgroundWithId:user.objectId
                                block:^(PFObject *user, NSError *error) {
        [user setObject:pfpObject forKey:@"pfp"];
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        NSLog(@"successfully updated pfp");
        }];
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
   
    // Get the image captured by the UIImagePickerController
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];

    // Do something with the images (based on your use case)
    self.pfpImage.image = editedImage;
    [self updatePfp];
    
   
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
