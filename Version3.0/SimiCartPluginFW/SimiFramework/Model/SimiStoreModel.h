//
//  SimiStoreModel.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/17/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiModel.h"
#import "SimiStoreAPI.h"

@interface SimiStoreModel : SimiModel

/*
 Notification name: DidGetStore
 */
- (void)getStoreWithStoreId:(NSString *)storeId;

- (void)saveToLocal:(NSString*)storeID;
- (void)getThemeConfigure;

@end
