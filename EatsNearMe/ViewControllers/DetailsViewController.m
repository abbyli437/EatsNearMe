//
//  DetailsViewController.m
//  EatsNearMe
//
//  Created by Abby Li on 7/13/21.
//

#import "DetailsViewController.h"

@interface DetailsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *restaurantImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *openLabel;
@property (weak, nonatomic) IBOutlet UILabel *websiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //restaurant image
    if (self.restaurant.imageURL != nil) {
        NSData *data = [[NSData alloc] initWithContentsOfURL:self.restaurant.imageURL];
        UIImage *imageData = [[UIImage alloc] initWithData:data];
        self.restaurantImage.image = imageData;
    }
    else {
        self.restaurantImage.image = [UIImage imageNamed:@"comingSoon.png"];
    }
    
    self.nameLabel.text = self.restaurant.name;
    self.descriptionLabel.text = self.restaurant.categories[0].name;
    self.priceLabel.text = self.restaurant.price;
    self.distanceLabel.text = self.distString;
    
    if (self.restaurant.closed) {
        self.openLabel.text = @"Closed";
        self.openLabel.textColor = [UIColor redColor];
    }
    else {
        self.openLabel.text = @"Open";
        self.openLabel.textColor = [UIColor greenColor];
    }
    
    self.websiteLabel.text = self.restaurant.URL.absoluteString;
    self.phoneLabel.text = self.restaurant.phone;
    //self.addressLabel.text = self.restaurant.location.address;
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
