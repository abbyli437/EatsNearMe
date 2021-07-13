//
//  ParseManager.m
//  EatsNearMe
//
//  Created by Abby Li on 7/13/21.
//

#import "ParseUtil.h"
#import "Parse/Parse.h"

@implementation ParseUtil

+ (void)udpateValues:(NSArray *)vals keys:(NSArray *)keys {
    //key array should be string array
    if (vals.count != keys.count) {
        return;
    }
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    PFUser *user = [PFUser currentUser];

    // Retrieve the object by id
    [query getObjectInBackgroundWithId:user.objectId
                                block:^(PFObject *user, NSError *error) {
        for (int i = 0; i < vals.count; i++) {
            [user setObject:vals[i] forKey:keys[i]];
        }
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            NSLog(@"successfully updated info");
        }];
    }];
}

@end
