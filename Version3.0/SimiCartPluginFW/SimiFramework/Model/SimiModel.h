//
//  SimiModel.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 1/21/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiMutableDictionary.h"
#import "SimiAPI.h"
#import "SimiResponder.h"

@interface SimiModel : SimiMutableDictionary{
    NSString *currentNotificationName;
    NSInteger modelActionType;
    BOOL isProcessingData;
}

+ (SimiAPI *)getSimiAPI;

- (SimiAPI *)getAPI;

//Update model data
- (void)setData:(NSDictionary *)data;
- (void)addData:(NSDictionary *)data;
- (void)editData:(NSDictionary *)data;
- (void)deleteData;

/*
 Notification name: [NSString stringWithFormat:@"%@-Before", currentNotificationName]
 */
- (NSString *)currentNotificationName;
- (void)preDoRequest;
- (void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder;

@end
