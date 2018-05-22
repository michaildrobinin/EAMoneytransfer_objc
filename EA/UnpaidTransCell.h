//
//  UnpaidTransCell.h
//  EA
//
//  Created by PSIHPOK on 2/10/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnpaidTransCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *transID;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *amount;
@property (weak, nonatomic) IBOutlet UILabel *sendAgent;
@property (weak, nonatomic) IBOutlet UILabel *recAgent;
@property (weak, nonatomic) IBOutlet UILabel *sendName;
@property (weak, nonatomic) IBOutlet UILabel *recName;
@property (weak, nonatomic) IBOutlet UILabel *status;


@end
