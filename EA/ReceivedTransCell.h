//
//  ReceivedTransCell.h
//  EA
//
//  Created by PSIHPOK on 2/11/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReceivedTransCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *transID;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *amount;
@property (weak, nonatomic) IBOutlet UILabel *city;
@property (weak, nonatomic) IBOutlet UILabel *senderName;
@property (weak, nonatomic) IBOutlet UILabel *receiverName;
@property (weak, nonatomic) IBOutlet UILabel *phone;

@end
