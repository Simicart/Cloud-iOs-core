//
//  SimiModelCollection.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/8/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiMutableArray.h"
#import "SimiAPI.h"
#import "SimiModel.h"
#import "SimiResponder.h"

@interface SimiModelCollection : SimiMutableArray{
    NSString *currentNotificationName;
    NSInteger modelActionType;
    BOOL isProcessingData;
}

+ (SimiAPI *)getSimiAPI;

- (SimiAPI *)getAPI;

//Action for collection model data
- (void)setData:(NSArray *)data;
- (void)addData:(NSArray *)data;

/*
 Notification name: [NSString stringWithFormat:@"%@-Before", currentNotificationName]
 */
- (NSString *)currentNotificationName;
- (void)preDoRequest;
- (void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder;
@end
