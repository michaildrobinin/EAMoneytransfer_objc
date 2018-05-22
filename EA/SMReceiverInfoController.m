//
//  SMReceiverInfoController.m
//  EA
//
//  Created by PSIHPOK on 1/12/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import "SMReceiverInfoController.h"
#import "DataManager.h"
#import "ProgressView.h"
#import "DownPicker.h"

@interface SMReceiverInfoController ()

    @property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
    @property (weak, nonatomic) IBOutlet UITextField *firstName;
    @property (weak, nonatomic) IBOutlet UITextField *lastName;
    @property (weak, nonatomic) IBOutlet UITextField *city;
    @property (weak, nonatomic) IBOutlet UITextField *country;
    @property (weak, nonatomic) IBOutlet UITextField *address;
    @property (weak, nonatomic) IBOutlet UITextField *altPhoneNumber;
    
@property (weak, nonatomic) IBOutlet UIImageView *imageview;

@end

@implementation SMReceiverInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.phoneNumber.text = [self getStringValue:@"recPhone"];
    self.firstName.text = [self getStringValue:@"recFirstName"];
    self.lastName.text = [self getStringValue:@"recLastName"];
    self.city.text = [self getStringValue:@"recCity"];
    //self.country.text = [self getStringValue:@"recCountry"];
    self.address.text = [self getStringValue:@"recAddress"];
    self.altPhoneNumber.text = [self getStringValue:@"recAltPhone"];
    
/*
    DownPicker* picker = [[DownPicker alloc] initWithTextField:self.country withData:@[@"Ethiopia", @"Eritrea", @"Sudan"]];
    [self.view addSubview:picker];
    if ([self.country.text isEqual:@""]) {
        picker.selectedIndex = 0;
    }
    else {
        if ([self.country.text isEqualToString:@"Ethiopia"])
            picker.selectedIndex = 0;
        else if ([self.country.text isEqualToString:@"Eritrea"])
            picker.selectedIndex = 1;
        else
            picker.selectedIndex = 2;
    }
*/
}
- (IBAction)phonenumber_entered:(id)sender {
    NSString *temp = self.phoneNumber.text;
    id<IDataStore> dataStore = [backendless.data ofTable:@"Transaction"];
    NSString* sender_where = [NSString stringWithFormat:@"senderPhone = '%@'", temp];
    
    DataQueryBuilder* sender_query = [[DataQueryBuilder alloc] init];
    
    [sender_query setWhereClause:sender_where];
    
    [dataStore find:sender_query response:^(NSArray* transactions) {
        for (int index = 0; index < transactions.count; index++) {
            NSDictionary* user = (NSDictionary*) [transactions objectAtIndex:index];
            NSString *phoneTemp = [(NSString*)[user objectForKey:@"senderPhone"]  stringByAppendingString:@""];
            if ([phoneTemp isEqualToString:temp])
            {
                [self.firstName setText:[(NSString*)[user objectForKey:@"recFirstName"]  stringByAppendingString:@""]];
                [self.lastName setText:[(NSString*)[user objectForKey:@"recLastName"]  stringByAppendingString:@""]];
                [self.address setText:[(NSString*)[user objectForKey:@"recAddress"]  stringByAppendingString:@""]];
                [self.phoneNumber setText:[(NSString*)[user objectForKey:@"recPhone"]  stringByAppendingString:@""]];
                [self.city setText:[(NSString*)[user objectForKey:@"recCity"]  stringByAppendingString:@""]];
                [self.altPhoneNumber setText:[(NSString*)[user objectForKey:@"recAltPhone"]  stringByAppendingString:@""]];
                
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
            NSString *phoneTemp = [(NSString*)[user objectForKey:@"recPhone"]  stringByAppendingString:@""];
            if ([phoneTemp isEqualToString:temp])
            {
                [self.firstName setText:[(NSString*)[user objectForKey:@"recFirstName"]  stringByAppendingString:@""]];
                [self.lastName setText:[(NSString*)[user objectForKey:@"recLastName"]  stringByAppendingString:@""]];
                [self.address setText:[(NSString*)[user objectForKey:@"recAddress"]  stringByAppendingString:@""]];
                [self.phoneNumber setText:[(NSString*)[user objectForKey:@"recPhone"]  stringByAppendingString:@""]];
                [self.city setText:[(NSString*)[user objectForKey:@"recCity"]  stringByAppendingString:@""]];
                [self.altPhoneNumber setText:[(NSString*)[user objectForKey:@"recAltPhone"]  stringByAppendingString:@""]];
                
                
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


- (NSString*) getStringValue:(NSString*) key {
    id object = [[DataManager getInstance].sendMoneyInfo objectForKey:key];
    if (object == NULL || object == [NSNull null])
        return @"";
    else {
        return (NSString*)[[DataManager getInstance].sendMoneyInfo objectForKey:key];
    }
}
- (IBAction)sh_keyboard:(id)sender {
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationItem setTitle:@"East Africa Money Wire"];
}
    
- (IBAction)onNext:(id)sender {
    BOOL bFilled = [self checkForm];
    if (!bFilled) {
        [ProgressView showToast:self.view message:@"Please fill all fields"];
    }
    else {
        NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:[DataManager getInstance].sendMoneyInfo];
        [dic setValuesForKeysWithDictionary:@{
                                        @"recPhone": self.phoneNumber.text,
                                        @"recFirstName": self.firstName.text,
                                        @"recLastName": self.lastName.text,
                                        @"recCity": self.city.text,
                                        //@"recCountry": self.country.text,
                                        @"recAddress": self.address.text,
                                        @"recAltPhone": self.altPhoneNumber.text
                                        }];
        float score = [DataManager getCORS:dic];
        [dic setValue:@(score) forKey:@"cors"];
        [ProgressView showProgressView:self.view message:nil];
        [[backendless.data ofTable:@"Transaction"] save:dic
                                               response:^(NSDictionary<NSString*,id> *result) {
                                                   [DataManager getInstance].sendMoneyInfo = result;
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [ProgressView dismissProgressView:^{
                                                           [self performSegueWithIdentifier:@"sendStep4" sender:sender];
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
    

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationItem setTitle:@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [DataManager getInstance].receiverName = [[self.firstName.text stringByAppendingString:@" "] stringByAppendingString:self.lastName.text];
    [DataManager getInstance].receiverAddress = [[[self getStringValue:@"recCountry"] stringByAppendingString:@"/"] stringByAppendingString:self.city.text];
    [DataManager getInstance].receiverPhone = self.phoneNumber.text;
    [DataManager getInstance].receiverAltPhone = self.altPhoneNumber.text;
}

@end
