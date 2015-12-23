//
//  SimiStoreAPI.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/17/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiAPI.h"

@interface SimiStoreAPI : SimiAPI

- (void)getStoreWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
- (void)getStoreCollectionWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
- (void)getThemeConfigureParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;

@end
