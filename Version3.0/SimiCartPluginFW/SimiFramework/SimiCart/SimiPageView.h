//
//  SimiPageView.h
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimiPageView : UIScrollView
// Config Page View
@property (nonatomic) UIEdgeInsets pageMargin;
@property (nonatomic) CGFloat itemSpace, lineSpace;

// Relayout subviews when it changed
- (void)reLayoutSubviews:(BOOL)updateSubviews;

@end
