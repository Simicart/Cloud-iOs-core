//
//  InitWorker.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 1/3/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+SimiObject.h"
#import "CustomIOS7AlertView.h"
#import <CoreLocation/CoreLocation.h>

@interface InitWorker : NSObject<UIAlertViewDelegate, CustomIOS7AlertViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) NSString *storeConfigFilePath;
@property (strong, nonatomic) NSMutableArray *pluginList;
@property (strong, nonatomic) NSString *baseURL;
@property (strong, nonatomic) UIViewController *rootController;
@property (nonatomic) BOOL isFirstGetActivePlugins;
@property (nonatomic) BOOL didSendDeviceTokenWithLocation;
@property (nonatomic) BOOL didGetStoreConfig;
@property (nonatomic) BOOL didGetPlugins;
@property (nonatomic) BOOL didGetAppConfig;
@property (nonatomic) BOOL isGetStoreConfig;
@property (nonatomic) BOOL isGetPlugins;
/*
 Post notification "InitializedRootController"
 */
- (UIViewController *)initializeRootController;

- (void)addInitWorkerObservers;
- (void)getSitePlugins;
- (void)getActivePlugins:(NSString*)Ids;
- (void)setAppSettings;
- (NSMutableArray *)observers;
- (void)getStoreConfig;
- (void)getAppConfig;
- (void)saveCurrency;
- (void)reloadAppConfig;

/*
 Check Login Status
 If have an login without logout before, login again
 Else do nothing
*/
- (void)initLogin;
- (void)applyTheme;

@end
