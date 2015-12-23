//
//  SimiResponder.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/7/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimiResponder : NSObject

@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSMutableArray *other;
@property (strong, nonatomic) NSError *error;

- (NSString *)responseMessage;

@end
