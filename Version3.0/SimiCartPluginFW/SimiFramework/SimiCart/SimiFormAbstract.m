//
//  SimiFormAbstract.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiFormAbstract.h"

NSString *const SimiFormOptionInline        = @"Inline";
NSString *const SimiFormOptionActionSheet   = @"ActionSheet";
NSString *const SimiFormOptionPopover       = @"Popover";
NSString *const SimiFormOptionNavigation    = @"Navigation";

@implementation SimiFormAbstract
@synthesize form = _form, children = _children;

@synthesize title = _title, required = _required, sortOrder = _sortOrder, height = _height;

@synthesize enabled = _enabled;

- (instancetype)initWithConfig:(NSDictionary *)config
{
    if (self = [super init]) {
        self.simiObjectName = [config objectForKey:@"name"];
        self.title          = [config objectForKey:@"title"];
        self.required       = [[config objectForKey:@"required"] boolValue];
        self.sortOrder      = [[config objectForKey:@"sort_order"] integerValue];
        self.height         = [[config objectForKey:@"height"] floatValue];
        _enabled            = YES;
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    // Update Children
    for (SimiFormAbstract *child in self.children) {
        [child setEnabled:enabled];
    }
    [self.inputText setEnabled:enabled];
    if (enabled) {
        [self.inputText setTextColor:[UIColor darkTextColor]];
    } else {
        [self.inputText setTextColor:[UIColor lightGrayColor]];
    }
}

- (CGFloat)getFieldHeight
{
    if (self.height > 0.1f) {
        return self.height;
    }
    return self.form.height;
}

#pragma mark - Update form data & valid data
- (void)updateFormData:(id)value
{
    if (value == nil) {
        [self.form removeObjectForKey:self.simiObjectName];
    } else {
        [self.form setValue:value forKey:self.simiObjectName];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:SimiFormFieldDataChangedNotification object:self];
    [self.form formDataChanged:self];
}

- (BOOL)isDataValid
{
    if (self.required && self.enabled) {
        if (![self.form objectForKey:self.simiObjectName]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Text Input Elements
@synthesize inputText = _inputText;

- (BOOL)isTextInput
{
    return NO;
}

- (BOOL)moveToNextTextInput
{
    return NO;
}

- (void)becomeCurrentTextInput
{
    
}

#pragma mark - Non-Text Input Elements
@synthesize optionType = _optionType;

- (NSUInteger)numberOfSubRows
{
    return 0;
}

- (BOOL)hasInlineOptions
{
    return NO;
}

- (void)toggleShowSubRows
{
    
}

- (UITableViewCell *)cellForSubRowAtIndex:(NSUInteger)index inTable:(UITableView *)tableView
{
    return nil;
}

- (CGFloat)heightForSubRowAtIndex:(NSUInteger)index
{
    return 0;
}

- (void)selectSubRowAtIndex:(NSUInteger)index inTable:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Row Element
- (SimiFormAbstract *)addField:(NSString *)type config:(NSDictionary *)config
{
    return nil;
}

#pragma mark - Row display methods
@synthesize tblSection = _tblSection;

- (void)initTableViewCell:(UITableViewCell *)cell
{
    
}

- (void)reloadField:(UIView *)cell
{
    if ([cell isKindOfClass:[UITableViewCell class]]) {
        [cell addSubview:self];
        self.frame = CGRectMake(0, 0, self.form.view.frame.size.width, [self getFieldHeight]);
    } else {
        self.frame = cell.frame;
    }
}

- (void)reloadFieldData
{
    
}

#pragma mark - Row action
- (void)selectTableViewCell:(UITableViewCell *)cell
{
    
}

@end
