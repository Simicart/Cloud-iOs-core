//
//  SCForgotPasswordViewController.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/25/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SCForgotPasswordViewController.h"
#import "SimiSection.h"
#import "SimiCustomerModel.h"

@interface SCForgotPasswordViewController ()

@end

@implementation SCForgotPasswordViewController

@synthesize tableViewForgotPass;

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
    self.navigationItem.title = [self formatTitleString:SCLocalizedString(@"Forgot Password")];
    tableViewForgotPass = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    tableViewForgotPass.separatorColor = [UIColor clearColor];
    tableViewForgotPass.delaysContentTouches = NO;
    tableViewForgotPass.dataSource = self;
    tableViewForgotPass.delegate =self;
    tableViewForgotPass.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
    tableViewForgotPass.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tableViewForgotPass];
    [self setCells:nil];
    [super viewDidLoadBefore];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCells:(NSMutableArray *)cells{
    if (cells) {
        _cells = cells;
    }else{
        _cells = [[NSMutableArray alloc] init];
        SimiSection *section1 = [[SimiSection alloc] init];
        section1.headerTitle = SCLocalizedString(@"Enter Your Email");
        SimiRow *row = [[SimiRow alloc] initWithIdentifier:FORGOT_PASS_TEXT_CELL height:44];
        [section1 addRow:row];
        
        SimiSection *section2 = [[SimiSection alloc] init];
        row = [[SimiRow alloc] initWithIdentifier:FORGOT_PASS_ACTION_CELL height:44];
        [section2 addRow:row];
        
        [_cells addObject:section1];
        [_cells addObject:section2];
    }
}

- (void)didClickSendButton{
    if([self NSStringIsValidEmail: textFieldEmail.text]){
        SimiCustomerModel *customer = [[SimiCustomerModel alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DidGetForgotPassword object:customer];
        [customer getForgotPasswordWithUserEmail:textFieldEmail.text];
        [self startLoadingData];
    }else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your email address is not valid" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
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

- (void)didReceiveNotification:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:responder.responseMessage delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
    [alertView show];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
}

#pragma mark Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _cells.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[_cells objectAtIndex:section] rows] count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [[_cells objectAtIndex:section] headerTitle];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        UIView *view = [UIView new];
        UILabel *lblHeader = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, CGRectGetWidth(tableView.frame) - 20, 44)];
        [lblHeader setText:[[[_cells objectAtIndex:section] headerTitle] uppercaseString]];
        [lblHeader setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2]];
        [lblHeader setTextColor:THEME_LIGHT_TEXT_COLOR];
        [lblHeader setTextAlignment:NSTextAlignmentRight];
        [view addSubview:lblHeader];
        return view;
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return [[_cells objectAtIndex:section] footerTitle];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [_cells objectAtIndex:indexPath.section];
    SimiRow *row = [[section rows] objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:row.identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
        if ([row.identifier isEqual:FORGOT_PASS_TEXT_CELL]) {
            CGRect frame = cell.frame;
            frame.origin.x = 15;
            frame.size.width = cell.frame.size.width - 30;
            textFieldEmail = [[UITextField alloc] initWithFrame:frame];
            textFieldEmail.placeholder = SCLocalizedString(@"Email");
            textFieldEmail.keyboardType = UIKeyboardTypeEmailAddress;
            textFieldEmail.autocapitalizationType = UITextAutocapitalizationTypeNone;
            textFieldEmail.autocorrectionType = UITextAutocorrectionTypeNo;
            textFieldEmail.delegate = self;
            [cell addSubview:textFieldEmail];
            //  Liam Update RTL
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                [textFieldEmail setTextAlignment:NSTextAlignmentRight];
            }
            //  End RTL
        }else{
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, cell.frame.size.width - 20, 44)];
            [button setBackgroundImage:[[SimiGlobalVar sharedInstance] imageFromColor:THEME_BUTTON_BACKGROUND_COLOR] forState:UIControlStateNormal];
            [button setTitle:SCLocalizedString(@"Reset my password") forState:UIControlStateNormal];
            [button setTitleColor:THEME_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
            [button.layer setCornerRadius:5.0f];
            [button.layer setMasksToBounds:YES];
            [button setAdjustsImageWhenHighlighted:YES];
            [button setAdjustsImageWhenDisabled:YES];
            button.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
            [button addTarget:self action:@selector(didClickSendButton) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button];
            cell.backgroundColor = [UIColor clearColor];
        }
    }
    for (id obj in cell.subviews){
        if ([NSStringFromClass([obj class]) isEqualToString:@"UITableViewCellScrollView"]){
            UIScrollView *scroll = (UIScrollView *) obj;
            scroll.delaysContentTouches = NO;
            break;
        }
    }
    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textFieldEmail resignFirstResponder];
    return YES;
}

@end
