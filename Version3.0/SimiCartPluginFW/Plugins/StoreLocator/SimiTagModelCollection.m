//
//  SimiTagModelCollection.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 6/27/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiTagModelCollection.h"
#import "SimiGlobalVar+StoreLocator.h"
#import "SimiTagAPI.h"

@implementation SimiTagModelCollection
- (void)getTagWithOffset:(NSString*)offset limit:(NSString*)limit
{
    currentNotificationName = @"DidFinishGetTagList";
    modelActionType = ModelActionTypeInsert;
    //Gin edit
    [self preDoRequest];
    //end
    [(SimiTagAPI *)[self getAPI] getTagListWithParams:@{@"offset":offset,@"limit":limit} target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder
{
    if ([currentNotificationName isEqualToString:@"DidFinishGetTagList"]) {
        if (responder.simiObjectName) {
            currentNotificationName = responder.simiObjectName;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
            switch (modelActionType) {
                case ModelActionTypeInsert:{
                    [self addData:[responseObjectData valueForKey:@"data"]];
                }
                    break;
                default:{
                    [self setData:[responseObjectData valueForKey:@"data"]];
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
