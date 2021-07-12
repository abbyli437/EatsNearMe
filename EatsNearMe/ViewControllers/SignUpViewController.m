//
//  SignUpViewController.m
//  EatsNearMe
//
//  Created by Abby Li on 7/12/21.
//

#import "SignUpViewController.h"
#import "Parse/Parse.h"
#import "AlertUtil.h"

@interface SignUpViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //sets up text fields
    self.usernameField.placeholder = @"Username";
    self.passwordField.placeholder = @"Password";
    self.passwordField.secureTextEntry = true;
}

- (IBAction)signUpTap:(id)sender {
    //set up alert
    UIAlertController *alert = [AlertUtil makeAlert:@"Invalid Sign Up" withMessage:@"Username or Password field is blank"];
    
    if ([self.usernameField.text isEqual:@""] || [self.passwordField.text isEqual:@""]) {
        [self presentViewController:alert animated:YES completion:^{
        }];
    }
    else {
        // initialize a user object
        PFUser *newUser = [PFUser user];
           
        // set user properties
        newUser.username = self.usernameField.text;
        newUser.password = self.passwordField.text;
           
        // call sign up function on the object
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (error != nil) {
                NSLog(@"Error: %@", error.localizedDescription);
            }
            else {
                NSLog(@"User registered successfully");
                   
                // manually segue to logged in view
                [self performSegueWithIdentifier:@"signUpToHomeSegue" sender:nil];
            }
        }];
    }
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
