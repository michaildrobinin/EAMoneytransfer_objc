//
//  ProgressView.m
//  EA
//
//  Created by PSIHPOK on 1/11/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import "ProgressView.h"

static JGProgressHUD* s_Hud = NULL;
static NSTimeInterval DEFAULT_DELAY = 3.0f;

@implementation ProgressView

+(void) showToast:(UIView*) view message:(NSString*) message {
    [ProgressView dismissProgressView:nil];
    s_Hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    [s_Hud setIndicatorView:NULL];
    [s_Hud.textLabel setText:message];
    [s_Hud showInView:view];
    [s_Hud dismissAfterDelay:DEFAULT_DELAY];
}

+(void) changeMessage:(NSString*) message {
    if (s_Hud != NULL) {
        [s_Hud.textLabel setText:message];
    }
}

+(void) showProgressView:(UIView*) view message:(NSString*) message {
    [ProgressView dismissProgressView:nil];
    s_Hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    [s_Hud.textLabel setText:message];
    [s_Hud showInView:view];
}

+(void) dismissProgressView:(void (^)(void)) completion {
    if (s_Hud != NULL) {
        [s_Hud dismiss];
        if (completion != nil) {
            completion();
        }
    }
}

+(void) showAlert:(UIViewController*) controller title:(NSString*) title message:(NSString*) message activeTitle:(NSString*) actTitle deactiveTitle:(NSString*) deactTitle activeAction:(void (^)(UIAlertAction*)) actAction deactiveAction:(void (^)(UIAlertAction*)) deactAction completion:(void (^)(void)) completion {
    [ProgressView dismissProgressView:nil];
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    if (actTitle != NULL) {
        UIAlertAction* active = [UIAlertAction actionWithTitle:actTitle style:UIAlertActionStyleDefault handler:actAction];
        [alertController addAction:active];
    }
    
    if (deactTitle != NULL) {
        UIAlertAction* deactive = [UIAlertAction actionWithTitle:deactTitle style:UIAlertActionStyleDefault handler:deactAction];
        [alertController addAction:deactive];
    }
    
    if (actTitle == NULL && deactTitle == NULL) {
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL];
        [alertController addAction:okAction];
    }
    
    [controller presentViewController:alertController animated:true completion:completion];
}

@end
