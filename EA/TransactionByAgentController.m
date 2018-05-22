//
//  TransactionByAgentController.m
//  EA
//
//  Created by PSIHPOK on 2/9/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import "TransactionByAgentController.h"
#import "TransactionByAgentCell.h"
#import "KPDropMenu/KPDropMenu.h"
#import "DataManager.h"
#import "ProgressView.h"

@interface TransactionByAgentController ()

@property (weak, nonatomic) IBOutlet KPDropMenu *agentDropMenu;
@property (weak, nonatomic) IBOutlet UITableView *transTableView;

@property (nonatomic) NSMutableArray* transactions;
@property (nonatomic) NSMutableArray* users;

@end

@implementation TransactionByAgentController

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
    self.users = [NSMutableArray array];
    self.transactions = [NSMutableArray array];
    [ProgressView showProgressView:self.view message:NULL];
    id<IDataStore> userStore = [backendless.data ofTable:@"Users"];
    [userStore find:^(NSArray* users) {
        NSMutableArray* nameArray = [NSMutableArray array];
        for (int index = 0; index < users.count; index++) {
            NSDictionary* user = (NSDictionary*) [users objectAtIndex:index];
            int agentType = [(NSNumber*)[user objectForKey:@"agentType"] intValue];
            if (agentType != 0) {
                [self.users addObject:user];
                NSString* nameStr = [DataManager getNameStr:[user objectForKey:@"firstName"] lastName:[user objectForKey:@"lastName"]];
                [nameArray addObject:nameStr];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressView dismissProgressView:NULL];
            self.agentDropMenu.items = nameArray;
            self.agentDropMenu.delegate = self;
            [self loadTrans:0];
        });
    } error:^(Fault* fault) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressView dismissProgressView:NULL];
            [ProgressView showToast:self.view message:@"Couldn't load Transactions"];
        });
    }];
}

-(void)didSelectItem : (KPDropMenu *) dropMenu atIndex : (int) atIndex {
    [self loadTrans:atIndex];
}

- (void) loadTrans:(int) index {
    NSDictionary* user = (NSDictionary*) [self.users objectAtIndex:index];
    NSString* userID = (NSString*) [user objectForKey:@"objectId"];
    [ProgressView showProgressView:self.view message:NULL];
    id<IDataStore> dataStore = [backendless.data ofTable:@"Transaction"];
    [dataStore find:^(NSArray* transArr) {
        id<IDataStore> pairStore = [backendless.data ofTable:@"AgentPair"];
        [pairStore find:^(NSArray* pairs) {
            self.transactions = [NSMutableArray array];
            for (int index = 0; index < transArr.count; index++) {
                NSDictionary* trans = (NSDictionary*) [transArr objectAtIndex:index];
                NSString* sender = (NSString*) [trans objectForKey:@"sendingAgentID"];
                NSString* receiver = NULL;
                for (int pIndex = 0; pIndex < pairs.count; pIndex++) {
                    NSDictionary* pair = (NSDictionary*) [pairs objectAtIndex:pIndex];
                    NSString* senderID = [pair objectForKey:@"senderID"];
                    NSString* receiverID = [pair objectForKey:@"receiverID"];
                    if ([senderID isEqualToString:sender] == true) {
                        receiver = receiverID;
                        break;
                    }
                }
                if ([sender isEqualToString:userID] == true || (receiver != NULL && [receiver isEqualToString:userID] == true)) {
                    [self.transactions addObject:trans];
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
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.transactions.count == 0)
        return 0;
    else
        return self.transactions.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TransactionByAgentCell* cell = (TransactionByAgentCell*) [tableView dequeueReusableCellWithIdentifier:@"transactionByAgentCell" forIndexPath:indexPath];
    NSDictionary* transaction = (NSDictionary*) [self.transactions objectAtIndex:indexPath.row];
    
    cell.transID.text = [self getTransID:transaction];
    cell.date.text = [self getDate:transaction];
    cell.senderName.text = [self getSender:transaction];
    cell.receiverName.text = [self getReceiver:transaction];
    cell.amount.text = [self getAmount:transaction];
    cell.status.text = [self getStatus:transaction];
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
