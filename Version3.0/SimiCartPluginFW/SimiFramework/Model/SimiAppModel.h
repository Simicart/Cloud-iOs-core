//
//  SimiAppModel.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/26/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiModel.h"

@interface SimiAppModel : SimiModel

/*
 Notification name: DidRegisterDevice
 */
- (void)registerDeviceWithToken:(NSString *)token withLatitude:(NSString*)latitude andLongitude:(NSString*)longitude;

@end
