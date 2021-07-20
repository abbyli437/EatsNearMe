//
//  SettingsViewController.m
//  EatsNearMe
//
//  Created by Abby Li on 7/12/21.
//

#import "SettingsViewController.h"
#import "TTRangeSlider.h"
#import "ParseUtil.h"
@import Parse;

@interface SettingsViewController () <TTRangeSliderDelegate>

@property (strong, nonatomic) TTRangeSlider *priceSlider;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UISlider *distanceSlider;
@property (strong, nonatomic) PFUser *user;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //note: I can use the synchronous fetch because I'd be doing everything below in the completion block anyways so it's basically the same thing
    self.user = [[PFUser currentUser] fetch];
    [self setUpPriceSlider];
    [self setUpDistanceSlider];
    
    [self getPriceText];
    [self updateDistance:self];
}

- (void)setUpPriceSlider {
    CGRect priceFrame = CGRectMake(self.distanceSlider.frame.origin.x, self.priceLabel.frame.origin.y + 25, self.distanceSlider.frame.size.width, 50);
    self.priceSlider = [[TTRangeSlider alloc] initWithFrame:priceFrame];
    
    self.priceSlider.delegate = self;
    self.priceSlider.minValue = 1;
    self.priceSlider.maxValue = 4;
    
    self.priceSlider.selectedMinimum = [self.user[@"priceRangeLow"] intValue];
    self.priceSlider.selectedMaximum = [self.user[@"priceRangeHigh"] intValue];
    
    self.priceSlider.hideLabels = true;
    self.priceSlider.enableStep = true;
    self.priceSlider.step = 1;
    self.priceSlider.tintColor = [UIColor grayColor];
    self.priceSlider.handleColor = [UIColor whiteColor];
    self.priceSlider.handleDiameter = 25.0;
    self.priceSlider.handleBorderWidth = 1.0;
    self.priceSlider.handleBorderColor = [UIColor grayColor];
    
    [self.contentView addSubview:self.priceSlider];
}

- (void)setUpDistanceSlider {
    self.distanceSlider.minimumValue = 0;
    self.distanceSlider.maximumValue = 24;
    
    self.distanceSlider.value = [self.user[@"maxDistance"] intValue];
}

- (void)getPriceText {
    NSString *priceString = @"";
    for (int i = 0; i < self.priceSlider.selectedMinimum; i++) {
        priceString = [priceString stringByAppendingString:@"$"];
    }
    priceString = [priceString stringByAppendingString:@" - "];
    for (int i = 0; i < self.priceSlider.selectedMaximum; i++) {
        priceString = [priceString stringByAppendingString:@"$"];
    }
    self.priceLabel.text = priceString;
}

-(void)rangeSlider:(TTRangeSlider *)sender didChangeSelectedMinimumValue:(float)selectedMinimum andMaximumValue:(float)selectedMaximum {
    [self getPriceText];
    
    //update info on Parse
    NSArray *vals = [NSArray arrayWithObjects:@(self.priceSlider.selectedMinimum), @(self.priceSlider.selectedMaximum), nil];
    NSArray *keys = [NSArray arrayWithObjects:@"priceRangeLow", @"priceRangeHigh", nil];
    [ParseUtil updateValues:vals keys:keys];
}

- (IBAction)updateDistance:(id)sender {
    int roundedDist = (int) (self.distanceSlider.value + 0.5); //0.5 because (int) always rounds down
    NSString *distString = [NSString stringWithFormat:@"%d", roundedDist];
    self.distanceLabel.text = [distString stringByAppendingString:@" miles"];
    
    //store new value on parse in miles
    roundedDist = (int) (self.distanceSlider.value);
    [ParseUtil updateValue:@(roundedDist) key:@"maxDistance"];
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
