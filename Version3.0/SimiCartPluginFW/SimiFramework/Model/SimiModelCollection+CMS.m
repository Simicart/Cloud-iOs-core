//
//  SimiModelCollection+CMS.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 5/30/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiModelCollection+CMS.h"

@implementation SimiModelCollection (CMS)

- (void)getCMSPagesWithParams:(NSDictionary *)params{
    currentNotificationName = DidGetCMSPages;
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    SimiAPI *api = [SimiAPI new];
    NSString *urlPath = [NSString stringWithFormat:@"%@pages", kBaseURL];
    [api requestWithMethod:GET URL:urlPath params:params target:self selector:@selector(didFinishRequest:responder:) header:nil];
}


@end
