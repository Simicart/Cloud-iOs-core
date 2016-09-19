//
//  SCEmailContactModel.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 10/24/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCEmailContactModel.h"
#import "SCEmailContactAPI.h"
@implementation SCEmailContactModel
- (void)getEmailContactWithParams:(NSDictionary*)dict
{
    currentNotificationName = @"DidGetEmailContactConfig";
    modelActionType = ModelActionTypeGet;
    [(SCEmailContactAPI *)[self getAPI] getEmailContactWithParams:dict target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder
{
    if ([currentNotificationName isEqualToString:@"DidGetEmailContactConfig"]) {
        if (responder.simiObjectName) {
            currentNotificationName = responder.simiObjectName;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
            switch (modelActionType) {
                case ModelActionTypeInsert:{
                    [self addData:[[responseObjectData valueForKey:@"data"]objectAtIndex:0]];
                }
                    break;
                default:{
                    [self setData:[[responseObjectData valueForKey:@"data"]objectAtIndex:0]];
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
