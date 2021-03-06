//
//  HomeListController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "HomeListController.h"
#import "HomeListTopView.h"
#import "HomeListBottomView.h"
#import "UserManager.h"
#import "PushMessageController.h"
#import "AppListController.h"
#import "IdentityManager.h"
#import "CalendarController.h"
#import "TaskListController.h"
#import "WebNonstandarViewController.h"
#import "SiginController.h"
#import "UserHttp.h"

@interface HomeListController ()<HomeListTopDelegate,HomeListBottomDelegate,RBQFetchedResultsControllerDelegate> {
    UIScrollView *_scrollView;//整体的滚动视图
    HomeListTopView *_homeListTopView;//头部数据视图
    HomeListBottomView *_homeListBottomView;//底部的按钮视图
    UserManager *_userManager;//用户管理器
    RBQFetchedResultsController *_userFetchedResultsController;//用户数据库监听
    RBQFetchedResultsController *_sigRuleFetchedResultsController;
    RBQFetchedResultsController *_pushMessageFetchedResultsController;//推送消息数据监听
}
@property (nonatomic, strong) UIButton *leftNavigationBarButton;//左边导航的按钮
@property (nonatomic, strong) UIButton *rightNavigationBarButton;//右边导航的按钮
@end

@implementation HomeListController

- (void)viewDidLoad {
    [super viewDidLoad];
    _userManager = [UserManager manager];
    //创建数据监听
    _userFetchedResultsController = [_userManager createUserFetchedResultsController];
    _userFetchedResultsController.delegate = self;
    _pushMessageFetchedResultsController = [_userManager createPushMessagesFetchedResultsController];
    _pushMessageFetchedResultsController.delegate = self;
    _sigRuleFetchedResultsController = [_userManager createSiginRuleFetchedResultsController];
    _sigRuleFetchedResultsController.delegate = self;
    //创建界面
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.showsVerticalScrollIndicator = NO;
    //创建头部数据视图
    CGFloat topViewHeight = 32 + MAIN_SCREEN_WIDTH / 2.f;
    _homeListTopView = [[HomeListTopView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, topViewHeight)];
    _homeListTopView.delegate = self;
    [_scrollView addSubview:_homeListTopView];
    //创建底部按钮视图
    CGFloat bottomViewHeight = MAIN_SCREEN_WIDTH / 2;
    _homeListBottomView = [[HomeListBottomView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_homeListTopView.frame), MAIN_SCREEN_WIDTH, bottomViewHeight)];
    _homeListBottomView.delegate = self;
    [_scrollView addSubview:_homeListBottomView];
    _scrollView.contentSize = CGSizeMake(MAIN_SCREEN_WIDTH, CGRectGetMaxY(_homeListBottomView.frame));
    [self.view addSubview:_scrollView];
    //加上左边边界侧滑手势
    UIScreenEdgePanGestureRecognizer * screenEdgePanGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(showLeftClicked:)];
    screenEdgePanGesture.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:screenEdgePanGesture];
    [self setLeftNavigationBarItem];
    [self setRightNavigationBarItem];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor homeListColor];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)showLeftClicked:(UIScreenEdgePanGestureRecognizer*)sepr {
    [self.navigationController.frostedViewController presentMenuViewController];
}
#pragma mark --
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    if(controller == _pushMessageFetchedResultsController) {
        UILabel *label = [self.rightNavigationBarButton viewWithTag:1001];
        int count = 0;
        for (PushMessage *push in [_userManager getPushMessageArr]) {
            //本地推送只读取现在之前的
            if(push.id.doubleValue > 0)
                if(push.addTime.timeIntervalSince1970 > [NSDate date].timeIntervalSince1970)
                    continue;
            if(push.unread == YES)
                count ++;
        }
        label.text = [NSString stringWithFormat:@"%d",count];
        label.hidden = !count;
    } else if(controller == _userFetchedResultsController) {
        User *user = [_userManager user];
        //修改了自己的信息后，红包头像显示错误
        RCUserInfo *userInfo = [RCUserInfo new];
        userInfo.userId = @([UserManager manager].user.user_no).stringValue;
        userInfo.name = [UserManager manager].user.real_name;
        userInfo.portraitUri = [UserManager manager].user.avatar;
        //#BANG-532 用户钱包信息显示不出来
        [RCIM sharedRCIM].currentUserInfo = userInfo;
        //重新设置签到记录的数据监听
        _sigRuleFetchedResultsController = [_userManager createSiginRuleFetchedResultsController];
        _sigRuleFetchedResultsController.delegate = self;
        UIImageView *imageView = [self.leftNavigationBarButton viewWithTag:1001];
        UILabel *nameLabel = [self.leftNavigationBarButton viewWithTag:1002];
        UILabel *companyLabel = [self.leftNavigationBarButton viewWithTag:1003];
        [imageView sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
        nameLabel.text = user.real_name;
        if(user.currCompany.company_no == 0)
            companyLabel.text = @"未选择圈子";
        else {
            NSString *companyName = user.currCompany.company_name;
            if(companyName.length > 8) {
                companyName = [companyName stringByReplacingCharactersInRange:NSMakeRange(8, companyName.length - 8) withString:@"..."];
            }
            companyLabel.text = companyName;
        }
    } else {//重新加一次上下班提醒
        [_userManager addSiginRuleNotfition];
    }
}
#pragma mark --
#pragma mark -- HomeListTopDelegate
//需要选择圈子后才能操作
- (void)executeNeedSelectCompany:(void (^)(void))aBlock
{
    if(_userManager.user.currCompany.company_no == 0) {
        [self.navigationController.view showMessageTips:@"请选择一个圈子后再进行此操作"];
        return;
    }
    aBlock();
}
//今天完成日程被点击
- (void)todayFinishCalendar {
    CalendarController *calendar = [CalendarController new];
    calendar.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:calendar animated:YES];
}
//本周完成日程被点击
- (void)weekFinishCalendar {
    CalendarController *calendar = [CalendarController new];
    calendar.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:calendar animated:YES];
}
//我委派的任务被点击
- (void)createTaskClicked {
    [self executeNeedSelectCompany:^{
        TaskListController *list = [TaskListController new];
        list.type = 0;
        list.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:list animated:YES];
    }];
}
//我负责的任务被点击
- (void)chargeTaskClicked {
    [self executeNeedSelectCompany:^{
        TaskListController *list = [TaskListController new];
        list.type = 1;
        list.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:list animated:YES];
    }];
}
#pragma mark --
#pragma mark -- HomeListBottomDelegate
- (void)homeListBottomLocalAppSelect:(LocalUserApp*)localUserApp {
    if([localUserApp.titleName isEqualToString:@"公告"]) {//公告
        [self executeNeedSelectCompany:^{
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
            NSString *str = [NSString stringWithFormat:@"%@Notice?userGuid=%@&companyNo=%d&access_token=%@",XYFMobileDomain,_userManager.user.user_guid,_userManager.user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.applicationUrl = str;
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [[self navigationController] pushViewController:webViewcontroller animated:YES];
        }];
    } else if ([localUserApp.titleName isEqualToString:@"动态"]) {//动态
        [self executeNeedSelectCompany:^{
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
            NSString *str = [NSString stringWithFormat:@"%@Dynamic?userGuid=%@&companyNo=%d&access_token=%@",XYFMobileDomain,_userManager.user.user_guid,_userManager.user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.applicationUrl = str;
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [[self navigationController] pushViewController:webViewcontroller animated:YES];
        }];
    } else if ([localUserApp.titleName isEqualToString:@"签到"]) {//签到
        [self executeNeedSelectCompany:^{
            SiginController *sigin = [SiginController new];
            sigin.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:sigin animated:YES];
        }];
    } else if([localUserApp.titleName isEqualToString:@"审批"]) {//审批
        [self executeNeedSelectCompany:^{
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
            NSString *str = [NSString stringWithFormat:@"%@ApprovalByFormBuilder?userGuid=%@&companyNo=%d&access_token=%@",XYFMobileDomain,_userManager.user.user_guid,_userManager.user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.applicationUrl = str;
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [[self navigationController] pushViewController:webViewcontroller animated:YES];
        }];
    } else if ([localUserApp.titleName isEqualToString:@"帮邮"]) {//邮件 调用手机上的邮件
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0f) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:"] options:@{} completionHandler:^(BOOL success) {
            }];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:"]];
        }
    } else if ([localUserApp.titleName isEqualToString:@"会议"]) {//会议
        [self executeNeedSelectCompany:^{
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
            NSString *str = [NSString stringWithFormat:@"%@meeting?userGuid=%@&companyNo=%d&access_token=%@",XYFMobileDomain,_userManager.user.user_guid,_userManager.user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.applicationUrl = str;
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [[self navigationController] pushViewController:webViewcontroller animated:YES];
        }];
    } else if([localUserApp.titleName isEqualToString:@"投票"]){//投票
        [self executeNeedSelectCompany:^{
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
            NSString *str = [NSString stringWithFormat:@"%@Vote?userGuid=%@&companyNo=%d&access_token=%@",XYFMobileDomain,_userManager.user.user_guid,_userManager.user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.applicationUrl = str;
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [[self navigationController] pushViewController:webViewcontroller animated:YES];
        }];
    }
}
//更多
- (void)homeListBottomMoreApp {
    AppListController *appList = [AppListController new];
    appList.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:appList animated:YES];
}
#pragma mark --
#pragma mark -- setNavigationBar
- (void)setLeftNavigationBarItem {
    User *user = _userManager.user;
    _leftNavigationBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftNavigationBarButton.frame = CGRectMake(0, 0, 100, 28);
    //创建头像
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, 33, 33)];
    [imageView zy_cornerRadiusRoundingRect];
    imageView.tag = 1001;
    [imageView sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    [_leftNavigationBarButton addSubview:imageView];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(38, 2, 100, 12)];
    nameLabel.font = [UIFont systemFontOfSize:12];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.text = user.real_name;
    nameLabel.tag = 1002;
    [_leftNavigationBarButton addSubview:nameLabel];
    UILabel *companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(38, 23, 100, 10)];
    companyLabel.font = [UIFont systemFontOfSize:10];
    companyLabel.textColor = [UIColor whiteColor];
    if([NSString isBlank:user.currCompany.company_name])
        companyLabel.text = @"未选择圈子";
    else {
        NSString *companyName = user.currCompany.company_name;
        if(companyName.length > 8) {
            companyName = [companyName stringByReplacingCharactersInRange:NSMakeRange(8, companyName.length - 8) withString:@"..."];
        }
        companyLabel.text = companyName;
    }
    companyLabel.tag = 1003;
    [_leftNavigationBarButton addSubview:companyLabel];
    [_leftNavigationBarButton addTarget:self action:@selector(leftNavigationBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_leftNavigationBarButton];
}
- (void)leftNavigationBtnClicked:(UIButton*)btn {
    [self.navigationController.frostedViewController presentMenuViewController];
}
- (void)setRightNavigationBarItem {
    _rightNavigationBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightNavigationBarButton.frame = CGRectMake(0, 0, 40, 40);
    [_rightNavigationBarButton setImage:[UIImage imageNamed:@"home_remind_icon"] forState:UIControlStateNormal];
    [_rightNavigationBarButton addTarget:self action:@selector(rightNavigationBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    _rightNavigationBarButton.clipsToBounds = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightNavigationBarButton];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(24, -5, 18, 18)];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.cornerRadius = 9;
    label.font = [UIFont systemFontOfSize:13];
    label.clipsToBounds = YES;
    label.backgroundColor = [UIColor redColor];
    label.userInteractionEnabled = NO;
    int count = 0;
    for (PushMessage *push in [_userManager getPushMessageArr]) {
        //本地推送只读取现在之前的
        if(push.id.doubleValue > 0)
            if(push.addTime.timeIntervalSince1970 > [NSDate date].timeIntervalSince1970)
                continue;
        if(push.unread == YES)
            count ++;
    }
    label.text = [NSString stringWithFormat:@"%d",count];
    label.tag = 1001;
    label.hidden = !count;
    [_rightNavigationBarButton addSubview:label];
}
- (void)rightNavigationBtnClicked:(UIButton*)item {
    PushMessageController *view = [PushMessageController new];
    view.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:view animated:YES];
}
@end
