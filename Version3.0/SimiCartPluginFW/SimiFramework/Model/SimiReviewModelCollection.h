//
//  SimiReviewModelCollection.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/14/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiModelCollection.h"

@interface SimiReviewModelCollection : SimiModelCollection

/*
 Notification name: DidGetReviewCollection
 */
- (void)getReviewCollectionWithProductId:(NSString *)productId star:(NSString *)star offset:(NSInteger)offset limit:(NSInteger)limit;

@end
