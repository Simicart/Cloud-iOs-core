//
//  SimiPluginModelCollection.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/23/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiPluginModelCollection.h"
#import "SimiPluginAPI.h"

@implementation SimiPluginModelCollection

- (SimiPluginAPI *)getAPI{
    SimiPluginAPI *api = [[SimiPluginAPI alloc] init];
    return api;
}

- (void)getActivePluginsWithParams:(NSDictionary *)params{
    currentNotificationName = DidGetActivePlugins;
    [self preDoRequest];
    [(SimiPluginAPI *)[self getAPI] getActivePluginsWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder
{
    if ([currentNotificationName isEqualToString:DidGetCategoryCollection]) {
        if (responder.simiObjectName) {
            currentNotificationName = responder.simiObjectName;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:DidGetActivePlugins];
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
            switch (modelActionType) {
                case ModelActionTypeInsert:{
                    [self addData:[responseObjectData valueForKey:@"plugins"]];
                }
                    break;
                default:{
                    [self setData:[responseObjectData valueForKey:@"plugins"]];
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
