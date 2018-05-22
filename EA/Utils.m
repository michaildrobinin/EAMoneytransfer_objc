//
//  Utils.m
//  EA
//
//  Created by PSIHPOK on 1/14/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (void)getAllButtonFromView:(UIView*)view {
    for (UIView* subview in view.subviews) {
        
        if (subview.subviews.count > 0) {
            [Utils getAllButtonFromView:subview];
        }
        else if ([subview isKindOfClass:[UIButton class]] && subview.tag != 1001) {
            NSLog(@"found a button!");
            subview.layer.borderWidth = 1.0f;
            subview.layer.borderColor = [[UIColor whiteColor] CGColor];
            [subview.layer setCornerRadius: 4];
            NSLog(@"button.tag = %ld", (long)subview.tag);
        }
    }
}

@end
