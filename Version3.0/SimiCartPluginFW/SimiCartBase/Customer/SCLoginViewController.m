//
//  SCLoginViewControllerUpdate.m
//  SimiCartPluginFW
//
//  Created by Axe on 8/6/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCLoginViewController.h"
#import "SimiCustomerModel.h"
#import "SimiResponder.h"
#import "KeychainItemWrapper.h"
#import "SCWebViewController.h"
#import "SCForgotPasswordViewController.h"
#import "SCAppDelegate.h"
#import "SimiCheckbox.h"

@implementation SCLoginViewController
{
    BOOL isSaveAccount;
    NSString *stringPassWord;
    NSString *stringEmail;
    SimiCheckbox *checkBox;
}
@synthesize isLoginInCheckout, textFieldEmail, textFieldPassword, buttonSignIn, btnSignInFacebook,btnRegister,btnHelp;
@synthesize cells = _cells;
@synthesize loginTableView;
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
    [self checkSaveAccount];
    self.navigationItem.title = SCLocalizedString(@"Sign In");
    loginTableView = [[SimiTableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    loginTableView.separatorColor = [UIColor clearColor];
    loginTableView.dataSource = self;
    loginTableView.delegate = self;
    loginTableView.delaysContentTouches = NO;
    loginTableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = loginTableView;
    [self.view setBackgroundColor:THEME_APP_BACKGROUND_COLOR];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [loginTableView addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self setCells:nil];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewDidLoadBefore];
    }
    
    
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewWillAppearBefore:YES];
    }
}

-(void) checkSaveAccount{
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleIdentifier = [NSString stringWithFormat:@"%@", [info objectForKey:@"CFBundleIdentifier"]];
    bundleIdentifier = [NSString stringWithFormat:@"%@_%@",bundleIdentifier,@"saveaccount"];
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:bundleIdentifier accessGroup:nil];
    stringEmail = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    stringPassWord = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    NSString *stringCheckSaveAccount = [wrapper objectForKey:(__bridge id)(kSecAttrDescription)];
    if ([stringCheckSaveAccount isEqualToString:@"1"]) {
        isSaveAccount = YES;
    }
}

#pragma mark setCells
-(void) setCells:(SimiTable *)cells{
    if(cells) _cells = cells;
    else{
        float rowHeight = SCREEN_HEIGHT/16.2142857143f + SCREEN_HEIGHT/37.8333333333f;
        _cells = [SimiTable new];
        SimiSection* section = [_cells addSectionWithIdentifier:LOGIN_SECTION];
        SimiRow* userNameRow = [[SimiRow alloc] initWithIdentifier:LOGIN_USER_NAME height:rowHeight];
        SimiRow* passwordRow = [[SimiRow alloc] initWithIdentifier:LOGIN_PASSWORD height:rowHeight];
        SimiRow* rememberRow = [[SimiRow alloc] initWithIdentifier:LOGIN_REMEMBER_ME height:rowHeight];
        SimiRow* signinRow = [[SimiRow alloc] initWithIdentifier:LOGIN_SIGNIN_BUTTON height:rowHeight];
        SimiRow* registerRow = [[SimiRow alloc] initWithIdentifier:LOGIN_REGISTER height:rowHeight];
        SimiRow* cancelRow = [[SimiRow alloc] initWithIdentifier:LOGIN_CANCEL height:rowHeight];
        [section addRow:userNameRow];
        [section addRow:passwordRow];
        [section addRow:rememberRow];
        [section addRow:signinRow];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"SCLoginViewController_InitCellsAfter" object:_cells userInfo:@{@"controller":self}];
        if(!isLoginInCheckout)
            [section addRow:registerRow];
        else
            [section addRow:cancelRow];
    }
}


-(void) borderView: (UIView*)view width:(float) width{
    [[view layer] setBorderColor:THEME_LINE_COLOR.CGColor];
    [[view layer] setCornerRadius:1.5f];
    [[view layer] setBorderWidth:width];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideKeyboard{
    [self.textFieldEmail resignFirstResponder];
    [self.textFieldPassword resignFirstResponder];
}


- (void)didLogin:(NSNotification *)noti{
    [self removeObserverForNotification:noti];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        if ([noti.name isEqualToString:DidLogin]) {
            NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
            NSString *bundleIdentifier = [NSString stringWithFormat:@"%@", [info objectForKey:@"CFBundleIdentifier"]];
            KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:bundleIdentifier accessGroup:nil];
            [wrapper setObject:self.textFieldPassword.text forKey:(__bridge id)(kSecAttrDescription)];
            bundleIdentifier = [NSString stringWithFormat:@"%@_%@",bundleIdentifier,@"saveaccount"];
            wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:bundleIdentifier accessGroup:nil];
            if (checkBox.checkState == M13CheckboxStateChecked) {
                [wrapper setObject:@"1" forKey:(__bridge id)(kSecAttrDescription)];
                [wrapper setObject:textFieldEmail.text forKey:(__bridge id)(kSecAttrAccount)];
                [wrapper setObject:textFieldPassword.text forKey:(__bridge id)(kSecAttrService)];
            }
            if(self.isLoginInCheckout)
            {
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                    //hainh june 29
                    if (SIMI_SYSTEM_IOS >= 8.0) {
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                    else [self.navigationController popViewControllerAnimated:NO];
                    //end
                }else
                    [self.navigationController popViewControllerAnimated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:PushLoginInCheckout object:nil];
            }
            else
            {
                [self goBackPreviousControllerAnimated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:PushLoginNormal object:nil];
            }
        }
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:SCLocalizedString(responder.responseMessage) delegate:nil cancelButtonTitle:SCLocalizedString(@"OK" ) otherButtonTitles: nil];
        textFieldPassword.text = @"";
        [alertView show];
    }
    [self stopLoadingData];
}

- (void)didClickedbuttonSignIn{
    
    if (checkBox.checkState == M13CheckboxStateUnchecked) {
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        NSString *bundleIdentifier = [NSString stringWithFormat:@"%@", [info objectForKey:@"CFBundleIdentifier"]];
        bundleIdentifier = [NSString stringWithFormat:@"%@_%@",bundleIdentifier,@"saveaccount"];
        KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:bundleIdentifier accessGroup:nil];
        @try {
            [wrapper resetKeychainItem];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    [self.textFieldPassword resignFirstResponder];
    [self.textFieldEmail resignFirstResponder];
    customer = [[SimiCustomerModel alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin:) name:DidLogin object:nil];
    [customer loginWithUserMail:self.textFieldEmail.text password:self.textFieldPassword.text];
    [self startLoadingData];
    [self hideKeyboard];
}

-(void) didClickButtonHelp{
    
    SCForgotPasswordViewController *nextController = [[SCForgotPasswordViewController alloc] init];
    [self.navigationController pushViewController:nextController animated:YES];
}

-(void) didClickButtonRegisterNewAccount{
    SCRegisterViewController *nextController = [[SCRegisterViewController alloc]init];
    nextController.delegate = self;
    if (SIMI_SYSTEM_IOS>=8) {
        [self.navigationController pushViewController:nextController animated:YES];
    }else{
        // May start edited 20151022
        [self.navigationController pushViewController:nextController animated:NO];
        // May end 20151022
    }
    

}

- (void)didClickedButtonCancel{
    if(self.isLoginInCheckout)
    {
        //hainh june 23
        if (SIMI_SYSTEM_IOS >= 8.0) {
            [self dismissViewControllerAnimated:NO completion:nil];
        }
        else {
            //[self.navigationController popViewControllerAnimated:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:NO];
            });
        }
        //end
    }
    else
        [self goBackPreviousControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SCLoginViewController-DidCancel" object:self];
}

- (BOOL)isTextFilled{
    if ((self.textFieldEmail.text == nil) || ([self.textFieldEmail.text isEqualToString:@""]) || ([self.textFieldPassword.text isEqualToString:@""]) || (self.textFieldPassword.text == nil)) {
        self.buttonSignIn.enabled = NO;
        self.buttonSignIn.alpha = 0.5;
        return NO;
    }
    self.buttonSignIn.enabled = YES;
    self.buttonSignIn.alpha = 1;
    return YES;
}

- (void)legalLabelClicked{
    SCWebViewController *privacyPage = [[SCWebViewController alloc] init];
    NSString *privacyURL = [[[[SimiGlobalVar sharedInstance] store] valueForKey:@"store_config"] valueForKeyPath:@"privacy"];
    [privacyPage setUrlPath:privacyURL];
    privacyPage.title = SCLocalizedString(@"Privacy");
    [self.navigationController pushViewController:privacyPage animated:YES];
}


#pragma mark Text Field Delegates
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@" "] && range.location == 0) {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.textFieldEmail) {
        [self.textFieldPassword becomeFirstResponder];
        return NO;
    }else if (![self.textFieldEmail.text isEqualToString:@""]){
        [self didClickedbuttonSignIn];
    }
    return YES;
}

#pragma mark Register View Delegate
- (void)didRegisterWithEmail:(NSString *)email password:(NSString *)password{
    self.textFieldEmail.text = email;
    self.textFieldPassword.text = password;
    self.buttonSignIn.enabled = [self isTextFilled];
}

#pragma mark UITableViewDelegate & UITableViewDataSource
-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{

}

-(UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SimiSection* section = [_cells objectAtIndex:indexPath.section];
    SimiRow* row = [section objectAtIndex:indexPath.row];
    
    float widthCell = 7 *SCREEN_WIDTH/8;
    float heightCell = SCREEN_HEIGHT/16.2142857143f;
    float paddingY = SCREEN_HEIGHT/37.8333333333f/2;
    float paddingX = SCREEN_WIDTH/16;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        float widthTable = (SCREEN_WIDTH*2/3);
         widthCell = 7 *widthTable/8;
         heightCell = widthTable/16.2142857143f;
         paddingY = widthTable/37.8333333333f/2;
         paddingX = widthTable/16;
    }
    
    UIFont* font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
    UITableViewCell* cell;
    if([section.identifier isEqualToString:LOGIN_SECTION]){
        
        if([row.identifier isEqualToString:LOGIN_USER_NAME])
        {
            cell = [tableView dequeueReusableCellWithIdentifier:LOGIN_USER_NAME];
            if(!cell)
            {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LOGIN_USER_NAME];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UIView *accountView = [[UIView alloc] initWithFrame:CGRectMake(paddingX, paddingY, widthCell, heightCell)];
                UIImageView* accountImage = [[UIImageView alloc] initWithFrame:CGRectMake(heightCell/4, heightCell/4, heightCell/2, heightCell/2)];
                accountImage.image = [UIImage imageNamed:@"ic_acc"];
                accountImage.contentMode = UIViewContentModeScaleAspectFill;
                
                
                textFieldEmail = [[UITextField alloc] initWithFrame:CGRectMake(heightCell, 0, widthCell - heightCell, heightCell)];
                textFieldEmail.placeholder = SCLocalizedString(@"Your account");
                textFieldEmail.clearButtonMode = UITextFieldViewModeWhileEditing;
                textFieldEmail.autocorrectionType = UITextAutocorrectionTypeNo;
                textFieldEmail.autocapitalizationType = UITextAutocapitalizationTypeNone;
                textFieldEmail.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                [textFieldEmail setFont:font];
                [textFieldEmail setTextColor:THEME_CONTENT_COLOR];
                textFieldEmail.attributedPlaceholder = [[NSAttributedString alloc]initWithString:SCLocalizedString(@"Your account") attributes:@{NSForegroundColorAttributeName:THEME_CONTENT_PLACEHOLDER_COLOR}];
                [textFieldEmail addTarget:self action:@selector(isTextFilled) forControlEvents:UIControlEventEditingChanged];
                [textFieldEmail setKeyboardType:UIKeyboardTypeEmailAddress];
                if (isSaveAccount && ![stringEmail isEqualToString:@""])
                {
                    textFieldEmail.text = stringEmail;
                }
                [accountView addSubview:accountImage];
                [accountView addSubview:textFieldEmail];
                [self borderView:accountView width:0.5f];
                [cell addSubview:accountView];
            }
        }
        else if([row.identifier isEqualToString:LOGIN_PASSWORD])
        {
            cell = [tableView dequeueReusableCellWithIdentifier:LOGIN_PASSWORD];
            if(!cell)
            {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LOGIN_PASSWORD];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UIView *passView = [[UIView alloc] initWithFrame:CGRectMake(paddingX, paddingY, widthCell, heightCell)];
                UIImageView* passImage = [[UIImageView alloc] initWithFrame:CGRectMake(heightCell/4, heightCell/4, heightCell/2, heightCell/2)];
                passImage.image = [UIImage imageNamed:@"ic_pass"];
                passImage.contentMode = UIViewContentModeScaleAspectFit;
                textFieldPassword = [[UITextField alloc] initWithFrame:CGRectMake(heightCell, 0, widthCell - 2* heightCell, heightCell)];
                textFieldPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
                textFieldPassword.autocorrectionType = UITextAutocorrectionTypeNo;
                textFieldPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
                textFieldPassword.secureTextEntry = YES;
                textFieldPassword.font = font;
                [textFieldPassword setTextColor:THEME_CONTENT_COLOR];
                textFieldPassword.attributedPlaceholder = [[NSAttributedString alloc]initWithString:SCLocalizedString(@"Your password") attributes:@{NSForegroundColorAttributeName:THEME_CONTENT_PLACEHOLDER_COLOR}];
                textFieldPassword.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                textFieldPassword.placeholder = SCLocalizedString(@"Your password");
                if (isSaveAccount && ![stringPassWord isEqualToString:@""]) {
                    textFieldPassword.text = stringPassWord;
                }
                [textFieldPassword addTarget:self action:@selector(isTextFilled) forControlEvents:UIControlEventEditingChanged];
                btnHelp = [[UIButton alloc] initWithFrame:CGRectMake(widthCell - 3*heightCell/4, heightCell/4, heightCell/2, heightCell/2)];
                [btnHelp setImage:[UIImage imageNamed:@"ic_forgot"] forState:UIControlStateNormal];
                [btnHelp addTarget:self action:@selector(didClickButtonHelp) forControlEvents:UIControlEventTouchUpInside];
                
                [passView addSubview:passImage];
                [passView addSubview:textFieldPassword];
                if(!isLoginInCheckout)
                [passView addSubview:btnHelp];
                [self borderView:passView width:0.5f];
                [cell addSubview:passView];
                
            }
        }else if([row.identifier isEqualToString: LOGIN_REMEMBER_ME]){
            cell = [tableView dequeueReusableCellWithIdentifier:LOGIN_REMEMBER_ME];
            if(!cell){
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LOGIN_REMEMBER_ME];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                checkBox = [[SimiCheckbox alloc]initWithTitle:SCLocalizedString(@"Remember me")];
                float checkBoxTextSize = [SCLocalizedString(@"Remember me") sizeWithAttributes:@{NSFontAttributeName: font}].width;
                [checkBox setFrame:CGRectMake(paddingX , paddingY, checkBoxTextSize + 70, heightCell)];
                checkBox.checkAlignment = M13CheckboxAlignmentLeft;
                if (isSaveAccount) {
                    checkBox.checkState = M13CheckboxStateChecked;
                }else
                {
                    checkBox.checkState = M13CheckboxStateUnchecked;
                }
                [cell addSubview:checkBox];
            }
        }else if([row.identifier isEqualToString:LOGIN_SIGNIN_BUTTON]){
            cell = [tableView dequeueReusableCellWithIdentifier:LOGIN_SIGNIN_BUTTON];
            if(!cell){
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LOGIN_SIGNIN_BUTTON];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                buttonSignIn = [[UIButton alloc] initWithFrame:CGRectMake(paddingX, paddingY, widthCell, heightCell)];
                [buttonSignIn setTitle:SCLocalizedString(@"Sign In") forState:UIControlStateNormal];
                [buttonSignIn titleLabel].font = font;
                [buttonSignIn setTitleColor:THEME_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
                buttonSignIn.backgroundColor = THEME_BUTTON_BACKGROUND_COLOR;
                [buttonSignIn titleLabel].textAlignment = NSTextAlignmentCenter;
                [self borderView:buttonSignIn width:0];
                [buttonSignIn addTarget:self action:@selector(didClickedbuttonSignIn) forControlEvents:UIControlEventTouchUpInside];
                buttonSignIn.enabled = [self isTextFilled];
                [cell addSubview:buttonSignIn];
            }
        }else if([row.identifier isEqualToString:LOGIN_REGISTER]){
            cell = [tableView dequeueReusableCellWithIdentifier:LOGIN_REGISTER];
            if(!cell){
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LOGIN_REGISTER];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UIView* registerView = [[UIView alloc] initWithFrame:CGRectMake(paddingX, paddingY, widthCell, heightCell*2)];
                UILabel* lblSuggest = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, widthCell, heightCell)];
                lblSuggest.text = SCLocalizedString(@"Don't have an account?");
                lblSuggest.font = font;
                [lblSuggest setTextColor:THEME_CONTENT_COLOR];
                lblSuggest.textAlignment = NSTextAlignmentCenter;
                btnRegister = [[UIButton alloc] initWithFrame:lblSuggest.frame];
                [btnRegister setBackgroundColor:[UIColor clearColor]];
                [self borderView:btnRegister width:0.5f];
                [btnRegister addTarget:self action:@selector(didClickButtonRegisterNewAccount) forControlEvents:UIControlEventTouchUpInside];
                [registerView addSubview:lblSuggest];
                [registerView addSubview:btnRegister];
                [cell addSubview:registerView];
            }
        }else if([row.identifier isEqualToString:LOGIN_CANCEL]){
            cell = [tableView dequeueReusableCellWithIdentifier:LOGIN_CANCEL];
            if(!cell){
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LOGIN_CANCEL];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UIButton* buttonCancel = [[UIButton alloc] initWithFrame:CGRectMake(paddingX, paddingY, widthCell, heightCell)];
                [buttonCancel setTitle:SCLocalizedString(@"Cancel") forState:UIControlStateNormal];
                [buttonCancel titleLabel].font = font;
                buttonCancel.backgroundColor = [UIColor lightGrayColor];
                [buttonCancel titleLabel].textAlignment = NSTextAlignmentCenter;
                [self borderView:buttonCancel width:0];
                [buttonCancel addTarget:self action:@selector(didClickedButtonCancel) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:buttonCancel];
            }
        }else{
        if(!cell) cell = [UITableViewCell new];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"SCLoginViewController_InitCellAfter" object:cell userInfo:@{@"indexPath":indexPath}];
        }
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[_cells objectAtIndex:section] count];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return ((SimiRow*)[[_cells objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]).height;
}


@end
