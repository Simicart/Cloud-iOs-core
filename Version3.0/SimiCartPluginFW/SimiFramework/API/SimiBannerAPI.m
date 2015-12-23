//
//  SimiBannerAPI.m
//  SimiCartPluginFW
//
//  Created by Thuy Dao on 2/20/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiBannerAPI.h"

@implementation SimiBannerAPI

/**
 * Method getBannerCollectionWithParams
 */

- (void)getBannerCollectionWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@", kBaseURL,kSimiGetBanner];
    [self requestWithMethod:GET URL:urlPath params:params target:target selector:selector header:nil];
}

@end
