//
//  SCForgotPasswordViewController.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/25/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiViewController.h"

static NSString *FORGOT_PASS_TEXT_CELL      = @"ForgotPassTextCell";
static NSString *FORGOT_PASS_ACTION_CELL    = @"ForgotPassActionCell";

@interface SCForgotPasswordViewController : SimiViewController<UITableViewDataSource, UITextFieldDelegate, UITableViewDelegate>{
    UITextField *textFieldEmail;
}

@property (strong, nonatomic) UITableView *tableViewForgotPass;
@property (strong, nonatomic) NSMutableArray *cells;

@end
