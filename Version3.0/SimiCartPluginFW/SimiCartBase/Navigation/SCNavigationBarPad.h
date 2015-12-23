//
//  SCNavigationBarPad.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/3/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCNavigationBarPhone.h"
#import "SCCartViewControllerPad.h"
#import "SCLeftMenuViewControllerPad.h"
#import "SCProductListViewControllerPad.h"

@interface SCNavigationBarPad : SCNavigationBarPhone<UIPopoverControllerDelegate, UISearchBarDelegate>
@property (strong, nonatomic) SCCartViewControllerPad *cartViewControllerPad;
@property (strong, nonatomic) SCLeftMenuViewControllerPad *leftMenuPad;
@property (strong, nonatomic) UIPopoverController *popController;
@property (strong, nonatomic) UIBarButtonItem *searchItem;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (nonatomic) BOOL isShowSearchBar;
@property (strong, nonatomic) NSString *currentKeySearch;
@property (strong, nonatomic) UIImageView *fogImageView;
@property (strong, nonatomic) UIButton *cartButton;
@end
