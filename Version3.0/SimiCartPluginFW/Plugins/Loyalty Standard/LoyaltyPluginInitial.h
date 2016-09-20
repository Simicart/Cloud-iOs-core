//
//  LoyaltyPluginInitial.h
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 12/31/14.
//  Copyright (c) 2014 Magestore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SimiCartBundle/SCOrderViewController.h>
#define LOYALTY_TAG         9183756
#define LOYALTY_CHECKOUT    LOYALTY_CART

static NSString *LOYALTY_CART   = @"loyalty";

@interface LoyaltyPluginInitial : NSObject
@property (weak, nonatomic) SCOrderViewController* orderViewController;
@property (weak, nonatomic) id loyaltyMenuRow;
@property (weak, nonatomic) id moreViewController;

@end
