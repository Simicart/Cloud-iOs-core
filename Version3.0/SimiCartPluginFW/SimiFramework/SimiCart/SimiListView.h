//
//  SimiListView.h
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimiListView : UIScrollView
// Config List View
@property (nonatomic) CGFloat headerSpace;
@property (nonatomic) CGFloat lineSpace;

// Relayout subviews when it changed
- (void)reLayoutSubviews:(BOOL)updateSubviews;

@end
