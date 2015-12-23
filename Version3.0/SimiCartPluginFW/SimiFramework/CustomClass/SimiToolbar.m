//
//  SimiToolbar.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/26/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiToolbar.h"

@implementation SimiToolbar

@synthesize doneButton, cancelButton, fixedSpace;

- (id)initWithFrame:(CGRect)frame
{
    frame.size.height = 44;
    self = [super initWithFrame:frame];
    if (self) {
        [self setBarStyle:UIBarStyleDefault];
        self.autoresizesSubviews = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
        doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(didClickToolbarButton:)];
        cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(didClickToolbarButton:)];
        fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixedSpace.width = 196*frame.size.width/320;
        [self setItems:[NSArray arrayWithObjects:cancelButton, fixedSpace, doneButton, nil]];
    }
    return self;
}

- (void)didClickToolbarButton:(id)sender{
    UIBarButtonItem *item = (UIBarButtonItem *)sender;
    if ([item isEqual:doneButton]) {
        [self.delegate toolbarDidClickDoneButton:self];
    }else{
        [self.delegate toolbarDidClickCancelButton:self];
    }
}

@end
