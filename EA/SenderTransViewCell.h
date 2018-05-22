//
//  SenderTransViewCell.h
//  EA
//
//  Created by PSIHPOK on 2/6/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SenderTransViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *transID;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *sender;
@property (weak, nonatomic) IBOutlet UILabel *receiver;
@property (weak, nonatomic) IBOutlet UILabel *amount;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UILabel *fee;


@end
