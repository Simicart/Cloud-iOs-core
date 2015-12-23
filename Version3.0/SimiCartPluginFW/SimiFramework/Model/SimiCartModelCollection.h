//
//  SimiCartModelCollection.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/17/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiModelCollection.h"
#import "SimiCartModel.h"

@interface SimiCartModelCollection : SimiModelCollection

@property (strong, nonatomic) NSString *cartQty;

/*
 Notification name: DidGetQuote
 */
- (void)getQuotesWithCustomerId:(NSString *)customerId;


- (NSInteger)indexOfObject:(SimiCartModel *)cartItem;

@end
