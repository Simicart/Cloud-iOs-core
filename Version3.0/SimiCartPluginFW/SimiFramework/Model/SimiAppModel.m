//
//  SimiAppModel.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/26/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiAppModel.h"
#import "SimiAppAPI.h"

@implementation SimiAppModel

- (void)registerDeviceWithToken:(NSString *)token withLatitude:(NSString *)latitude andLongitude:(NSString *)longitude{
    currentNotificationName = DidRegisterDevice;
    [self preDoRequest];
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:@"1" forKey:@"type"];
    [params setValue:token forKey:@"token"];
    [params setValue:latitude forKey:@"latitude"];
    [params setValue:longitude forKey:@"longitude"];
    [(SimiAppAPI *)[self getAPI] registerDeviceWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}

@end
