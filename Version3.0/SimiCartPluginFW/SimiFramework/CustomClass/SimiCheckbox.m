//
//  SimiCheckbox.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 7/11/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiCheckbox.h"

@implementation SimiCheckbox

- (id)initWithTitle:(NSString *)title
{
    if (self = [super initWithTitle:title]) {
        [self setCheckAlignment:M13CheckboxAlignmentLeft];
        self.strokeColor = [UIColor grayColor];
        self.checkColor = [UIColor darkGrayColor];
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.titleLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
        self.titleLabel.textColor = THEME_TEXT_COLOR;
    }
    return self;
}

@end
