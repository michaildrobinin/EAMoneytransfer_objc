//
//  ReviewAssignController.m
//  EA
//
//  Created by PSIHPOK on 2/9/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import "ReviewAssignController.h"
#import "ProgressView.h"
#import "DataManager.h"
#import "ReviewAssignCell.h"
#import "AdminTransDetailController.h"

@interface ReviewAssignController ()

@property (weak, nonatomic) IBOutlet UITableView *reviewAssignTableView;
@property (nonatomic) NSMutableArray* transactions;

@property (nonatomic) NSMutableArray* sendAgentNameArray;
@property (nonatomic) NSMutableArray* recAgentNameArray;

@end

@implementation ReviewAssignController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"East Africa Money Wire"];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Back"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(backBtnClicked:)];
    self.navigationItem.leftBarButtonItem = backButton;
    // Do any additional setup after loading the view.
}

- (void)backBtnClicked:(id) sender {
    [self.navigationController dismissViewControllerAnimated:false completion:NULL];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.transactions = [NSMutableArray array];
    self.sendAgentNameArray = [NSMutableArray array];
    self.recAgentNameArray = [NSMutableArray array];
    self.reviewAssignTableView.delaysContentTouches = false;
    [self loadTable];
}

- (void) loadTable {
    [ProgressView showProgressView:self.view message:NULL];
    id<IDataStore> dataStore = [backendless.data ofTable:@"Transaction"];
    NSString* agentId = [backendless.userService.currentUser getObjectId];
    if (agentId == NULL) {
        [ProgressView dismissProgressView:NULL];
        [ProgressView showToast:self.view message:@"Couldn't get Sender Agent Information"];
    }
    else {
        NSString* sender_where = [NSString stringWithFormat:@"status = 0"];
        
        DataQueryBuilder* sender_query = [[DataQueryBuilder alloc] init];
        
        [sender_query setWhereClause:sender_where];
        [dataStore find:sender_query response:^(NSArray* transactions)
        {
            for (int index = 0; index < transactions.count; index++) {
                NSDictionary* trans = (NSDictionary*) [transactions objectAtIndex:index];
                int status = [(NSNumber*)[trans objectForKey:@"status"] intValue];
                if (status == TS_PENDING) {
                    [self.transactions addObject:trans];
                }
            }
            id<IDataStore> userStore = [backendless.data ofTable:@"Users"];
            [userStore find:^(NSArray* users)
            {
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
                            for (int uuIndex = 0; uuIndex < users.count; uuIndex++) {
                                NSDictionary* user = (NSDictionary*)[users objectAtIndex:uuIndex];
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
                            [self.reviewAssignTableView reloadData];
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
        } error:^(Fault* fault)
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [ProgressView dismissProgressView:NULL];
                [ProgressView showToast:self.view message:@"Couldn't load Transactions"];
            });
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.transactions == NULL)
        return 0;
    return self.transactions.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReviewAssignCell* cell = (ReviewAssignCell*) [tableView dequeueReusableCellWithIdentifier:@"reviewAssignCell" forIndexPath:indexPath];
    NSDictionary* trans = (NSDictionary*) self.transactions[indexPath.row];
    
    cell.transID.text = [self getTransID:trans];
    cell.date.text = [self getDate:trans];
    cell.amount.text = [self getAmount:trans]; cell.fees.text = [self getAgentFee:trans];
    cell.sender.text = [self getSender:trans]; cell.receiver.text = [self getReceiver:trans];
    cell.sendAgent.text = [self getSenderAgent:indexPath.row];
    cell.recAgent.text = [self getReceiverAgent:indexPath.row];
    cell.cors.text = [self getCORS:trans]; cell.country.text = [self getCountry:trans];
    [cell.approveBtn addTarget:self action:@selector(approve:) forControlEvents:UIControlEventTouchUpInside];
    [cell.editBtn addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void) approve:(id) sender {
    // [self performSegueWithIdentifier:@"approve" sender:sender];
    UITableViewCell* cell = (UITableViewCell*) [[(UIView*)sender superview] superview];
    NSIndexPath* indexPath = [self.reviewAssignTableView indexPathForCell:cell];
    if (indexPath != NULL) {
        NSDictionary* trans = (NSDictionary*) self.transactions[indexPath.row];
        NSMutableDictionary* newTrans = [NSMutableDictionary dictionaryWithDictionary:trans];
        NSMutableDictionary* prevTrans = [NSMutableDictionary dictionaryWithDictionary:trans];
        [newTrans setObject:@(TS_PROCESSING) forKey:@"status"];
        [ProgressView showProgressView:self.view message:NULL];
        id<IDataStore> dataStore = [backendless.data ofTable:@"Transaction"];

        [dataStore save:newTrans response:^(id response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ProgressView dismissProgressView:NULL];
                [self.transactions removeObjectsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row]];
                [self.reviewAssignTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            });
        } error:^(Fault* fault) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ProgressView dismissProgressView:NULL];
                [ProgressView showToast:self.view message:@"Failed to approve the transaction"];
            });
        }];
    }
}

- (void) edit:(id) sender {
    [self performSegueWithIdentifier:@"editTrans" sender:sender];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 8;
    NSDictionary* transaction = self.transactions[indexPath.row];
    CGFloat width = [[UIScreen mainScreen] bounds].size.width - 16;
    height += [self heightForView:[self getTransID:transaction] font:[UIFont systemFontOfSize:17] width:width] + 8;
    height += [self heightForView:[self getDate:transaction] font:[UIFont systemFontOfSize:17] width:width] + 8;
    height += [self heightForView:[self getAmount:transaction] font:[UIFont systemFontOfSize:17] width:width] + 8;
    height += [self heightForView:[self getAgentFee:transaction] font:[UIFont systemFontOfSize:17] width:width] + 8;
    height += [self heightForView:[self getSender:transaction] font:[UIFont systemFontOfSize:17] width:width] + 8;
    height += [self heightForView:[self getReceiver:transaction] font:[UIFont systemFontOfSize:17] width:width] + 8;
    height += [self heightForView:[self getCORS:transaction] font:[UIFont systemFontOfSize:17] width:width] + 8;
    height += [self heightForView:[self getSenderAgent:indexPath.row] font:[UIFont systemFontOfSize:17] width:width] + 8;
    height += [self heightForView:[self getReceiverAgent:indexPath.row] font:[UIFont systemFontOfSize:17] width:width] + 8;
    height += [self heightForView:[self getCountry:transaction] font:[UIFont systemFontOfSize:17] width:width] + 8;
    height += 38;
    
    return height;
}

- (NSString*) addPrefix:(NSString*) prefix main:(NSString*) main {
    if (main != nil) {
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

- (NSString*) getAmount:(NSDictionary*) trans {
    double amount = [DataManager getDouble:trans key:@"amountInUSD"];
    return [self addPrefix:@"Amount: " main:[NSString stringWithFormat:@"%.2f", amount]];
}

- (NSString*) getAgentFee:(NSDictionary*) trans {
    double amount = [DataManager getDouble:trans key:@"amountInUSD"];
    return [self addPrefix:@"Agent fee: " main:[NSString stringWithFormat:@"%.2f", amount * 0.06 * 0.25]];
}

- (NSString*) getCORS:(NSDictionary*) trans {
    double match = [DataManager getDouble:trans key:@"cors"];
    return [self addPrefix:@"CORS: " main:[NSString stringWithFormat:@"%.0f%%", match]];
}

- (NSString*) getCountry:(NSDictionary*) trans {
//    if (trans == nil) {
//        return @"Country: ";
//    }
    return [self addPrefix:@"Country: " main:[trans objectForKey:@"recCountry"]];
}

- (NSString*) getSenderAgent:(NSInteger) index {
    if (index >= self.sendAgentNameArray.count) {
        return @"SendingAgent: ";
    }
    return [self addPrefix:@"SendingAgent: " main:[self.sendAgentNameArray objectAtIndex:index]];
}

- (NSString*) getReceiverAgent:(NSInteger) index {
    if (index >= self.recAgentNameArray.count) {
        return @"ReceivingAgent: ";
    }
    return [self addPrefix:@"ReceivingAgent: " main:[self.recAgentNameArray objectAtIndex:index]];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"approve"] == true)
    {
        UINavigationController* dest = (UINavigationController*)[segue destinationViewController];
        AdminTransDetailController* detail = (AdminTransDetailController*) dest.topViewController;
        UITableViewCell* cell = (UITableViewCell*) [[(UIView*) sender superview] superview];
        NSIndexPath* indexPath = [self.reviewAssignTableView indexPathForCell:cell];
        if (indexPath != NULL) {
            detail.transaction = self.transactions[indexPath.row];
        }
    }
    else if ([segue.identifier isEqualToString:@"editTrans"] == true) {
        UITableViewCell* cell = (UITableViewCell*) [[(UIView*) sender superview] superview];
        NSIndexPath* indexPath = [self.reviewAssignTableView indexPathForCell:cell];
        if (indexPath != NULL) {
            [DataManager getInstance]->bEditSendMoneyInfo = true;
            [DataManager getInstance].sendMoneyInfo = self.transactions[indexPath.row];
        }
    }
}

@end
