//
//  AdminTransDetailController.m
//  EA
//
//  Created by PSIHPOK on 2/12/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import "AdminTransDetailController.h"
#import "ProgressView.h"

@interface AdminTransDetailController ()

@property (weak, nonatomic) IBOutlet UILabel *receiverName;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *additionalPhoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *senderName;
@property (weak, nonatomic) IBOutlet UILabel *sendingAgent;
@property (weak, nonatomic) IBOutlet UILabel *receivingAgent;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UILabel *corsStatus;

@end

@implementation AdminTransDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Back"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(backBtnClicked:)];
    self.navigationItem.leftBarButtonItem = backButton;
    [self.navigationItem setTitle:@"East Africa Money Wire"];
}

- (void)backBtnClicked:(id) sender {
    [self.navigationController dismissViewControllerAnimated:false completion:NULL];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [ProgressView showProgressView:self.view message:NULL];
    id<IDataStore> userStore = [backendless.data ofTable:@"Users"];
    [userStore find:^(NSArray* users) {
        id<IDataStore> pairStore = [backendless.data ofTable:@"AgentPair"];
        [pairStore find:^(NSArray* pairs) {
            NSDictionary* trans = (NSDictionary*)self.transaction;
            NSString* senderID = (NSString*) [trans objectForKey:@"sendingAgentID"];
            NSString* receiverID = (NSString*) [trans objectForKey:@"receiverAgentID"];
            NSString* sendAgentName = @"";
            NSString* receiverAgentName = @"";
            for (int uIndex = 0; uIndex < users.count; uIndex++) {
                NSDictionary* user = (NSDictionary*)[users objectAtIndex:uIndex];
                NSString* objectId = (NSString*)[user objectForKey:@"objectId"];
                if ([objectId isEqualToString:senderID] == true) {
                    sendAgentName = [(NSString*)[user objectForKey:@"firstName"] stringByAppendingString:[user objectForKey:@"lastName"]];
                }
                if ([objectId isEqualToString:receiverID] == true) {
                    receiverAgentName = [(NSString*)[user objectForKey:@"firstName"] stringByAppendingString:[user objectForKey:@"lastName"]];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [ProgressView dismissProgressView:^{
                    self.receiverName.text = [self addPrefix:@"ReceiverName: " main:[DataManager getNameStr:[self.transaction objectForKey:@"recFirstName"] lastName:[self.transaction objectForKey:@"recLastName"]]];
                    self.phoneNumber.text = [self addPrefix:@"Phone Number: " main:[self.transaction objectForKey:@"recPhone"]];
                    self.additionalPhoneNumber.text = [self addPrefix:@".0 PhoneNumber: " main:[self.transaction objectForKey:@"recAltPhone"]];
                    self.senderName.text = [self addPrefix:@"SenderName: " main:[DataManager getNameStr:[self.transaction objectForKey:@"senderFirstName"] lastName:[self.transaction objectForKey:@"senderLastName"]]];
                    self.sendingAgent.text = [self addPrefix:@"Sending Agent: " main:sendAgentName];
                    self.receivingAgent.text = [self addPrefix:@"Receiving Agent: " main:receiverAgentName];
                    self.status.text = [self getStatus:self.transaction];
                }];
            });
        } error:^(Fault* fault) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ProgressView dismissProgressView:NULL];
                [ProgressView showToast:self.view message:@"Couldn't load Transactions"];
            });
        }];
    } error:^(Fault* fault) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressView dismissProgressView:NULL];
            [ProgressView showToast:self.view message:@"Couldn't load Transactions"];
        });
    }];
}

- (NSString*) getStatus:(NSDictionary*) trans {
    int status = [(NSNumber*)[trans objectForKey:@"status"] intValue];
    switch (status) {
        case TS_PENDING:
            return @"Status: Pending";
        case TS_PROCESSING:
            return @"Status: Pending";
        case TS_CALLED_PHONE:
            return @"Status: Called Phone";
        case TS_NO_ANSWER:
            return @"Status: No Ansewer";
        default:
            return @"Status: Paid";
    }
}

- (IBAction)onEdit:(id)sender {
    [self performSegueWithIdentifier:@"editTrans" sender:NULL];
}

- (IBAction)onFlag:(id)sender {
    
}

- (IBAction)onOk:(id)sender {
    [ProgressView showProgressView:self.view message:NULL];
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:self.transaction];
    [dic setObject:@(TS_PROCESSING) forKey:@"status"];
    id<IDataStore> dataStore = [backendless.data ofTable:@"Transaction"];
    [dataStore save:dic response:^(id response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressView dismissProgressView:NULL];
        });
    } error:^(Fault* fault) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressView dismissProgressView:NULL];
            [ProgressView showToast:self.view message:@"Couldn't update the status"];
        });
    }];
}

- (NSString*) addPrefix:(NSString*) prefix main:(NSString*) main {
    if (main != nil)
    {
        return [prefix stringByAppendingString:main];
    }
    return prefix;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [DataManager getInstance]->bEditSendMoneyInfo = true;
    [DataManager getInstance].sendMoneyInfo = self.transaction;
}

@end
