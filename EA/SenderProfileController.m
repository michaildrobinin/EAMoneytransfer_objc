//
//  SenderProfileController.m
//  EA
//
//  Created by PSIHPOK on 2/6/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import "SenderProfileController.h"
#import "ProgressView.h"
#import "DataManager.h"

@interface SenderProfileController ()

@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *password;
@property (weak, nonatomic) IBOutlet UILabel *fullName;
@property (weak, nonatomic) IBOutlet UILabel *storeName;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *email;

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *fullNameField;
@property (weak, nonatomic) IBOutlet UITextField *storeNameField;
@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;

@property (nonatomic) NSArray* labelArray;
@property (nonatomic) NSArray* fieldArray;

@end

@implementation SenderProfileController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Back"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(backBtnClicked:)];
    self.navigationItem.leftBarButtonItem = backButton;
    _labelArray = @[_username, _password, _fullName, _storeName, _address, _phoneNumber, _email];
    _fieldArray = @[_usernameField, _passwordField, _fullNameField, _storeNameField, _addressField, _phoneField, _emailField];
    for (NSInteger index = 0; index < _fieldArray.count; index++) {
        UIView* view = (UIView*) [_fieldArray objectAtIndex:index];
        [view setHidden:TRUE];
    }
    
    BackendlessUser* user = backendless.userService.currentUser;
    _username.text = (NSString*) [user getProperty:@"username"];
    //_password.text = (NSString*) user.password;
    _password.text = @"";
    _fullName.text = [[(NSString*)[user getProperty:@"firstName"] stringByAppendingString:@" "] stringByAppendingString:(NSString*)[user getProperty:@"lastName"]];
    _storeName.text = (NSString*) [user getProperty:@"storeName"];
    _address.text = (NSString*) [user getProperty:@"address1"];
    _phoneNumber.text = (NSString*) [user getProperty:@"phone"];
    _email.text = (NSString*) [user getProperty:@"email"];
    [self addPrefix];
}

- (void) addPrefix {
    _username.text = [NSString stringWithFormat:@"User Name: %@", _username.text];
    _password.text = [NSString stringWithFormat:@"Password: %@", _password.text];
    _fullName.text = [NSString stringWithFormat:@"First/Last Name: %@", _fullName.text];
    _storeName.text = [NSString stringWithFormat:@"Store Name: %@", _storeName.text];
    _address.text = [NSString stringWithFormat:@"Address: %@", _address.text];
    _phoneNumber.text = [NSString stringWithFormat:@"Phone Number: %@", _phoneNumber.text];
    _email.text = [NSString stringWithFormat:@"Email: %@", _email.text];
}

- (NSString*) getValue:(NSString*) str index:(NSInteger) index {
    NSArray* array = [str componentsSeparatedByString:@" "];
    if (array.count <= index)
        return str;
    return (NSString*) [array objectAtIndex:index];
}

- (void) removePrefix {
    _usernameField.text = [self getValue:_usernameField.text index:2];
    _passwordField.text = [self getValue:_passwordField.text index:1];
    _fullNameField.text = [self getValue:_fullNameField.text index:2];
    _storeNameField.text = [self getValue:_storeNameField.text index:2];
    _addressField.text = [self getValue:_addressField.text index:1];
    _phoneField.text = [self getValue:_phoneField.text index:2];
    _emailField.text = [self getValue:_emailField.text index:1];
}

- (void)backBtnClicked:(id) sender {
    [self.navigationController dismissViewControllerAnimated:false completion:NULL];
}

- (IBAction)onClickEdit:(id)sender {
    for (NSInteger index = 0; index < _fieldArray.count; index++) {
        UILabel* label = (UILabel*) [_labelArray objectAtIndex:index];
        UITextField* field = (UITextField*) [_fieldArray objectAtIndex:index];
        [label setHidden:TRUE];
        [field setHidden:FALSE];
        [field setText:label.text];
    }
    [self removePrefix];
}

- (IBAction)onClickDone:(id)sender {
    UILabel* sampleLabel = (UILabel*)[_labelArray objectAtIndex:0];
    if (sampleLabel.hidden == FALSE) {
        return;
    }
    
    for (NSInteger index = 0; index < _fieldArray.count; index++) {
        UILabel* label = (UILabel*) [_labelArray objectAtIndex:index];
        UITextField* field = (UITextField*) [_fieldArray objectAtIndex:index];
        [label setHidden:FALSE];
        [field setHidden:TRUE];
        [label setText:field.text];
    }
    [ProgressView showProgressView:self.view message:NULL];
    BackendlessUser* user = backendless.userService.currentUser;
    NSArray* nameArr = [_fullName.text componentsSeparatedByString:@" "];
    [user updateProperties:@{@"username": _username.text}];
    [user setPassword:_password.text];
    //[user updateProperties:@{@"password": _password.text}];
    if (nameArr.count > 1) {
        [user updateProperties:@{@"firstName": (NSString*)[nameArr objectAtIndex:0]}];
        [user updateProperties:@{@"lastName": (NSString*)[nameArr objectAtIndex:1]}];
    }
    [user updateProperties:@{@"storeName": _storeName.text}];
    [user updateProperties:@{@"address1": _address.text}];
    [user updateProperties:@{@"phone": _phoneNumber.text}];
    [user updateProperties:@{@"email": _email.text}];
    [backendless.userService update:user response:^(BackendlessUser* user) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressView dismissProgressView:^{
                [self addPrefix];
            }];
        });
    } error:^(Fault* error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressView dismissProgressView:NULL];
            [ProgressView showToast:self.view message:@"Failed to update profile"];
            for (NSInteger index = 0; index < _fieldArray.count; index++) {
                UILabel* label = (UILabel*) [_labelArray objectAtIndex:index];
                UITextField* field = (UITextField*) [_fieldArray objectAtIndex:index];
                [label setHidden:TRUE];
                [field setHidden:FALSE];
            }
        });
    }];
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
