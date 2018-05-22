//
//  ProgressView.h
//  EA
//
//  Created by PSIHPOK on 1/11/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JGProgressHUD/JGProgressHUD.h"
@interface ProgressView : NSObject

+(void) showToast:(UIView*) view message:(NSString*) message;
+(void) changeMessage:(NSString*) message;
+(void) showProgressView:(UIView*) view message:(NSString*) message;
+(void) dismissProgressView:(void (^)(void)) completion;
+(void) showAlert:(UIViewController*) controller title:(NSString*) title message:(NSString*) message activeTitle:(NSString*) actTitle deactiveTitle:(NSString*) deactTitle activeAction:(void (^)(UIAlertAction*)) actAction deactiveAction:(void (^)(UIAlertAction*)) deactAction completion:(void (^)(void)) completion;

@end
