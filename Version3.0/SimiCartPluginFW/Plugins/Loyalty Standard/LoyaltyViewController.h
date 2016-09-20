//
//  LoyaltyViewController.h
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 1/15/15.
//  Copyright (c) 2015 Magestore. All rights reserved.
//

#import <SimiCartBundle/SimiViewController.h>
#import <SimiCartBundle/SimiTable.h>

#import "LoyaltyModel.h"

static NSString *LOYALTY_BALANCE    = @"balance";
static NSString *LOYALTY_EARN       = @"earn";
static NSString *LOYALTY_SPEND      = @"spend";
static NSString *LOYALTY_POLICY     = @"policy";
static NSString *LOYALTY_CARD       = @"card";
static NSString *LOYALTY_HISTORY    = @"history";
static NSString *LOYALTY_SETTING    = @"setting";
static NSString *LOYALTY_LOGIN      = @"login";

@interface LoyaltyViewController : SimiViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) LoyaltyModel *loyaltyPolicy;
@property (strong, nonatomic) SimiTable *cells;
@property (nonatomic) BOOL skipReloadData;

@end
