//
//  SCSettingViewController.m
//  SimiCartPluginFW
//
//  Created by Axe on 8/8/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCSettingViewController.h"
#import "SCSettingCell.h"
#import "SimiSection.h"
#import "SCStoreViewController.h"
#import "SimiStoreModelCollection.h"
#import "SimiCurrencyModelCollection.h"
#import "SimiCurrencyModel.h"
#import "SCAppDelegate.h"
#import "SimiModelCollection+CMS.h"

@implementation SCSettingViewController
{
    SimiStoreModelCollection *stores;
    SimiStoreModel *currentStore;
    SimiCurrencyModelCollection *currencies;
    SimiCurrencyModel *currentCurrency;
}
-(id) init{
    self = [super init];
    if(self){
           }
    return self;
}


-(void) viewDidLoadBefore{
    _lblLang = [UILabel new];
    _lblLang.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2];
    _lblLang.textColor = [UIColor lightGrayColor];
    _tableViewSetting = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [_tableViewSetting setBackgroundColor:[UIColor clearColor]];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [_tableViewSetting setFrame:CGRectMake(0, 0, SCREEN_WIDTH *2/3, SCREEN_HEIGHT *2/3)];
    }
    _tableViewSetting.delegate = self;
    _tableViewSetting.dataSource = self;
    [self.view addSubview:_tableViewSetting];
    stores = [SimiGlobalVar sharedInstance].storeModelCollection;
    if (stores == nil) {
        [self getStoreCollection];
    }
    if (currencies == nil) {
        [self getCurrencyCollection];
    }
   
    [self setCells:nil];
    if (currentStore == nil) {
        currentStore = [[SimiGlobalVar sharedInstance] store];
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewDidLoadBefore];
    }
    self.navigationItem.title = SCLocalizedString(@"Setting");
}
- (void)viewWillAppearBefore:(BOOL)animated
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewWillAppearBefore:YES];
    }
}

#pragma mark Table View Data Source
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [_cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if([row.identifier isEqualToString:LANGUAGE_CELL]){
        SCStoreViewController *storeViewController = [[SCStoreViewController alloc] init];
        [storeViewController setDataType:@"store"];
        [storeViewController setFixedData: stores];
        storeViewController.navigationItem.title = SCLocalizedString(@"Language");
        [storeViewController setSelectedName:[[currentStore valueForKey:@"store_config"] valueForKey:@"store_name"]];
        [storeViewController setSelectedId:[[currentStore valueForKey:@"store_config"] valueForKey:@"store_id"]];
        storeViewController.delegate = self;
        [self.navigationController pushViewController:storeViewController animated:YES];
    }else if ([row.identifier isEqualToString:APP_SETTING_CELL])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }else if ([row.identifier isEqualToString:CURRENCY_CELL])
    {
        SCStoreViewController *storeViewController = [[SCStoreViewController alloc] init];
        [storeViewController setDataType:@"currency"];
        [storeViewController setFixedData: currencies];
        storeViewController.navigationItem.title = SCLocalizedString(@"Currency");
        NSString *selectedName = @"";
        for (SimiCurrencyModel *currencyModel in currencies) {
            if ([[currencyModel valueForKey:@"currency_code"] isEqualToString:[[currentStore valueForKey:@"store_config"] valueForKey:@"currency_code"]]) {
                selectedName = [currencyModel valueForKey:@"currency_name"];
                break;
            }
        }
        [storeViewController setSelectedName:selectedName];
        storeViewController.delegate = self;
        [self.navigationController pushViewController:storeViewController animated:YES];
    }
}
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [_cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    return row.height;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[_cells objectAtIndex:0] count];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [_cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    SCSettingCell* cell;
    cell = [tableView dequeueReusableCellWithIdentifier:row.identifier];
    if(cell == nil){
        cell = [[SCSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier withRow:row];
        cell.accessoryType = row.accessoryType;
    }
    if (cell == nil) {
        return [UITableViewCell new];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}



-(void) setCells:(SimiTable *)cells{
    if(cells) _cells = cells;
    else{
        _cells = [[SimiTable alloc] init];
        
        SimiSection *section = [[SimiSection alloc] init];
        if (stores.count > 1) {
            SimiRow* langRow = [[SimiRow alloc] initWithIdentifier:LANGUAGE_CELL height:55];
            langRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            langRow.title = SCLocalizedString(@"Language");
            langRow.image = [UIImage imageNamed:@"ic_lang_den"];
            [section addRow:langRow];
        }
        
        if (currencies.count >= 1) {
            SimiRow* currencyRow = [[SimiRow alloc] initWithIdentifier:CURRENCY_CELL height:55];
            currencyRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            currencyRow.title = SCLocalizedString(@"Currency");
            currencyRow.image = [UIImage imageNamed:@"ic_curency"];
            [section addRow:currencyRow];
        }
        
        if (SIMI_SYSTEM_IOS >= 8) {
            SimiRow* appSettingRow = [[SimiRow alloc] initWithIdentifier:APP_SETTING_CELL height:55];
            appSettingRow.accessoryType = UITableViewCellAccessoryNone;
            appSettingRow.title = SCLocalizedString(@"App Setting");
            appSettingRow.image = [UIImage imageNamed:@"ic_app_setting"];
            [section addRow:appSettingRow];
        }
        
        [_cells addObject:section];
    }
    [self.tableViewSetting reloadData];
}

#pragma mark SCStoreViewDelegate

- (void)didSelectDataWithID:(NSString *)dataID dataCode:(NSString *)dataCode dataName:(NSString *)dataName dataType:(NSString *)dataType
{
    if ([dataType isEqualToString:@"store"]) {
        if (![dataID isEqualToString:[[currentStore valueForKey:@"store_config"] valueForKey:@"store_id"]]) {
            [[SimiStoreModel new]saveToLocal:dataID];
            [(SCAppDelegate *)[[UIApplication sharedApplication] delegate] switchLanguage];
        }
        return;
    }
    
    if ([dataType isEqualToString:@"currency"]) {
        if (![dataCode isEqualToString:[[currentStore valueForKey:@"store_config"] valueForKey:@"currency_code"]]) {
            if (currentCurrency == nil) {
                currentCurrency = [SimiCurrencyModel new];
            }
            [currentCurrency saveToLocal:dataCode];
            [(SCAppDelegate *)[[UIApplication sharedApplication] delegate] switchLanguage];
            [self startLoadingData];
        }
    }
}

#pragma mark Get Store Collection
- (void)getStoreCollection
{
    stores = [SimiStoreModelCollection new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetStoreCollection:) name:@"DidGetStoreCollection" object:stores];
    [stores getStoreCollection];
    [self startLoadingData];
}

- (void)didGetStoreCollection:(NSNotification*)noti
{
    [self stopLoadingData];
    if ([noti.name isEqualToString:@"DidGetStoreCollection"]) {
        [[NSNotificationCenter defaultCenter]removeObserverForNotification:noti];
        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        if ([responder.status isEqualToString:@"SUCCESS"]) {
            [SimiGlobalVar sharedInstance].storeModelCollection = noti.object;
            [self setCells:nil];
        }
    }
}

#pragma mark Get Currency Collection
- (void)getCurrencyCollection
{
    [self startLoadingData];
    currencies = [SimiCurrencyModelCollection new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCurrencyCollection:) name:@"DidGetCurrencyCollection" object:currencies];
    [currencies getCurrencyCollection];
}

- (void)didGetCurrencyCollection:(NSNotification*)noti
{
    [self stopLoadingData];
    if ([noti.name isEqualToString:@"DidGetCurrencyCollection"]) {
        [[NSNotificationCenter defaultCenter]removeObserverForNotification:noti];
        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        if ([responder.status isEqualToString:@"SUCCESS"]) {
            for (SimiCurrencyModel* currencyModel in currencies) {
                [currencyModel setValue:[currencyModel valueForKey:@"title"] forKey:@"currency_name"];
                [currencyModel setValue:[currencyModel valueForKey:@"value"] forKey:@"currency_code"];
            }
            [SimiGlobalVar sharedInstance].currencyModelCollection = currencies;
            [self setCells:nil];
        }
    }
}
@end


