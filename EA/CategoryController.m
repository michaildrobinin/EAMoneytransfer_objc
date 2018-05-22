//
//  CategoryController.m
//  EA
//
//  Created by PSIHPOK on 1/14/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import "CategoryController.h"
#import "DataManager.h"

@interface CategoryController ()

@property (weak, nonatomic) IBOutlet UILabel *adminName;
@property (weak, nonatomic) IBOutlet UIButton *reviewAssignTrans;
@property (weak, nonatomic) IBOutlet UIButton *exchangeCommissionRate;
@property (weak, nonatomic) IBOutlet UIButton *agentPairing;
@property (weak, nonatomic) IBOutlet UIButton *transByAgent;
@property (weak, nonatomic) IBOutlet UIButton *unpaidTrans;
@property (weak, nonatomic) IBOutlet UIButton *complianceName;


@property (weak, nonatomic) IBOutlet UIButton *sendMoney;
@property (weak, nonatomic) IBOutlet UIButton *viewTrans;
@property (weak, nonatomic) IBOutlet UIButton *commissionReportSendAgent;
@property (weak, nonatomic) IBOutlet UIButton *profileSendAgent;

@property (weak, nonatomic) IBOutlet UIButton *receiveTrans;
@property (weak, nonatomic) IBOutlet UIButton *unpaidTransForRecAgent;
@property (weak, nonatomic) IBOutlet UIButton *commissionReportRecAgent;
@property (weak, nonatomic) IBOutlet UIButton *profileRecAgent;

@property (nonatomic) NSArray* adminViews;
@property (nonatomic) NSArray* sendAgentViews;
@property (nonatomic) NSArray* receiveAgentViews;

@end

@implementation CategoryController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.adminViews = @[self.adminName, self.reviewAssignTrans, self.exchangeCommissionRate, self.agentPairing, self.transByAgent, self.unpaidTrans, self.complianceName];
    self.sendAgentViews = @[self.sendMoney, self.viewTrans, self.commissionReportSendAgent, self.profileSendAgent];
    self.receiveAgentViews = @[self.receiveTrans, self.unpaidTransForRecAgent, self.commissionReportRecAgent, self.profileRecAgent];
    NSNumber* userType = (NSNumber*) [backendless.userService.currentUser getProperty:@"agentType"];
    NSString* firstName = (NSString*) [backendless.userService.currentUser getProperty:@"firstName"];
    NSString* lastName = (NSString*) [backendless.userService.currentUser getProperty:@"lastName"];
    self.adminName.text = [[firstName stringByAppendingString:@" "] stringByAppendingString:lastName];
    [self showButtonsByUserType:userType.intValue];
}

- (void) showButtonsByUserType:(NSInteger) type {
    switch (type) {
        case 0:
            for (NSInteger index = 0; index < self.adminViews.count; index++) {
                UIView* view = [self.adminViews objectAtIndex:index];
                [view setHidden:NO];
            }
            for (NSInteger index = 0; index < self.sendAgentViews.count; index++) {
                UIView* view = [self.sendAgentViews objectAtIndex:index];
                [view setHidden:YES];
            }
            for (NSInteger index = 0; index < self.receiveAgentViews.count; index++) {
                UIView* view = [self.receiveAgentViews objectAtIndex:index];
                [view setHidden:YES];
            }
            break;
        case 1:
            for (NSInteger index = 0; index < self.adminViews.count; index++) {
                UIView* view = [self.adminViews objectAtIndex:index];
                [view setHidden:YES];
            }
            for (NSInteger index = 0; index < self.sendAgentViews.count; index++) {
                UIView* view = [self.sendAgentViews objectAtIndex:index];
                [view setHidden:NO];
            }
            for (NSInteger index = 0; index < self.receiveAgentViews.count; index++) {
                UIView* view = [self.receiveAgentViews objectAtIndex:index];
                [view setHidden:YES];
            }
            break;
        default:
            for (NSInteger index = 0; index < self.adminViews.count; index++) {
                UIView* view = [self.adminViews objectAtIndex:index];
                [view setHidden:YES];
            }
            for (NSInteger index = 0; index < self.sendAgentViews.count; index++) {
                UIView* view = [self.sendAgentViews objectAtIndex:index];
                [view setHidden:YES];
            }
            for (NSInteger index = 0; index < self.receiveAgentViews.count; index++) {
                UIView* view = [self.receiveAgentViews objectAtIndex:index];
                [view setHidden:NO];
            }
            break;
    }
}

// Admin
- (IBAction)onReviewAssignTrans:(id)sender {
    [self performSegueWithIdentifier:@"reviewAssign" sender:NULL];
}

- (IBAction)exchangeCommissionRate:(id)sender {
    [self performSegueWithIdentifier:@"exchangeRate" sender:NULL];
}

- (IBAction)agentPairing:(id)sender {
    [self performSegueWithIdentifier:@"agentPairing" sender:NULL];
}

- (IBAction)transByAgent:(id)sender {
    [self performSegueWithIdentifier:@"transactionByAgent" sender:NULL];
}

- (IBAction)unpaidTrans:(id)sender {
    [self performSegueWithIdentifier:@"unpaidTrans" sender:NULL];
}

- (IBAction)complianceName:(id)sender {
    [self performSegueWithIdentifier:@"cors" sender:NULL];
}

// Sending Agent
- (IBAction)sendMoney:(id)sender {
    [self performSegueWithIdentifier:@"sendMoney" sender:NULL];
}

- (IBAction)viewTrans:(id)sender {
    [self performSegueWithIdentifier:@"sendViewTransaction" sender:NULL];
}

- (IBAction)commissionReportForSendAgent:(id)sender {
    [self performSegueWithIdentifier:@"sendCommissionReport" sender:NULL];
}

- (IBAction)profileSendAgent:(id)sender {
    [self performSegueWithIdentifier:@"sendProfile" sender:NULL];
}

// Receiving Agent
- (IBAction)receiveTrans:(id)sender {
    [self performSegueWithIdentifier:@"receiveTrans" sender:NULL];
}

- (IBAction)unpaidTransForRecAgent:(id)sender {
    [self performSegueWithIdentifier:@"recUnpaidTrans" sender:NULL];
}

- (IBAction)commissionReportRecAgent:(id)sender {
    [self performSegueWithIdentifier:@"sendCommissionReport" sender:NULL];
}

- (IBAction)profileRecAgent:(id)sender {
    [self performSegueWithIdentifier:@"sendProfile" sender:NULL];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

@end
