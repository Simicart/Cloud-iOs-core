//
//  SimiTreeView.h
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/17/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SimiTreeViewAlgorithm <NSObject>

- (UIView *)down:(NSString *)pattern fromView:(UIView *)view;
- (UIView *)up:(NSString *)pattern fromView:(UIView *)view;
- (NSArray *)allSubviews:(NSString *)pattern ofView:(UIView *)view;

@end

@interface SimiTreeView : NSObject

+ (id<SimiTreeViewAlgorithm>)getAlgorithm;

@end
