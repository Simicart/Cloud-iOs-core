//
//  SimiCustomerAPI.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 1/20/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiCustomerAPI.h"

@implementation SimiCustomerAPI

- (void)loginWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiLogin];
    [self requestWithMethod:POST URL:url params:params target:target selector:selector header:nil];
}

- (void)registerWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiRegister];
    [self requestWithMethod:POST URL:url params:params target:target selector:selector header:nil];
}

- (void)getCustomerProfileWithUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiCustomers, extendsUrl];
    [self requestWithMethod:GET URL:url params:nil target:target selector:selector header:nil];
}

- (void)changeUserInfoWithParams:(NSMutableDictionary *)params extendsUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiCustomers, extendsUrl];
    [self requestWithMethod:PUT URL:url params:params target:target selector:selector header:nil];
}

- (void)changeUserPasswordWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiChangeUserPassword];
    [self requestWithMethod:POST URL:url params:params target:target selector:selector header:nil];
}

- (void)getForgotPasswordWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@",kBaseURL, kSimiGetForgotPassword];
    [self requestWithMethod:POST URL:url params:params target:target selector:selector header:nil];
}

- (void)getAddressCollectionWithUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiCustomers,extendsUrl];
    [self requestWithMethod:GET URL:url params:nil target:target selector:selector header:nil];
}
@end
