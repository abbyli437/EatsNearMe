//
//  SettingsViewController.m
//  EatsNearMe
//
//  Created by Abby Li on 7/12/21.
//

#import "SettingsViewController.h"
#import "TTRangeSlider.h"

@interface SettingsViewController ()

@property (strong, nonatomic) TTRangeSlider *priceSlider;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UISlider *distanceSlider;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self makePriceSlider];
    [self getPriceText];
}

- (void)makePriceSlider {
    CGRect priceFrame = CGRectMake(self.distanceSlider.frame.origin.x, self.priceLabel.frame.origin.y + 25, self.distanceSlider.frame.size.width, 50);
    self.priceSlider = [[TTRangeSlider alloc] initWithFrame:priceFrame];
    //[self.priceSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    
    self.priceSlider.delegate = self;
    self.priceSlider.minValue = 1;
    self.priceSlider.maxValue = 4;
    self.priceSlider.selectedMinimum = 1;
    self.priceSlider.selectedMaximum = 4;
    self.priceSlider.hideLabels = true;
    self.priceSlider.enableStep = true;
    self.priceSlider.step = 1;
    
    [self.contentView addSubview:self.priceSlider];
}

- (void)getPriceText {
    NSString *priceString = @"";
    for (int i = 0; i < self.priceSlider.minValue; i++) {
        priceString = [priceString stringByAppendingString:@"$"];
    }
    priceString = [priceString stringByAppendingString:@" - "];
    for (int i = 0; i < self.priceSlider.maxValue; i++) {
        priceString = [priceString stringByAppendingString:@"$"];
    }
    self.priceLabel.text = priceString;
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
