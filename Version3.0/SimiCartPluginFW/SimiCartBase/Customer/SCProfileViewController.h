//
//  SCProfileViewController.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/5/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//
#import "SimiTableView.h"
#import "SimiViewController.h"
#import "SimiCustomerModel.h"
#import "SimiCart.h"

@interface SCProfileViewController : SimiViewController

/*
 The function tableView cellForRowAtIndexPath raise notification name: "InitializedProfileCell-After" after created a cell.
 The function tableView didSelectRowAtIndexPath raise notification name: "DidSelectProfileCellAtIndexPath" before TO-DO list in the function.
 */

@property (strong, nonatomic) SimiTableView *tableViewProfile;
@property (strong, nonatomic) SimiCustomerModel *customer;
// New Form Pattern
@property (strong, nonatomic) SimiFormBlock *form;
@property (strong, nonatomic) SimiModel *customerInfo;


@end
