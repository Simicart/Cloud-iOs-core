//
//  SCAccountViewController.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/3/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SCAccountViewController.h"
#import "SCOrderHistoryViewController.h"
#import "SCAddressViewController.h"
#import "SCProfileViewController.h"
#import "SCChangePasswordViewController.h"
#import "SimiRow.h"
#import "SimiSection.h"

@interface SCAccountViewController ()

@end

@implementation SCAccountViewController

@synthesize tableViewAccount;

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
    [self initView];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewDidLoadBefore];
    }
    self.navigationItem.title = SCLocalizedString(@"Account");
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewWillAppearBefore:YES];
    }
}

- (void)setCells:(NSMutableArray *)cells
{
    if (cells) {
        _cells = cells;
    }else{
        _cells = [[NSMutableArray alloc] init];
        SimiSection *section = [[SimiSection alloc] initWithIdentifier:ACCOUNT_MAIN_SECTION];
        
        SimiRow *profile = [[SimiRow alloc]initWithIdentifier:ACCOUNT_PROFILE_ROW height:55];
        profile.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        profile.title = SCLocalizedString(@"Profile");
        profile.image = [UIImage imageNamed:@"ic_acc"];
        profile.sortOrder = 100;
        [section addObject:profile];
        
        SimiRow *password = [[SimiRow alloc] initWithIdentifier:ACCOUNT_CHANGE_PASSWORD_ROW height:55];
        password.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        password.title = SCLocalizedString(@"Change your password");
        password.image = [UIImage imageNamed:@"ic_password"];
        password.sortOrder = 200;
        [section addObject:password];
        
        SimiRow *address = [[SimiRow alloc]initWithIdentifier:ACCOUNT_ADDRESS_ROW height:55];
        address.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        address.title = SCLocalizedString(@"Address Book");
        address.image = [UIImage imageNamed:@"ic_address_book"];
        address.sortOrder = 300;
        [section addObject:address];
        
        SimiRow *oderHistory  = [[SimiRow alloc]initWithIdentifier:ACCOUNT_ORDERS_ROW height:55];
        oderHistory.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        oderHistory.title = SCLocalizedString(@"Order History");
        oderHistory.image = [UIImage imageNamed:@"ic_history_den"];
        oderHistory.sortOrder = 400;
        [section addObject:oderHistory];
        
        SimiRow *signOut = [[SimiRow alloc]initWithIdentifier:ACCOUNT_SIGNOUT_ROW height:55];
        signOut.accessoryType = UITableViewCellAccessoryNone;
        signOut.title = SCLocalizedString(@"Sign Out");
        signOut.image = [UIImage imageNamed:@"ic_log_out"];
        signOut.sortOrder = 500;
        [section addObject:signOut];
        
        [_cells addObject:section];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SCAccountViewController-InitCellsAfter" object:_cells];
    [tableViewAccount reloadData];
}

- (void)initView
{
    [self setCells:nil];
    tableViewAccount = [[SimiTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [tableViewAccount setFrame:CGRectMake(0, 0, SCREEN_WIDTH*2/3, SCREEN_HEIGHT*2/3)];
    }
    tableViewAccount.dataSource = self;
    tableViewAccount.delegate = self;
    [tableViewAccount setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:tableViewAccount];
}

- (void)viewWillAppearAfter:(BOOL)animated
{
    [super viewWillAppearAfter:animated];
    [tableViewAccount deselectRowAtIndexPath:[tableViewAccount indexPathForSelectedRow] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _cells.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SimiSection *simiSection = [_cells objectAtIndex:section];
    return simiSection.rows.count;

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:simiRow.identifier];
    
   [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedAccountCell-Before" object:cell userInfo:@{@"self": self, @"table": tableView, @"indexPath": indexPath}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return cell;
    }
    float sizeIcon = 25;
    float paddingLeft = 15;
    float paddingRight = 30;
    float spaceIconAndName = 20;
    //Gin edit
    float oriXTitle =paddingLeft + sizeIcon + spaceIconAndName;
    float widthName = SCREEN_WIDTH - paddingLeft - paddingRight - sizeIcon - spaceIconAndName;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        widthName = SCREEN_WIDTH*2/3 - paddingLeft - paddingRight - sizeIcon - spaceIconAndName;
        if([[SimiGlobalVar sharedInstance] isReverseLanguage]){
             paddingLeft = SCREEN_WIDTH *2/3 - paddingRight - sizeIcon;
             oriXTitle = paddingLeft - widthName - spaceIconAndName;
         }
    }else{
        if([[SimiGlobalVar sharedInstance] isReverseLanguage]){
            paddingLeft = SCREEN_WIDTH - paddingRight - sizeIcon;
            widthName = SCREEN_WIDTH  - paddingRight - sizeIcon - spaceIconAndName;
            oriXTitle = paddingLeft - widthName - spaceIconAndName;
        }
    }
   //end
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(paddingLeft, (simiRow.height - sizeIcon)/2, sizeIcon, sizeIcon)];
        [image setImage:simiRow.image];
        [cell addSubview:image];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(oriXTitle, (simiRow.height - 20)/2, widthName, 20)];
        label.text = simiRow.title;
        [label setFont:[UIFont fontWithName: THEME_FONT_NAME size:15]];
        [label setTextColor:THEME_CONTENT_COLOR];
        [cell addSubview:label];
        //Gin edit
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [cell.textLabel setTextAlignment:NSTextAlignmentRight];
            [label setTextAlignment:NSTextAlignmentRight];
        }
       //end
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedAccountCell-After" object:cell userInfo:@{@"self": self, @"table": tableView, @"indexPath": indexPath}];
    cell.accessoryType = simiRow.accessoryType;
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimiSection *section = [_cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    return row.height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [(SimiSection *)[_cells objectAtIndex:section] headerTitle];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [(SimiSection *)[_cells objectAtIndex:section] footerTitle];
}

#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SimiSection *section = [_cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectAccountCellAtIndexPath" object:row userInfo:@{@"self": self, @"tableView": tableView, @"indexPath": indexPath}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    if ([row.identifier isEqualToString:ACCOUNT_PROFILE_ROW]) {
        SCProfileViewController *profileController = [[SCProfileViewController alloc] init];
        [self.navigationController pushViewController:profileController animated:YES];
    }else if([row.identifier isEqualToString:ACCOUNT_CHANGE_PASSWORD_ROW]){
        SCChangePasswordViewController* changePasswordVC = [SCChangePasswordViewController new];
        [self.navigationController pushViewController:changePasswordVC animated:YES];
    }
    else if ([row.identifier isEqualToString:ACCOUNT_ADDRESS_ROW]) {
        SCAddressViewController *addressController = [[SCAddressViewController alloc] init];
        addressController.isGetOrderAddress = NO;
        addressController.enableEditing = YES;
        [self.navigationController pushViewController:addressController animated:YES];
    } else if ([row.identifier isEqualToString:ACCOUNT_ORDERS_ROW]) {
        SCOrderHistoryViewController *orderController = [[SCOrderHistoryViewController alloc] init];
        [self.navigationController pushViewController:orderController animated:YES];
    } else if ([row.identifier isEqualToString:ACCOUNT_SIGNOUT_ROW]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DidLogout object:nil];
        [self goBackPreviousControllerAnimated:YES];
    }
}

@end
