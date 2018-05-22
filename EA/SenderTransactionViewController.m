//
//  SenderTransactionViewController.m
//  EA
//
//  Created by PSIHPOK on 2/6/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import "SenderTransactionViewController.h"
#import "SenderTransViewCell.h"
#import "ProgressView.h"
#import "DataManager.h"

@interface SenderTransactionViewController ()

@property (weak, nonatomic) IBOutlet UITableView *transTableView;

@property (nonatomic) NSArray* transactions;

@end

@implementation SenderTransactionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    id<IDataStore> dataStore = [backendless.data ofTable:@"Transaction"];
    NSString* agentId = [backendless.userService.currentUser getObjectId];
    if (agentId == NULL) {
        [ProgressView dismissProgressView:NULL];
        [ProgressView showToast:self.view message:@"Couldn't get Sender Agent Information"];
    }
    else {
        NSString* where = [NSString stringWithFormat:@"sendingAgentID = '%@'", agentId];
        DataQueryBuilder* query = [[DataQueryBuilder alloc] init];
        [query setWhereClause:where];
        [dataStore find:query response:^(NSArray* transactions) {
            self.transactions = transactions;
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
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    SenderTransViewCell* cell = (SenderTransViewCell*) [tableView dequeueReusableCellWithIdentifier:@"senderTransViewCell" forIndexPath:indexPath];
    NSDictionary* transaction = (NSDictionary*) [self.transactions objectAtIndex:indexPath.row];
    
    cell.transID.text = [self getTransID:transaction];
    cell.date.text = [self getDate:transaction];
    cell.sender.text = [self getSender:transaction];
    cell.receiver.text = [self getReceiver:transaction];
    cell.amount.text = [self getAmount:transaction];
    cell.status.text = [self getStatus:transaction];
    cell.fee.text = [self getAgentFee:transaction];
    
    return cell;
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

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.transactions != NULL)
        return self.transactions.count;
    else
        return 0;
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
