//
//  SMTranInfoController.m
//  EA
//
//  Created by PSIHPOK on 1/12/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import "SMTranInfoController.h"
#import "DataManager.h"
#import "ProgressView.h"
#import "DownPicker.h"

@interface SMTranInfoController () {
    float exRateA;
    float exRateB;
    float exRateE;
    float serviceRate;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageview;

@property (weak, nonatomic) IBOutlet UITextField *recCountry;

    @property (weak, nonatomic) IBOutlet UITextField *amountInUSD;
    @property (weak, nonatomic) IBOutlet UITextField *exchangeRate;
    @property (weak, nonatomic) IBOutlet UILabel *localAmount;
    @property (weak, nonatomic) IBOutlet UILabel *serviceCharge;
@property (weak, nonatomic) IBOutlet UILabel *exRate;
@property (weak, nonatomic) IBOutlet UILabel *serviceChargeTitle;

@property (nonatomic) DownPicker* countryPicker;


@end

@implementation SMTranInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.amountInUSD.text = [self getAmountValue:@"amountInUSD"];
    self.exRate.text = [self getAmountValue:@"exchangeRate"];
    self.localAmount.text = [self getAmountValue:@"localAmount"];
    self.serviceCharge.text = [self getAmountValue:@"serviceCharge"];
    self.recCountry.text = [self getStringValue:@"recCoutry"];
    
    self.countryPicker = [[DownPicker alloc] initWithTextField:self.recCountry withData:@[@"Ethiopia", @"Eritrea", @"Sudan"]];
    [self.countryPicker addTarget:self action:@selector(changeCountry:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.countryPicker];
    if ([self.recCountry.text isEqual:@""]) {
        self.countryPicker.selectedIndex = 0;
    }
    else {
        if ([self.recCountry.text isEqualToString:@"Ethiopia"])
            self.countryPicker.selectedIndex = 0;
        else if ([self.recCountry.text isEqualToString:@"Eritrea"])
            self.countryPicker.selectedIndex = 1;
        else
            self.countryPicker.selectedIndex = 2;
    }
}

- (NSString*) getStringValue:(NSString*) key {
    id object = [[DataManager getInstance].sendMoneyInfo objectForKey:key];
    if (object == NULL || object == [NSNull null])
        return @"";
    else {
        return (NSString*)[[DataManager getInstance].sendMoneyInfo objectForKey:key];
    }
}
- (IBAction)show_hide_keyboard:(id)sender {
    [self.view endEditing:YES];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationItem setTitle:@"East Africa Money Wire"];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style: UIBarButtonItemStylePlain target:self action:@selector(Back)];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (IBAction)Back
{
    [self dismissViewControllerAnimated:YES completion:nil]; // ios 6
}

- (void)changeCountry:(id) sender {
    NSString* country = [self.countryPicker text];
    [self updateRate:country];
}

- (void)updateRate:(NSString*) country {
    [ProgressView showProgressView:self.view message:NULL];
    id<IDataStore> rateStore = [backendless.data ofTable:@"ExchangeRate"];
    [rateStore find:^(NSArray* rateArray) {
        for (int index = 0; index < rateArray.count; index++) {
            NSDictionary* dic = (NSDictionary*) [rateArray objectAtIndex:index];
            
            NSString* param = [dic objectForKey:@"param"];
            float rate = [(NSNumber*)[dic objectForKey:@"rate"] floatValue];
            
            NSString* keyA = [NSString stringWithFormat:@"%@A", country];
            NSString* keyB = [NSString stringWithFormat:@"%@B", country];
            if ([param isEqualToString:keyA])
                exRateA = rate;
            if ([param isEqualToString:keyB])
                exRateB = rate;
            if ([param isEqualToString:country])
                exRateE = rate;
            if ([param isEqualToString:@"Send&Receive"])
                serviceRate = rate;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressView dismissProgressView:NULL];
            self.exRate.text = [NSString stringWithFormat:@"%.2f", exRateE];
            self.localAmount.text = [NSString stringWithFormat:@"%.2f", exRateE * [self.amountInUSD.text floatValue]];
            self.serviceChargeTitle.text = [NSString stringWithFormat:@"Transaction Fee: (%.2f\%%)", exRateB];
            self.serviceCharge.text = [NSString stringWithFormat:@"%.2f", serviceRate* [self.amountInUSD.text floatValue] / 100];
        });
    } error:^(Fault* fault) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressView dismissProgressView:NULL];
            [ProgressView showToast:self.view message:@"Failed to get Exchange Rates"];
        });
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSString* country = self.recCountry.text;
    [self updateRate:country];
}

- (NSString*) getAmountValue:(NSString*) key {
    id object = [[DataManager getInstance].sendMoneyInfo objectForKey:key];
    if (object == NULL || object == [NSNull null])
        return @"";
    else {
        float value = [(NSNumber*)[[DataManager getInstance].sendMoneyInfo objectForKey:key] floatValue];
        return [NSString stringWithFormat:@"%0.2f", value];
    }
}

- (IBAction)onPreview:(id)sender {
    BOOL bFilled = [self checkForm];
    if (!bFilled) {
        [ProgressView showToast:self.view message:@"Please fill all fields"];
    }
    else {
        if ([DataManager getInstance]->bEditSendMoneyInfo && [DataManager getInstance].sendMoneyInfo != NULL) {
            NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:[DataManager getInstance].sendMoneyInfo];
            [dic setValuesForKeysWithDictionary:@{
                                                  @"amountInUSD": @([self.amountInUSD.text floatValue]),
                                                  @"exchangeRate": @([self.exRate.text floatValue]),
                                                  @"localAmount": @([self.localAmount.text floatValue]),
                                                  @"serviceCharge": @([self.serviceCharge.text floatValue]),
                                                  @"recCountry": self.recCountry.text
                                                  }];
            [ProgressView showProgressView:self.view message:nil];
            
            [[backendless.data ofTable:@"Transaction"] save:dic
                                                   response:^(NSDictionary<NSString*,id> *result) {
                                                       [DataManager getInstance].sendMoneyInfo = result;
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           [ProgressView dismissProgressView:^{
                                                               [self performSegueWithIdentifier:@"admin_assign_preview" sender:sender];
                                                           }];
                                                       });
                                                   } error:^(Fault *fault) {
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           [ProgressView dismissProgressView:NULL];
                                                           [ProgressView showToast:self.view message:@"Failed to Send Money"];
                                                       });
                                                   }];
        }
        else {
            NSString* senderId = [backendless.userService.currentUser getObjectId];
            [ProgressView showProgressView:self.view message:nil];
            id<IDataStore> userStore = [backendless.data ofTable:@"Users"];
            [userStore find:^(NSArray* users) {
                BOOL bExistReceiver = false;
                for (int uIndex = 0; uIndex < users.count; uIndex++) {
                    NSDictionary* user = (NSDictionary*) [users objectAtIndex:uIndex];
                    int agentType = [(NSNumber*)[user objectForKey:@"agentType"] intValue];
                    if (agentType == 2) {
                        bExistReceiver = true;
                        break;
                    }
                }
                if (bExistReceiver == false) {
                    [ProgressView dismissProgressView:NULL];
                    [ProgressView showToast:self.view message:@"There isn't any Receiving Agent"];
                }
                else {
                    id<IDataStore> pairStore = [backendless.data ofTable:@"AgentPair"];
                    [pairStore find:^(NSArray* pairs) {
                        NSString* receiverId = NULL;
                        for (int index = 0; index < pairs.count; index++) {
                            NSDictionary* pair = (NSDictionary*) [pairs objectAtIndex:index];
                            NSString* sender = (NSString*) [pair objectForKey:@"senderID"];
                            if ([sender isEqualToString:senderId] == true) {
                                receiverId = (NSString*) [pair objectForKey:@"receiverID"];
                            }
                        }
                        if (receiverId == NULL) {
                            for (int uIndex = 0; uIndex < users.count; uIndex++) {
                                NSDictionary* user = (NSDictionary*) [users objectAtIndex:uIndex];
                                int agentType = [(NSNumber*)[user objectForKey:@"agentType"] intValue];
                                if (agentType == 2) {
                                    receiverId = (NSString*)[user objectForKey:@"objectId"];
                                    break;
                                }
                            }
                        }
                        NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                                   @"amountInUSD": @([self.amountInUSD.text floatValue]),
                                                                                                   @"exchangeRate": @([self.exRate.text floatValue]),
                                                                                                   @"localAmount": @([self.localAmount.text floatValue]),
                                                                                                   @"serviceCharge": @([self.serviceCharge.text floatValue]),
                                                                                                   @"sendingAgentID": senderId,
                                                                                                   @"receiverAgentID": receiverId,
                                                                                                   @"status": @(0),
                                                                                                   @"recCountry": self.recCountry.text
                                                                                                   }];
                        [[backendless.data ofTable:@"Transaction"] getObjectCount:^(NSNumber* count) {
                            NSString* transID = [self createTransID:[count intValue]];
                            [dic setValue:transID forKey:@"transID"];
                            [[backendless.data ofTable:@"Transaction"] save:dic
                                                                   response:^(NSDictionary<NSString*,id> *result) {
                                                                       [DataManager getInstance].sendMoneyInfo = result;
                                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                                           [ProgressView dismissProgressView:^{
                                                                               [self performSegueWithIdentifier:@"sendStep1" sender:nil];
                                                                           }];
                                                                       });
                                                                   } error:^(Fault *fault) {
                                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                                           [ProgressView dismissProgressView:NULL];
                                                                           [ProgressView showToast:self.view message:@"Failed to Send Money"];
                                                                       });
                                                                   }];
                        } error:^(Fault* fault) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [ProgressView dismissProgressView:NULL];
                                [ProgressView showToast:self.view message:@"Failed to Send Money"];
                            });
                        }];
                    } error:^(Fault* fault) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [ProgressView dismissProgressView:NULL];
                            [ProgressView showToast:self.view message:@"Failed to Send Money"];
                        });
                    }];
                }
            } error:^(Fault* fault) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [ProgressView dismissProgressView:NULL];
                    [ProgressView showToast:self.view message:@"Failed to Send Money"];
                });
            }];
        }
    }
}

- (NSString*)createTransID:(int) lastNumber {
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY"];
    NSString* year = [formatter stringFromDate:date];
    return [NSString stringWithFormat:@"%@%06d", year, lastNumber];
}
    
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* newStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    float localAmt = [newStr floatValue] * [self.exRate.text floatValue];
    self.localAmount.text = [NSString stringWithFormat:@"%0.2f", localAmt];
    
    if ([newStr floatValue] > 1000) {
        float serviceCharge = serviceCharge = [newStr floatValue] * exRateA / 100;
        self.serviceCharge.text = [NSString stringWithFormat:@"%0.2f", serviceCharge];
        self.serviceChargeTitle.text = [NSString stringWithFormat:@"Transaction Fee: (%.2f\%%)", exRateA];
    }
    else {
        float serviceCharge = serviceCharge = [newStr floatValue] * exRateB / 100;
        self.serviceCharge.text = [NSString stringWithFormat:@"%0.2f", serviceCharge];
        self.serviceChargeTitle.text = [NSString stringWithFormat:@"Transaction Fee: (%.2f\%%)", exRateB];
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [DataManager getInstance].amountInUSD = self.amountInUSD.text;
    [DataManager getInstance].amountLocal = self.localAmount.text;
    [DataManager getInstance].serviceCharge = self.serviceCharge.text;
    
    float total = [self.amountInUSD.text floatValue] + [self.serviceCharge.text floatValue];
    [DataManager getInstance].totalTransAmount = [NSString stringWithFormat:@"%0.2f", total];
}

@end
