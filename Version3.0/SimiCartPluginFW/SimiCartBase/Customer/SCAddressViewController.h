//
//  SCAddressViewController.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/19/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiViewController.h"
#import "SimiAddressModel.h"
#import "SimiAddressModelCollection.h"
#import "SimiTableView.h"
#import "SCNewAddressViewController.h"

static NSString *ADDRESS_ADD_SECTION    = @"add";
static NSString *ADDRESS_EDIT_SECTION   = @"edit";

@protocol SCAddressDelegate <NSObject>

- (void)selectAddress:(SimiAddressModel *)address;

@end

@interface SCAddressViewController : SimiViewController<UITableViewDataSource, UITableViewDelegate, SCNewAddressDelegate>{
    NSString *addressTempPath;
    SimiAddressModelCollection *addressCollection;
}

/**
 Notification: InitAddressCells-Before
 Notification: InitAddressCells-After
 */
@property (strong, nonatomic) NSMutableArray *addressCells;

/*
 The function tableView cellForRowAtIndexPath raise notification name: "InitializedAddressCell-After" after created a cell.
 The function tableView didSelectRowAtIndexPath raise notification name: "DidSelectAddressCellAtIndexPath" before TO-DO list in the function.
 */

@property (strong, nonatomic) SimiTableView *tableViewAddress;
@property (strong, nonatomic) UIActivityIndicatorView *loading;
@property (strong, nonatomic) id<SCAddressDelegate> delegate;
@property (strong, nonatomic) SimiCustomerModel *customer;
@property (nonatomic) BOOL enableEditing;
@property (nonatomic) BOOL isGettingAddress;
@property (nonatomic) BOOL isGetOrderAddress;
//  Liam ADD 150707 for use Default Address;
@property (nonatomic) BOOL isSelectAddressFromCartForCheckOut;
//  End 150707

- (void)getAddresses;

@end
