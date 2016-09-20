//
//  LoyaltyModelCollection.h
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 1/27/15.
//  Copyright (c) 2015 Magestore. All rights reserved.
//

#import <SimiCartBundle/SimiModelCollection.h>

@interface LoyaltyModelCollection : SimiModelCollection

- (void)getTransactionsWithOffset:(NSInteger)offset limit:(NSInteger)limit;

@end
