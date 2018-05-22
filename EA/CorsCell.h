//
//  CorsCell.h
//  EA
//
//  Created by PSIHPOK on 2/12/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CorsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *transID;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *amount;
@property (weak, nonatomic) IBOutlet UILabel *sender;
@property (weak, nonatomic) IBOutlet UILabel *birthday;
@property (weak, nonatomic) IBOutlet UILabel *match;


@end
