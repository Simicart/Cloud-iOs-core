//
//  SimiAppAPI.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/26/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiAPI.h"

@interface SimiAppAPI : SimiAPI

- (void)registerDeviceWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;

@end
