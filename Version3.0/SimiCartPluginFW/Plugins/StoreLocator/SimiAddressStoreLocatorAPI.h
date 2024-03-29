//
//  SimiAddressStoreLocatorAPI.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/11/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiAPI.h>
@interface SimiAddressStoreLocatorAPI : SimiAPI
- (void)getCountryListWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
@end
