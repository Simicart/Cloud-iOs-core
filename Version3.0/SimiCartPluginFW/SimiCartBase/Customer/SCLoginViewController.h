//
//  SCLoginViewControllerUpdate.h
//  SimiCartPluginFW
//
//  Created by Axe on 8/6/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRegisterViewController.h"
#import "SimiTable.h"

static NSString *LOGIN_SECTION = @"LOGIN_SECTION" ,*LOGIN_USER_NAME = @"USER_NAME", *LOGIN_PASSWORD = @"PASSWORD", *LOGIN_REMEMBER_ME = @"REMEMBER_ME", *LOGIN_SIGNIN_BUTTON = @"SIGNIN_BUTTON", *LOGIN_REGISTER = @"REGISTER", *LOGIN_CANCEL = @"CANCEL";


@interface SCLoginViewController : SimiViewController<UITextFieldDelegate, RegisterDelegate, UITableViewDataSource, UITableViewDelegate>

{
    UITapGestureRecognizer *gesture;
    SimiCustomerModel *customer;
}
@property (nonatomic) BOOL isLoginInCheckout;
@property (strong, nonatomic) UITextField *textFieldEmail;
@property (strong, nonatomic) UITextField *textFieldPassword;
@property (strong, nonatomic) UIButton *buttonSignIn;
@property (strong,nonatomic) UIButton *btnSignInFacebook;
@property (strong,nonatomic) UIButton *btnRegister;
@property (strong,nonatomic) UIButton *btnHelp;

@property (strong, nonatomic) SimiTable *cells;

@property (strong, nonatomic) SimiTableView* loginTableView;

@end
