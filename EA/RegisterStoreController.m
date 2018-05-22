//
//  RegisterStoreController.m
//  EA
//
//  Created by PSIHPOK on 1/11/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import "RegisterStoreController.h"
#import "DataManager.h"
#import "ProgressView.h"

@interface RegisterStoreController ()

@property (weak, nonatomic) IBOutlet UITextField *storeName;
@property (weak, nonatomic) IBOutlet UITextField *companyName;
@property (weak, nonatomic) IBOutlet UITextField *address1;
@property (weak, nonatomic) IBOutlet UITextField *address2;
@property (weak, nonatomic) IBOutlet UITextField *state;
@property (weak, nonatomic) IBOutlet UITextField *zipcode;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
@property (nonatomic) UITapGestureRecognizer *tapRecognizer;

@end

@implementation RegisterStoreController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:
     UIKeyboardWillShowNotification object:nil];
    
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:
     UIKeyboardWillHideNotification object:nil];
    
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                 action:@selector(didTapAnywhere:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationItem setTitle:@"Register an Agent"];
}

-(void) keyboardWillShow:(NSNotification *) note {
    [self.view addGestureRecognizer:self.tapRecognizer];
}

-(void) keyboardWillHide:(NSNotification *) note
{
    [self.view removeGestureRecognizer:self.tapRecognizer];
}

-(void)didTapAnywhere: (UITapGestureRecognizer*) recognizer {
    [self.storeName resignFirstResponder];
    [self.companyName resignFirstResponder];
    [self.address1 resignFirstResponder];
    [self.address2 resignFirstResponder];
    [self.state resignFirstResponder];
    [self.zipcode resignFirstResponder];
    [self.phoneNumber resignFirstResponder];
}

- (IBAction)onShowCustomerInfo:(id)sender {
    BOOL bFilled = [self checkForm];
    if (!bFilled) {
        [ProgressView showToast:self.view message:@"Please fill all fields"];
    }
    else {
        BackendlessUser* user = backendless.userService.currentUser;
        [user setProperty:@"storeName" object:self.storeName.text];
        [user setProperty:@"companyName" object:self.companyName.text];
        [user setProperty:@"address1" object:self.address1.text];
        [user setProperty:@"address2" object:self.address2.text];
        [user setProperty:@"state" object:self.state.text];
        [user setProperty:@"zipcode" object:self.zipcode.text];
        [user setProperty:@"phone" object:self.phoneNumber.text];
        [ProgressView showProgressView:self.view message:NULL];
        [backendless.userService update:user response:^(BackendlessUser* user){
            dispatch_async(dispatch_get_main_queue(), ^{
                [ProgressView dismissProgressView:NULL];
                [self performSegueWithIdentifier:@"showCustomerInfo" sender:NULL];
            });
        } error:^(Fault* fault) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ProgressView dismissProgressView:NULL];
                [ProgressView showToast:self.view message:@"Failed to Add information"];
            });
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationItem setTitle:@""];
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
