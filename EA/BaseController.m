//
//  BaseController.m
//  EA
//
//  Created by PSIHPOK on 1/14/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import "BaseController.h"
#import "Utils.h"

@interface BaseController ()

@end

@implementation BaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Utils getAllButtonFromView:self.view];
}
    
- (BOOL)checkForm {
    NSArray* textFields = [self getTextFields:self.view];
    
    for (int i = 0; i < textFields.count; i++) {
        UITextField* field = [textFields objectAtIndex:i];
        if (field.text.length == 0) return NO;
    }
    
    return YES;
}
    
    - (NSMutableArray*) getTextFields:(UIView*) view {
        NSMutableArray* results = [NSMutableArray array];
        NSArray* subviews = [view subviews];
        for (int i = 0; i < subviews.count; i++) {
            UIView* subview = [subviews objectAtIndex:i];
            if ([subview isKindOfClass:[UITextField class]]) {
                [results addObject:subview];
            }
            else {
                [results addObjectsFromArray:[self getTextFields:subview]];
            }
        }
        return results;
    }

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
