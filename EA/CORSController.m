//
//  CORSController.m
//  EA
//
//  Created by PSIHPOK on 2/12/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import "CORSController.h"
#import "CorsCell.h"
#import "DataManager.h"
#import "ProgressView.h"

@interface CORSController ()

@property (weak, nonatomic) IBOutlet UITableView *corsTableView;

@property (nonatomic) NSMutableArray* transactions;

@end

@implementation CORSController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"East Africa Money Wire"];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Back"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(backBtnClicked:)];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)backBtnClicked:(id) sender {
    [self.navigationController dismissViewControllerAnimated:false completion:NULL];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.transactions = [NSMutableArray array];
    [ProgressView showProgressView:self.view message:NULL];
    id<IDataStore> dataStore = [backendless.data ofTable:@"Transaction"];
    [dataStore find:^(NSArray* transArray) {
        for (int index = 0; index < transArray.count; index++) {
            NSDictionary* trans = (NSDictionary*)[transArray objectAtIndex:index];
            float cors = [(NSNumber*)[trans objectForKey:@"cors"] floatValue];
            if (cors > 0) {
                [self.transactions addObject:trans];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressView dismissProgressView:NULL];
            [self.corsTableView reloadData];
        });
    } error:^(Fault* fault) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressView dismissProgressView:NULL];
            [ProgressView showToast:self.view message:@"Failed to approve the transaction"];
        });
    }];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.transactions.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CorsCell* cell = (CorsCell*) [tableView dequeueReusableCellWithIdentifier:@"corsCell" forIndexPath:indexPath];
    NSDictionary* trans = (NSDictionary*)[self.transactions objectAtIndex:indexPath.row];
    cell.transID.text = [self getTransID:trans];
    cell.date.text = [self getDate:trans];
    cell.sender.text = [self getSender:trans];
    cell.amount.text = [self getAmount:trans];
    cell.birthday.text = [self getBirthday:trans];
    cell.match.text = [self getMatch:trans];
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

- (NSString*) getAmount:(NSDictionary*) trans {
    double amount = [DataManager getDouble:trans key:@"amountInUSD"];
    return [self addPrefix:@"Amount: " main:[NSString stringWithFormat:@"%.2f", amount]];
}

- (NSString*) getBirthday:(NSDictionary*) trans {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM YYYY"];
    NSString* dateStr = [formatter stringFromDate:(NSDate*)[trans objectForKey:@"senderBirthday"]];
    return [self addPrefix:@"Birthday: " main:dateStr];
}

- (NSString*) getMatch:(NSDictionary*) trans {
    double match = [DataManager getDouble:trans key:@"cors"];
    return [self addPrefix:@"Match: " main:[NSString stringWithFormat:@"%.0f%%", match]];
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
    height += [self heightForView:[self getSender:transaction] font:[UIFont systemFontOfSize:17] width:width] + 8;
    height += [self heightForView:[self getAmount:transaction] font:[UIFont systemFontOfSize:17] width:width] + 8;
    height += [self heightForView:[self getBirthday:transaction] font:[UIFont systemFontOfSize:17] width:width] + 8;
    height += [self heightForView:[self getMatch:transaction] font:[UIFont systemFontOfSize:17] width:width] + 8;
    height += 8;
    
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
