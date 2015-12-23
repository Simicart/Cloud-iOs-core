//
//  SCAccountViewController.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/3/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiViewController.h"
#import "SimiTableView.h"


static NSString *ACCOUNT_MAIN_SECTION   = @"mainsection";
static NSString *ACCOUNT_PROFILE_ROW    = @"profile";
static NSString *ACCOUNT_ADDRESS_ROW    = @"address";
static NSString *ACCOUNT_ORDERS_ROW     = @"orders";
static NSString *ACCOUNT_SIGNOUT_ROW    = @"signout";

@interface SCAccountViewController : SimiViewController<UITableViewDelegate, UITableViewDataSource>

/*
 The function tableView cellForRowAtIndexPath raise notification name: "InitializedAccountCell-After" after created a cell.
 The function tableView didSelectRowAtIndexPath raise notification name: "DidSelectAccountCellAtIndexPath" before TO-DO list in the function.
 */

@property (strong, nonatomic) SimiTableView *tableViewAccount;
@property (strong, nonatomic) NSMutableArray *cells;

- (void)initView;

@end
