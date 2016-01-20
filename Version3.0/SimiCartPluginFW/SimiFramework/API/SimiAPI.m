//
//  SimiAPI.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 1/20/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiAPI.h"
#import "SimiResponder.h"
#import "SimiMutableArray.h"
#import "SimiMutableDictionary.h"
#import "KeychainItemWrapper.h"


//SimiCart Catalog API
NSString *const kSimiProducts           = @"products";
NSString *const kSimiGetSpots           = @"spot-products";
NSString *const kSimiSearchProduct      = @"products/search";
NSString *const kSimiCategories         = @"categories";

//SimiCart Customer API
NSString *const kSimiRegister           = @"customer-account/register";
NSString *const kSimiLogin              = @"customer-account/login";
NSString *const kSimiChangeUserPassword = @"customer-account/change-password";
NSString *const kSimiLogout             = @"customer/sign_out";
NSString *const kSimiCustomers          = @"customers";
NSString *const kSimiCheckLoginStatus   = @"customer/check_login_status";
NSString *const kSimiGetForgotPassword  = @"customer-account/forget-password";

//SimiCart Quotes
NSString *const kSimiQuotes             = @"quotes";


//SimiCart Promotions
NSString *const kSimiSetCouponCode      = @"promotions/apply";
NSString *const kSimiRemoveCouponCode   = @"promotions/remove";

//SimiCart Config API
NSString *const kSimiGetBanner          = @"banners";
NSString *const kSimiSettings           = @"settings";
NSString *const kSimiRegisterDevice     = @"devices";
NSString *const kThemeConfigure         = @"app-configs";
NSString *const kSitePlugins         = @"site-plugins";
NSString *const kActivePlugins         = @"public-plugins";


//SimiCart Address API
NSString *const kSimiCountries          = @"countries";

//SimiCart Orders
NSString *const kSimiOrders             = @"orders";

@implementation SimiAPI

- (void)requestWithURL:(NSString *)url params:(NSDictionary *)params target:(id)target selector:(SEL)selector header:(NSDictionary *)header{
    self.target = (NSObject *)target;
    self.selector = selector;
    if ([self.target respondsToSelector:@selector(currentNotificationName)]) {
        self.simiObjectName = [[target currentNotificationName] copy];
    }
    if (params == nil) {
        params = @{};
    }
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleIdentifier = [NSString stringWithFormat:@"%@", [info objectForKey:@"CFBundleIdentifier"]];
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:bundleIdentifier accessGroup:nil];
    NSString *email = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [wrapper objectForKey:(__bridge id)(kSecAttrDescription)];
    NSMutableDictionary *customerInfo = [NSMutableDictionary new];
    if (email && password && [[SimiGlobalVar sharedInstance]isLogin]) {
        [customerInfo setObject:email forKey:@"email"];
        [customerInfo setObject:password forKey:@"password"];
    }
    [customerInfo addEntriesFromDictionary:params];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:customerInfo options:0 error:nil];
    NSString *string = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    
    [[SimiNetworkManager sharedInstance] requestWithMethod:@"POST" urlPath:url parameters:@{@"data":string} target:self selector:@selector(convertData:) header:header];
}

- (void)requestWithMethod:(NSString*)medthod URL:(NSString *)url params:(NSDictionary *)params target:(id)target selector:(SEL)selector header:(NSDictionary *)header
{
    self.target = (NSObject *)target;
    self.selector = selector;
    if ([self.target respondsToSelector:@selector(currentNotificationName)]) {
        self.simiObjectName = [[target currentNotificationName] copy];
    }
    if (params == nil) {
        params = @{};
    }
    if (header == nil) {
        header = @{};
    }
    NSMutableDictionary *headerParams = [[NSMutableDictionary alloc]initWithDictionary:header];
    if ([medthod isEqualToString:POST]) {
        [headerParams setValue:@"application/json" forKey:@"Content-Type"];
    }
    [[SimiNetworkManager sharedInstance] requestWithMethod:medthod urlPath:url parameters:params target:self selector:@selector(convertData:) header:headerParams];
}


- (void)convertData:(id)responseObject{
    if (self.target != nil && self.selector != nil) {
        if ([responseObject isKindOfClass:[NSError class]]) {
            SimiResponder *responder = [[SimiResponder alloc] init];
            responder.simiObjectName = self.simiObjectName;
            responder.error = responseObject;
            responder.status = @"Network Error";
            responder.message = @"Network Error";
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.target performSelector:self.selector withObject:nil withObject:responder];
#pragma clang diagnostic pop
        }else{
            NSMutableDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSMutableArray *error = nil;
            if ([response valueForKey:@"errors"] && [[response valueForKey:@"errors"]isKindOfClass:[NSArray class]])
            {
                error = [[NSMutableArray alloc]initWithArray:[response valueForKey:@"errors"]];
            }
            if (error == nil) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                SimiResponder *responder = [[SimiResponder alloc] init];
                responder.simiObjectName = self.simiObjectName;
                responder.status = @"SUCCESS";
                responder.message = nil;
                if([response valueForKey:@"other"]){
                    responder.other = [response valueForKey:@"other"];
                }
                if ([self.target isKindOfClass:NSClassFromString(@"SimiMutableArray")]) {
                    [self.target performSelector:self.selector withObject:[[SimiMutableDictionary alloc]initWithDictionary:response] withObject:responder];
                }else{
                    [self.target performSelector:self.selector withObject:[[SimiMutableDictionary alloc]initWithDictionary:response] withObject:responder];
                }
            }else{
                SimiResponder *responder = [[SimiResponder alloc] init];
                responder.simiObjectName = self.simiObjectName;
                responder.status = @"ERROR";
                if (error.count > 0) {
                    if ([[error objectAtIndex:0] isKindOfClass:[NSDictionary class]]) {
                        NSMutableDictionary *errorContent = [[NSMutableDictionary alloc]initWithDictionary:[error objectAtIndex:0]];
                        if ([errorContent valueForKey:@"message"]) {
                            responder.message = [NSString stringWithFormat:@"%@",[errorContent valueForKey:@"message"]];
                        }
                    }
                }
                [self.target performSelector:self.selector withObject:nil withObject:responder];
#pragma clang diagnostic pop
            }
        }
    }
}

@end
