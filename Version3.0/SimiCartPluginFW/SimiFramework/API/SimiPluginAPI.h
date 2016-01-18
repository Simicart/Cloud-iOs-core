//
//  SimiPluginAPI.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/23/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiAPI.h"

@interface SimiPluginAPI : SimiAPI

- (void)getActivePluginsWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;

- (void)getSitePluginsWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;

@end
