//
//  SCNavigationBarPad.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/3/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCNavigationBarPad.h"

static NSString *TRANSLUCENTVIEW = @"LEFTMENU_TRANSLUCENTVIEW";
static NSString *FOGIMAGE = @"FOGIMAGE";

@implementation SCNavigationBarPad
@synthesize rightButtonItems = _rightButtonItems, cartItem = _cartItem, cartBadge = _cartBadge;
+ (instancetype)sharedInstance
{
    static SCNavigationBarPad *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SCNavigationBarPad alloc] init];
    });
    return _sharedInstance;
}

- (id)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin:) name:DidLogin object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogout:) name:DidLogout object:nil];
    }
    return self;
}

- (NSMutableArray *)rightButtonItems{
    _rightButtonItems = [[NSMutableArray alloc] init];
    if (_cartButton == nil) {
        _cartButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [_cartButton setImage:[[UIImage imageNamed:@"ic_cart"]imageWithColor:THEME_NAVIGATION_ICON_COLOR] forState:UIControlStateNormal];
        [_cartButton addTarget:self action:@selector(didSelectCartBarItem:) forControlEvents:UIControlEventTouchUpInside];
    }
    [_cartBadge setTintColor:THEME_COLOR];
    
    _cartItem = [[UIBarButtonItem alloc] initWithCustomView:_cartButton];
    if (_cartBadge == nil) {
        _cartBadge = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:_cartButton];
        _cartBadge.shouldHideBadgeAtZero = YES;
        _cartBadge.badgeValue = [[[SimiGlobalVar sharedInstance] cart] cartQty];
        _cartBadge.badgeMinSize = 4;
        _cartBadge.badgePadding = 4;
        _cartBadge.badgeOriginX = _cartButton.frame.size.width - 10;
        _cartBadge.badgeOriginY = _cartButton.frame.origin.y - 3;
        _cartBadge.badgeFont = [UIFont fontWithName:THEME_FONT_NAME size:12];
        [_cartBadge setTintColor:THEME_COLOR];
        _cartBadge.badgeBGColor = THEME_NAVIGATION_ICON_COLOR;
        _cartBadge.badgeTextColor = THEME_COLOR;
    }
    
    UIBarButtonItem *itemSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    itemSpace.width = 20;
    
    if (!_isShowSearchBar) {
        UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        
        [searchButton setImage:[[UIImage imageNamed:@"ic_search.png"] imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [searchButton addTarget:self action:@selector(didSelectSearchButton:) forControlEvents:UIControlEventTouchUpInside];
        _searchItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
        [_rightButtonItems addObjectsFromArray:@[_cartItem, itemSpace, _searchItem]];
        
    }else
    {
        if (_searchBar ==nil) {
            _searchBar = [UISearchBar new];
            _searchBar.placeholder = SCLocalizedString(@"Search");
         //Gin edit
            for ( UIView * subview in [[_searchBar.subviews objectAtIndex:0] subviews] )
            {
                if ([subview isKindOfClass:NSClassFromString(@"UISearchBarTextField") ] ) {
                    UITextField *searchView = (UITextField *)subview ;
                    if ([[SimiGlobalVar sharedInstance] isReverseLanguage]) {
                        [searchView setTextAlignment:NSTextAlignmentRight];
                    }
                }
            }
          //End
            _searchBar.delegate = self;
        }
        _searchBar.frame = CGRectMake(SCREEN_WIDTH - 320 - itemSpace.width, 0, 0, 45);
        [UIView animateWithDuration:0.3 animations:^{
            _searchBar.frame = CGRectMake(0, 0, SCREEN_WIDTH - 320 - itemSpace.width, 45);
        }];
        
        _searchBar.tintColor = THEME_SEARCH_TEXT_COLOR;
        _searchItem = [[UIBarButtonItem alloc] initWithCustomView:_searchBar];
        [_rightButtonItems addObjectsFromArray:@[itemSpace, _searchItem]];
    }
    return _rightButtonItems;
}

- (void)didSelectCartBarItem:(id)sender
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    UIViewController *viewController = [[(UINavigationController *)currentVC viewControllers] lastObject];
    for (UIViewController *viewControllerTemp in viewController.navigationController.viewControllers) {
        if ([viewControllerTemp isKindOfClass:[SCCartViewControllerPad class]]) {
            [viewControllerTemp.navigationController popToViewController:viewControllerTemp animated:YES];
            return;
        }
    }
    
    [(UINavigationController *)currentVC pushViewController:self.cartViewControllerPad animated:YES];
    return;
}


- (SCLeftMenuViewController *)leftMenuPad
{
    if (_leftMenuPad == nil) {
        _leftMenuPad = [SCLeftMenuViewControllerPad new];
        [_leftMenuPad.view setFrame:CGRectMake(-328, 0, 328, 65)];
        _leftMenuPad.delegate = self;
    }
    return _leftMenuPad;
}


#pragma mark Action
- (void)didSelectLeftBarItem:(id)sender
{
    if (!self.isShowingLeftMenu) {
        [self.leftMenuPad didClickShow];
        self.isShowingLeftMenu = YES;
    }
}

- (SCCartViewControllerPad *)cartViewControllerPad
{
    if (_cartViewControllerPad == nil) {
        _cartViewControllerPad = [SCCartViewControllerPad new];
        SimiCustomerModel *customer = [[SimiGlobalVar sharedInstance] customer];
        if([customer valueForKey:@"_id"] != nil && ![[customer valueForKey:@"_id"] isEqualToString:@""]){
            [_cartViewControllerPad getQuotesWithCustomerId:[customer valueForKey:@"_id"]];
        }
        [_cartViewControllerPad getCart];
    }
    return _cartViewControllerPad;
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
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self.leftMenuPad action:@selector(didClickHide)];
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self.leftMenuPad action:@selector(didClickHide)];
        swipe.direction = UISwipeGestureRecognizerDirectionLeft;
        singleTap.numberOfTapsRequired = 1;
        [imageShadow addGestureRecognizer:singleTap];
        [imageShadow addGestureRecognizer:swipe];
        [navi.view addSubview:imageShadow];
        [navi.view bringSubviewToFront:self.leftMenuPad.view];
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

- (void)openCategoryProductsListWithCategoryId:(NSString *)categoryId
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    SCProductListViewControllerPad * nextViewController = [SCProductListViewControllerPad new];
    [nextViewController setCategoryID:categoryId];
    [(UINavigationController *)currentVC pushViewController:nextViewController animated:YES];
}

- (void)menu:(SCLeftMenuViewController *)menu didSelectRow:(SimiRow *)row withIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SCLeftMenu_DidSelectRow" object:self userInfo:@{@"simirow":row, @"indexPath":indexPath}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    
    SimiTable *cells = menu.cells;
    SimiSection *section = [cells objectAtIndex:indexPath.section];
    if ([section.identifier isEqualToString:LEFTMENU_SECTION_MAIN]) {
        if ([row.identifier isEqualToString:LEFTMENU_ROW_HOME]) {
            [(UINavigationController *)currentVC popToRootViewControllerAnimated:YES];
        }else if([row.identifier isEqualToString:LEFTMENU_ROW_SETTING])
        {
            SCSettingViewController *settingViewController = [SCSettingViewController new];
            UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:settingViewController];
            self.popController = [[UIPopoverController alloc]initWithContentViewController:navi];
            settingViewController.isInPopover = YES;
            self.popController.delegate =  self;
            [self.popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:currentVC.view permittedArrowDirections:0 animated:YES];
        }else if([row.identifier isEqualToString:LEFTMENU_ROW_ORDERHISTORY])
        {
            SCOrderHistoryViewController *orderHistoryViewController = [SCOrderHistoryViewController new];
            UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:orderHistoryViewController];
            self.popController = [[UIPopoverController alloc]initWithContentViewController:navi];
            orderHistoryViewController.isInPopover = YES;
            self.popController.delegate =  self;
            [self.popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:currentVC.view permittedArrowDirections:0 animated:YES];
        }else if ([row.identifier isEqualToString:LEFTMENU_ROW_DOWNLOAD]){
            if(self.downloadControllViewController == nil)
            {
                self.downloadControllViewController = [[DownloadControlViewController alloc]init];
            }
            UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:self.downloadControllViewController];
            self.popController = [[UIPopoverController alloc]initWithContentViewController:navi];
            self.downloadControllViewController.isInPopover = YES;
            self.popController.delegate =  self;
            [self.popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:currentVC.view permittedArrowDirections:0 animated:YES];
        }
        
    }else if ([section.identifier isEqualToString:LEFTMENU_SECTION_MORE])
    {
        if([row.identifier isEqualToString:LEFTMENU_ROW_SETTING])
        {
            SCSettingViewController *settingViewController = [SCSettingViewController new];
            UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:settingViewController];
            self.popController = [[UIPopoverController alloc]initWithContentViewController:navi];
            settingViewController.isInPopover = YES;
            self.popController.delegate =  self;
            [self.popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:currentVC.view permittedArrowDirections:0 animated:YES];
        }else if ([row.identifier isEqualToString:LEFTMENU_ROW_CMS])
        {
            UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
            SCWebViewController *webViewController = [[SCWebViewController alloc] init];
            webViewController.title = row.title;
            webViewController.content = [row.data valueForKey:@"content"];
            [(UINavigationController *)currentVC popToRootViewControllerAnimated:NO];
            [(UINavigationController *)currentVC pushViewController:webViewController animated:YES];
        }
    }
}

- (void)didSelectLoginRow
{
    if([[SimiGlobalVar sharedInstance]isLogin])
    {
        SCAccountViewController *accountViewController = [SCAccountViewController new];
        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:accountViewController];
        self.popController = [[UIPopoverController alloc]initWithContentViewController:navi];
        UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
        self.popController.delegate =  self;
        accountViewController.isInPopover = YES;
        accountViewController.popover = self.popController;
        [self.popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:currentVC.view permittedArrowDirections:0 animated:YES];
        return;
    }
    SCLoginViewController *loginViewController = [SCLoginViewController new];
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:loginViewController];
    self.popController = [[UIPopoverController alloc]initWithContentViewController:navi];
    
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    self.popController.delegate =  self;
    [self.popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:currentVC.view permittedArrowDirections:0 animated:YES];
}

#pragma mark Notification Action
- (void)didLogin:(NSNotification*)noti
{
    [self.popController dismissPopoverAnimated:YES];
}

- (void)didLogout:(NSNotification*)noti
{
    [self.popController dismissPopoverAnimated:YES];
}

#pragma mark Search Action
- (void)didSelectSearchButton:(id)sender
{
    _isShowSearchBar = YES;
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    SimiViewController *viewPad = (SimiViewController *)[[(UINavigationController*)currentVC viewControllers]lastObject];
    viewPad.navigationItem.leftItemsSupplementBackButton = NO;
    if (_fogImageView == nil) {
        _fogImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [_fogImageView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.9]];
        _fogImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapFogImageView:)];
        [_fogImageView addGestureRecognizer:tapGesture];
    }
    [viewPad.view addSubview:_fogImageView];
    [viewPad reloadRightBarItemsPad];
    viewPad.navigationItem.leftBarButtonItems =  nil;
}

- (void)didTapFogImageView:(UIGestureRecognizer*)tapGesture
{
    _isShowSearchBar = NO;
    [_searchBar resignFirstResponder];
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    SimiViewController *viewPad = (SimiViewController *)[[(UINavigationController*)currentVC viewControllers]lastObject];
    viewPad.navigationItem.leftItemsSupplementBackButton = YES;
    [_fogImageView removeFromSuperview];
    [viewPad reloadRightBarItemsPad];
    viewPad.navigationItem.leftBarButtonItems = self.leftButtonItems;
}

#pragma mark Search Bar Delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    _isShowSearchBar = NO;
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    SimiViewController *viewPad = (SimiViewController *)[[(UINavigationController*)currentVC viewControllers]lastObject];
    viewPad.navigationItem.leftItemsSupplementBackButton = YES;
    [_fogImageView removeFromSuperview];
    [viewPad reloadRightBarItemsPad];
    viewPad.navigationItem.leftBarButtonItems = self.leftButtonItems;
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    SimiViewController *viewControllerTemp = (SimiViewController *)[[(UINavigationController*)currentVC viewControllers]lastObject];
    _currentKeySearch = _searchBar.text;
    [searchBar resignFirstResponder];
    _isShowSearchBar = NO;
    [viewControllerTemp reloadRightBarItemsPad];
    [_fogImageView removeFromSuperview];
    
    SCProductListViewControllerPad * searchViewController = [[SCProductListViewControllerPad alloc]init];
    
    searchViewController.productListGetProductType = ProductListGetProductTypeFromSearch;
    searchViewController.keySearchProduct = _currentKeySearch;
    searchViewController.navigationItem.title = [NSString stringWithFormat:@"\"%@\"",_currentKeySearch];
    [viewControllerTemp.navigationController pushViewController:searchViewController animated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
