//
//  UnpaidTransController.m
//  EA
//
//  Created by PSIHPOK on 2/10/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import "UnpaidTransController.h"
#import "UnpaidTransCell.h"
#import "DataManager.h"
#import "ProgressView.h"

@interface UnpaidTransController ()

@property (weak, nonatomic) IBOutlet UITableView *transTableView;
@property (nonatomic) NSMutableArray* transactions;
@property (nonatomic) NSMutableArray* sendAgentNameArray;
@property (nonatomic) NSMutableArray* recAgentNameArray;

@end

@implementation UnpaidTransController

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
    self.transactions = [NSMutableArray array];
    self.sendAgentNameArray = [NSMutableArray array];
    self.recAgentNameArray = [NSMutableArray array];
    [ProgressView showProgressView:self.view message:NULL];
    id<IDataStore> dataStore = [backendless.data ofTable:@"Transaction"];
    NSString* agentId = [backendless.userService.currentUser getObjectId];
    if (agentId == NULL) {
        [ProgressView dismissProgressView:NULL];
        [ProgressView showToast:self.view message:@"Couldn't get Sender Agent Information"];
    }
    else {
        [dataStore find:^(NSArray* transactions) {
            for (int index = 0; index < transactions.count; index++) {
                NSDictionary* trans = (NSDictionary*) [transactions objectAtIndex:index];
                int status = [(NSNumber*)[trans objectForKey:@"status"] intValue];
                if (status != TS_PAID) {
                    [self.transactions addObject:trans];
                }
            }
            id<IDataStore> userStore = [backendless.data ofTable:@"Users"];
            [userStore find:^(NSArray* users) {
                id<IDataStore> pairStore = [backendless.data ofTable:@"AgentPair"];
                [pairStore find:^(NSArray* pairs) {
                    for (int tIndex = 0; tIndex < self.transactions.count; tIndex++) {
                        NSDictionary* trans = (NSDictionary*)[self.transactions objectAtIndex:tIndex];
                        NSString* senderID = (NSString*) [trans objectForKey:@"sendingAgentID"];
                        NSString* receiverID = NULL;
                        for (int pIndex = 0; pIndex < pairs.count; pIndex++) {
                            NSDictionary* pair = (NSDictionary*) [pairs objectAtIndex:pIndex];
                            NSString* sender = (NSString*) [pair objectForKey:@"senderID"];
                            NSString* receiver = (NSString*) [pair objectForKey:@"receiverID"];
                            if ([sender isEqualToString:senderID] == true) {
                                receiverID = receiver;
                                break;
                            }
                        }
                        if (receiverID == NULL) {
                            for (int uIndex = 0; uIndex < users.count; uIndex++) {
                                NSDictionary* user = (NSDictionary*)[users objectAtIndex:uIndex];
                                int agentType = [(NSNumber*)[user objectForKey:@"agentType"] intValue];
                                if (agentType == 2) {
                                    receiverID = (NSString*) [user objectForKey:@"objectId"];
                                }
                            }
                        }
                        for (int uIndex = 0; uIndex < users.count; uIndex++) {
                            NSDictionary* user = (NSDictionary*)[users objectAtIndex:uIndex];
                            NSString* objectId = (NSString*)[user objectForKey:@"objectId"];
                            if ([objectId isEqualToString:senderID] == true) {
                                NSString* name = [user objectForKey:@"firstName"];
                                name = [name stringByAppendingString:@" "];
                                name = [name stringByAppendingString:(NSString*)[user objectForKey:@"lastName"]];
                                [self.sendAgentNameArray addObject:name];
                            }
                            if ([objectId isEqualToString:receiverID] == true) {
                                NSString* name = [user objectForKey:@"firstName"];
                                name = [name stringByAppendingString:@" "];
                                name = [name stringByAppendingString:(NSString*)[user objectForKey:@"lastName"]];
                                [self.recAgentNameArray addObject:name];
                            }
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [ProgressView dismissProgressView:^{
                            [self.transTableView reloadData];
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
        } error:^(Fault* fault) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ProgressView dismissProgressView:NULL];
                [ProgressView showToast:self.view message:@"Couldn't load Transactions"];
            });
        }];
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.transactions.count == 0)
        return 0;
    else
        return self.transactions.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UnpaidTransCell* cell = (UnpaidTransCell*) [tableView dequeueReusableCellWithIdentifier:@"unpaidTransCell" forIndexPath:indexPath];
    NSDictionary* transaction = (NSDictionary*) [self.transactions objectAtIndex:indexPath.row];
    
    cell.transID.text = [self getTransID:transaction];
    cell.date.text = [self getDate:transaction];
    cell.sendName.text = [self getSender:transaction];
    cell.recName.text = [self getReceiver:transaction];
    cell.amount.text = [self getAmount:transaction];
    cell.status.text = [self getStatus:transaction];
    cell.sendAgent.text = [self getSenderAgent:indexPath.row];
    cell.recAgent.text = [self getReceiverAgent:indexPath.row];
    
    return cell;
}

- (NSString*) addPrefix:(NSString*) prefix main:(NSString*) main {
    if (main != nil)
    {
        return [prefix stringByAppendingString:main];
    }
    return prefix;
}

- (NSString*) getTransID:(NSDictionary*) transaction {
    return [self addPrefix:@"T-ID: " main:[transaction objectForKey:@"transID"]];
}

- (NSString*) getDate:(NSDictionary*) trans {
    return [self addPrefix:@"Date: " main:[DataManager getDateStr:trans key:@"created"]];
}

- (NSString*) getSender:(NSDictionary*) trans {
    return [self addPrefix:@"Sender: " main:[DataManager getNameStr:[trans objectForKey:@"senderFirstName"] lastName:[trans objectForKey:@"senderLastName"]]];
}

- (NSString*) getReceiver:(NSDictionary*) trans {
    return [self addPrefix:@"Receiver: " main:[DataManager getNameStr:[trans objectForKey:@"recFirstName"] lastName:[trans objectForKey:@"recLastName"]]];
}

- (NSString*) getSenderAgent:(NSInteger) index {
    return [self addPrefix:@"SendingAgent: " main:[self.sendAgentNameArray objectAtIndex:index]];
}

- (NSString*) getReceiverAgent:(NSInteger) index {
    return [self addPrefix:@"ReceivingAgent: " main:[self.recAgentNameArray objectAtIndex:index]];
}

- (NSString*) getAmount:(NSDictionary*) trans {
    double amount = [DataManager getDouble:trans key:@"amountInUSD"];
    return [self addPrefix:@"Amount: " main:[NSString stringWithFormat:@"%.2f", amount]];
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

-(CGFloat) heightForView:(NSString*) text font:(UIFont*) font width:(CGFloat) width {
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, CGFLOAT_MAX)];
    [label setNumberOfLines:0];
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    [label setFont:font];
    [label setText:text];
    [label sizeToFit];
    return [label frame].size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 8;
    NSDictionary* transaction = self.transactions[indexPath.row];
    CGFloat width = [[UIScreen mainScreen] bounds].size.width - 16;
    height += [self heightForView:[self getTransID:transaction] font:[UIFont systemFontOfSize:17] width:width] + 8;
    height += [self heightForView:[self getDate:transaction] font:[UIFont systemFontOfSize:17] width:width] + 8;
    height += [self heightForView:[self getAmount:transaction] font:[UIFont systemFontOfSize:17] width:width] + 8;
    height += [self heightForView:[self getSender:transaction] font:[UIFont systemFontOfSize:17] width:width] + 8;
    height += [self heightForView:[self getReceiver:transaction] font:[UIFont systemFontOfSize:17] width:width] + 8;
    height += [self heightForView:[self getStatus:transaction] font:[UIFont systemFontOfSize:17] width:width] + 8;
    height += [self heightForView:[self getSenderAgent:indexPath.row] font:[UIFont systemFontOfSize:17] width:width] + 8;
    height += [self heightForView:[self getReceiverAgent:indexPath.row] font:[UIFont systemFontOfSize:17] width:width] + 8;
    
    return height;
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
