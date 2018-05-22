//
//  SMSenderIDController.m
//  EA
//
//  Created by PSIHPOK on 1/12/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import "SMSenderIDController.h"
#import "DataManager.h"
#import "ProgressView.h"

@interface SMSenderIDController ()
@property (weak, nonatomic) IBOutlet UIImageView *idPhoto;

    @property (weak, nonatomic) IBOutlet UITextField *birthday;
    @property (weak, nonatomic) IBOutlet UITextField *ssn;
    @property (weak, nonatomic) IBOutlet UITextField *license;
    @property (weak, nonatomic) IBOutlet UITextField *expiryDate;
    @property (weak, nonatomic) IBOutlet UITextField *email;

@property (nonatomic) NSDate* birthDate;
@property (nonatomic) NSDate* expiry;
    
@end

@implementation SMSenderIDController

- (IBAction)sh_keyboard:(id)sender {
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.birthday.text = [self getStringValue:@"senderBirthday"];
    self.ssn.text = [self getStringValue:@"senderSSN"];
    self.license.text = [self getStringValue:@"senderLicense"];
    self.expiryDate.text = [self getStringValue:@"senderExpiryDate"];
}

- (NSString*) getStringValue:(NSString*) key {
    id object = [[DataManager getInstance].sendMoneyInfo objectForKey:key];
    if (object == NULL || object == [NSNull null])
        return @"";
    else {
        return (NSString*)[[DataManager getInstance].sendMoneyInfo objectForKey:key];
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationItem setTitle:@"East Africa Money Wire"];
}

- (IBAction)onOpenIDGallery:(id)sender {
    UIImagePickerController* controller = [[UIImagePickerController alloc] init];
    [controller setDelegate:self];
    [controller setSourceType:UIImagePickerControllerSourceTypeCamera];
    [controller setAllowsEditing:TRUE];
    [self presentViewController:controller animated:TRUE completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:FALSE completion:nil];
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (image != NULL) {
        [self.idPhoto setImage:image];
    }
    else {
        [ProgressView showToast:self.view message:@"The photo of ID Card has broken. Please take again"];
    }
}

- (IBAction)onNext:(id)sender {
    BOOL bFilled = [self checkForm];
    if (!bFilled) {
        [ProgressView showToast:self.view message:@"Please fill all fields"];
    }
    else {
        NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:[DataManager getInstance].sendMoneyInfo];
        [dic setValuesForKeysWithDictionary:@{
                                        @"senderBirthday": self.birthDate,
                                        @"senderSSN": self.ssn.text,
                                        @"senderLicense": self.license.text,
                                        @"senderExpiryDate": self.expiry
                                        }];
        [ProgressView showProgressView:self.view message:nil];
        [[backendless.data ofTable:@"Transaction"] save:dic
                                               response:^(NSDictionary<NSString*,id> *result) {
                                                   [DataManager getInstance].sendMoneyInfo = result;
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [ProgressView dismissProgressView:^{
                                                           [self performSegueWithIdentifier:@"sendStep3" sender:nil];
                                                       }];
                                                   });
                                               } error:^(Fault *fault) {
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [ProgressView dismissProgressView:NULL];
                                                       [ProgressView showToast:self.view message:@"Failed to Send Money"];
                                                   });
                                               }];
    }
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.birthday || textField == self.expiryDate) {
        UIDatePicker* picker = [[UIDatePicker alloc] init];
        picker.datePickerMode = UIDatePickerModeDate;
        [picker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
        [textField setInputView:picker];
    }
}

- (void)datePickerValueChanged:(UIDatePicker*) sender {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    if (self.birthday.inputView == sender) {
        self.birthday.text = [formatter stringFromDate:[sender date]];
        self.birthDate = [sender date];
    }
    else if (self.expiryDate.inputView == sender) {
        self.expiryDate.text = [formatter stringFromDate:[sender date]];
        self.expiry = [sender date];
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
