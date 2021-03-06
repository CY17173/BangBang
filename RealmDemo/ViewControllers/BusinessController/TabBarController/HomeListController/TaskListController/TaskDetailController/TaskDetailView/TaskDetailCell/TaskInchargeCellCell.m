//
//  TaskInchargeCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskInchargeCellCell.h"
#import "TaskModel.h"

@interface TaskInchargeCellCell ()
@property (weak, nonatomic) IBOutlet UIImageView *inchargeImage;
@property (weak, nonatomic) IBOutlet UILabel *inchargeName;

@end

@implementation TaskInchargeCellCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.inchargeImage zy_cornerRadiusRoundingRect];
    self.inchargeName.adjustsFontSizeToFitWidth = YES;
    // Initialization code
}
- (void)dataDidChange {
    TaskModel *model = self.data;
    self.inchargeName.text = model.incharge_name;
    [self.inchargeImage sd_setImageWithURL:[NSURL URLWithString:model.incharge_avatar] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
