//
//  SimiCategoryAPI.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/10/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiAPI.h"

@interface SimiCategoryAPI : SimiAPI

- (void)getCategoryCollectionWithParams:(NSDictionary *)params extendsUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector;

-(void) getCategoryWithId:(NSString*) categoryId params:(NSDictionary* )params target:(id)target selector:(SEL)selector;

@end
