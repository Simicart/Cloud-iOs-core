//
//  SimiCustomerAPI.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 1/20/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiAPI.h"

@interface SimiCustomerAPI : SimiAPI

- (void)loginWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;

- (void)registerWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;

- (void)getCustomerProfileWithUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector;

- (void)changeUserInfoWithParams:(NSMutableDictionary *)params extendsUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector;

- (void)changeUserPasswordWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;

- (void)getForgotPasswordWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;

- (void)getAddressCollectionWithUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector;
@end
