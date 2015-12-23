//
//  SimiFormBoolean.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiFormBoolean.h"

@implementation SimiFormBoolean
@synthesize switcher = _switcher;

- (instancetype)initWithConfig:(NSDictionary *)config
{
    if (self = [super initWithConfig:config]) {
        self.switcher = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 51, 31)];
        [self.switcher addTarget:self action:@selector(changeSwitcher) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void)reloadField:(UITableViewCell *)cell
{
    if ([cell isKindOfClass:[UITableViewCell class]]) {
        cell.accessoryView = self.switcher;
        cell.textLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
        cell.textLabel.text = self.title;
    } else {
        [cell addSubview:self.switcher];
    }
}

- (void)reloadFieldData
{
    [self.switcher setOn:[[self.form objectForKey:self.simiObjectName] boolValue]];
}

- (void)changeSwitcher
{
    [self updateFormData:[NSNumber numberWithBool:self.switcher.on]];
}

@end
