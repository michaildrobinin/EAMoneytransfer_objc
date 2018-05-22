//
//  LoginController.m
//  EA
//
//  Created by PSIHPOK on 1/14/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import "LoginController.h"
#import "CategoryController.h"
#import "DataManager.h"
#import "ProgressView.h"

@interface LoginController ()

@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;


@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     self.userName.text = @"test@admin.com";
     self.password.text = @"123456";
}

- (IBAction)onLogin:(id)sender {
    if (self.userName.text.length == 0 || self.password.text.length == 0) {
        [ProgressView showToast:self.view message:@"Please fill all fields"];
    }
    else {
        [ProgressView showProgressView:self.view message:NULL];
        [backendless.userService login:self.userName.text password:self.password.text response:^(BackendlessUser* user) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ProgressView dismissProgressView:^{
                    [self performSegueWithIdentifier:@"login" sender:NULL];
                }];
            });
        } error:^(Fault* fault) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ProgressView dismissProgressView:NULL];
                [ProgressView showToast:self.view message:@"Failed to Login"];
            });
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
