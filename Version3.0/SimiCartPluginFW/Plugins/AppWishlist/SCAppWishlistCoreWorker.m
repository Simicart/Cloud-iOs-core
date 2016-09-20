//
//  SCAppWishlistCoreWorker.m
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 8/25/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCAppWishlistCoreWorker.h"
#import <SimiCartBundle/SCLeftMenuViewController.h>
#import <SimiCartBundle/SCNavigationBarPhone.h>
#import <SimiCartBundle/SCNavigationBarPad.h>

@implementation SCAppWishlistCoreWorker

@synthesize wishlistViewController, currentProductVC, currentProductMoreVC, currentProduct, wishlistButton, wishlistModel;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
#pragma mark wishlist Button
        wishlistButton = [UIButton new];
        [wishlistButton setImageEdgeInsets:UIEdgeInsetsMake(9, 9, 9, 9)];
        [wishlistButton.layer setCornerRadius:25.0f];
        [wishlistButton.layer setShadowOffset:CGSizeMake(1, 1)];
        [wishlistButton.layer setShadowRadius:2];
        wishlistButton.layer.shadowOpacity = 0.5;
        [wishlistButton setBackgroundColor:[UIColor whiteColor]];
        [wishlistButton addTarget:self action:@selector(didTouchWishlistButton) forControlEvents:UIControlEventTouchUpInside];
        wishlistModel = [SCAppWishlistModelCollection new];
        
        self.heighButton = 50;
        
        //Product More View
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productViewControllerWillAppear:) name:@"SCProductViewControllerViewWillAppear" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initViewMoreAction:) name:@"SCProductMoreViewController_InitViewMoreAction" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beforeTouchMoreAction:) name:@"SCProductMoreViewController-BeforeTouchMoreAction" object:nil];
        
        //My Account Screen
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializedAccountCellAfter:) name:@"SCAccountViewController-InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectAccountCellAtIndexPath:) name:@"DidSelectAccountCellAtIndexPath" object:nil];
        
        //Left Menu
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listMenuInitCellsAfter:) name:@"SCLeftMenu_InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listMenuDidSelectRow:) name:SCLeftMenuDidSelectRow object:nil];
        
    }
    return self;
}

#pragma mark Event Handlers
// Product View Controller Will Appear
- (void)productViewControllerWillAppear:(NSNotification *)noti
{
    currentProductVC = noti.object;
}

//Add wishlist button on product more view screen
- (void)initViewMoreAction:(NSNotification *)noti
{
    MoreActionView * actionView = noti.object;
    for (UIView *icons in actionView.arrayIcon) {
        if (icons == wishlistButton)
            return;
    }
    actionView.numberIcon += 1;
    [actionView.arrayIcon addObject:wishlistButton];
}

//Update product and wishlist button
- (void)beforeTouchMoreAction:(NSNotification *)noti
{
    currentProductMoreVC = noti.object;
    currentProduct = currentProductMoreVC.productModel;
    [self updateWishlistIcon];
}

#pragma mark Update Wishlist Icon
-(void)updateWishlistIcon
{
    [wishlistButton setImage:[UIImage imageNamed:@"wishlist_empty_icon"] forState:UIControlStateNormal];
}

#pragma mark Wishlist Button Touched

- (void)didTouchWishlistButton
{
    if (![[SimiGlobalVar sharedInstance] isLogin]) {
        [currentProductMoreVC.navigationController pushViewController:[SCLoginViewController new] animated:YES];
        return;
    }
    [currentProductVC showAlertContactSimiCartWithMessage:@"This feature can only be accessed with the fully synced version. Please contact SimiCart by email or chat with us"];
}

#pragma mark Add to Wishlist
- (void)addProductToWishlist
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddProductToWishlist:) name:@"DidAddProductToWishlist" object:nil];
    
    if (currentProductVC) {
        SCProductViewController *productVC = currentProductVC;
        SimiProductModel *product = productVC.product;
        NSMutableArray *selectedOptions = [[NSMutableArray alloc] init];
        NSMutableDictionary *optionDict = productVC.optionDict;
        NSArray *allKeys = productVC.allKeys;
        for (int i = 0; i < allKeys.count; i++) {
            NSMutableArray *optionsForKey = [optionDict valueForKey:[allKeys objectAtIndex:i]];
            for (NSDictionary *option in optionsForKey) {
                if ([[option valueForKeyPath:@"is_selected"] boolValue]) {
                    [selectedOptions addObject:option];
                }
            }
        }
        
        SimiProductModel *cartItem = [[SimiProductModel alloc] init];
        [cartItem setValue:[product valueForKeyPath:@"product_id"] forKey:@"product_id"];
        [cartItem setValue:[product valueForKeyPath:@"product_name"] forKey:@"product_name"];
        [cartItem setValue:[product valueForKeyPath:@"product_price"] forKey:@"product_price"];
        [cartItem setValue:[product valueForKeyPath:@"product_image"] forKey:@"product_image"];
        [cartItem setValue:[product valueForKeyPath:@"product_qty"] forKey:@"product_qty"];
        [cartItem setValue:selectedOptions forKey:@"options"];
        
        [wishlistModel addProductToWishlist:cartItem otherParams:nil];
    }
    else
        [wishlistModel addProductToWishlist:currentProduct otherParams:nil];
}

- (void)didAddProductToWishlist:(NSNotification *)noti
{
    [wishlistButton setEnabled:YES];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        [currentProduct setObject:[(NSDictionary *)[responder.other objectAtIndex:0] objectForKey:@"wishlist_item_id"] forKey:@"wishlist_item_id"];
        [self updateWishlistIcon];
    }
    else {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:responder.responseMessage  delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    [self removeObserverForNotification:noti];
}

#pragma mark Remove From Wishlist
-(void)removeProductFromWishlist
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemoveProductFromWishlist:) name:@"DidRemoveProductFromWishlist" object:nil];
    [wishlistModel removeProductFromWishlist:[currentProduct objectForKey:@"wishlist_item_id"] otherParams:nil];
}

- (void)didRemoveProductFromWishlist:(NSNotification *)noti
{
    [wishlistButton setEnabled:YES];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        [currentProduct setObject:@"0" forKey:@"wishlist_item_id"];
        [self updateWishlistIcon];
    }
    else {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:responder.responseMessage  delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    [self removeObserverForNotification:noti];
}

#pragma mark Add to My Account Screen
-(void)initializedAccountCellAfter:(NSNotification *)noti
{
    NSArray * cells = noti.object;
    for (SimiSection *section in cells) {
        if (section.identifier != ACCOUNT_MAIN_SECTION)
            return;
        if ([section isKindOfClass:[SimiSection class]]) {
            float rowHeight;
            for (SimiRow *row in section.rows) {
                rowHeight = row.height;
                if (row.identifier == ACCOUNT_WISHLIST_ROW)
                    return;
            }
            SimiRow *wishlistRow = [[SimiRow alloc]initWithIdentifier:ACCOUNT_WISHLIST_ROW height:rowHeight sortOrder:310];
            wishlistRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            wishlistRow.title = SCLocalizedString(@"My Wishlist");
            wishlistRow.image = [UIImage imageNamed:@"wishlist_account_icon"];
            [section addRow:wishlistRow];
            [section sortItems];
        }
    }
}

-(void)didSelectAccountCellAtIndexPath:(NSNotification *)noti
{
    if ([(SimiRow *)noti.object identifier] == ACCOUNT_WISHLIST_ROW) {
        SCAccountViewController *accountVC = [noti.userInfo objectForKey:@"self"];
        if (wishlistViewController == nil) {
            wishlistViewController = [SCAppWishlistViewController new];
        }
        UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
        UIViewController *viewController = [[(UINavigationController *)currentVC viewControllers] lastObject];
        for (UIViewController *viewControllerTemp in viewController.navigationController.viewControllers) {
            if (viewControllerTemp == wishlistViewController) {
                [viewControllerTemp.navigationController popToViewController:viewControllerTemp animated:YES];
                return;
            }
        }
        [(UINavigationController *)currentVC pushViewController:self.wishlistViewController animated:YES];
        if (accountVC.isInPopover) {
            [accountVC.popover dismissPopoverAnimated:YES];
        }
        accountVC.isDiscontinue = YES;
    }
}

#pragma mark Add to Left Menu
-(void)listMenuInitCellsAfter:(NSNotification *)noti
{
    NSArray * cells = noti.object;
    if ([[SimiGlobalVar sharedInstance] isLogin]) {
        for (SimiSection *section in cells) {
            if ([section isKindOfClass:[SimiSection class]]) {
                if (section.identifier != LEFTMENU_SECTION_MAIN)
                    return;
                float rowHeight = 50;
                for (SimiRow *row in section.rows) {
                    rowHeight = row.height;
                    if (row.identifier == LEFTMENU_WISHLIST_ROW)
                        return;
                }
                
                SimiRow *wishlistRow = [[SimiRow alloc]initWithIdentifier:LEFTMENU_WISHLIST_ROW height:rowHeight sortOrder:310];
                wishlistRow.title = SCLocalizedString(@"My Wishlist");
                wishlistRow.image = [UIImage imageNamed:@"wishlist_leftmenu_icon"];
                [section addRow:wishlistRow];
                [section sortItems];
            }
        }
    }
}

-(void)listMenuDidSelectRow:(NSNotification *)noti
{
    if ([(SimiRow *)[noti.userInfo objectForKey:@"simirow"] identifier] == LEFTMENU_WISHLIST_ROW) {
        if (wishlistViewController == nil) {
            wishlistViewController = [SCAppWishlistViewController new];
        }
        UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
        UIViewController *viewController = [[(UINavigationController *)currentVC viewControllers] lastObject];
        for (UIViewController *viewControllerTemp in viewController.navigationController.viewControllers) {
            if (viewControllerTemp == wishlistViewController) {
                [viewControllerTemp.navigationController popToViewController:viewControllerTemp animated:YES];
                return;
            }
        }
        [(UINavigationController *)currentVC pushViewController:self.wishlistViewController animated:YES];
        
        [(SCNavigationBarPhone*)noti.object setIsDiscontinue:YES];
    }
}
#pragma mark dealloc
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
