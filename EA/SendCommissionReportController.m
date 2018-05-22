//
//  SendCommissionReportController.m
//  EA
//
//  Created by PSIHPOK on 2/9/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import "SendCommissionReportController.h"
#import "ProgressView.h"
#import "DataManager.h"
#import "SenderCommissionReportCell.h"

@interface SendCommissionReportController ()

@property (weak, nonatomic) IBOutlet UITableView *reportTableView;

@property (weak, nonatomic) IBOutlet UILabel *totalCommission;
@property (weak, nonatomic) IBOutlet UILabel *totalAmountSent;

@property (nonatomic) NSArray* transactions;
@property (nonatomic) NSMutableArray* commissions;

@end

@implementation SendCommissionReportController

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
    self.commissions = [NSMutableArray array];
    [ProgressView showProgressView:self.view message:NULL];
    id<IDataStore> dataStore = [backendless.data ofTable:@"Transaction"];
    NSString* agentId = [backendless.userService.currentUser getObjectId];
    int agentType = [(NSNumber*)[backendless.userService.currentUser getProperty:@"agentType"] intValue];
    if (agentId == NULL) {
        [ProgressView dismissProgressView:NULL];
        [ProgressView showToast:self.view message:@"Couldn't get Sender Agent Information"];
    }
    else {
        NSString* where = NULL;
        if (agentType == 1) {
            where = [NSString stringWithFormat:@"sendingAgentID = '%@'", agentId];
        }
        else {
            where = [NSString stringWithFormat:@"receiverAgentID = '%@'", agentId];
        }
        
        DataQueryBuilder* query = [[DataQueryBuilder alloc] init];
        [query setWhereClause:where];
        [dataStore find:query response:^(NSArray* transactions) {
            self.transactions = transactions;
            double sum = 0;
            for (int index = 0; index < self.transactions.count; index++) {
                NSDictionary* trans = [self.transactions objectAtIndex:index];
                double amount = [DataManager getDouble:trans key:@"amountInUSD"];
                sum += amount;
            }
            [self splitTransToComms];
            dispatch_async(dispatch_get_main_queue(), ^{
                [ProgressView dismissProgressView:^{
                    self.totalAmountSent.text = [NSString stringWithFormat:@"Amount Sent: %.2f", sum];
                    self.totalCommission.text = [NSString stringWithFormat:@"Commission: %.2f", sum * 0.06 * 0.25];
                    [self.reportTableView reloadData];
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

- (void) splitTransToComms {
    NSDate* baseDate = NULL;
    double sumAmount = 0;
    if (self.transactions.count == 1) {
        NSDictionary* trans = [self.transactions objectAtIndex:0];
        double amount = [DataManager getDouble:trans key:@"amountInUSD"];
        baseDate = (NSDate*)[trans objectForKey:@"created"];
        NSDictionary* comm = @{
                               @"date": baseDate,
                               @"amount": @(amount)
                               };
        [self.commissions addObject:comm];
        return;
    }
    for (int index = 0; index < self.transactions.count; index++) {
        NSDictionary* trans = [self.transactions objectAtIndex:index];
        double amount = [DataManager getDouble:trans key:@"amountInUSD"];
        if (baseDate == NULL) {
            baseDate = (NSDate*)[trans objectForKey:@"created"];
            sumAmount = amount;
        }
        else {
            NSDate* date = (NSDate*)[trans objectForKey:@"created"];
            BOOL bSameDay = [[NSCalendar currentCalendar] isDate:baseDate inSameDayAsDate:date];
            if (bSameDay == TRUE) {
                sumAmount += amount;
                if (index == self.transactions.count - 1) {
                    NSDictionary* comm = @{
                                           @"date": baseDate,
                                           @"amount": @(sumAmount)
                                           };
                    [self.commissions addObject:comm];
                }
            }
            else {
                NSDictionary* comm = @{
                                       @"date": baseDate,
                                       @"amount": @(sumAmount)
                                       };
                [self.commissions addObject:comm];
                baseDate = date;
                sumAmount = amount;
            }
        }
    }
}

- (NSString*) addPrefix:(NSString*) prefix main:(NSString*) main {
    if (main != nil)
    {
        return [prefix stringByAppendingString:main];
    }
    return prefix;
}

- (NSString*) getDate:(NSString*) dateStr {
    return [self addPrefix:@"Date: " main:dateStr];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SenderCommissionReportCell* cell = (SenderCommissionReportCell*) [tableView dequeueReusableCellWithIdentifier:@"senderCommissionReportCell" forIndexPath:indexPath];
    
    NSDictionary* comm = (NSDictionary*) [self.commissions objectAtIndex:indexPath.row];
    double amount = [(NSNumber*)[comm objectForKey:@"amount"] doubleValue];
    cell.amountSent.text = [NSString stringWithFormat:@"Amount Sent: %.2f", amount];
    cell.commission.text = [NSString stringWithFormat:@"Commission: %.2f", amount * 0.06 * 0.25];
    NSDate* baseDate = (NSDate*) [comm objectForKey:@"date"];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    NSString* dateStr = [formatter stringFromDate:baseDate];
    cell.date.text = [self getDate:dateStr];
    
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.commissions.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 95;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

@end
