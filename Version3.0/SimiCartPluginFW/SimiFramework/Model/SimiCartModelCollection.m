//
//  SimiCartModelCollection.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/17/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiCartModelCollection.h"
#import "SimiCartAPI.h"
#import "SimiResponder.h"
#import "SimiCartModel.h"

@implementation SimiCartModelCollection

- (void)getQuotesWithCustomerId:(NSString *)customerId{
    currentNotificationName = DidGetQuotes;
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:customerId forKey:@"filter[customer|customer_id]"];
    [params setValue:@"0" forKey:@"filter[orig_order_id]"];
    [self preDoRequest];
    [(SimiCartAPI *)[self getAPI] getQuotesWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}

- (NSInteger)indexOfObject:(SimiCartModel *)cartItem{
    for (int i = 0; i < self.count; i++) {
        SimiCartModel *item = [self objectAtIndex:i];
        if ([[item valueForKey:@"_id"] isEqualToString:[cartItem valueForKey:@"_id"]]) {
            return i;
        }
    }
    return -1;
}

- (NSString *)cartQty{
    NSInteger badge = 0;
    for (NSArray *obj in self) {
        badge += [[obj valueForKey:@"qty"] integerValue];
    }
    return [NSString stringWithFormat:@"%ld", (long)badge];
}

- (void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder
{
    if ([currentNotificationName isEqualToString:DidGetQuotes]) {
        if (responder.simiObjectName) {
            currentNotificationName = responder.simiObjectName;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
            switch (modelActionType) {
                case ModelActionTypeInsert:{
                    [self addData:[responseObjectData valueForKey:@"quotes"]];
                }
                    break;
                default:{
                    [self setData:[responseObjectData valueForKey:@"quotes"]];
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
