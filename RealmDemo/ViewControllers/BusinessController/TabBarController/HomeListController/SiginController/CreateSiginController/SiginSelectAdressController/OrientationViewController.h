//
//  OrientationViewController.h
//  BangBang
//
//  Created by PC-002 on 15/12/9.
//  Copyright © 2015年 Lottak. All rights reserved.
//

#import "POIAnnotation.h"
#import "SiginRuleSet.h"
#import "PunchCardAddressSetting.h"
//回调传值
typedef void(^finishOrientation)(AMapPOI *pio);

@interface OrientationViewController : UIViewController
/**
 *  完成回调函数
 */
@property (strong, nonatomic) finishOrientation finishOrientation;
//当前签到规则
@property (nonatomic, strong) SiginRuleSet *currSiginRule;
/**
 *  签到规则的最近的一个地址  现在改成显示所有的签到位置
 */
//@property (strong, nonatomic) PunchCardAddressSetting *setting;
/**
 *  当前选择的签到类型
 */
@property (assign, nonatomic)  int category;

@end
