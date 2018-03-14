//
//  ERWordCell.h
//  ERobot
//
//  Created by Mac on 17/2/13.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ERWordCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *wordLabel;
- (IBAction)readButtonClick:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *paraphraseLabel;
- (IBAction)editButtonClick:(id)sender;
@end
