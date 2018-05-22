//
//  AgentPairingController.m
//  EA
//
//  Created by PSIHPOK on 2/9/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import "AgentPairingController.h"
#import "ProgressView.h"
#import "DataManager.h"
#import "AgentPairCell.h"

@interface AgentPairingController ()

@property (weak, nonatomic) IBOutlet UITableView *pairTableView;

@property (nonatomic) NSArray* users;
@property (nonatomic) NSMutableArray* sendUsers;
@property (nonatomic) NSMutableArray* recUsers;
@property (nonatomic) NSMutableArray* pairArray;
@property (nonatomic) NSMutableArray* recNameArray;

@property (nonatomic) NSMutableArray* pairDicArray;

@property (nonatomic) id<IDataStore> dataStore;
@property (nonatomic) id<IDataStore> pairDataStore;

@end

@implementation AgentPairingController

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
    self.sendUsers = [NSMutableArray array];
    self.recUsers = [NSMutableArray array];
    self.recNameArray = [NSMutableArray array];
    [ProgressView showProgressView:self.view message:NULL];
    self.dataStore = [backendless.data ofTable:@"Users"];
    self.pairDataStore = [backendless.data ofTable:@"AgentPair"];
    [self.dataStore find:^(NSArray* users) {
        self.users = users;
        for (int index = 0; index < self.users.count; index++) {
            NSDictionary* userDic = (NSDictionary*) [self.users objectAtIndex:index];
            int agentType = [(NSNumber*)[userDic objectForKey:@"agentType"] intValue];
            if (agentType == 1) {
                [self.sendUsers addObject:userDic];
            }
            else if (agentType == 2) {
                [self.recUsers addObject:userDic];
            }
        }
        [self.pairDataStore find:^(NSArray* pairs) {
            self.pairArray = [NSMutableArray arrayWithCapacity:self.sendUsers.count];
            for (int index = 0; index < self.recUsers.count; index++) {
                NSDictionary* user = (NSDictionary*) [self.recUsers objectAtIndex:index];
                NSString* name = [[user objectForKey:@"firstName"] stringByAppendingString:@" "];
                name = [name stringByAppendingString:[user objectForKey:@"lastName"]];
                [self.recNameArray addObject:name];
            }
            self.pairDicArray = [NSMutableArray array];
            for (int index = 0; index < self.sendUsers.count; index++) {
                NSDictionary* user = (NSDictionary*) [self.sendUsers objectAtIndex:index];
                NSString* senderID = (NSString*) [user objectForKey:@"objectId"];
                Boolean bFind = false;
                for (int pairIndex = 0; pairIndex < pairs.count; pairIndex++) {
                    NSDictionary* pair = (NSDictionary*) [pairs objectAtIndex:pairIndex];
                    NSString* sender = (NSString*) [pair objectForKey:@"senderID"];
                    NSString* receiver = (NSString*) [pair objectForKey:@"receiverID"];
                    if ([senderID isEqualToString:sender] == true) {
                        for (int recIndex = 0; recIndex < self.recUsers.count; recIndex++) {
                            NSDictionary* rec = (NSDictionary*) [self.recUsers objectAtIndex:recIndex];
                            NSString* recID = (NSString*) [rec objectForKey:@"objectId"];
                            if ([recID isEqualToString:receiver] == true) {
                                bFind = true;
                                [self.pairArray addObject:[NSNumber numberWithInt:recIndex]];
                                [self.pairDicArray addObject:pair];
                                break;
                            }
                        }
                    }
                }
                if (bFind == false) {
                    NSDictionary* rec = (NSDictionary*) [self.recUsers objectAtIndex:0];
                    NSString* recID = (NSString*) [rec objectForKey:@"objectId"];
                    [self.pairArray addObject:[NSNumber numberWithInt:0]];
                    [self.pairDicArray addObject:@{
                                                   @"senderID": senderID,
                                                   @"receiverID": recID
                                                   }];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [ProgressView dismissProgressView:^{
                    [self.pairTableView reloadData];
                }];
            });
        } error:^(Fault* fault) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ProgressView dismissProgressView:NULL];
                [ProgressView showToast:self.view message:@"Couldn't load Agents"];
            });
        }];
    } error:^(Fault* fault) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressView dismissProgressView:NULL];
            [ProgressView showToast:self.view message:@"Couldn't load Agents"];
        });
    }];
}

- (IBAction)onSave:(id)sender {
    [ProgressView showProgressView:self.view message:NULL];
    [self updateObject:0 completion:^ {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressView dismissProgressView:NULL];
        });
    }];
}

- (void) updateObject:(int) depth completion:(void(^)()) completion {
    if (depth == self.pairArray.count) completion();
    else {
        
        int index = [(NSNumber*)[self.pairArray objectAtIndex:depth] intValue];
        NSDictionary* receiver = (NSDictionary*)[self.recUsers objectAtIndex:index];
        NSDictionary* sender = (NSDictionary*)[self.sendUsers objectAtIndex:depth];
        NSMutableDictionary* pairDic = [NSMutableDictionary dictionaryWithDictionary:[self.pairDicArray objectAtIndex:depth]];
        [pairDic setObject:[sender objectForKey:@"objectId"] forKey:@"senderID"];
        [pairDic setObject:[receiver objectForKey:@"objectId"] forKey:@"receiverID"];
        
        self.pairDataStore = [backendless.data ofTable:@"AgentPair"];
        [self.pairDataStore save:pairDic response:^(id response) {
            [self updateObject:depth + 1 completion:completion];
        } error:^(Fault* fault) {
            [self updateObject:depth + 1 completion:completion];
        }];
    }
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AgentPairCell* cell = (AgentPairCell*) [tableView dequeueReusableCellWithIdentifier:@"agentPairCell" forIndexPath:indexPath];
    NSDictionary* sendDic = (NSDictionary*) [self.sendUsers objectAtIndex:indexPath.row];
    NSString* senderName = @"Sending Agent Name: ";
    senderName = [senderName stringByAppendingString:[sendDic objectForKey:@"firstName"]];
    senderName = [senderName stringByAppendingString:@" "];
    senderName = [senderName stringByAppendingString:[sendDic objectForKey:@"lastName"]];
    cell.sendAgent.text = senderName;
    
    DownPicker* picker = [[DownPicker alloc] initWithTextField:cell.recNames withData:self.recNameArray];
    [cell addSubview:picker];
    NSInteger pair = [(NSNumber*)[self.pairArray objectAtIndex:indexPath.row] integerValue];
    picker.selectedIndex = pair;
    [picker addTarget:self action:@selector(downPickerSelected:) forControlEvents:UIControlEventValueChanged];
    
    if (indexPath.row % 2 == 0) {
        [cell setBackgroundColor:[UIColor colorWithRed:76 / 255.0f green:101 / 255.0f blue:147 / 255.0f alpha:0.5f]];
    }
    else {
        [cell setBackgroundColor:[UIColor colorWithRed:197 / 255.0f green:134 / 255.0f blue:99 / 255.0f alpha:0.5f]];
    }
    return cell;
}

- (void) downPickerSelected:(id) picker {
    UITableViewCell* cell = (UITableViewCell*)[(DownPicker*) picker superview];
    NSIndexPath* indexPath = [self.pairTableView indexPathForCell:cell];
    if (indexPath != NULL) {
        [self.pairArray replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithInt:[((DownPicker*)picker) selectedIndex]]];
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sendUsers.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
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
