//
//  SCNewAddressViewController.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/19/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiViewController.h"
#import "SimiTableView.h"
#import "SimiAddressModelCollection.h"
#import "SimiAddressModel.h"
#import "SimiTextField.h"
#import "SimiCart.h"

@protocol SCNewAddressDelegate <NSObject>

- (void)didSaveAddress:(SimiAddressModel *)address;

@end

@interface SCNewAddressViewController : SimiViewController

/*
 The function tableView cellForRowAtIndexPath raise notification name: "InitializedNewAddressCell-After" after created a cell.
 The function tableView didSelectRowAtIndexPath raise notification name: "DidSelectNewAddressCellAtIndexPath" before TO-DO list in the function.
 */
@property (strong, nonatomic) id<SCNewAddressDelegate> delegate;
@property (strong, nonatomic) SimiAddressModel *address;
@property (strong, nonatomic) SimiAddressModelCollection *states;
@property (strong, nonatomic) SimiAddressModelCollection *countries;
@property (strong, nonatomic) SimiTableView *tableViewAddress;

// New Form Pattern
@property (strong, nonatomic) SimiFormBlock *form;
@property (strong, nonatomic) SimiFormSelect *country;
@property (strong, nonatomic) SimiFormText *stateName;
@property (strong, nonatomic) SimiFormSelect *stateId;
@property (strong, nonatomic) NSString *customerId;

- (void)formDataChanged:(NSNotification *)note;

@property (nonatomic) BOOL isEditing;
@property (nonatomic) BOOL isNewCustomer;

- (void)didGetCountries;
- (void)saveAddress;
-(void)hideKeyboard;

@end
