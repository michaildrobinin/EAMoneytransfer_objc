//
//  SenderCommissionReportCell.h
//  EA
//
//  Created by PSIHPOK on 2/9/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SenderCommissionReportCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *amountSent;
@property (weak, nonatomic) IBOutlet UILabel *commission;


@end
