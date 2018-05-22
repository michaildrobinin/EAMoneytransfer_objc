//
//  PreviewController.m
//  EA
//
//  Created by PSIHPOK on 2/2/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import "PreviewController.h"
#import "DataManager.h"
#import "AppDelegate.h"
#import "ProgressView.h"

@interface PreviewController ()

    @property (weak, nonatomic) IBOutlet UILabel *resultTitle;
    @property (weak, nonatomic) IBOutlet UILabel *senderName;
    @property (weak, nonatomic) IBOutlet UILabel *senderAddress;
    @property (weak, nonatomic) IBOutlet UILabel *senderPhone;

    @property (weak, nonatomic) IBOutlet UILabel *receiverName;
    @property (weak, nonatomic) IBOutlet UILabel *receiverAddress;
    @property (weak, nonatomic) IBOutlet UILabel *receiverPhone;
    @property (weak, nonatomic) IBOutlet UILabel *receiverAPhone;
    
    @property (weak, nonatomic) IBOutlet UILabel *amountInUSD;
    @property (weak, nonatomic) IBOutlet UILabel *amountLocalCurrency;
    @property (weak, nonatomic) IBOutlet UILabel *serviceCharge;
    @property (weak, nonatomic) IBOutlet UILabel *totalTransactionAmount;
    
    @property (weak, nonatomic) IBOutlet UIButton *printBtn;
    @property (weak, nonatomic) IBOutlet UIButton *editBtn;
    @property (weak, nonatomic) IBOutlet UIButton *submitBtn;
    
    
@end

@implementation PreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.printBtn setHidden:YES];
    self.resultTitle.text = @"Transaction Summary";
    self.resultTitle.textAlignment = NSTextAlignmentRight;
    
    self.senderName.text = [self.senderName.text stringByAppendingString:[DataManager getInstance].senderName];
    self.senderAddress.text = [self.senderAddress.text stringByAppendingString:[DataManager getInstance].senderAddress];
    self.senderPhone.text = [self.senderPhone.text stringByAppendingString:[DataManager getInstance].senderPhone];
    self.receiverName.text = [self.receiverName.text stringByAppendingString:[DataManager getInstance].receiverName];
    self.receiverAddress.text = [self.receiverAddress.text stringByAppendingString:[DataManager getInstance].receiverAddress];
    self.receiverPhone.text = [self.receiverPhone.text stringByAppendingString:[DataManager getInstance].receiverPhone];
    self.receiverAPhone.text = [self.receiverAPhone.text stringByAppendingString:[DataManager getInstance].receiverAltPhone];
    self.amountInUSD.text = [self.amountInUSD.text stringByAppendingString:[DataManager getInstance].amountInUSD];
    self.amountLocalCurrency.text = [self.amountLocalCurrency.text stringByAppendingString:[DataManager getInstance].amountLocal];
    self.serviceCharge.text = [self.serviceCharge.text stringByAppendingString:[DataManager getInstance].serviceCharge];
    self.totalTransactionAmount.text = [self.totalTransactionAmount.text stringByAppendingString:[DataManager getInstance].totalTransAmount];
}
    
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationItem setTitle:@"East Africa Money Wire"];
}
    
- (IBAction)onClickPrint:(id)sender {
    [self print];
}

- (IBAction)onClickEdit:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onClickSubmit:(id)sender {
    [self.printBtn setHidden:NO];
    [self.editBtn setHidden:YES];
    [self.submitBtn setHidden:YES];
    self.resultTitle.text = @"Congratulations, your transaction has been submitted";
    self.resultTitle.textAlignment = NSTextAlignmentCenter;
}

- (void)print {
    NSString* htmlStr = @"<h1>Transaction</h1><h2>Sender Info</h2><h4>Name: %@</h4><h4>Address: %@</h4><h4>Phone: %@</h4><h2>Receiver Info</h2><h4>Name: %@</h4><h4>Address: %@</h4><h4>Phone: %@</h4><h4>Alternative Phone: %@</h4><h2>Transaction Info</h2><h4>Amount to be send in USD: %@</h4><h4>Amount in Local Currency: %@</h4><h4>Service Charge: %@</h4><h4>Total Transaction Amount: %@</h4>";
    NSString* html = [NSString stringWithFormat:htmlStr, [DataManager getInstance].senderName, [DataManager getInstance].senderAddress, [DataManager getInstance].senderPhone, [DataManager getInstance].receiverName, [DataManager getInstance].receiverAddress, [DataManager getInstance].receiverPhone, [DataManager getInstance].receiverAltPhone, [DataManager getInstance].amountInUSD, [DataManager getInstance].amountLocal, [DataManager getInstance].serviceCharge, [DataManager getInstance].totalTransAmount];
    UIMarkupTextPrintFormatter *formatter = [[UIMarkupTextPrintFormatter alloc] initWithMarkupText:html];
    //formatter.contentInsets = UIEdgeInsetsMake(72, 72, 72, 72); // 1" margins
    formatter.perPageContentInsets = UIEdgeInsetsMake(72, 72, 72, 72); // 1" margins
    
    if ([UIPrintInteractionController isPrintingAvailable]) {
        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        printInfo.jobName = @"Print_Transaction";
        printInfo.outputType = UIPrintInfoOutputGeneral;
        
        UIPrintInteractionController *printController = [UIPrintInteractionController sharedPrintController];
        printController.printFormatter = formatter;
        // printController.delegate = self;
        
        [printController presentAnimated:true completionHandler: ^(UIPrintInteractionController *printInteractionController, BOOL completed, NSError * __nullable error){
            if (completed) {
                UIViewController* main = [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:@"categoryController"];
                [[(AppDelegate*)[[UIApplication sharedApplication] delegate] window] setRootViewController:main];
                [DataManager getInstance].sendMoneyInfo = NULL;
            }
            else {
                [ProgressView showToast:self.view message:@"Couldn't Print Transaction"];
            }
        }];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

@end
