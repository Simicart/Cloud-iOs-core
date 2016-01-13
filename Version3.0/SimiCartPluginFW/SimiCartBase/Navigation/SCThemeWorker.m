//
//  SCThemeWorker.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/3/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCThemeWorker.h"
#import "SimiNavigationController.h"
#import "SCHomeViewController.h"
#import "MatrixHomeViewController.h"
#import "ZaraHomeViewController.h"
#import "SCHomeViewControllerPad.h"
#import "MatrixHomeViewControllerPad.h"
#import "ZaraHomeViewControllerPad.h"
#import "SCOrderViewController.h"

#import "SCCategoryViewController.h"
#import "SCProductViewController.h"
#import "SCProductViewControllerPad.h"
#import "SCProductListViewController.h"
#import "SCProductListViewControllerPad.h"
#import "SCThankYouPageViewController.h"
@implementation SCThemeWorker
- (id)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"InitializedRootController" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationWillSwitchLanguage" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlaceOrderWithNewCustomer:) name:DidPlaceOrderAfter object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotificationFromServer:) name:@"DidRecieveNotificationFromServer" object:nil];
    }
    return self;
}

+ (SCThemeWorker *)sharedInstance{
    static SCThemeWorker *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SCThemeWorker alloc] init];
    });
    return _sharedInstance;
}

- (void)didPlaceOrderWithNewCustomer:(NSNotification*)noti
{
    if ([noti.name isEqualToString:DidPlaceOrderAfter]) {
        SCOrderViewController *orderViewController = [noti.userInfo valueForKey:@"controller"];
        if (orderViewController.isNewCustomer) {
            SimiCustomerModel *customer = [[SimiCustomerModel alloc]init];
            NSString *stringUserEmail = [orderViewController.addressNewCustomerModel valueForKey:@"email"];
            NSString *stringPassWord = [orderViewController.addressNewCustomerModel valueForKey:@"customer_password"];
            SCThankYouPageViewController *thankVC = [[SCThankYouPageViewController alloc] init];
            thankVC.order = [[noti userInfo] valueForKey:@"data"];
            [_navigationBarPhone setThankYouPageController:thankVC];
            _navigationBarPad.thankYouPageController = thankVC;
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didLogin:) name:@"DidLogin" object:customer];
            [customer loginWithUserMail:stringUserEmail password:stringPassWord];
        }
    }
}

- (void)didLogin:(NSNotification*)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([[responder.status uppercaseString] isEqualToString:@"SUCCESS"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PushLoginNormal" object:nil];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    [self removeObserverForNotification:noti];
}

- (void)didReceiveNotification:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"InitializedRootController"]) {
        self.rootController = noti.object;
        self.rootController.tabBar.hidden = YES;
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            _navigationBarPhone = [SCNavigationBarPhone new];
            [[SimiGlobalVar sharedInstance] addObserver:[_navigationBarPhone cartViewController] forKeyPath:@"isLogin" options:NSKeyValueObservingOptionNew context:nil];
            SimiNavigationController *homeNavi = [[SimiNavigationController alloc] init];
            switch ([SimiGlobalVar sharedInstance].themeUsing) {
                case ThemeShowDefault:
                {
                    SCHomeViewController *homeController = [[SCHomeViewController alloc] init];
                    [homeNavi setViewControllers:@[homeController]];
                }
                    break;
                case ThemeShowMatrixTheme:
                {
                    MatrixHomeViewController *homeController = [[MatrixHomeViewController alloc] init];
                    [homeNavi setViewControllers:@[homeController]];
                }
                    break;
                case ThemeShowZTheme:
                {
                    ZaraHomeViewController *homeController = [[ZaraHomeViewController alloc] init];
                    [homeNavi setViewControllers:@[homeController]];
                }
                    break;
                default:
                    break;
            }
            self.rootController.viewControllers = @[homeNavi];
        }else
        {
            _navigationBarPad = [SCNavigationBarPad new];
            [[SimiGlobalVar sharedInstance] addObserver:[_navigationBarPad cartViewControllerPad] forKeyPath:@"isLogin" options:NSKeyValueObservingOptionNew context:nil];
            SimiNavigationController *homeNavi = [[SimiNavigationController alloc] init];
            switch ([SimiGlobalVar sharedInstance].themeUsing) {
                case ThemeShowDefault:
                {
                    SCHomeViewControllerPad *homeController = [[SCHomeViewControllerPad alloc] init];
                    [homeNavi setViewControllers:@[homeController]];
                }
                    break;
                case ThemeShowMatrixTheme:
                {
                    MatrixHomeViewControllerPad *homeController = [[MatrixHomeViewControllerPad alloc] init];
                    [homeNavi setViewControllers:@[homeController]];
                }
                    break;
                case ThemeShowZTheme:
                {
                    ZaraHomeViewControllerPad *homeController = [[ZaraHomeViewControllerPad alloc] init];
                    [homeNavi setViewControllers:@[homeController]];
                }
                    break;
                default:
                    break;
            }
            self.rootController.viewControllers = @[homeNavi];
        }
        
        if (SIMI_SYSTEM_IOS >= 7) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            [[UINavigationBar appearance] setBarTintColor:THEME_COLOR];
            [[UIActivityIndicatorView appearance] setColor:THEME_COLOR];
            [[UINavigationBar appearance] setTintColor:THEME_NAVIGATION_ICON_COLOR];
        }
    }
}

- (void)didReceiveNotificationFromServer:(NSNotification*)noti
{
    UINavigationController *recentNaviCon = (UINavigationController *)self.rootController.selectedViewController;
    NSString *stringNotiType = [[noti.object valueForKey:@"aps"] valueForKey:@"type"];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if ([stringNotiType isEqualToString:@"2"]) {
            if ([[[noti.object valueForKey:@"aps"] valueForKey:@"has_child"]boolValue]) {
                SCCategoryViewController* nextController = [SCCategoryViewController new];
                nextController.categoryId = [[noti.object valueForKey:@"aps"] valueForKey:@"categoryID"];
                nextController.navigationItem.title = [[noti.object valueForKey:@"aps"] valueForKey:@"categoryName"];
                [recentNaviCon pushViewController:nextController animated:YES];
            }else
            {
                SCProductListViewController *nextController = [[SCProductListViewController alloc]init];
                nextController.categoryID = [[noti.object valueForKey:@"aps"] valueForKey:@"categoryID"];
                nextController.productListGetProductType = ProductListGetProductTypeFromCategory;
                nextController.navigationItem.title = [[[noti.object valueForKey:@"aps"] valueForKey:@"categoryName"] uppercaseString];
                [recentNaviCon pushViewController:nextController animated:YES];
            }
        }else if([stringNotiType isEqualToString:@"1"])
        {
            SCProductViewController *nextController = [SCProductViewController new];
            nextController.firstProductID = [[noti.object valueForKey:@"aps"] valueForKey:@"productID"];
            nextController.arrayProductsID = [[NSMutableArray alloc]initWithArray:@[nextController.firstProductID]];
            [recentNaviCon pushViewController:nextController animated:YES];
        }else if([stringNotiType isEqualToString:@"3"])
        {
            SCWebViewController *nextController = [[SCWebViewController alloc] init];
            [nextController setUrlPath:[[noti.object valueForKey:@"aps"] valueForKey:@"url"]];
            nextController.title = [[noti.object valueForKey:@"aps"] valueForKey:@"title"];
            [recentNaviCon pushViewController:nextController animated:YES];
        }
    }else
    {
        if ([stringNotiType isEqualToString:@"1"])
        {
            SCProductViewControllerPad *nextController = [SCProductViewControllerPad new];
            nextController.firstProductID = [[noti.object valueForKey:@"aps"] valueForKey:@"productID"];
            nextController.arrayProductsID = [[NSMutableArray alloc]initWithArray:@[nextController.firstProductID]];
            [recentNaviCon pushViewController:nextController animated:YES];
        }else if([stringNotiType isEqualToString:@"2"])
        {
            SCProductListViewControllerPad *gridViewController = [[SCProductListViewControllerPad alloc]init];
            gridViewController.productListGetProductType = ProductListGetProductTypeFromCategory;
            gridViewController.categoryID = [[noti.object valueForKey:@"aps"] valueForKey:@"categoryID"];
            gridViewController.categoryName = [[[noti.object valueForKey:@"aps"] valueForKey:@"categoryName"] uppercaseString];
            gridViewController.navigationItem.title = gridViewController.categoryName;
            [recentNaviCon pushViewController:gridViewController animated:YES];
        }else if([stringNotiType isEqualToString:@"3"])
        {
            SCWebViewController *nextController = [[SCWebViewController alloc] init];
            [nextController setUrlPath:[[noti.object valueForKey:@"aps"] valueForKey:@"url"]];
            nextController.title = [[noti.object valueForKey:@"aps"] valueForKey:@"title"];
            [recentNaviCon pushViewController:nextController animated:YES];
        }
    }
}
@end
