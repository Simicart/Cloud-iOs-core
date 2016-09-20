//
//  SCNavigationBarPhone.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/3/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCNavigationBarPhone.h"
#import "ActionSheetPicker.h"

static NSString *TRANSLUCENTVIEW = @"LEFTMENU_TRANSLUCENTVIEW";
@implementation SCNavigationBarPhone

#pragma mark Init
+ (instancetype)sharedInstance{
    static SCNavigationBarPhone *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SCNavigationBarPhone alloc] init];
    });
    return _sharedInstance;
}

- (id)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeCart:) name:DidChangeCart object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPushLoginNormal:) name:PushLoginNormal object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPushLogout:) name:DidLogout object:nil];
    }
    return self;
}

- (NSMutableArray *)leftButtonItems{
    if (_leftButtonItems == nil) {
        _leftButtonItems = [[NSMutableArray alloc] init];
        
        UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [leftButton setImage:[[UIImage imageNamed:@"ic_menu"]imageWithColor:THEME_NAVIGATION_ICON_COLOR] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(didSelectLeftBarItem:) forControlEvents:UIControlEventTouchUpInside];
        [leftButton setAdjustsImageWhenHighlighted:YES];
        [leftButton setAdjustsImageWhenDisabled:YES];
        _leftMenuItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        
        [_leftButtonItems addObjectsFromArray:@[_leftMenuItem]];
    }
    return _leftButtonItems;
}

- (NSMutableArray *)rightButtonItems{
    if (_rightButtonItems == nil) {
        if ([SimiGlobalVar sharedInstance].isZopimChat == YES) {
            _rightButtonItems = [[NSMutableArray alloc] init];
            
            UIButton *cartButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
            [cartButton setImage:[[UIImage imageNamed:@"ic_cart"] imageWithColor:THEME_NAVIGATION_ICON_COLOR] forState:UIControlStateNormal];
            [cartButton addTarget:self action:@selector(didSelectCartBarItem:) forControlEvents:UIControlEventTouchUpInside];
            
            _cartItem = [[UIBarButtonItem alloc] initWithCustomView:cartButton];
            if (_cartBadge == nil) {
                _cartBadge = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:cartButton];
                _cartBadge.shouldHideBadgeAtZero = YES;
                _cartBadge.badgeValue = [[[SimiGlobalVar sharedInstance] cart] cartQty];
                _cartBadge.badgeMinSize = 4;
                _cartBadge.badgePadding = 4;
                _cartBadge.badgeOriginX = cartButton.frame.size.width - 10;
                _cartBadge.badgeOriginY = cartButton.frame.origin.y - 3;
                _cartBadge.badgeFont = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:12];
                [_cartBadge setTintColor:THEME_COLOR];
                _cartBadge.badgeBGColor = THEME_NAVIGATION_ICON_COLOR;
                _cartBadge.badgeTextColor = THEME_COLOR;
            }
            UIButton *chatButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
            [chatButton setImage:[[UIImage imageNamed:@"ic_livechat"] imageWithColor:THEME_NAVIGATION_ICON_COLOR] forState:UIControlStateNormal];
            [chatButton addTarget:self action:@selector(didSelectChatBarItem:) forControlEvents:UIControlEventTouchUpInside];
            _chatItem = [[UIBarButtonItem alloc] initWithCustomView:chatButton];
            [_rightButtonItems addObjectsFromArray:@[_cartItem,_chatItem]];
        } else {
            _rightButtonItems = [[NSMutableArray alloc] init];
            
            UIButton *cartButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
            [cartButton setImage:[[UIImage imageNamed:@"ic_cart"] imageWithColor:THEME_NAVIGATION_ICON_COLOR] forState:UIControlStateNormal];
            [cartButton addTarget:self action:@selector(didSelectCartBarItem:) forControlEvents:UIControlEventTouchUpInside];
            
            _cartItem = [[UIBarButtonItem alloc] initWithCustomView:cartButton];
            if (_cartBadge == nil) {
                _cartBadge = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:cartButton];
                _cartBadge.shouldHideBadgeAtZero = YES;
                _cartBadge.badgeValue = [[[SimiGlobalVar sharedInstance] cart] cartQty];
                _cartBadge.badgeMinSize = 4;
                _cartBadge.badgePadding = 4;
                _cartBadge.badgeOriginX = cartButton.frame.size.width - 10;
                _cartBadge.badgeOriginY = cartButton.frame.origin.y - 3;
                _cartBadge.badgeFont = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:12];
                [_cartBadge setTintColor:THEME_COLOR];
                _cartBadge.badgeBGColor = THEME_NAVIGATION_ICON_COLOR;
                _cartBadge.badgeTextColor = THEME_COLOR;
            }
            [_rightButtonItems addObjectsFromArray:@[_cartItem]];
        }
    }
    return _rightButtonItems;
}

- (SCLeftMenuViewController *)leftMenuPhone
{
    if (_leftMenuPhone == nil) {
        _leftMenuPhone = [SCLeftMenuViewController new];
        [_leftMenuPhone.view setFrame:CGRectMake(-(SCREEN_WIDTH*4)/5, 0, (SCREEN_WIDTH*4)/5, 65)];
        _leftMenuPhone.delegate = self;
    }
    
    return _leftMenuPhone;
}

- (SCCartViewController *)cartViewController
{
    if (_cartViewController == nil) {
        _cartViewController = [[SCCartViewController alloc]init];
        SimiCustomerModel *customer = [[SimiGlobalVar sharedInstance] customer];
        if([customer valueForKey:@"_id"] != nil && ![[customer valueForKey:@"_id"] isEqualToString:@""]){
            [_cartViewController getQuotesWithCustomerId:[customer valueForKey:@"_id"]];
        }
        [_cartViewController getCart];
    }
    return _cartViewController;
}

#pragma mark Action
- (void)didSelectLeftBarItem:(id)sender
{
    if (!self.isShowingLeftMenu) {
        [self.leftMenuPhone didClickShow];
        self.isShowingLeftMenu = YES;
    }
}

- (void)didSelectCartBarItem:(id)sender
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    UIViewController *viewController = [[(UINavigationController *)currentVC viewControllers] lastObject];
    for (UIViewController *viewControllerTemp in viewController.navigationController.viewControllers) {
        if ([viewControllerTemp isKindOfClass:[SCCartViewController class]]) {
            [viewControllerTemp.navigationController popToViewController:viewControllerTemp animated:YES];
            return;
        }
    }
    [(UINavigationController *)currentVC pushViewController:self.cartViewController animated:YES];
    return;
}

- (void)didSelectChatBarItem:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tapToChatButton" object:sender];
}

#pragma mark Left Menu Delegate
-(void)menu:(SCLeftMenuViewController *)menu didClickShowButonWithShow:(BOOL)show
{
    UINavigationController *navi = (UINavigationController *)[(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    if (show) {
        CGFloat size = SCREEN_HEIGHT > SCREEN_WIDTH ? SCREEN_HEIGHT : SCREEN_WIDTH;
        UIImageView *imageShadow = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, size, size)];
        imageShadow.backgroundColor = [[SimiGlobalVar sharedInstance]colorWithHexString:@"#000000" alpha:0.75];
        [imageShadow setAlpha:0];
        [UIView animateWithDuration:0.2 animations:^{
            [imageShadow setAlpha:1.0];
        } completion:^(BOOL finished) {
            
        }];
        imageShadow.simiObjectIdentifier = TRANSLUCENTVIEW;
        imageShadow.userInteractionEnabled = YES;

        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self.leftMenuPhone action:@selector(didClickHide)];
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self.leftMenuPhone action:@selector(didClickHide)];
        swipe.direction = UISwipeGestureRecognizerDirectionLeft;
        singleTap.numberOfTapsRequired = 1;
        [imageShadow addGestureRecognizer:singleTap];
        [imageShadow addGestureRecognizer:swipe];
        [navi.view addSubview:imageShadow];
        [navi.view bringSubviewToFront:self.leftMenuPhone.view];
    }else{
        self.isShowingLeftMenu = NO;
        for (UIView * view in navi.view.subviews ) {
            if ([(NSString*)view.simiObjectIdentifier isEqualToString:TRANSLUCENTVIEW]) {
                [UIView animateWithDuration:0.2 animations:^{
                    [view setAlpha:0];
                } completion:^(BOOL finished) {
                    [view removeFromSuperview];
                }];
            }
        }
    }
}

- (void)didSelectLoginRow
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    if (![[SimiGlobalVar sharedInstance]isLogin]) {
        SCLoginViewController *loginViewController = [SCLoginViewController new];
        [(UINavigationController *)currentVC pushViewController:loginViewController animated:YES];
    }else
    {
        SCAccountViewController *accountViewController = [SCAccountViewController new];
        [(UINavigationController *)currentVC pushViewController:accountViewController animated:YES];
    }
}

-(void) didSelectSettingRow{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
        SCSettingViewController *settingViewController = [SCSettingViewController new];
        [(UINavigationController *)currentVC pushViewController:settingViewController animated:YES];
    
}

- (void)menu:(SCLeftMenuViewController *)menu didSelectRow:(SimiRow *)row withIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    [[NSNotificationCenter defaultCenter]postNotificationName:SCLeftMenuDidSelectRow object:self userInfo:@{@"simirow":row, @"indexPath":indexPath}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    
    SimiTable *cells = menu.cells;
    SimiSection *section = [cells objectAtIndex:indexPath.section];
    if ([section.identifier isEqualToString:LEFTMENU_SECTION_MAIN]) {
        if ([row.identifier isEqualToString:LEFTMENU_ROW_CATEGORY]) {
            SCCategoryViewController *categoryViewController = [SCCategoryViewController new];
            categoryViewController.categoryId = @"";
            [(UINavigationController *)currentVC pushViewController:categoryViewController animated:YES];
        }else if([row.identifier isEqualToString:LEFTMENU_ROW_HOME])
        {
            [(UINavigationController *)currentVC popToRootViewControllerAnimated:YES];
        }else if ([row.identifier isEqualToString:LEFTMENU_ROW_ORDERHISTORY])
        {
            SCOrderHistoryViewController *orderController = [[SCOrderHistoryViewController alloc] init];
            [(UINavigationController *)currentVC pushViewController:orderController animated:YES];
        }else if ([row.identifier isEqualToString:LEFTMENU_ROW_DOWNLOAD])
        {
            if(self.downloadControllViewController == nil)
            {
                self.downloadControllViewController = [[DownloadControlViewController alloc]init];
            }
            UIViewController *viewController = [[(UINavigationController *)currentVC viewControllers] lastObject];
            for (UIViewController *viewControllerTemp in viewController.navigationController.viewControllers) {
                if ([viewControllerTemp isKindOfClass:[DownloadControlViewController class]]) {
                    [viewControllerTemp.navigationController popToViewController:viewControllerTemp animated:YES];
                    return;
                }
            }
            [(UINavigationController*)currentVC pushViewController:self.downloadControllViewController animated:YES];
        }
        else if([row.identifier isEqualToString:LEFTMENU_ROW_SETTING]){
            SCSettingViewController *settingViewController = [SCSettingViewController new];
            [(UINavigationController *)currentVC pushViewController:settingViewController animated:YES];
        }
    }else if([section.identifier isEqualToString:LEFTMENU_SECTION_MORE]){
        if([row.identifier isEqualToString:LEFTMENU_ROW_SETTING]){
            SCSettingViewController *settingViewController = [SCSettingViewController new];
            [(UINavigationController *)currentVC pushViewController:settingViewController animated:YES];
        }else if([row.identifier isEqualToString:LEFTMENU_ROW_CMS])
        {
            SCWebViewController *webViewController = [[SCWebViewController alloc] init];
            webViewController.title = row.title;
            webViewController.content = [row.data valueForKey:@"content"];
            [(UINavigationController *)currentVC pushViewController:webViewController animated:YES];
        }else if([row.identifier isEqualToString:LEFTMENU_ROW_CHANGETHEME])
        {
            ActionSheetStringPicker *stringPicket = [[ActionSheetStringPicker alloc]initWithTitle:@"Change Theme" rows:@[@"Default Theme", @"Matrix Theme", @"Zara Theme"] initialSelection:[SimiGlobalVar sharedInstance].themeUsing target:self successAction:@selector(didSelectValue:element:) cancelAction:@selector(cancelActionSheet:) origin:currentVC.view];
            [stringPicket showActionSheetPicker];
        }
    }
}

- (void)didSelectValue:(NSNumber *)selectedIndex element:(id)element
{
    if ([selectedIndex integerValue] != [SimiGlobalVar sharedInstance].themeUsing) {
        [SimiGlobalVar sharedInstance].themeUsing = [selectedIndex integerValue];
        [SimiGlobalVar sharedInstance].useThemeConfigOnLocal = YES;
        [[NSNotificationCenter defaultCenter]postNotificationName:ChangeAppLanguage object:nil];
    }
}

- (void)cancelActionSheet:(id)sender
{
    
}

#pragma mark Did Receive Notification
- (void)didChangeCart:(NSNotification *)noti
{
    self.cartBadge.badgeValue = [[[SimiGlobalVar sharedInstance] cart] cartQty];
}

- (void)didPushLoginNormal:(NSNotification*)noti
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    [(UINavigationController *)currentVC popToRootViewControllerAnimated:YES];
    NSString *message = [NSString stringWithFormat:SCLocalizedString(@"Welcome %@! Start shopping now"),[[SimiGlobalVar sharedInstance].customer valueForKey:@"name"]];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.tag = 100;
    alert.delegate = self;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    /*
    if(alertView.tag == 100)
        switch (buttonIndex) {
            case 0:
            {
                if(self.thankYouPageController != nil){
                    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
                    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                        UINavigationController *navi;
                        navi = [[UINavigationController alloc]initWithRootViewController:self.thankYouPageController];
                        _popThankController = [[UIPopoverController alloc] initWithContentViewController:navi];
                        self.thankYouPageController.popOver = _popThankController;
                        [_popThankController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:currentVC.view permittedArrowDirections:0 animated:YES];
                    }else{
                        [(UINavigationController *)currentVC pushViewController:self.thankYouPageController animated:YES];
                    }
                    self.thankYouPageController = nil;
                }
            }
                break;
    }
     */
}

- (void)didPushLogout:(NSNotification*)noti
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    [(UINavigationController *)currentVC popToRootViewControllerAnimated:YES];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:SCLocalizedString(@"You've logged out. Thank you") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
