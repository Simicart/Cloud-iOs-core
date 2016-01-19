//
//  SimiSpotModelCollection.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 12/3/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import "SimiSpotModelCollection.h"
@implementation SimiSpotModelCollection
- (void)getSpotCollection
{
    currentNotificationName = DidGetSpotCollection;
    [self preDoRequest];
    modelActionType = ModelActionTypeGet;
    NSString *urlPath = [NSString stringWithFormat:@"%@%@", kBaseURL,kSimiGetSpots];
    [[self getAPI] requestWithMethod:GET URL:urlPath params:@{@"order":@"position",@"status":@"1"} target:self selector:@selector(didFinishRequest:responder:) header:nil];
}

- (void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder
{
    if ([currentNotificationName isEqualToString:DidGetSpotCollection]) {
        if (responder.simiObjectName) {
            currentNotificationName = responder.simiObjectName;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
            switch (modelActionType) {
                case ModelActionTypeInsert:{
                    [self addData:[responseObjectData valueForKey:@"spot-products"]];
                }
                    break;
                default:{
                    [self setData:[responseObjectData valueForKey:@"spot-products"]];
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
