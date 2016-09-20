//
//  SCNavigationBarPhone.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/3/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBBadgeBarButtonItem.h"
#import "SimiViewController.h"
#import "SCCartViewController.h"
#import "SCLeftMenuViewController.h"
#import "ILTranslucentView.h"
#import "SCLoginViewController.h"
#import "SCCategoryViewController.h"
#import "SCAccountViewController.h"
#import "SCSettingViewController.h"
#import "SCOrderHistoryViewController.h"
#import "SCWebViewController.h"
#import "SCThankYouPageViewController.h"
#import "DownloadControlViewController.h"

@interface SCNavigationBarPhone : NSObject<SCLeftMenuPhoneViewController_Delegate, UIAlertViewDelegate>
@property (strong, nonatomic) NSMutableArray *leftButtonItems;
@property (strong, nonatomic) NSMutableArray *rightButtonItems;
@property (strong, nonatomic) UIBarButtonItem *leftMenuItem;
@property (strong, nonatomic) UIBarButtonItem *cartItem;
@property (strong, nonatomic) UIBarButtonItem *chatItem;

@property (strong, nonatomic) BBBadgeBarButtonItem *cartBadge;
@property (strong, nonatomic) SCLeftMenuViewController *leftMenuPhone;
@property (strong, nonatomic) SCCartViewController *cartViewController;
@property (strong, nonatomic) SCThankYouPageViewController *thankYouPageController;
@property (strong, nonatomic) UIPopoverController * popThankController;
@property (strong, nonatomic) DownloadControlViewController *downloadControllViewController;

@property (nonatomic) BOOL isShowingLeftMenu;
+ (instancetype)sharedInstance;
@end
