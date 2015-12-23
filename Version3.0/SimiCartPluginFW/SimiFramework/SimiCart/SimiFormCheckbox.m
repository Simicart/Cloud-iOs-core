//
//  SimiFormCheckbox.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiFormCheckbox.h"
#import "M13Checkbox.h"

@interface SimiFormCheckbox()
@property (strong, nonatomic) M13Checkbox *checkbox;
@end

@implementation SimiFormCheckbox
@synthesize checkbox = _checkbox;

- (instancetype)initWithConfig:(NSDictionary *)config
{
    if (self = [super initWithConfig:config]) {
        self.checkbox = [[M13Checkbox alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        self.checkbox.strokeColor = [UIColor grayColor];
        [self.checkbox addTarget:self action:@selector(changeCheckbox) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void)changeCheckbox
{
    if ([self.checkbox checkState] == M13CheckboxStateChecked) {
        [self updateFormData:@1];
    } else {
        [self updateFormData:nil];
    }
}

#pragma mark - Form Abstract Methods
- (void)reloadField:(UITableViewCell *)cell
{
    if ([cell isKindOfClass:[UITableViewCell class]]) {
        cell.accessoryView = self.checkbox;
        cell.textLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
        cell.textLabel.text = self.title;
    }
}

- (void)reloadFieldData
{
    if ([[self.form objectForKey:self.simiObjectName] boolValue]) {
        [self.checkbox setCheckState:M13CheckboxStateChecked];
    } else {
        [self.checkbox setCheckState:M13CheckboxStateUnchecked];
    }
}

- (void)selectTableViewCell:(UITableViewCell *)cell
{
    [self.checkbox toggleCheckState];
    [self changeCheckbox];
}

@end
