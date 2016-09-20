//
//  LoyaltySettingViewController.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 1/21/15.
//  Copyright (c) 2015 Magestore. All rights reserved.
//

#import <SimiCartBundle/SimiTable.h>
#import <SimiCartBundle/SimiRow.h>
#import "LoyaltySettingViewController.h"
#import "LoyaltyViewController.h"

@interface LoyaltySettingViewController ()
@property (strong, nonatomic) SimiTable *table;
@property (strong, nonatomic) LoyaltyModel *settings;
@end

@implementation LoyaltySettingViewController
@synthesize tableView = _tableView, model = _model;
@synthesize table = _table, settings = _settings;

- (void)viewDidLoadBefore
{
    [self setToSimiView];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewDidLoadBefore];
    }else
        [self configureNavigationBarOnViewDidLoad];
    self.title = SCLocalizedString(@"Settings");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveSettings)];
    
    // Init Table View Data
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    // Init Settings Data
    _settings = [LoyaltyModel new];
    if ([_model objectForKey:@"is_notification"]) {
        [_settings setValue:[_model objectForKey:@"is_notification"] forKey:@"is_notification"];
    }
    if ([_model objectForKey:@"expire_notification"]) {
        [_settings setValue:[_model objectForKey:@"expire_notification"] forKey:@"expire_notification"];
    }
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    //Ravi
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _tableView.frame = CGRectMake(0, SCREEN_HEIGHT/3, SCREEN_WIDTH*2/3, SCREEN_HEIGHT*2/3);
    }else{
        _tableView.frame = self.view.bounds;
        [super viewWillAppearBefore:YES];
    }
    //End
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)saveSettings
{
    [self startLoadingData];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSaveSettings:) name:@"SavedLoyaltySettings" object:nil];
    [_settings saveSettings];
}

- (void)didSaveSettings:(NSNotification *)noti
{
    [self stopLoadingData];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        LoyaltyViewController *back = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
        back.skipReloadData = NO;
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:responder.responseMessage delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
    }
    [self removeObserverForNotification:noti];
}

- (SimiTable *)table
{
    if (_table != nil) {
        return _table;
    }
    _table = [SimiTable new];
    
    SimiSection *section = [_table addSectionWithIdentifier:LOYALTY_EMAIL_NOTI headerTitle:SCLocalizedString(@"Email Subscriptions") footerTitle:SCLocalizedString(@"Subscribe to receive updates on your point balance")];
    [[section addRowWithIdentifier:LOYALTY_EMAIL_NOTI height:44 sortOrder:0] setTitle:SCLocalizedString(@"Point Balance Update")];
    
    section = [_table addSectionWithIdentifier:LOYALTY_EMAIL_EXP headerTitle:nil footerTitle:SCLocalizedString(@"Subscribe to receive notifications of expiring points in advance")];
    [[section addRowWithIdentifier:LOYALTY_EMAIL_EXP height:44 sortOrder:0] setTitle:SCLocalizedString(@"Expired Point Transaction")];
    
    return _table;
}

#pragma mark - Table view datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.table count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.table objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self.table objectAtIndex:section] headerTitle];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [[self.table objectAtIndex:section] footerTitle];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimiSection *section = [self.table objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if ([section.identifier isEqualToString:LOYALTY_EMAIL_NOTI]) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISwitch *switcher = [UISwitch new];
        switcher.tag = (NSInteger)LOYALTY_EMAIL_NOTI;
        switcher.on = [[_settings objectForKey:@"is_notification"] boolValue];
        [switcher addTarget:self action:@selector(toggleSwitcher:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switcher;
    } else if ([section.identifier isEqualToString:LOYALTY_EMAIL_EXP]) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISwitch *switcher = [UISwitch new];
        switcher.tag = (NSInteger)LOYALTY_EMAIL_EXP;
        switcher.on = [[_settings objectForKey:@"expire_notification"] boolValue];
        [switcher addTarget:self action:@selector(toggleSwitcher:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switcher;
    }
    cell.textLabel.text = row.title;
    return cell;
}

#pragma mark - Table View delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[[self.table objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] height];
}

#pragma mark - Update settings
- (void)toggleSwitcher:(UISwitch *)sender
{
    if (sender.tag == (NSInteger)LOYALTY_EMAIL_NOTI) {
        [_settings setValue:[NSNumber numberWithBool:sender.on] forKey:@"is_notification"];
    } else if (sender.tag == (NSInteger)LOYALTY_EMAIL_EXP) {
        [_settings setValue:[NSNumber numberWithBool:sender.on] forKey:@"expire_notification"];
    }
}

@end
