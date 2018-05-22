//
//  SMSendUserInfoController.m
//  EA
//
//  Created by PSIHPOK on 1/12/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import "SMSendUserInfoController.h"
#import "DataManager.h"
#import "ProgressView.h"
#import "SMSenderIDController.h"
@interface SMSendUserInfoController ()

    @property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
    @property (weak, nonatomic) IBOutlet UITextField *firstName;
    @property (weak, nonatomic) IBOutlet UITextField *lastName;
    @property (weak, nonatomic) IBOutlet UITextField *email;
    @property (weak, nonatomic) IBOutlet UITextField *address;
    @property (weak, nonatomic) IBOutlet UITextField *city;
    @property (weak, nonatomic) IBOutlet UITextField *state;
    @property (weak, nonatomic) IBOutlet UITextField *zipcode;
    @property (nonatomic) UITapGestureRecognizer *tapRecognizer;

@end

@implementation SMSendUserInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([DataManager getInstance]->bEditSendMoneyInfo && [DataManager getInstance].sendMoneyInfo != NULL) {
        self.phoneNumber.text = [[DataManager getInstance].sendMoneyInfo objectForKey:@"senderPhone"];
        self.firstName.text = [[DataManager getInstance].sendMoneyInfo objectForKey:@"senderFirstName"];
        self.lastName.text = [[DataManager getInstance].sendMoneyInfo objectForKey:@"senderLastName"];
        self.email.text = [[DataManager getInstance].sendMoneyInfo objectForKey:@"senderEmail"];
        self.address.text = [[DataManager getInstance].sendMoneyInfo objectForKey:@"senderAddress"];
        self.city.text = [[DataManager getInstance].sendMoneyInfo objectForKey:@"senderCity"];
        self.state.text = [[DataManager getInstance].sendMoneyInfo objectForKey:@"senderState"];
        self.zipcode.text = [[DataManager getInstance].sendMoneyInfo objectForKey:@"senderZipcode"];
    }
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
    [self.navigationItem setTitle:@"East Africa Money Wire"];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style: UIBarButtonItemStylePlain target:self action:@selector(Back)];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [ProgressView showProgressView:self.view message:NULL];
    [DataManager loadCORSTable:^(NSDictionary* dic) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressView dismissProgressView:NULL];
        });
    }];
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
    [self.address resignFirstResponder];
    [self.phoneNumber resignFirstResponder];
    [self.city resignFirstResponder];
    [self.state resignFirstResponder];
    [self.zipcode resignFirstResponder];
}

- (IBAction)Back
{
    [self dismissViewControllerAnimated:YES completion:nil]; // ios 6
}

- (IBAction)onNext:(id)sender {
    BOOL bFilled = [self checkForm];
    if (!bFilled) {
        [ProgressView showToast:self.view message:@"Please fill all fields"];
    }
    else {
        NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:[DataManager getInstance].sendMoneyInfo];
        [dic setValuesForKeysWithDictionary:@{
                                              @"senderFirstName": self.firstName.text,
                                              @"senderLastName": self.lastName.text,
                                              @"senderEmail": self.email.text,
                                              @"senderAddress": self.address.text,
                                              @"senderCity": self.city.text,
                                              @"senderState": self.state.text,
                                              @"senderZipcode": self.zipcode.text,
                                              @"senderPhone": self.phoneNumber.text
                                              }];
        [ProgressView showProgressView:self.view message:nil];
        [[backendless.data ofTable:@"Transaction"] save:dic
                                               response:^(NSDictionary<NSString*,id> *result) {
                                                   [DataManager getInstance].sendMoneyInfo = result;
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [ProgressView dismissProgressView:^{
                                                           if ([[dic objectForKey:@"amountInUSD"] intValue] > 1000) {
                                                               [self performSegueWithIdentifier:@"sendStep2" sender:nil];
                                                           } else {
                                                               [self performSegueWithIdentifier:@"sendStep24" sender:nil];
                                                           }
                                                           
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
- (IBAction)phoneNumberEdited:(id)sender {
    NSString *temp = self.phoneNumber.text;
    id<IDataStore> dataStore = [backendless.data ofTable:@"Transaction"];
    NSString* sender_where = [NSString stringWithFormat:@"senderPhone = '%@'", temp];

    DataQueryBuilder* sender_query = [[DataQueryBuilder alloc] init];

    [sender_query setWhereClause:sender_where];

    [dataStore find:sender_query response:^(NSArray* transactions) {
        for (int index = 0; index < transactions.count; index++) {
            NSDictionary* user = (NSDictionary*) [transactions objectAtIndex:index];
            NSString *phoneTemp = [(NSString*)[user objectForKey:@"senderPhone"]  stringByAppendingString:@""];
            
//            NSString *ns_birthday = [(NSString*)[user objectForKey:@"senderBirthday"] stringByAppendingString:@""];
//            NSString *ns_ssn = [(NSString*)[user objectForKey:@"senderSSN"] stringByAppendingString:@""];
//            NSString *ns_license = [(NSString*)[user objectForKey:@"senderLicense"] stringByAppendingString:@""];
//            NSString *ns_expirydate = [(NSString*)[user objectForKey:@"senderExpiryDate"] stringByAppendingString:@""];
//
//            SMSenderIDController *smid = [[SMSenderIDController alloc] initWithNibName:@"SMSenderIDController" bundle:nil];
//            smid.sm_birthday = ns_birthday;
//            smid.sm_ssn = ns_ssn;
//            smid.sm_license = ns_license;
//            smid.sm_expirydate = ns_expirydate;
//            NSString *phoneTemp1 = [(NSString*)[user objectForKey:@"recPhone"]  stringByAppendingString:@""];
            if ([phoneTemp isEqualToString:temp])
            {
                [self.firstName setText:[(NSString*)[user objectForKey:@"senderFirstName"]  stringByAppendingString:@""]];
                [self.lastName setText:[(NSString*)[user objectForKey:@"senderLastName"]  stringByAppendingString:@""]];
                [self.email setText:[(NSString*)[user objectForKey:@"senderEmail"]  stringByAppendingString:@""]];
                [self.address setText:[(NSString*)[user objectForKey:@"senderAddress"]  stringByAppendingString:@""]];
                [self.phoneNumber setText:[(NSString*)[user objectForKey:@"senderPhone"]  stringByAppendingString:@""]];
                [self.city setText:[(NSString*)[user objectForKey:@"senderCity"]  stringByAppendingString:@""]];
                [self.state setText:[(NSString*)[user objectForKey:@"senderState"]  stringByAppendingString:@""]];
                [self.zipcode setText:[(NSString*)[user objectForKey:@"senderZipcode"]  stringByAppendingString:@""]];

                break;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressView dismissProgressView:NULL];
        });
    } error:^(Fault* fault) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressView dismissProgressView:NULL];
            [ProgressView showToast:self.view message:@"Couldn't load Transactions"];
        });
    }];
    NSString* receive_where = [NSString stringWithFormat:@"recPhone = '%@'", temp];
    DataQueryBuilder* receive_query = [[DataQueryBuilder alloc] init];
    [receive_query setWhereClause:receive_where];
    [dataStore find:receive_query response:^(NSArray* transactions) {
        for (int index = 0; index < transactions.count; index++) {
            NSDictionary* user = (NSDictionary*) [transactions objectAtIndex:index];
//            NSString *phoneTemp = [(NSString*)[user objectForKey:@"senderPhone"]  stringByAppendingString:@""];
            NSString *phoneTemp = [(NSString*)[user objectForKey:@"recPhone"]  stringByAppendingString:@""];
//            NSString *ns_birthday = [(NSString*)[user objectForKey:@"senderBirthday"] stringByAppendingString:@""];
//            NSString *ns_ssn = [(NSString*)[user objectForKey:@"senderSSN"]stringByAppendingString:@""];
//            NSString *ns_license = [(NSString*)[user objectForKey:@"senderLicense"]stringByAppendingString:@""];
//            NSString *ns_expirydate = [(NSString*)[user objectForKey:@"senderExpiryDate"]stringByAppendingString:@""];
//
//            SMSenderIDController *smid = [[SMSenderIDController alloc] initWithNibName:@"SMSenderIDController" bundle:nil];
//            smid.sm_birthday = ns_birthday;
//            smid.sm_ssn = ns_ssn;
//            smid.sm_license = ns_license;
//            smid.sm_expirydate = ns_expirydate;
            if ([phoneTemp isEqualToString:temp])
            {
                [self.firstName setText:[(NSString*)[user objectForKey:@"senderFirstName"]  stringByAppendingString:@""]];
                [self.lastName setText:[(NSString*)[user objectForKey:@"senderLastName"]  stringByAppendingString:@""]];
                [self.email setText:[(NSString*)[user objectForKey:@"senderEmail"]  stringByAppendingString:@""]];
                [self.address setText:[(NSString*)[user objectForKey:@"senderAddress"]  stringByAppendingString:@""]];
                [self.phoneNumber setText:[(NSString*)[user objectForKey:@"senderPhone"]  stringByAppendingString:@""]];
                [self.city setText:[(NSString*)[user objectForKey:@"senderCity"]  stringByAppendingString:@""]];
                [self.state setText:[(NSString*)[user objectForKey:@"senderState"]  stringByAppendingString:@""]];
                [self.zipcode setText:[(NSString*)[user objectForKey:@"senderZipcode"]  stringByAppendingString:@""]];
        

                break;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressView dismissProgressView:NULL];
        });
    } error:^(Fault* fault) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressView dismissProgressView:NULL];
            [ProgressView showToast:self.view message:@"Couldn't load Transactions"];
        });
    }];
}
- (NSString*)createTransID:(int) lastNumber {
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY"];
    NSString* year = [formatter stringFromDate:date];
    return [NSString stringWithFormat:@"%@%06d", year, lastNumber];
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
    [DataManager getInstance].senderName = [[self.firstName.text stringByAppendingString:@" "] stringByAppendingString:self.lastName.text];
    [DataManager getInstance].senderAddress = [[[[self.address.text stringByAppendingString:@" "] stringByAppendingString:[self.city.text stringByAppendingString:@" "]] stringByAppendingString:[self.state.text stringByAppendingString:@" "]] stringByAppendingString:self.zipcode.text];
    [DataManager getInstance].senderPhone = self.phoneNumber.text;
}

@end
