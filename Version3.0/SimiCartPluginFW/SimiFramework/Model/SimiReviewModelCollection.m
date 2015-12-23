//
//  SimiReviewModelCollection.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/14/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiReviewModelCollection.h"
#import "SimiReviewAPI.h"

@implementation SimiReviewModelCollection

- (void)getReviewCollectionWithProductId:(NSString *)productId star:(NSString *)star offset:(NSInteger)offset limit:(NSInteger)limit{
    currentNotificationName = @"DidGetReviewCollection";
    modelActionType = ModelActionTypeInsert;
    [self preDoRequest];
    [(SimiReviewAPI *)[self getAPI] getReviewCollectionWithParams:@{@"product_id": productId, @"star":star, @"offset": [NSString stringWithFormat:@"%ld", (long)offset], @"limit": [NSString stringWithFormat:@"%ld", (long)limit]} target:self selector:@selector(didFinishRequest:responder:)];
}

@end
