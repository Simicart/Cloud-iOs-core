//
//  SimiAPI.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 1/20/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimiNetworkManager.h"

//SimiCart Product API
extern NSString *const kSimiProducts;
extern NSString *const kSimiGetSpots;
extern NSString *const kSimiCategories;
extern NSString *const kSimiSearchProduct;

//SimiCart Customer API
extern NSString *const kSimiRegister;
extern NSString *const kSimiLogin;
extern NSString *const kSimiLogout;
extern NSString *const kSimiCustomers;
extern NSString *const kSimiCheckLoginStatus;
extern NSString *const kSimiGetForgotPassword;
extern NSString *const kSimiChangeUserPassword;

//SimiCart Cart API
extern NSString *const kSimiQuotes;

//SimiCart Order API
extern NSString *const kSimiSetCouponCode;
extern NSString *const kSimiRemoveCouponCode;

//SimiCart Config API
extern NSString *const kSimiGetBanner;
extern NSString *const kSimiSettings;
extern NSString *const kSimiRegisterDevice;
extern NSString *const kThemeConfigure;
extern NSString *const kSitePlugins;
extern NSString *const kActivePlugins;

//SimiCart Address API
extern NSString *const kSimiCountries;

extern NSString *const kSimiOrders;

static NSString *POST = @"POST";
static NSString *GET = @"GET";
static NSString *DELETE = @"DELETE";
static NSString *PUT = @"PUT";

// SimiAPI class
@interface SimiAPI : NSObject

@property (strong, nonatomic) NSObject *target;
@property (nonatomic) SEL selector;

- (void)convertData:(id)responseObject;
- (void)requestWithURL:(NSString *)url params:(NSDictionary *)params target:(id)target selector:(SEL)selector header:(NSDictionary *)header;
- (void)requestWithMethod:(NSString*)medthod URL:(NSString *)url params:(NSDictionary *)params target:(id)target selector:(SEL)selector header:(NSDictionary *)header;

@end
