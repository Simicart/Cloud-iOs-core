//
//  SCRegisterViewController.h
//  SimiCartPluginFW
//
//  Created by Thuy Dao on 2/27/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiTableView.h"
#import "SimiViewController.h"
#import "SimiCart.h"

@protocol RegisterDelegate <NSObject>
- (void)didRegisterWithEmail:(NSString *)email password:(NSString *)password;
@end

@interface SCRegisterViewController : SimiViewController

/*
 The function tableView cellForRowAtIndexPath raise notification name: "InitializedRegisterCell-After" after created a cell.
 The function tableView didSelectRowAtIndexPath raise notification name: "DidSelectRegisterCellAtIndexPath" before TO-DO list in the function.
 */

@property (strong, nonatomic) id<RegisterDelegate> delegate;
@property (strong, nonatomic) SimiTableView *tableViewRegister;

// New Form Pattern
@property (strong, nonatomic) SimiFormBlock *form;
@property (strong, nonatomic) SimiCustomerModel *customer;

- (void)formDataChanged:(NSNotification *)note;


@end
