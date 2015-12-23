//
//  SimiPageView.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiPageView.h"

@implementation SimiPageView
@synthesize pageMargin = _pageMargin, itemSpace = _itemSpace, lineSpace = _lineSpace;

- (instancetype)init
{
    if (self = [super init]) {
        _pageMargin = UIEdgeInsetsZero;
        _itemSpace = 0;
        _lineSpace = 0;
    }
    return self;
}

- (void)reLayoutSubviews:(BOOL)updateSubviews
{
    CGFloat x = self.pageMargin.left;
    CGFloat y = self.pageMargin.top;
    CGFloat maxX = self.bounds.size.width - self.pageMargin.right;
    CGFloat maxY = 0;
    for (UIView *subview in self.subviews) {
        if (updateSubviews) {
            [subview sizeToFit];
        }
        CGRect frame = subview.frame;
        // Finding the best position
        if (frame.size.width > maxX - self.pageMargin.left) {
            frame.size.width = maxX - self.pageMargin.left;
        }
        if (x + frame.size.width > maxX && x > self.pageMargin.left) {
            // NEW LINE
            x = self.pageMargin.left;
            y += maxY + self.lineSpace;
            maxY = frame.size.height;
        } else {
            // CURRENT LINE
            maxY = MAX(maxY, frame.size.height);
        }
        // Draw Subview
        frame.origin.x = x;
        frame.origin.y = y;
        subview.frame = frame;
        // Update current position
        x += frame.size.width + self.itemSpace;
    }
    self.contentSize = CGSizeMake(self.contentSize.width, y + maxY + self.pageMargin.bottom);
}

@end
