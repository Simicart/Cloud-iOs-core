//
//  SimiCategoryModelCollection.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/10/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiModelCollection.h"

@interface SimiCategoryModelCollection : SimiModelCollection

@property (strong, nonatomic) NSString* parentCategoryId;
/*
 Notification name: DidGetCategoryCollection
 */
- (void)getCategoryCollectionWithParentId:(NSString *)categoryId params:(NSDictionary *)params;

/*
 Notification name: DidGetHomeCategories
 */
- (void)getHomeDefaultCategories;
@end
