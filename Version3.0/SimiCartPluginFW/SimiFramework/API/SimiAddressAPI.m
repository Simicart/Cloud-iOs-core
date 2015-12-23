//
//  SimiAddressAPI.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/19/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiAddressAPI.h"

@implementation SimiAddressAPI

- (void)getCountryCollectionWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiCountries];
    [self requestWithMethod:GET URL:url params:params target:target selector:selector header:nil];
}

- (void)saveAddress:(NSDictionary *)params extendsUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiCustomers, extendsUrl];
    [self requestWithMethod:PUT URL:url params:params target:target selector:selector header:nil];
}

- (void)addNewAddress:(NSDictionary *)params extendsUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiCustomers, extendsUrl];
    [self requestWithMethod:POST URL:url params:params target:target selector:selector header:nil];
}

@end
