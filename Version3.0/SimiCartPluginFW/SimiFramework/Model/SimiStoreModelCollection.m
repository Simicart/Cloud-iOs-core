//
//  SimiStoreModelCollection.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/17/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiStoreModelCollection.h"

@implementation SimiStoreModelCollection

- (void)getStoreCollection{
    currentNotificationName = @"DidGetStoreCollection";
    [self preDoRequest];
    [(SimiStoreAPI *)[self getAPI] getStoreCollectionWithParams:nil target:self selector:@selector(didFinishRequest:responder:)];
}

@end
