//
//  RegisterUserController.m
//  EA
//
//  Created by PSIHPOK on 1/11/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import "RegisterUserController.h"
#import "DataManager.h"
#import "ProgressView.h"

@interface RegisterUserController ()

@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UISegmentedControl *agentType;
@property (nonatomic) UITapGestureRecognizer *tapRecognizer;


@end

@implementation RegisterUserController

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
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style: UIBarButtonItemStylePlain target:self action:@selector(Back)];
    self.navigationItem.leftBarButtonItem = backButton;
}
-(void) keyboardWillShow:(NSNotification *) note {
    [self.view addGestureRecognizer:self.tapRecognizer];
}

-(void) keyboardWillHide:(NSNotification *) note
{
    [self.view removeGestureRecognizer:self.tapRecognizer];
}

-(void)didTapAnywhere: (UITapGestureRecognizer*) recognizer {
    [self.firstName resignFirstResponder];
    [self.lastName resignFirstResponder];
    [self.email resignFirstResponder];
    [self.password resignFirstResponder];
}

- (IBAction)Back
{
    [self dismissViewControllerAnimated:YES completion:nil]; // ios 6
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)onRegisterUserInfo:(id)sender {
    BOOL bFilled = [self checkForm];
    if (!bFilled) {
        [ProgressView showToast:self.view message:@"Please fill all fields"];
    }
    else {
        BackendlessUser *user = [BackendlessUser new];
        [user setProperty:@"email" object:self.email.text];
        [user setPassword:self.password.text];
        [user setProperty:@"firstName" object:self.firstName.text];
        [user setProperty:@"lastName" object:self.lastName.text];
        if (self.agentType.selectedSegmentIndex == 1) {
            [user setProperty:@"agentType" object:[NSNumber numberWithInteger:2]];
        }
        [ProgressView showProgressView:self.view message:NULL];
        
        [backendless.userService registerUser:user
                                     response:^(BackendlessUser *registeredUser) {
                                         [backendless.userService login:self.email.text password:self.password.text response:^(BackendlessUser* user) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [ProgressView dismissProgressView:^{
                                                     [self performSegueWithIdentifier:@"showUserDetail" sender:NULL];
                                                 }];
                                             });
                                         } error:^(Fault* fault) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [ProgressView dismissProgressView:NULL];
                                                 [ProgressView showToast:self.view message:@"Failed to Register Agent"];
                                             });
                                         }];
                                     }
                                        error:^(Fault *fault) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [ProgressView dismissProgressView:NULL];
                                                [ProgressView showToast:self.view message:@"Failed to Register Agent"];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

@end
