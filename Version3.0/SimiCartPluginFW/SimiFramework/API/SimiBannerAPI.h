//
//  SimiBannerAPI.h
//  SimiCartPluginFW
//
//  Created by Thuy Dao on 2/20/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimiAPI.h"

@interface SimiBannerAPI : SimiAPI

/**
 * Method getBannerCollectionWithParams
 */

- (void)getBannerCollectionWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;

@end
