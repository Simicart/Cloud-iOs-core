//
//  SimiPluginModelCollection.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/23/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiModelCollection.h"

@interface SimiPluginModelCollection : SimiModelCollection

/*
 Notification name: DidGetActivePlugins
 */
- (void)getActivePluginsWithParams:(NSDictionary *)params;
- (void)getSitePluginsWithParams:(NSDictionary *)params;

@end
