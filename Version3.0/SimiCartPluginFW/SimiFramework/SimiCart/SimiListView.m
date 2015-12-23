//
//  SimiListView.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiListView.h"

@implementation SimiListView
@synthesize headerSpace = _headerSpace, lineSpace = _lineSpace;

- (instancetype)init
{
    if (self = [super init]) {
        self.headerSpace = 0;
        self.lineSpace = 0;
    }
    return self;
}

- (void)reLayoutSubviews:(BOOL)updateSubviews
{
    CGFloat y = self.headerSpace;
    for (UIView *subview in self.subviews) {
        if (updateSubviews) {
            [subview sizeToFit];
        }
        // Update Frame for Subview by List style
        CGRect frame = subview.frame;
        frame.origin.y = y;
        subview.frame = frame;
        // Increase Y-axis
        y += frame.size.height + self.lineSpace;
    }
    self.contentSize = CGSizeMake(self.contentSize.width, y);
}

@end
