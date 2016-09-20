//
//  SCAppWishlistCoreWorker.h
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 8/25/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SimiCartBundle/SCProductViewController.h>
#import <SimiCartBundle/SCProductMoreViewController.h>
#import <SimiCartBundle/SCAccountViewController.h>
#import "SCAppWishlistViewController.h"
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SimiRow.h>


static NSString *ACCOUNT_WISHLIST_ROW     = @"account_wishlist";

static NSString *LEFTMENU_WISHLIST_ROW     = @"leftmenu_wishlist";

@interface SCAppWishlistCoreWorker : NSObject

@property (strong, nonatomic) SimiProductModel *currentProduct;
@property (strong, nonatomic) SCProductMoreViewController *currentProductMoreVC;
@property (strong, nonatomic) SCProductViewController *currentProductVC;
@property (strong, nonatomic) SCAppWishlistViewController *wishlistViewController;

@property (strong, nonatomic) UIButton *wishlistButton;
@property (strong, nonatomic) SCAppWishlistModelCollection *wishlistModel;

@property (nonatomic) NSInteger heighButton;

@end
