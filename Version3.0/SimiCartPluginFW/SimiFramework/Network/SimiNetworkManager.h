//
//  SimiNetworkManager.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 1/17/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPSessionManager.h"
#import "AFNetworkReachabilityManager.h"

@interface SimiNetworkManager : NSObject

@property (nonatomic) BOOL reachable;
@property (nonatomic) BOOL isSecure;
@property (strong, nonatomic) NSMutableDictionary *headerParams;

+(SimiNetworkManager *)sharedInstance;
- (void)requestWithMethod:(NSString *)method urlPath:(NSString *)urlPath parameters:(NSDictionary *)params target:(id)target selector:(SEL)selector header:(NSDictionary *)header;

@end
