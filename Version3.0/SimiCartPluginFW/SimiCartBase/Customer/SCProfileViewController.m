//
//  SCProfileViewController.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/5/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SCProfileViewController.h"
#import "SCAppDelegate.h"

@interface SCProfileViewController ()
{
    BOOL isFirstLoad;
}

@end

@implementation SCProfileViewController

@synthesize tableViewProfile, customer, form;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoadBefore
{
    [self setToSimiView];
    self.navigationItem.title = [self formatTitleString:SCLocalizedString(@"Profile")];
    customer = [[SimiGlobalVar sharedInstance] customer];
    isFirstLoad = YES;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [super viewDidLoadBefore];
    }else
        [self configureNavigationBarOnViewDidLoad];
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [super viewWillAppearBefore:YES];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (isFirstLoad) {
        isFirstLoad = NO;
        [customer getCustomerProfile];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotificationCustomer:) name:DidGetProfile object:customer];
        [self startLoadingData];
    }
}

- (void)didReceiveNotificationCustomer: (NSNotification *)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        [self loadData];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(responder.responseMessage) delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
    }
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
}

-(void)loadData
{
    tableViewProfile = [[SimiTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [tableViewProfile setBackgroundColor:[UIColor clearColor]];
    tableViewProfile.delaysContentTouches = NO;
    
    form = (SimiFormBlock *)[SimiCart createBlock:@"SimiFormBlock"];
    form.isShowRequiredText = YES;
    form.height = 50;
    
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
    
    [form addField:@"Email"
            config:@{
                     @"name": @"email",
                     @"title": SCLocalizedString(@"Email"),
                     @"required": @1
                     }].enabled = ![SimiGlobalVar sharedInstance].isLogin;
    
    if (![[config dobShow] isEqualToString:@""]) {
        [form addField:@"Date"
                config:@{
                         @"name": @"dob",
                         @"title": SCLocalizedString(@"Date of Birth"),
                         @"date_type": @"date",
                         @"date_format": @"yyyy-MM-dd",
                         @"required": [NSNumber numberWithBool:[[config dobShow] isEqualToString:@"req"]]
                         }];
        //format Date of Birth
        NSString *year = [customer valueForKey:@"year"];
        NSString *month = [customer valueForKey:@"month"];
        NSString *day = [customer valueForKey:@"day"];
        NSString *dateShow = [[[[year stringByAppendingString:@"-"] stringByAppendingString:month]stringByAppendingString:@"-"]stringByAppendingString:day];
        [customer setValue:dateShow forKey:@"dob"];
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
                         @"title": SCLocalizedString(@"Tax/VAT number"),
                         @"required": [NSNumber numberWithBool:[[config taxvatShow] isEqualToString:@"req"]]
                         }];
    }
        
    
    
    [form setFormData:customer];
    
    [super viewDidLoad];
    if (!self.isDiscontinue) {
        form.view = tableViewProfile;
        [form showView];
        [self.view addSubview:tableViewProfile];
    }
    //Add Save button
    UIBarButtonItem *button = [[UIBarButtonItem alloc]initWithTitle:SCLocalizedString(@"Save") style:UIBarButtonItemStyleDone target:self action:@selector(saveProfile)];
    self.navigationItem.rightBarButtonItem = button;
    self.navigationItem.rightBarButtonItem.enabled = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(formDataChanged:) name:SimiFormDataChangedNotification object:form];
    //Add customer form event
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidCreateProfileForm" object:tableViewProfile userInfo:@{@"customerProfile": self}];
}

- (void)viewWillAppearAfter:(BOOL)animated{
    [super viewWillAppearAfter:animated];
    [tableViewProfile deselectRowAtIndexPath:[tableViewProfile indexPathForSelectedRow] animated:YES];
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

- (void)saveProfile{
    // Valid Form
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
    
    //Set data to customer model
    [customer addData:form];
    //POST data to server
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSaveProfile:) name:DidChangeUserInfo object:customer];
    [customer changeUserProfile];
    [self startLoadingData];

}

- (void)didSaveProfile:(NSNotification *)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Change password" message:responder.responseMessage delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        NSString *message = SCLocalizedString(@"The account information has been saved.");
        if ([noti.name isEqualToString:DidChangeUserInfo]) {
            alertView.message = message;
            
        }
    }
    if(![alertView.message isEqualToString:@""] && alertView.message != nil)
        [alertView show];
    [self stopLoadingData];
    [super removeObserverForNotification:noti];
}

#pragma mark Config Content Inset Table
- (void)keyboardWasShown
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, 240, 0);
    tableViewProfile.contentInset = contentInsets;
    tableViewProfile.scrollIndicatorInsets = contentInsets;
}

- (void)hideKeyboard{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    tableViewProfile.contentInset = contentInsets;
    tableViewProfile.scrollIndicatorInsets = contentInsets;
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
