//
//  SimiBannerModelCollection.m
//  SimiCartPluginFW
//
//  Created by Thuy Dao on 2/20/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiBannerModelCollection.h"
#import "SimiBannerAPI.h"

@implementation SimiBannerModelCollection

/**
 * Method getBannerListWithProcessType
 */
- (void)getBannerCollection{
    currentNotificationName = DidGetBanner;
    [self preDoRequest];
    [(SimiBannerAPI *)[self getAPI] getBannerCollectionWithParams:nil target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder
{
    if ([currentNotificationName isEqualToString:DidGetBanner]) {
        if (responder.simiObjectName) {
            currentNotificationName = responder.simiObjectName;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
            switch (modelActionType) {
                case ModelActionTypeInsert:{
                    [self addData:[responseObjectData valueForKey:@"banners"]];
                }
                    break;
                default:{
                    [self setData:[responseObjectData valueForKey:@"banners"]];
                }
                    break;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }else if (responseObject == nil){
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }
    }else
    {
        [super didFinishRequest:responseObject responder:responder];
    }
}

@end
