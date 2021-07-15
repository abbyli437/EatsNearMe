//
//  RestaurantCardView.m
//  EatsNearMe
//
//  Created by Abby Li on 7/15/21.
//

//from online, will deal with this later
#define ACTION_MARGIN 120 //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
#define SCALE_STRENGTH 4 //%%% how quickly the card shrinks. Higher = slower shrinking
#define SCALE_MAX .93 //%%% upper bar for how much the card shrinks. Higher = shrinks less
#define ROTATION_MAX 1 //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
#define ROTATION_STRENGTH 320 //%%% strength of rotation. Higher = weaker rotation
#define ROTATION_ANGLE M_PI/8 //%%% Higher = stronger rotation angle

#import "RestaurantCardView.h"
#import <CoreLocation/CoreLocation.h>
@import YelpAPI;

@implementation RestaurantCardView {
    CGFloat xFromCenter;
    CGFloat yFromCenter; //not sure if I need this but ok
}

@synthesize delegate;
@synthesize panGestureRecognizer;
@synthesize originalPoint;
@synthesize restaurantImage;
@synthesize nameLabel;
@synthesize descriptionLabel;
@synthesize priceLabel;
@synthesize distanceLabel;
@synthesize checkMarkImage;

- (id)initWithFrame:(CGRect)frame //loc:(CLLocation *)curLocation
{
    //TODO: make sub-methods for each of these UI elems just because they need some setting up. Would be better organized that way.
    self = [super initWithFrame:frame];
    if (self) {
        self.restaurantImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 340, 300)]; //hard coded width, bad
        
        //name
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 325, 60, 30)];
        
        //description
        self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 360, 260, 25)];
        
        //price
        self.priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(190, 330, 120, 20)];
        
        //distance
        self.distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 390, 260, 25)];
        
        //checkmark image
        self.checkMarkImage = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"checkmark.circle.fill"]];
        self.checkMarkImage.alpha = 0;
        
        self.backgroundColor = [UIColor systemPinkColor];
        self.alpha = 1;
        
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(beingDragged:)];
        
        [self addGestureRecognizer:panGestureRecognizer];
        
        [self addSubview:self.restaurantImage];
        [self addSubview:self.nameLabel];
        [self addSubview:self.descriptionLabel];
        [self addSubview:self.priceLabel];
        [self addSubview:self.distanceLabel];
        [self addSubview:self.checkMarkImage];
        
    }
    return self;
}

- (void)setRestaurant:(YLPBusiness *)restaurant {
    //set up restaurant image
    _restaurant = restaurant;
    if (self.restaurant.imageURL != nil) {
        NSData *data = [[NSData alloc] initWithContentsOfURL:self.restaurant.imageURL];
        UIImage *imageData = [[UIImage alloc] initWithData:data];
        self.restaurantImage.image = imageData;
        //self.restaurantImage = [[UIImageView alloc] initWithImage:imageData];
    }
    else {
        self.restaurantImage.image = [UIImage imageNamed:@"comingSoon.png"];
        //self.restaurantImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comingSoon.png"]];
    }
    
    self.nameLabel.text = self.restaurant.name;
    
    self.descriptionLabel.text = self.restaurant.categories[0].name;
    
    self.priceLabel.text = self.restaurant.price;
    
    //distance label
    CLLocation *restaurantLoc = [[CLLocation alloc] initWithLatitude:self.restaurant.location.coordinate.latitude longitude:self.restaurant.location.coordinate.longitude];
    //this is in meters
    CLLocationDistance dist = [self.curLocation distanceFromLocation:restaurantLoc];
    double distMiles = dist / 1609.0;
    NSString *distStr = [NSString stringWithFormat:@"%f", distMiles];
    distStr = [distStr stringByAppendingString:@" miles away"];
    self.distanceLabel.text = distStr;

}

- (void)beingDragged:(UIPanGestureRecognizer *)sender
{
    //%%% this extracts the coordinate data from your swipe movement. (i.e. How much did you move?)
    xFromCenter = [sender translationInView:self].x; //%%% positive for right swipe, negative for left
    yFromCenter = [sender translationInView:self].y; //%%% positive for up, negative for down
    NSLog(@"this is here!");
    
    //%%% checks what state the gesture is in. (are you just starting, letting go, or in the middle of a swipe?)
    switch (sender.state) {
            //%%% just started swiping
        case UIGestureRecognizerStateBegan:{
            self.originalPoint = self.center;
            break;
        };
            //%%% in the middle of a swipe
        case UIGestureRecognizerStateChanged:{
            //sets up image for swipe left/right
            if (xFromCenter < 0) {
                self.checkMarkImage.image = [UIImage systemImageNamed:@"xmark.circle.fill"];
                self.checkMarkImage.tintColor = [UIColor redColor];
            }
            else {
                self.checkMarkImage.image = [UIImage systemImageNamed:@"checkmark.circle.fill"];
                self.checkMarkImage.tintColor = [UIColor greenColor];
            }
            
            //image fade
            self.checkMarkImage.alpha = fabs(xFromCenter) / self.center.x;
            
            /*
            //%%% dictates rotation (see ROTATION_MAX and ROTATION_STRENGTH for details)
            CGFloat rotationStrength = MIN(xFromCenter / ROTATION_STRENGTH, ROTATION_MAX);
            
            //%%% degree change in radians
            CGFloat rotationAngel = (CGFloat) (ROTATION_ANGLE * rotationStrength);
            
            //%%% amount the height changes when you move the card up to a certain point
            CGFloat scale = MAX(1 - fabsf(rotationStrength) / SCALE_STRENGTH, SCALE_MAX);
            
            //%%% move the object's center by center + gesture coordinate
            self.center = CGPointMake(self.originalPoint.x + xFromCenter, self.originalPoint.y + yFromCenter);
            
            //%%% rotate by certain amount
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            
            //%%% scale by certain amount
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            
            //%%% apply transformations
            self.transform = scaleTransform;
            */
            break;
        };
            //%%% let go of the card
        case UIGestureRecognizerStateEnded: {
            //[self afterSwipeAction];
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
}

//%%% called when the card is let go
- (void)afterSwipeAction
{
    if (xFromCenter > ACTION_MARGIN) {
        [self rightAction];
    } else if (xFromCenter < -ACTION_MARGIN) {
        [self leftAction];
    } else { //%%% resets the card
        [UIView animateWithDuration:0.3
                         animations:^{
            self.center = self.originalPoint;
            //self.transform = CGAffineTransformMakeRotation(0);
            self.checkMarkImage.alpha = 0;
        }];
    }
}

//%%% called when a swipe exceeds the ACTION_MARGIN to the right
-(void)rightAction
{
    CGPoint finishPoint = CGPointMake(500, 2 * yFromCenter + self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedRight:self];
    
    NSLog(@"YES");
}

//%%% called when a swip exceeds the ACTION_MARGIN to the left
-(void)leftAction
{
    CGPoint finishPoint = CGPointMake(-500, 2 * yFromCenter + self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedLeft:self];
    
    NSLog(@"NO");
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
	
