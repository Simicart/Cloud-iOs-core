//
//  SimiAddressAPI.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/19/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiAPI.h"

@interface SimiAddressAPI : SimiAPI
- (void)getCountryCollectionWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;

- (void)saveAddress:(NSDictionary *)params extendsUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector;

- (void)addNewAddress:(NSDictionary *)params extendsUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector;

@end
