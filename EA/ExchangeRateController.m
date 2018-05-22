//
//  ExchangeRateController.m
//  EA
//
//  Created by PSIHPOK on 2/9/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import "ExchangeRateController.h"
#import "ProgressView.h"
#import "DataManager.h"

@interface ExchangeRateController ()

@property (weak, nonatomic) IBOutlet UITextField *ethiopia;
@property (weak, nonatomic) IBOutlet UITextField *eritrea;
@property (weak, nonatomic) IBOutlet UITextField *sudan;

@property (weak, nonatomic) IBOutlet UITextField *ethiopiaB;
@property (weak, nonatomic) IBOutlet UITextField *ethiopiaA;
@property (weak, nonatomic) IBOutlet UITextField *eritreaB;
@property (weak, nonatomic) IBOutlet UITextField *eritreaA;
@property (weak, nonatomic) IBOutlet UITextField *sudanB;
@property (weak, nonatomic) IBOutlet UITextField *sudanA;
@property (weak, nonatomic) IBOutlet UITextField *srRate;

@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (nonatomic) NSArray* params;
@property (nonatomic) NSArray* rateDics;

@end

@implementation ExchangeRateController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"East Africa Money Wire"];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Back"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(backBtnClicked:)];
    self.navigationItem.leftBarButtonItem = backButton;
    self.params = @[@"Ethiopia", @"Eritrea", @"Sudan",
                    @"EthiopiaB", @"EthiopiaA",
                    @"EritreaB", @"EritreaA",
                    @"SudanB", @"SudanA",
                    @"Send&Receive"];
}

- (void)backBtnClicked:(id) sender {
    [self.navigationController dismissViewControllerAnimated:false completion:NULL];
}

- (NSString*) getRate:(NSMutableArray*) array index:(NSInteger) index {
    double rate = [(NSNumber*)[array objectAtIndex:index] doubleValue];
    return [NSString stringWithFormat:@"%.2f", rate];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [ProgressView showProgressView:self.view message:NULL];
    id<IDataStore> dataStore = [backendless.data ofTable:@"ExchangeRate"];
    [dataStore find:^(NSArray* rates) {
        self.rateDics = rates;
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressView dismissProgressView:^{
                NSMutableArray* array = [NSMutableArray array];
                for (int pIndex = 0; pIndex < self.params.count; pIndex++) {
                    NSString* key = (NSString*) [self.params objectAtIndex:pIndex];
                    for (int index = 0; index < rates.count; index++) {
                        NSDictionary* rateDic = (NSDictionary*) [rates objectAtIndex:index];
                        if ([(NSString*)[rateDic objectForKey:@"param"] isEqualToString:key] == true) {
                            [array addObject:[rateDic objectForKey:@"rate"]];
                            break;
                        }
                    }
                }
                self.ethiopia.text = [self getRate:array index:0];
                self.eritrea.text = [self getRate:array index:1];
                self.sudan.text = [self getRate:array index:2];
                self.ethiopiaB.text = [self getRate:array index:3];
                self.ethiopiaA.text = [self getRate:array index:4];
                self.eritreaB.text = [self getRate:array index:5];
                self.eritreaA.text = [self getRate:array index:6];
                self.sudanB.text = [self getRate:array index:7];
                self.sudanA.text = [self getRate:array index:8];
                self.srRate.text = [self getRate:array index:9];
            }];
        });
    } error:^(Fault* fault) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressView dismissProgressView:NULL];
            [ProgressView showToast:self.view message:@"Couldn't load Rates"];
        });
    }];
}

- (NSDictionary*) getChangedDic:(UITextField*) field param:(NSString*) param {
    NSDictionary* findDic;
    for (int index = 0; index < self.rateDics.count; index++) {
        NSDictionary* dic = (NSDictionary*) [self.rateDics objectAtIndex:index];
        if ([(NSString*)[dic objectForKey:@"param"] isEqualToString:param] == true) {
            findDic = dic;
            break;
        }
    }
    NSMutableDictionary* newDic = [NSMutableDictionary dictionaryWithDictionary:findDic];
    [newDic setObject:@([field.text doubleValue]) forKey:@"rate"];
    return newDic;
}

- (IBAction)onSave:(id)sender {
    BOOL bFilled = [self checkForm];
    if (!bFilled) {
        [ProgressView showToast:self.view message:@"Please fill all fields"];
    }
    else {
        id<IDataStore> dataStore = [backendless.data ofTable:@"ExchangeRate"];
        NSDictionary* ethiopia = [self getChangedDic:self.ethiopia param:[self.params objectAtIndex:0]];
        [dataStore save:ethiopia];
        NSDictionary* eritrea = [self getChangedDic:self.eritrea param:[self.params objectAtIndex:1]];
        [dataStore save:eritrea];
        NSDictionary* sudan = [self getChangedDic:self.sudan param:[self.params objectAtIndex:2]];
        [dataStore save:sudan];
        NSDictionary* ethiopiaB = [self getChangedDic:self.ethiopiaB param:[self.params objectAtIndex:3]];
        [dataStore save:ethiopiaB];
        NSDictionary* ethiopiaA = [self getChangedDic:self.ethiopiaA param:[self.params objectAtIndex:4]];
        [dataStore save:ethiopiaA];
        NSDictionary* eritreaB = [self getChangedDic:self.eritreaB param:[self.params objectAtIndex:5]];
        [dataStore save:eritreaB];
        NSDictionary* eritreaA = [self getChangedDic:self.eritreaA param:[self.params objectAtIndex:6]];
        [dataStore save:eritreaA];
        NSDictionary* sudanB = [self getChangedDic:self.sudanB param:[self.params objectAtIndex:7]];
        [dataStore save:sudanB];
        NSDictionary* sudanA = [self getChangedDic:self.sudanA param:[self.params objectAtIndex:8]];
        [dataStore save:sudanA];
        NSDictionary* srRate = [self getChangedDic:self.srRate param:[self.params objectAtIndex:9]];
        [dataStore save:srRate];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

@end
