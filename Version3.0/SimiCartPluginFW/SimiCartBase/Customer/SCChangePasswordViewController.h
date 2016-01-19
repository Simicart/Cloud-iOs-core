//
//  SCChangePasswordViewController.h
//  SimiCartPluginFW
//
//  Created by Axe on 1/19/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimiTableView.h"
#import "SimiFormBlock.h"

@interface SCChangePasswordViewController : SimiViewController

@property (strong, nonatomic) SimiTableView* tableViewChangePassword;
@property (strong, nonatomic) SimiCustomerModel *customer;

@property (strong, nonatomic) SimiFormBlock* form;

@end
