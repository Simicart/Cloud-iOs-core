//
//  SimiReviewAPI.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/14/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiAPI.h"

@interface SimiReviewAPI : SimiAPI

- (void)getReviewWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
- (void)getReviewCollectionWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;

@end
