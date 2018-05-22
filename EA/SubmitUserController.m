//
//  SubmitUserController.m
//  EA
//
//  Created by PSIHPOK on 1/11/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import "SubmitUserController.h"
#import "ProgressView.h"
#import "SMNavController.h"
#import "DataManager.h"
#import "ProgressView.h"

@interface SubmitUserController ()

@property (weak, nonatomic) IBOutlet UITextField *yearsInBusiness;
@property (weak, nonatomic) IBOutlet UITextField *customersPerDay;
@property (weak, nonatomic) IBOutlet UITextField *EIN;
@property (nonatomic) UITapGestureRecognizer *tapRecognizer;

@end

@implementation SubmitUserController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"Register an Agent"];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:
     UIKeyboardWillShowNotification object:nil];
    
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:
     UIKeyboardWillHideNotification object:nil];
    
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                 action:@selector(didTapAnywhere:)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationItem setTitle:@""];
}

-(void) keyboardWillShow:(NSNotification *) note {
    [self.view addGestureRecognizer:self.tapRecognizer];
}

-(void) keyboardWillHide:(NSNotification *) note
{
    [self.view removeGestureRecognizer:self.tapRecognizer];
}

-(void)didTapAnywhere: (UITapGestureRecognizer*) recognizer {
    [self.yearsInBusiness resignFirstResponder];
    [self.customersPerDay resignFirstResponder];
    [self.EIN resignFirstResponder];
}

- (IBAction)onClickSubmit:(id)sender {
    BOOL bFilled = [self checkForm];
    if (!bFilled) {
        [ProgressView showToast:self.view message:@"Please fill all fields"];
    }
    else {
        BackendlessUser* user = backendless.userService.currentUser;
        [user setProperty:@"yearsInBusiness" object:self.yearsInBusiness.text];
        [user setProperty:@"customersPerDay" object:self.customersPerDay.text];
        [user setProperty:@"EIN" object:self.EIN.text];
        [ProgressView showProgressView:self.view message:NULL];
        [backendless.userService update:user response:^(BackendlessUser* user){
            dispatch_async(dispatch_get_main_queue(), ^{
                [ProgressView dismissProgressView:NULL];
                [ProgressView showToast:self.view message:@"We have received your application"];
                UIViewController* controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"categoryController"];
                [self presentViewController:controller animated:FALSE completion:nil];
            });
        } error:^(Fault* fault) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ProgressView dismissProgressView:NULL];
                [ProgressView showToast:self.view message:@"Failed to Add information"];
            });
        }];
    }
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
