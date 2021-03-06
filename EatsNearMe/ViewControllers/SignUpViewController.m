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
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        // initialize a user object
        PFUser *newUser = [PFUser user];
           
        // set user properties
        newUser.username = self.usernameField.text;
        newUser.password = self.passwordField.text;
        
        //default settings
        [newUser setObject:@(2) forKey:@"maxDistance"];
        [newUser setObject:@(1) forKey:@"priceRangeLow"];
        [newUser setObject:@(4) forKey:@"priceRangeHigh"];
        
        //initialize empty dictionary of left/right swipes
        NSMutableDictionary *swipes = [[NSMutableDictionary alloc] initWithCapacity:10];
        [swipes setObject:[[NSMutableDictionary alloc] init] forKey:@"leftSwipes"];
        [swipes setObject:[[NSMutableDictionary alloc] init] forKey:@"rightSwipes"];
        [newUser setObject:swipes forKey:@"swipes"];
        
        //category dict
        NSMutableDictionary *categoryDict = [[NSMutableDictionary alloc] initWithCapacity:10];
        [newUser setObject:categoryDict forKey:@"categoryDict"];
        
        //default offset of 0
        [newUser setValue:@(0) forKey:@"offset"];
        
        // call sign up function on the object
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (error != nil) {
                NSLog(@"Error: %@", error.localizedDescription);
                UIAlertController *alert2 = [AlertUtil makeAlert:@"Error" withMessage:error.localizedDescription];
                [self presentViewController:alert2 animated:YES completion:nil];
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
