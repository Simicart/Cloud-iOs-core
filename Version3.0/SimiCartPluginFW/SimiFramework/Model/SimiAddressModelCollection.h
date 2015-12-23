//
//  SimiAddressModelCollection.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/19/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiModelCollection.h"
#import "SimiAddressAPI.h"

@interface SimiAddressModelCollection : SimiModelCollection

/*
 Notification name: DidGetCountryCollection
 */
- (void)getCountryCollection;

/*
 Notification name: DidGetStateCollection
 */
- (void)getStateCollectionWithCountryName:(NSString *)countryName countryCode:(NSString *)countryCode;

@end
