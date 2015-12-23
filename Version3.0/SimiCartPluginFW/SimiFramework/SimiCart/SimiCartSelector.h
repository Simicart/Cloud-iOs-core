//
//  SimiCartSelector.h
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/19/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimiCartSelector : NSObject
@property (weak, nonatomic) id target;
@property (nonatomic) SEL action;

- (instancetype)initWithTarget:(id)target action:(SEL)action;
- (void)invoke:(id)object; // Run selector with object

@end
