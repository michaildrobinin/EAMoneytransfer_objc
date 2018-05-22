//
//  TransDetailController.m
//  EA
//
//  Created by PSIHPOK on 2/11/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import "TransDetailController.h"
#import "ProgressView.h"
#import "DataManager.h"

@interface TransDetailController ()

@property (weak, nonatomic) IBOutlet UILabel *recName;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *additionalPhoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *city;
@property (weak, nonatomic) IBOutlet UILabel *senderName;
@property (weak, nonatomic) IBOutlet UILabel *senderLocation;



@end

@implementation TransDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"East Africa Money Wire"];
    self.recName.text = [NSString stringWithFormat:@"Receiver Name: %@", [DataManager getNameStr:[self.trans objectForKey:@"recFirstName"] lastName:[self.trans objectForKey:@"recLastName"]]];
    self.phoneNumber.text = [NSString stringWithFormat:@"Phone Number: %@", [self.trans objectForKey:@"recPhone"]];
    self.additionalPhoneNumber.text = [NSString stringWithFormat:@"Additional Phone Number: %@", [self.trans objectForKey:@"recAltPhone"]];
    self.city.text = [NSString stringWithFormat:@"City: %@", [self.trans objectForKey:@"recCity"]];
    self.senderName.text = [NSString stringWithFormat:@"Sender Name: %@", [DataManager getNameStr:[self.trans objectForKey:@"senderFirstName"] lastName:[self.trans objectForKey:@"senderLastName"]]];
    self.senderLocation.text = [NSString stringWithFormat:@"Sender Location: %@", [self.trans objectForKey:@"senderCity"]];
}

- (IBAction)onCall:(id)sender {
    [ProgressView showProgressView:self.view message:NULL];
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:self.trans];
    [dic setObject:@(TS_CALLED_PHONE) forKey:@"status"];
    id<IDataStore> dataStore = [backendless.data ofTable:@"Transaction"];
    [dataStore save:dic response:^(id response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressView dismissProgressView:^{
                [self.navigationController popViewControllerAnimated:true];
            }];
        });
    } error:^(Fault* fault) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressView dismissProgressView:NULL];
            [ProgressView showToast:self.view message:@"Couldn't update the status"];
        });
    }];
}

- (IBAction)onPaid:(id)sender {
    [ProgressView showProgressView:self.view message:NULL];
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:self.trans];
    [dic setObject:@(TS_PAID) forKey:@"status"];
    id<IDataStore> dataStore = [backendless.data ofTable:@"Transaction"];
    [dataStore save:dic response:^(id response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressView dismissProgressView:^{
                [self.navigationController popViewControllerAnimated:true];
            }];
        });
    } error:^(Fault* fault) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressView dismissProgressView:NULL];
            [ProgressView showToast:self.view message:@"Couldn't update the status"];
        });
    }];
}

- (IBAction)onNoAnswer:(id)sender {
    [ProgressView showProgressView:self.view message:NULL];
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:self.trans];
    [dic setObject:@(TS_NO_ANSWER) forKey:@"status"];
    id<IDataStore> dataStore = [backendless.data ofTable:@"Transaction"];
    [dataStore save:dic response:^(id response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressView dismissProgressView:^{
                [self.navigationController popViewControllerAnimated:true];
            }];
        });
    } error:^(Fault* fault) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressView dismissProgressView:NULL];
            [ProgressView showToast:self.view message:@"Couldn't update the status"];
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
