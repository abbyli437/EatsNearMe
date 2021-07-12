//
//  LoginViewController.m
//  EatsNearMe
//
//  Created by Abby Li on 7/12/21.
//

#import "LoginViewController.h"
#import "Parse/Parse.h"
#import "AlertUtil.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //sets up text fields
    self.usernameField.placeholder = @"Username";
    self.passwordField.placeholder = @"Password";
    self.passwordField.secureTextEntry = true;
}

- (IBAction)loginTap:(id)sender {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
        
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
            
            UIAlertController *alert = [AlertUtil makeAlert:@"Invalid Login" withMessage:@"Invalid username or incorrect password"];
          
            [self presentViewController:alert animated:YES completion:^{
                }];
        }
        else {
            NSLog(@"User logged in successfully");
                
            // display view controller that needs to shown after successful login
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
        }
    }];
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
