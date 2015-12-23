//
//  SCRegisterViewController.m
//  SimiCartPluginFW
//
//  Created by Thuy Dao on 2/27/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SCRegisterViewController.h"
#import "SimiCustomerModel.h"
#import "SimiSection.h"

@implementation SCRegisterViewController

@synthesize form, customer, tableViewRegister;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoadBefore
{
    self.navigationItem.title = SCLocalizedString(@"Register");
    [self setToSimiView];
    CGRect frame = self.view.frame;
    tableViewRegister = [[SimiTableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    tableViewRegister.separatorColor = tableViewRegister.backgroundColor;
    tableViewRegister.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [tableViewRegister setBackgroundColor:[UIColor clearColor]];
    form = (SimiFormBlock *)[SimiCart createBlock:@"SimiFormBlock"];
    form.isShowRequiredText = YES;
    form.height = 40;

    SimiGlobalVar *config = [SimiGlobalVar sharedInstance];
    //Add fields
    if (![[config prefixShow] isEqualToString:@""]) {
        [form addField:@"Text"
                config:@{
                         @"name" : @"prefix",
                         @"title": SCLocalizedString(@"Prefix"),
                         @"required": [NSNumber numberWithBool:[[config prefixShow] isEqualToString:@"req"]]
                         }];
    }
    
    [form addField:@"Name"
            config:@{
                     @"name": @"first_name",
                     @"title": SCLocalizedString(@"First Name"),
                     @"required": @1
                     }];
    
    [form addField:@"Name"
            config:@{
                     @"name": @"last_name",
                     @"title": SCLocalizedString(@"Last Name"),
                     @"required": @1
                     }];
    
    if (![[config suffixShow] isEqualToString:@""]) {
        [form addField:@"Text"
                config:@{
                         @"name" : @"suffix",
                         @"title": SCLocalizedString(@"Suffix"),
                         @"required": [NSNumber numberWithBool:[[config suffixShow] isEqualToString:@"req"]]
                         }];
    }
    
    
    if (![[config dobShow] isEqualToString:@""]) {
        [form addField:@"Date"
                config:@{
                         @"name": @"dob",
                         @"title": SCLocalizedString(@"Date of Birth"),
                         @"date_type": @"date",
                         @"date_format": @"yyyy-MM-dd",
                         @"required": [NSNumber numberWithBool:[[config dobShow] isEqualToString:@"req"]]
                         }];
    }
    
    if (![[config genderShow] isEqualToString:@""]) {
        [form addField:@"Select"
                config:@{
                         @"name": @"gender",
                         @"title": SCLocalizedString(@"Gender"),
                         @"required": [NSNumber numberWithBool:[[config genderShow] isEqualToString:@"req"]],
                         @"source": @[@{@"value":@"123",@"label":SCLocalizedString(@"Male")},@{@"value":@"234",@"label":SCLocalizedString(@"Female")}]
                         }];
    }
    
    if (![[config taxvatShow] isEqualToString:@""]) {
        [form addField:@"Text"
                config:@{
                         @"name": @"taxvat",
                         @"title": SCLocalizedString(@"VAT Number"),
                         @"required": [NSNumber numberWithBool:[[config taxvatShow] isEqualToString:@"req"]]
                         }];
    }
    
    [form addField:@"Email"
            config:@{
                     @"name": @"email",
                     @"title": SCLocalizedString(@"Email"),
                     @"required": @1
                     }].enabled = ![config isLogin];
    
    [form addField:@"Password"
            config:@{
                     @"name": @"password",
                     @"title": SCLocalizedString(@"Password"),
                     @"required": @1
                     }];
    [form addField:@"Password"
            config:@{
                     @"name": @"password_confirmation",
                     @"title": SCLocalizedString(@"Confirm Password"),
                     @"required": @1
                     }];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewDidLoadBefore];
    }else
        [self configureNavigationBarOnViewDidLoad];
}

- (void)viewDidLoadAfter
{
    [super viewDidLoadAfter];
    if (!self.isDiscontinue) {
        //  Liam Fixbug iOs 7 150619
        if (SIMI_SYSTEM_IOS >= 7 && SIMI_SYSTEM_IOS < 8) {
            //Add register button
            form.actionTitle = SCLocalizedString(@"Register");
            [form.actionBtn setBackgroundImage:[[SimiGlobalVar sharedInstance] imageFromColor:THEME_BUTTON_BACKGROUND_COLOR] forState:UIControlStateNormal];
            [form.actionBtn setTitleColor:THEME_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
            [form addTarget:self action:@selector(didClickButtonRegister)];
        }
        //  End 150619
        form.view = tableViewRegister;
        [form showView];
        [self.view addSubview:tableViewRegister];
    }
    
    //Add register button
    form.actionTitle = SCLocalizedString(@"Register");
    [form addTarget:self action:@selector(didClickButtonRegister)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(formDataChanged:) name:SimiFormDataChangedNotification object:form];
    //Add customer form event
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidCreateAddressAutofill" object:tableViewRegister userInfo:@{@"newCustomerView": self}];
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewWillAppearBefore:YES];
    }
}
- (void)viewWillAppearAfter:(BOOL)animated{
    [super viewWillAppearAfter:animated];
    [tableViewRegister deselectRowAtIndexPath:[tableViewRegister indexPathForSelectedRow] animated:YES];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard) name:UIKeyboardDidHideNotification object:nil];
    }
}

- (void)viewWillDisappearBefore:(BOOL)animated
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    }
    [super viewWillDisappearBefore:animated];
}

- (void)didClickButtonRegister
{
    NSString *tfPass = [form objectForKey:@"password"];
    NSString *tfConfirm = [form objectForKey:@"password_confirmation"];
    if (![tfPass isEqualToString:tfConfirm]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(@"Password and Confirm password don't match.") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    NSString *tfEmail = [form objectForKey:@"email"];
    if(![self NSStringIsValidEmail:tfEmail])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(@"Check your email and try again.") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
        return;
    }
    // Valid Form
    if (![form isDataValid]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(@"Please select all (*) fields") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
        return;
    }
    //Set data to customer model
    if (customer == nil) {
        customer = [[SimiCustomerModel alloc] init];
    }
    [customer removeAllObjects];
    [customer addData:form];
    // POST data to server
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRegisterCustomer:) name:@"DidRegister" object:customer];
    [self startLoadingData];
    [customer doRegister];
}

- (void)didRegisterCustomer:(NSNotification *)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:responder.responseMessage delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
    [alertView show];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        if ([noti.name isEqualToString:@"DidRegister"]) {
            [self.navigationController popViewControllerAnimated:YES];
            [self.delegate didRegisterWithEmail:[customer valueForKey:@"email"] password:[customer valueForKey:@"password"]];
        }
    }
    [self removeObserverForNotification:noti];
    [self stopLoadingData];
}

- (void)keyboardWasShown
{
    UIEdgeInsets contentInsets;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        contentInsets = UIEdgeInsetsMake(40, 0, 180, 0);
    }else
    {
        contentInsets = UIEdgeInsetsMake(40, 0, 400, 0);
    }
    tableViewRegister.contentInset = contentInsets;
    tableViewRegister.scrollIndicatorInsets = contentInsets;
}


- (void)hideKeyboard{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    CGRect frame = tableViewRegister.frame;
    tableViewRegister.frame = CGRectMake(0.0f,
                                      0.0f,
                                      frame.size.width,
                                      frame.size.height);
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(40, 0, 100, 0);;
    tableViewRegister.contentInset = contentInsets;
    tableViewRegister.scrollIndicatorInsets = contentInsets;
    [UIView commitAnimations];
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

#pragma mark - Form Data Change
- (void)formDataChanged:(NSNotification *)note
{
    SimiFormAbstract *field = [[note userInfo] objectForKey:@"field"];
    if ([field.simiObjectName isEqualToString:@"dob"]) {
        NSArray *dob = [[form objectForKey:@"dob"] componentsSeparatedByString:@"-"];
        if ([dob count] > 2) {
            [form setValue:[dob objectAtIndex:0] forKey:@"year"];
            [form setValue:[dob objectAtIndex:1] forKey:@"month"];
            [form setValue:[dob objectAtIndex:2] forKey:@"day"];
        }
    }
}


@end
