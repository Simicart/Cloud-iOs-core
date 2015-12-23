//
//  SimiCMSPagesModelCollection.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 12/2/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import "SimiCMSPagesModelCollection.h"

@implementation SimiCMSPagesModelCollection
- (void)getCMSPagesWithParams:(NSDictionary *)params
{
    currentNotificationName = DidGetCMSPages;
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    SimiAPI *api = [SimiAPI new];
    NSString *urlPath = [NSString stringWithFormat:@"%@pages", kBaseURL];
    [api requestWithMethod:GET URL:urlPath params:params target:self selector:@selector(didFinishRequest:responder:) header:nil];
}

- (void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder
{
    if ([currentNotificationName isEqualToString:DidGetCMSPages]) {
        if (responder.simiObjectName) {
            currentNotificationName = responder.simiObjectName;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
            switch (modelActionType) {
                case ModelActionTypeInsert:{
                    [self addData:[responseObjectData valueForKey:@"pages"]];
                }
                    break;
                default:{
                    [self setData:[responseObjectData valueForKey:@"pages"]];
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
