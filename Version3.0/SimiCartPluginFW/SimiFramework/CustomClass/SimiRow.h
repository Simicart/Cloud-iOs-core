//
//  SimiRow.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/25/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimiRow : NSObject

@property (strong, nonatomic) NSString *identifier;
@property (nonatomic) CGFloat height;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSMutableDictionary *data;
@property (nonatomic) UITableViewCellAccessoryType accessoryType;

@property (nonatomic) NSInteger sortOrder; // Sort Row in a Section

- (instancetype)initWithIdentifier:(NSString *)identifier height:(double)height;

// Working with Row and action
- (instancetype)initWithIdentifier:(NSString *)identifier height:(CGFloat)height sortOrder:(NSInteger)order;
- (void)addTarget:(id)target action:(SEL)action;
- (void)addTargetUsingBlock:(void (^)())block;
- (void)invokeActions;

@end
