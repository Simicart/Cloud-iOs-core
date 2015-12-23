//
//  SimiNetworkManager.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 1/17/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiNetworkManager.h"

@implementation SimiNetworkManager

@synthesize reachable, headerParams, isSecure;

+ (SimiNetworkManager *)sharedInstance{
    static SimiNetworkManager *_sharedInstance = nil;
    static dispatch_once_t onePredicate;
    dispatch_once(&onePredicate, ^{
        _sharedInstance = [[SimiNetworkManager alloc] init];
    });
    return _sharedInstance;
}

- (id)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachable) name:AFNetworkingReachabilityDidChangeNotification object:nil];
        isSecure = YES;
        headerParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"Bearer %@",kSimiKey], @"Authorization", nil];
    }
    return self;
}

- (BOOL)reachable{
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

- (void)requestWithMethod:(NSString *)method urlPath:(NSString *)urlPath parameters:(NSDictionary *)params target:(id)target selector:(SEL)selector header:(NSDictionary *)header{
    if (SIMI_DEBUG_ENABLE) {
        NSLog(@"Request: %@", urlPath);
        NSLog(@"Params: %@", params);
    }
    //Add Header
    AFHTTPRequestSerializer *request = [[AFHTTPRequestSerializer alloc] init];
    if (isSecure && headerParams.count > 0) {
        NSArray *keys = [headerParams allKeys];
        for (NSString *key in keys) {
            [request setValue:[headerParams valueForKey:key] forHTTPHeaderField:key];
        }
        if ([method isEqualToString:POST] || [method isEqualToString:PUT] ) {
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        }
    }
    if (header != nil) {
        for (NSString *key in [header allKeys]) {
            [request setValue:[header valueForKey:key] forHTTPHeaderField:key];
        }
    }
    
    AFHTTPRequestOperationManager *operationManager = [AFHTTPRequestOperationManager manager];
    [operationManager setRequestSerializer:request];
    
    AFHTTPResponseSerializer *serializer = [AFHTTPResponseSerializer serializer];
    [serializer setAcceptableContentTypes:nil];
    [operationManager setResponseSerializer:serializer];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([[method uppercaseString] isEqualToString:@"POST"]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
        NSString *string = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
        [operationManager POST:urlPath parameters:string success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if (target != nil && selector != nil) {
                if (SIMI_DEBUG_ENABLE) {
                    NSLog(@"Response String: %@", [operation responseString]);
                }
                [target performSelector:selector withObject:responseObject];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (target != nil && selector != nil) {
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                if (SIMI_DEBUG_ENABLE) {
                    NSLog(@"Request Error: %@", [error localizedDescription]);
                }
                [target performSelector:selector withObject:error];
            }
            NSLog(@"Failure: %@", error);
        }];
    }else if ([[method uppercaseString] isEqualToString:@"GET"]){
        [operationManager GET:urlPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if (target != nil && selector != nil) {
                if (SIMI_DEBUG_ENABLE){
                    NSLog(@"Response String: %@", [operation responseString]);
                }
                [target performSelector:selector withObject:responseObject];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if (SIMI_DEBUG_ENABLE) {
                NSLog(@"Request Error: %@", [error localizedDescription]);
            }
            if (target != nil && selector != nil) {
                [target performSelector:selector withObject:error];
            }
        }];
    }else if ([[method uppercaseString] isEqualToString:@"PUT"]){
        NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
        NSString *string = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
        [operationManager PUT:urlPath parameters:string success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if (target != nil && selector != nil) {
                if (SIMI_DEBUG_ENABLE){
                    NSLog(@"Response String: %@", [operation responseString]);
                }
                [target performSelector:selector withObject:responseObject];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if (SIMI_DEBUG_ENABLE) {
                NSLog(@"Request Error: %@", [error localizedDescription]);
            }
            if (target != nil && selector != nil) {
                [target performSelector:selector withObject:error];
            }
        }];
    }else if ([[method uppercaseString] isEqualToString:@"DELETE"]){
        [operationManager DELETE:urlPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if (target != nil && selector != nil) {
                if (SIMI_DEBUG_ENABLE){
                    NSLog(@"Response String: %@", [operation responseString]);
                }
                [target performSelector:selector withObject:responseObject];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if (SIMI_DEBUG_ENABLE) {
                NSLog(@"Request Error: %@", [error localizedDescription]);
            }
            if (target != nil && selector != nil) {
                [target performSelector:selector withObject:error];
            }
        }];
    }
#pragma clang diagnostic pop
}

@end
