//
//  SCChangePasswordViewController.m
//  SimiCartPluginFW
//
//  Created by Axe on 1/19/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SCChangePasswordViewController.h"
#import "SimiFormText.h"
#import "SimiCart.h"
@interface SCChangePasswordViewController ()

@end

@implementation SCChangePasswordViewController
@synthesize form, customer, tableViewChangePassword;

- (void)viewDidLoadBefore {
    [self setToSimiView];
    self.navigationItem.title = [self formatTitleString:SCLocalizedString(@"Change Password")];
    self.customer = [[SimiGlobalVar sharedInstance] customer];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        [super viewDidLoadBefore];
    }else
        [self configureNavigationBarOnViewDidLoad];
    CGRect frame = self.view.bounds;
    frame.size.width = 2*SCREEN_WIDTH/3;
    frame.size.height = 2*SCREEN_HEIGHT/3;
    tableViewChangePassword = [[SimiTableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    [tableViewChangePassword setBackgroundColor:[UIColor clearColor]];
    [tableViewChangePassword setDelaysContentTouches:YES];
    
    form = (SimiFormBlock *)[SimiCart createBlock:@"SimiFormBlock"];
    form.isShowRequiredText = YES;
    form.height = 50;
    [form addField:@"Password"
            config:@{
                     @"name": @"password",
                     @"title": SCLocalizedString(@"Current Password"),
                     @"required": @1
                     }];
    [form addField:@"Password"
            config:@{
                     @"name": @"newpassword",
                     @"title": SCLocalizedString(@"New Password"),
                     @"required": @1
                     }];
    [form addField:@"Password"
            config:@{
                     @"name": @"conpassword",
                     @"title": SCLocalizedString(@"Confirm Password"),
                     @"required": @1
                     }];
    [customer removeObjectForKey:@"oldpassword"];
    [customer removeObjectForKey:@"newpassword"];
    [customer removeObjectForKey:@"conpassword"];
    
    [form setFormData:customer];
    
    [super viewDidLoadBefore];
    if(!self.isDiscontinue){
        form.view = tableViewChangePassword;
        [form showView];
        [self.view addSubview:tableViewChangePassword];
    }
    
    [customer getCustomerProfile];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProfile:) name:DidGetProfile object:customer];
    [self startLoadingData];
}

-(void) viewWillAppearBefore:(BOOL)animated{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewWillAppearBefore:YES];
    }
        
    //Add Save button
    UIBarButtonItem *button = [[UIBarButtonItem alloc]initWithTitle:SCLocalizedString(@"Save") style:UIBarButtonItemStyleDone target:self action:@selector(changePassword)];
    self.navigationItem.rightBarButtonItem = button;
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)didGetProfile: (NSNotification *)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(responder.responseMessage) delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
    }
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) changePassword{
    if (![form isDataValid]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(@"Please select all (*) fields") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
        return;
    }
    for (SimiFormAbstract *field in self.form.fields) {
        if ([field isKindOfClass:[SimiFormText class]]) {
            [((SimiFormText*)field).inputText resignFirstResponder];
        }
    }
    NSString *curPass = @"";
    NSString *newPass = @"";
    NSString *confirmPass = @"";
    if([form valueForKey:@"password"])
        curPass = [form valueForKey:@"password"];
    if([form valueForKey:@"newpassword"])
        newPass = [form valueForKey:@"newpassword"];
    if([form valueForKey:@"conpassword"])
        confirmPass = [form valueForKey:@"conpassword"];
    
    if (curPass.length > 0 || newPass.length > 0 || confirmPass.length > 0) {
        if (![newPass isEqualToString:confirmPass]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(@"Password and Confirm password don't match.") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
            [alertView show];
            return;
        }else if(newPass.length < 6){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(@"Password must be least 6 characters") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
            [alertView show];
            return;
        }else{
            [customer setValue:@"1" forKey:@"change_password"];
        }
    }
    [customer addData:form];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangePassword:) name:DidChangeUserPassword object:customer];
    [customer changeUserPassword];
    [self startLoadingData];
}

-(void) didChangePassword: (NSNotification* )noti{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:responder.status message:responder.responseMessage delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
    if([[responder.status uppercaseString] isEqualToString:@"SUCCESS"]){
        [form removeObjectForKey:@"oldpassword"];
        [form removeObjectForKey:@"newpassword"];
        [form removeObjectForKey:@"conpassword"];
        [tableViewChangePassword reloadData];
        [self.navigationController popToRootViewControllerAnimated:YES];
        alertView.message = @"Your password has changed successfully";
    }
    
    if(![alertView.message isEqualToString:@""] && alertView.message != nil)
        [alertView show];
    [self stopLoadingData];
    [super removeObserverForNotification:noti];
}

@end
