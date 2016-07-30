//
//  ComCalendarDetailViewController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/21.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "ComCalendarDetailViewController.h"
#import "ComCalendarEditController.h"
#import "ComCalendarView.h"
#import "Calendar.h"
#import "UserManager.h"
//#import "UserHttp.h"

@interface ComCalendarDetailViewController ()<ComCalendarEditDelegate> {
    Calendar *_calendar;
    ComCalendarView *_comCalendarView;
    UserManager *_userManager;
}

@end

@implementation ComCalendarDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"日程详情";
    _userManager = [UserManager manager];
    if(_calendar.status == 1 && [_calendar.user_guid isEqualToString:_userManager.user.user_guid])//未完成就有下面的操作按钮 如果是自己创建的
        _comCalendarView = [[ComCalendarView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 50)];
    else
        _comCalendarView = [[ComCalendarView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT)];
    _comCalendarView.data = _calendar;
    [self.view addSubview:_comCalendarView];
    if(_calendar.status == 1 && [_calendar.user_guid isEqualToString:_userManager.user.user_guid]) {//如果是自己创建的
        if([_calendar.user_guid isEqualToString:_userManager.user.user_guid])//如果是自己创建的 就可以修改
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(rightClicked:)];
        UIToolbar *bottomBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, MAIN_SCREEN_HEIGHT - 50 - 64, MAIN_SCREEN_WIDTH, 50)];
        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"ic_delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(deleteCalendarClicked:)];
        [deleteItem setTitle:@"删除日程"];
        UIBarButtonItem *finishItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"ic_complete"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(finishCalendarClicked:)];
        [finishItem setTitle:@"完成日程"];
        bottomBar.items = @[spaceItem,deleteItem,spaceItem,finishItem,spaceItem];
        [self.view addSubview:bottomBar];
    }
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackIndicatorTransitionMaskImage:nil];
    [self.navigationController.navigationBar setShadowImage:nil];
}
- (void)dataDidChange {
    _calendar = [[Calendar alloc] initWithJSONDictionary:[self.data JSONDictionary]];
}
//完成日程
- (void)finishCalendarClicked:(UIButton*)btn {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"你确定要完成该日程?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *alertSure = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //status 状态0-已删除，1-正常，2-已完成
        _calendar.status = 2;
//        [self.navigationController.view showLoadingTips:@""];
//        [UserHttp updateUserCalendar:_calendar handler:^(id data, MError *error) {
//            [self.navigationController.view dismissTips];
//            if(error) {
//                [self.navigationController.view showFailureTips:error.statsMsg];
//                return ;
//            }
//            [_userManager updateCalendar:_calendar];
//            [self.navigationController.view showSuccessTips:@"完成成功"];
//            [self.navigationController popViewControllerAnimated:YES];
//        }];
        [_userManager updateCalendar:_calendar];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alertVC addAction:alertCancel];
    [alertVC addAction:alertSure];
    [self presentViewController:alertVC animated:YES completion:nil];
}
//删除日程
- (void)deleteCalendarClicked:(UIButton*)btn {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"你确定要删除该日程?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *alertSure = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //status 状态0-已删除，1-正常，2-已完成
        _calendar.status = 0;
//        [self.navigationController.view showLoadingTips:@""];
//        [UserHttp updateUserCalendar:_calendar handler:^(id data, MError *error) {
//            [self.navigationController.view dismissTips];
//            if(error) {
//                [self.navigationController.view showFailureTips:error.statsMsg];
//                return ;
//            }
//            [_userManager updateCalendar:_calendar];
//            [self.navigationController.view showSuccessTips:@"删除成功"];
//            [self.navigationController popViewControllerAnimated:YES];
//        }];
        [_userManager updateCalendar:_calendar];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alertVC addAction:alertCancel];
    [alertVC addAction:alertSure];
    [self presentViewController:alertVC animated:YES completion:nil];

}
- (void)rightClicked:(UIBarButtonItem*)item {
    ComCalendarEditController *com = [ComCalendarEditController new];
    com.data = _calendar;
    com.delegate = self;
    [self.navigationController pushViewController:com animated:YES];
}
#pragma amrk -- ComCalendarEditDelegate
- (void)ComCalendarEdit:(Calendar *)Calendar {
    _calendar = Calendar;
    _comCalendarView.data = Calendar;
}
@end
