//
//  SimiModelCollection+CMS.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 5/30/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiCartBundle.h"

@interface SimiModelCollection (CMS)

/*
 Notification name: DidGetCMSPages
 */
- (void)getCMSPagesWithParams:(NSDictionary *)params;

@end
