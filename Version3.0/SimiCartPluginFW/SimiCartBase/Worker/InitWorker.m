//
//  InitWorker.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 1/3/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "InitWorker.h"
#import "SimiNetworkManager.h"
#import "KeychainItemWrapper.h"
#import "SCAppDelegate.h"
#import "SCCartViewController.h"
#import "SimiPluginModelCollection.h"
#import "SimiAppModel.h"
#import "SCWebViewController.h"
#import "UIImageView+WebCache.h"

#import "SCCategoryViewController.h"
#import "SCProductListViewController.h"
#import "SoundEffect.h"
#import "SimiOrderModel.h"
#import "UILabelDynamicSize.h"
#import "SimiAddressModelCollection.h"
#import "SimiCurrencyModelCollection.h"
#import "SCThemeWorker.h"
#import "SCProductViewControllerPad.h"
#import "SimiCacheData.h"

#define ALERTWIDTH UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone? 300:520
#define HEIGHT_TITLE UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone? 30:40
#define HEIGHT_ALERTCONTENT UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone? 200:100
#define TITLE_FONTSIZE UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone? 15:20
#define MESSAGE_FONTSIZE UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone? 13:18
#define DISTANCE_OTHER_CONTENT 15;

@implementation InitWorker{
    SimiPluginModelCollection *activePlugins;
    NSMutableArray *observers;
    UIImageView *loadingView;
    UIWindow *window;
    NSDictionary *notiData;
    
    NSString *url;
    UIView *contentAlertView;
    UILabel *lblAlertTitle;
    UILabel *lblAlertContent;
    CLLocationManager *clLocationManager;
    float currentLatitude;
    float currentLongitude;
    BOOL isReceiveRemoteNotification; //Check receive remote notification with _rootController is nil
    BOOL isShowPopup; //Check xem popup hien co show hay khong?
    
    NSString *token;
}

@synthesize storeConfigFilePath, pluginList;

#pragma mark Main Init
- (id)init{
    self = [super init];
    if (self) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        [self addInitWorkerObservers];
        [self setAppSettings];
        [self loadingViewFade];
        [self initLogin];
        
        clLocationManager = [CLLocationManager new];
        clLocationManager.delegate = self;
        if (SIMI_SYSTEM_IOS >= 8.0) {
            [clLocationManager requestAlwaysAuthorization];
        }
        currentLatitude = 0;
        currentLongitude = 0;
        [clLocationManager startUpdatingLocation];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didCheckoutSuccess:) name:@"DidCheckOut-Success" object:nil];
    }
    return self;
}

#pragma mark Setting App & Init Worker
- (void)setAppSettings{
    // Set the version default
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *buildVersion = [info objectForKey:@"CFBundleVersion"];
    NSString *shortBuildVersion;
    @try
    {
        shortBuildVersion = [buildVersion stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""];
    }
    @catch(NSException *ex)
    {
        shortBuildVersion = @"";
    }
    NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[version stringByAppendingString:[NSString stringWithFormat:@" (%@)", shortBuildVersion]] forKey:@"app_version"];
    [defaults synchronize];
}

- (void)addInitWorkerObservers{
    //Add self as an observer for Login/Logout event
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin:) name:DidLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogout:) name:DidLogout object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProfile:) name:DidGetProfile object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetAllDataAtHome:) name:@"DidGetAllDataAtHome" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationDidFinishLaunching" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationDidRegisterForRemote" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationDidReceiveNotificationFromServer" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationWillSwitchLanguage" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AskForLocationPermision" object:nil userInfo:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getStoreConfig) name:@"SimiFormatter-MissLocale" object:nil];
}

- (void)applyTheme{
    //Set Theme
    window.backgroundColor = [UIColor whiteColor];
    if (SIMI_SYSTEM_IOS >= 7) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [[UINavigationBar appearance] setBarTintColor:THEME_COLOR];
        [[UITabBar appearance] setTintColor:THEME_COLOR];
        [[UISearchBar appearance] setTintColor:THEME_COLOR];
        [[UIActivityIndicatorView appearance] setColor:THEME_COLOR];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    }
}

#pragma mark Init Login, Plugin, Root Controller, Plugin
- (void)initLogin{
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleIdentifier = [NSString stringWithFormat:@"%@", [info objectForKey:@"CFBundleIdentifier"]];
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:bundleIdentifier accessGroup:nil];
    NSString *email = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [wrapper objectForKey:(__bridge id)(kSecAttrDescription)];
    NSString *stateLogin = [wrapper objectForKey:(__bridge id)(kSecAttrLabel)];
    NSString *name = [wrapper objectForKey:(__bridge id)(kSecAttrComment)];
    if (email.length > 0) {
        SimiCustomerModel *customer = [[SimiCustomerModel alloc] init];
        if ([stateLogin isEqualToString:@"loginwithfacebook"] && name) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AutoLoginWithFacebook" object:email userInfo:@{@"name":name}];
            [self getPlugins];
            [self saveCurrency];
        }else
        {
            self.isFirstGetActivePlugins = YES;
            [customer loginWithUserMail:email password:password];
        }
    }else{
        [self getPlugins];
        [self saveCurrency];
        [[SimiGlobalVar sharedInstance] setIsLogin:NO];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if ([userDefaults valueForKey:@"quoteId"]) {
            [SimiGlobalVar sharedInstance].quoteId = [userDefaults valueForKey:@"quoteId"];
        }
    }
}

- (UIViewController *)initializeRootController{
    if (_rootController == nil) {
        _rootController = [[UITabBarController alloc] init];
        id obj = nil;
        obj = [SCThemeWorker sharedInstance];
        if (SIMI_DEVELOPMENT_ENABLE) {
            id zaraThemeAvailable = NSClassFromString(@"ZaraThemeAvailable");
            id matrixThemeAvailable = NSClassFromString(@"MatrixThemeAvailable");
            if (ZTHEME_ENABLE && zaraThemeAvailable != nil) {
                [SimiGlobalVar sharedInstance].themeUsing = ThemeShowZTheme;
            }else if (SIMI_THEME_ENABLE && matrixThemeAvailable) {
                [SimiGlobalVar sharedInstance].themeUsing = ThemeShowMatrixTheme;
            }else
            {
                [SimiGlobalVar sharedInstance].themeUsing = ThemeShowDefault;
            }
        }else
        {
            if ([[[SimiGlobalVar sharedInstance].appConfigure valueForKey:@"layout"] isEqualToString:@"zara"]) {
                [SimiGlobalVar sharedInstance].themeUsing = ThemeShowZTheme;
            }else if ([[[SimiGlobalVar sharedInstance].appConfigure valueForKey:@"layout"] isEqualToString:@"matrix"]) {
                [SimiGlobalVar sharedInstance].themeUsing = ThemeShowMatrixTheme;
            }else{
                [SimiGlobalVar sharedInstance].themeUsing = ThemeShowDefault;
            }
        }
    }
    return _rootController;
}

- (void)initializePlugins{
    NSString *path = [[NSBundle mainBundle] resourcePath];
    NSString *suffix = @".plist";
    NSString *prefix = @"plugin-";
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *directoryAndFileNames = [fm contentsOfDirectoryAtPath:path error:&error];
    NSArray *pluginFileNames = [directoryAndFileNames filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(SELF CONTAINS[c] %@) AND (SELF ENDSWITH[c] %@)", prefix, suffix]];
    pluginList = [[NSMutableArray alloc] init];
    NSMutableSet *newSet = [[NSMutableSet alloc] init];
    NSString *pluginString = @"";
    
    for (SimiModel *plugin in activePlugins) {
        pluginString = [pluginString stringByAppendingString:[NSString stringWithFormat:@"%@|", [plugin valueForKey:@"sku"]]];
    }
    
    //Read Plugins
    if (SIMI_DEVELOPMENT_ENABLE) {
        for (NSString *pluginFileName in pluginFileNames) {
            NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], pluginFileName]];
            NSArray *value = [dict valueForKey:@"Observers"];
            [newSet addObjectsFromArray:value];
        }
    }else{
        for (NSString *pluginFileName in pluginFileNames) {
            NSString *pluginName = [pluginFileName substringWithRange:NSMakeRange(prefix.length, pluginFileName.length - prefix.length - suffix.length)];
            if ([pluginString rangeOfString:pluginName].location != NSNotFound) {
                NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], pluginFileName]];
                NSArray *value = [dict valueForKey:@"Observers"];
                [newSet addObjectsFromArray:value];
            }
        }
    }
    
    [pluginList addObjectsFromArray:[newSet allObjects]];
    observers = [[NSMutableArray alloc] init];
    for (id plugin in pluginList) {
        id obj = [NSClassFromString(plugin) new];
        if (obj != nil){
            [observers addObject:obj];
        }
    }
    if (SIMI_DEBUG_ENABLE) {
        NSLog(@"Observers: %@", observers);
    }
}

#pragma mark Get Data
- (void)getPlugins{
    if (!self.isGetPlugins) {
        self.isGetPlugins = YES;
        if (activePlugins == nil) {
            activePlugins = [[SimiPluginModelCollection alloc] init];
        }
        if ([SimiGlobalVar sharedInstance].themeUsing == ThemeShowZTheme) {
            [self getCountryCollection];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidInit" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetPlugins:) name:DidGetActivePlugins object:activePlugins];
//        [activePlugins getActivePluginsWithParams:nil];
    }
}

- (void)saveCurrency
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libDir = [paths objectAtIndex:0];
    NSString *currencyConfigFilePath = [libDir stringByAppendingPathComponent:@"CurrencyConfig.plist"];
    NSFileManager *fileMan = [NSFileManager defaultManager];
    if ([fileMan fileExistsAtPath:currencyConfigFilePath]) {
        NSDictionary *currencyConfig = [[NSDictionary alloc] initWithContentsOfFile:currencyConfigFilePath];
        if ([currencyConfig valueForKey:@"currency_code"]) {
            SimiCurrencyModel *currencyModel = [SimiCurrencyModel new];
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didSaveCurrency:) name:@"DidSaveCurrency" object:nil];
            [currencyModel saveCurrency:@{@"currency":[currencyConfig valueForKey:@"currency_code"]}];
            return;
        }
    }
    [self getStoreConfig];
    [self getAppConfig];
}

- (void)didSaveCurrency:(NSNotification*)noti
{
    if ([noti.name isEqualToString:@"DidSaveCurrency"]) {
        [self removeObserverForNotification:noti];
        [self getStoreConfig];
        [self getAppConfig];
    }
}

- (void)getStoreConfig{
    if (!self.isGetStoreConfig) {
        self.isGetStoreConfig = YES;
        SimiStoreModel *store = [[SimiStoreModel alloc] init];
        [store getStoreWithStoreId:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetStoreConfig:) name:DidGetStore object:store];
    }
}

- (void)getAppConfig
{
    SimiStoreModel *appConfigure = [SimiStoreModel new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetThemeConfigure:) name:DidGetThemeConfigure object:appConfigure];
    [appConfigure getThemeConfigure];
}

#pragma mark Did Receive Notification

- (void)didGetPlugins:(NSNotification*)noti
{
    self.didGetPlugins = YES;
    [self gotoHome];
    [self removeObserverForNotification:noti];
}

- (void)didGetStoreConfig:(NSNotification*)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    self.didGetStoreConfig = YES;
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        SimiStoreModel *store = noti.object;
        [[SimiGlobalVar sharedInstance] setStore:store];
        [[SimiGlobalVar sharedInstance] setIsReverseLanguage:[[[store valueForKey:@"store_config"] valueForKey:@"is_rtl"]boolValue]];
        [SimiGlobalVar sharedInstance].isCloudVersion = YES;
        NSString *useStore = @"0";
        useStore = [[store valueForKey:@"store_config"] valueForKey:@"use_store"];
        NSString *storeCode = [[store valueForKey:@"store_config"] valueForKey:@"store_code"];
        if([useStore boolValue]){
            NSArray *splitURL = [kBaseURL componentsSeparatedByString:@"//"];
            NSString *splitURLend = splitURL[1];
            NSMutableArray *splitURL1 = [NSMutableArray arrayWithArray:[splitURLend componentsSeparatedByString:@"/"]];
            if(![splitURL1[splitURL1.count-2] isEqualToString:storeCode] && storeCode != nil){
                [splitURL1 replaceObjectAtIndex:splitURL1.count-2 withObject:storeCode];
                splitURLend = [splitURL1 componentsJoinedByString:@"/"];
                kBaseURL = [[splitURL[0] stringByAppendingString:@"//"]stringByAppendingString:splitURLend];
            }
        }
    }
    [self gotoHome];
    [self removeObserverForNotification:noti];
}

- (void)didGetThemeConfigure:(NSNotification*)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    self.didGetAppConfig = YES;
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        SimiStoreModel *appConfigure = noti.object;
        [[SimiGlobalVar sharedInstance] setAppConfigure:appConfigure];
    }
    [self gotoHome];
    [self removeObserverForNotification:noti];
}

- (void)gotoHome
{
    if (self.didGetStoreConfig && self.didGetAppConfig) {
        [self stoploadingViewFade];
        [self initializeRootController];
        [self initializePlugins];
        if ([SimiGlobalVar sharedInstance].themeUsing == ThemeShowZTheme) {
            [self getCountryCollection];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedRootController" object:_rootController];
        window.rootViewController = _rootController;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidInit" object:nil];
    }
}

- (void)didGetAllDataAtHome:(NSNotification*)noti
{
    if ([SimiGlobalVar sharedInstance].themeUsing != ThemeShowZTheme) {
        [self getCountryCollection];
    }
    [self removeObserverForNotification:noti];
}

- (void)didLogin:(NSNotification*)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        [[SimiCacheData sharedInstance] renewData];
        SimiCustomerModel *customer = noti.object;
        @try {
            [[SimiGlobalVar sharedInstance] setCustomer:customer];
            [[SimiGlobalVar sharedInstance] setIsLogin: YES];
            [SimiGlobalVar sharedInstance].isNeedReloadAddressBookCollection = YES;
            [SimiGlobalVar sharedInstance].needGetDownloadItems = YES;
        }
        @catch (NSException *exception) {
            
        }
        
        //Store username in Keychain
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        NSString *bundleIdentifier = [NSString stringWithFormat:@"%@", [info objectForKey:@"CFBundleIdentifier"]];
        KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:bundleIdentifier accessGroup:nil];
        [wrapper setObject:@"SimiCart" forKey:(__bridge id)(kSecAttrService)];
        [wrapper setObject:[customer valueForKey:@"email"] forKey:(__bridge id)(kSecAttrAccount)];
    }
    if (self.isFirstGetActivePlugins) {
        [self getPlugins];
        [self saveCurrency];
        self.isFirstGetActivePlugins = NO;
    }
}

- (void)didLogout:(NSNotification*)noti
{
    //Remove username and password in Keychain
//    SimiCustomerModel *customer = noti.object;
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleIdentifier = [NSString stringWithFormat:@"%@", [info objectForKey:@"CFBundleIdentifier"]];
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:bundleIdentifier accessGroup:nil];
    [wrapper resetKeychainItem];
    [[SimiGlobalVar sharedInstance] setCustomer:nil];
    [[SimiGlobalVar sharedInstance] setIsLogin: NO];
    [[SimiGlobalVar sharedInstance] setQuoteId:nil];
    [SimiGlobalVar sharedInstance].cart = nil;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults valueForKey:@"quoteId"]) {
        [userDefaults setValue:@"" forKey:@"quoteId"];
        [userDefaults synchronize];
    }
    [[SimiCacheData sharedInstance] renewData];
}

- (void)didGetProfile:(NSNotification*)noti
{
    SimiCustomerModel *customer = noti.object;
    [[SimiGlobalVar sharedInstance] setCustomer:customer];
}

- (void)didReceiveNotification:(NSNotification *)noti{
    if ([noti.name isEqualToString:@"ApplicationDidFinishLaunching"]) {
#pragma mark ApplicationDidFinishLaunching
        //Let the device know receive push notification
        if([[UIDevice currentDevice].systemVersion floatValue] >= 8)
        {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        else
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
        
        NSDictionary *launchOptions = [noti.userInfo valueForKey:@"options"];
        notiData = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        [self handleNotificationFromServer];
        [self removeObserverForNotification:noti];
    }else if ([noti.name isEqualToString:@"ApplicationDidRegisterForRemote"]){
#pragma mark ApplicationDidRegisterForRemote
        NSData *deviceToken = [noti.userInfo valueForKey:@"device_token"];
        token = deviceToken.description;
        token = [token stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
        SimiAppModel *app = [[SimiAppModel alloc] init];
        [app registerDeviceWithToken:token withLatitude:[NSString stringWithFormat:@"%f",currentLatitude] andLongitude:[NSString stringWithFormat:@"%f", currentLongitude]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidRegisterDevice" object:nil];
        [self removeObserverForNotification:noti];
    }else if ([noti.name isEqualToString:@"DidRegisterDevice"]){
#pragma mark DidRegisterDevice
        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        if (SIMI_DEBUG_ENABLE) {
            NSLog(@"Register Device Responder: %@", responder.responseMessage);
        }
    }else if ([noti.name isEqualToString:@"ApplicationDidReceiveNotificationFromServer"]){
#pragma mark ApplicationDidReceiveNotificationFromServer
        notiData = [noti userInfo];
        [self handleNotificationFromServer];
    }else if ([noti.name isEqualToString:@"ApplicationWillSwitchLanguage"]){
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)reloadAppConfig
{
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AFNetworkingReachabilityDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ApplicationDidBecomeActive" object:nil];
    [self getPlugins];
}

- (void)loadingViewFade{
    CGFloat height = SCREEN_HEIGHT;
    window = [[[UIApplication sharedApplication] delegate] window];
    CGRect frame = window.frame;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        //For iPhone/iPod
        if (height == 568) {
            loadingView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-568h"]];
        }else if (height == 667){
            loadingView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-667h"]];
        }else if (height == 736)
        {
            loadingView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-736h"]];
        }else
            loadingView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default"]];
    }else{
        loadingView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-Landscape-v7"]];
    }
    [loadingView setContentMode:UIViewContentModeScaleAspectFit];
    loadingView.frame = frame;
    
    UIViewController *viewController = [UIViewController new];
    [viewController.view addSubview:loadingView];
    window.rootViewController = viewController;
    
    //Create and add the Activity Indicator to loadingView
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.center = CGPointMake(loadingView.frame.size.width/2, loadingView.frame.size.height/2 + 160);
    activityIndicator.hidesWhenStopped = YES;
    activityIndicator.color = THEME_COLOR;
    [loadingView addSubview:activityIndicator];
    
    if ([DEMO_MODE boolValue]) {
        UILabel *demoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, loadingView.frame.size.height - 60, loadingView.frame.size.width, 60)];
        demoLabel.textAlignment = NSTextAlignmentCenter;
        demoLabel.numberOfLines = 2;
        demoLabel.text = @"This is a demo version.\nThis text will be removed from live app.";
        demoLabel.textColor = THEME_COLOR;
        [loadingView addSubview:demoLabel];
    }
    [activityIndicator startAnimating];
}

- (void)stoploadingViewFade{
    [loadingView removeFromSuperview];
}

- (NSMutableArray *)observers{
    return observers;
}

- (NSString *)storeConfigFilePath{
    return storeConfigFilePath;
}

- (void)handleNotificationFromServer{
    if ([[[notiData valueForKey:@"aps"] objectForKey:@"show_popup"] boolValue]) {
        if (_rootController != nil) {
            if (!isShowPopup) {
                [self showPopupWhenReceiveRemoteNotification];
            }
        }else
        {
            isReceiveRemoteNotification = YES;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didOpenHomePage:) name:DidGetBanner object:nil];
        }
    }
}

#pragma mark Alert View delegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self processAfterRecieveNotiFromServer];
    }
}

- (void)processAfterRecieveNotiFromServer
{
    NSString *stringNotiType = [[notiData valueForKey:@"aps"] valueForKey:@"type"];
    UITabBarController *rootController = (UITabBarController *)_rootController;
    UINavigationController *recentNaviCon = (UINavigationController *)rootController.selectedViewController;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if ([stringNotiType isEqualToString:@"2"]) {
            if ([[[notiData valueForKey:@"aps"] valueForKey:@"has_child"]boolValue]) {
                SCCategoryViewController* nextController = [SCCategoryViewController new];
                nextController.categoryId = [[notiData valueForKey:@"aps"] valueForKey:@"categoryID"];
                nextController.categoryRealName = [[notiData valueForKey:@"aps"] valueForKey:@"categoryName"];
                [recentNaviCon pushViewController:nextController animated:YES];
            }else
            {
                SCProductListViewController *nextController = [[SCProductListViewController alloc]init];;
                [nextController setCategoryID: [[notiData valueForKey:@"aps"] valueForKey:@"categoryID"]];
                nextController.productListGetProductType = ProductListGetProductTypeFromCategory;
                [recentNaviCon pushViewController:nextController animated:YES];
            }
            
        }else if([stringNotiType isEqualToString:@"1"])
        {
            SCProductViewController *nextController = [SCProductViewController new];
            [nextController setProductId:[[notiData valueForKey:@"aps"] valueForKey:@"productID"]];
            [recentNaviCon pushViewController:nextController animated:YES];
        }else if([stringNotiType isEqualToString:@"3"])
        {
            url = [[notiData valueForKey:@"aps"] valueForKey:@"url"];
            SCWebViewController *nextController = [[SCWebViewController alloc] init];
            [nextController setUrlPath:url];
            [recentNaviCon pushViewController:nextController animated:YES];
        }
    }else
    {
        if ([stringNotiType isEqualToString:@"2"]) {
            SCProductListViewControllerPad *nextController = [[SCProductListViewControllerPad alloc]init];;
            [nextController setCategoryID: [[notiData valueForKey:@"aps"] valueForKey:@"categoryID"]];
            nextController.productListGetProductType = ProductListGetProductTypeFromCategory;
            [recentNaviCon pushViewController:nextController animated:YES];
        }else if([stringNotiType isEqualToString:@"1"])
        {
            SCProductViewControllerPad *nextController = [SCProductViewControllerPad new];
            [nextController setProductId:[[notiData valueForKey:@"aps"] valueForKey:@"productID"]];
            [recentNaviCon pushViewController:nextController animated:YES];
        }else if([stringNotiType isEqualToString:@"3"])
        {
            url = [[notiData valueForKey:@"aps"] valueForKey:@"url"];
            SCWebViewController *nextController = [[SCWebViewController alloc] init];
            [nextController setUrlPath:url];
            [recentNaviCon pushViewController:nextController animated:YES];
        }
    }
}

#pragma mark Customization Alert Delegate

- (void)didOpenHomePage:(NSNotification*)noti
{
    [[NSNotificationCenter defaultCenter]removeObserverForNotification:noti];
        if (isReceiveRemoteNotification) {
            isReceiveRemoteNotification = NO;
            [self showPopupWhenReceiveRemoteNotification];
        }
}
- (void)showPopupWhenReceiveRemoteNotification
{
    // Notification Sound
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    SoundEffect* sf = [SoundEffect soundEffectWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"alarm" ofType:@".mp3"]];
    if (sf != nil) {
        [sf play];
    }else
        AudioServicesPlayAlertSound(1007);
    
    // Notification Alert
    isShowPopup = YES;
    NSString *imageUrl = [[notiData valueForKey:@"aps"] valueForKey:@"imageUrl"];
    contentAlertView = [UIView new];
    lblAlertTitle  = [UILabel new];
    lblAlertContent = [UILabel new];
    int heightContentAlert = 0;
    NSString *cancelTitle = SCLocalizedString(@"Close");
    NSString *showTitle = SCLocalizedString(@"Show");
    NSString *title = [[notiData valueForKey:@"aps"] valueForKey:@"title"];
    NSString *message = [[notiData valueForKey:@"aps"] valueForKey:@"message"];
    int alertSize = ALERTWIDTH;
    if (![title isEqualToString:@""]) {
        [lblAlertTitle setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:TITLE_FONTSIZE]];
        heightContentAlert += HEIGHT_TITLE + DISTANCE_OTHER_CONTENT;
        [lblAlertTitle setTextColor:[UIColor blackColor]];
        [lblAlertTitle setFrame:CGRectMake(10, 0, ALERTWIDTH, heightContentAlert)];
        lblAlertTitle.text = title;
        [lblAlertTitle setTextAlignment:NSTextAlignmentCenter];
        [contentAlertView addSubview:lblAlertTitle];
    }
    CustomIOS7AlertView *alertView =  [CustomIOS7AlertView new];
    alertView.delegate = self;
    if (imageUrl != nil && ![imageUrl isEqualToString:@""]) {
        UIImageView *imageView = [UIImageView new];
        // Xác định kích thước image notification
        // Begin
        float widthImage = [[[notiData valueForKey:@"aps"] valueForKey:@"width"]floatValue];
        float heightImage = [[[notiData valueForKey:@"aps"] valueForKey:@"height"]floatValue];
        float widthImageView = 0;
        float heightImageView = 0;
        if (widthImage < alertSize && heightImage < alertSize) {
            widthImageView = widthImage;
            heightImageView = heightImage;
        }else if(widthImage >= heightImage)
        {
            widthImageView = alertSize - 20;
            heightImageView = widthImageView *heightImage/widthImage;
        }else
        {
            heightImageView = alertSize - 20;
            widthImageView = heightImageView *widthImage/heightImage;
        }
        [imageView setFrame:CGRectMake((alertSize - widthImageView)/2, heightContentAlert, widthImageView, heightImageView)];
        heightContentAlert += heightImageView + DISTANCE_OTHER_CONTENT;
        // End
        
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [contentAlertView addSubview:imageView];
        
        if (![message isEqualToString:@""]) {
            [lblAlertContent setFont:[UIFont fontWithName:THEME_FONT_NAME size:MESSAGE_FONTSIZE]];
            [lblAlertContent setFrame:CGRectMake(10, heightContentAlert, alertSize - 20, HEIGHT_ALERTCONTENT)];
            if (message.length > 250)
                lblAlertContent.text = [message substringToIndex:250];
            else
                lblAlertContent.text = message;
            [lblAlertContent resizLabelToFit];
            heightContentAlert += lblAlertContent.frame.size.height + DISTANCE_OTHER_CONTENT;
            [lblAlertContent setTextAlignment:NSTextAlignmentCenter];
            lblAlertContent.numberOfLines = 8;
            [contentAlertView addSubview:lblAlertContent];
        }
        [contentAlertView setFrame:CGRectMake(0, 0, alertSize, heightContentAlert)];
        [alertView setContainerView:contentAlertView];
        [alertView setButtonTitles:[NSMutableArray arrayWithObjects:cancelTitle, showTitle, nil]];
        [alertView setUseMotionEffects:true];
        [alertView show];
    }else
    {
        if (![message isEqualToString:@""]) {
            [lblAlertContent setFont:[UIFont fontWithName:THEME_FONT_NAME size:MESSAGE_FONTSIZE]];
            [lblAlertContent setFrame:CGRectMake(10, heightContentAlert, alertSize - 20, HEIGHT_ALERTCONTENT)];
            lblAlertContent.text = message;
            [lblAlertContent resizLabelToFit];
            heightContentAlert += lblAlertContent.frame.size.height + DISTANCE_OTHER_CONTENT;
            [lblAlertContent setTextAlignment:NSTextAlignmentCenter];
            lblAlertContent.numberOfLines = 30;
            [contentAlertView addSubview:lblAlertContent];
        }
        
        [contentAlertView setFrame:CGRectMake(0, 0, alertSize, heightContentAlert)];
        [alertView setContainerView:contentAlertView];
        [alertView setButtonTitles:[NSMutableArray arrayWithObjects:cancelTitle, showTitle, nil]];
        [alertView setUseMotionEffects:true];
        [alertView show];
    }
}
- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView close];
    isShowPopup = NO;
    switch (buttonIndex) {
        case 1:
        {
            [self processAfterRecieveNotiFromServer];
        }
            break;
        default:
            break;
    }
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    [clLocationManager stopUpdatingLocation];
    currentLatitude = newLocation.coordinate.latitude;
    currentLongitude = newLocation.coordinate.longitude;
    
    SimiAppModel *app = [[SimiAppModel alloc] init];
    if (token != nil) {
        if (!self.didSendDeviceTokenWithLocation) {
            [app registerDeviceWithToken:token withLatitude:[NSString stringWithFormat:@"%f",currentLatitude] andLongitude:[NSString stringWithFormat:@"%f", currentLongitude]];
            self.didSendDeviceTokenWithLocation = YES;
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [clLocationManager stopUpdatingLocation];
    currentLatitude = 0;
    currentLongitude = 0;
}

#pragma mark Did Checkout Success
- (void)didCheckoutSuccess:(NSNotification*)noti
{
    SimiOrderModel *orderModel = noti.object;
    NSDictionary *apsDictionary = (NSDictionary*)[orderModel valueForKey:@"notification"];
    notiData = [[NSDictionary alloc]initWithObjects:@[apsDictionary] forKeys:@[@"aps"]];
    [self showPopupWhenReceiveRemoteNotification];
}


//  Liam Add 150402
#pragma mark Get Country Collection
- (void)getCountryCollection
{
    SimiAddressModelCollection *countries = [[SimiAddressModelCollection alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCountries:) name:DidGetCountryCollection object:countries];
    [countries getCountryCollection];
}

- (void)didGetCountries:(NSNotification*)noti
{
    if ([noti.name isEqualToString:DidGetCountryCollection]) {
        [[NSNotificationCenter defaultCenter]removeObserverForNotification:noti];
        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        if ([responder.status isEqualToString:@"SUCCESS"]) {
            [SimiGlobalVar sharedInstance].countryColllection = noti.object;
        }
    }
}
@end
