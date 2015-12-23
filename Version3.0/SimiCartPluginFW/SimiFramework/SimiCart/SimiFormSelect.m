//
//  SimiFormSelect.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiFormSelect.h"

@implementation SimiFormSelect {
    BOOL isShowSubRows;
}
@synthesize dataSource = _dataSource, optionHeight = _optionHeight;
@synthesize valueField = _valueField, labelField = _labelField;
@synthesize indexTitles = _indexTitles, searchable = _searchable;
@synthesize optionsViewController = _optionsViewController, optionsPopover = _optionsPopover, navController = _navController;

- (instancetype)initWithConfig:(NSDictionary *)config
{
    if (self = [super initWithConfig:config]) {
        self.inputText = [UITextField new];
        self.inputText.delegate = self;
        self.inputText.clearsOnBeginEditing = NO;
        
        self.inputText.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
        self.inputText.clearButtonMode = UITextFieldViewModeAlways;
        [self.inputText setTextColor:THEME_CONTENT_COLOR];
        //  Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [self.inputText setTextAlignment:NSTextAlignmentRight];
        }
        //  End RTL
        
        self.dataSource = [config objectForKey:@"source"];
        self.optionType = [config objectForKey:@"option_type"];
        if (self.optionType == nil) {
            self.optionType = SimiFormOptionInline;
        }
        isShowSubRows = NO;
        self.optionHeight = [[config objectForKey:@"option_height"] floatValue];
        if ([self.optionType isEqualToString:SimiFormOptionInline]
            || [self.optionType isEqualToString:SimiFormOptionNavigation]
        ) {
            self.inputText.clearButtonMode = UITextFieldViewModeNever;
            self.inputText.userInteractionEnabled = NO;
        }
        self.optionsViewController = [config objectForKey:@"options_view_controller"];
        self.navController = [config objectForKey:@"nav_controller"];
        
        self.valueField = [config objectForKey:@"value_field"];
        if (self.valueField == nil) {
            self.valueField = @"value";
        }
        self.labelField = [config objectForKey:@"label_field"];
        if (self.labelField == nil) {
            self.labelField = @"label";
        }
        self.indexTitles = [[config objectForKey:@"index_titles"] boolValue];
        self.searchable = [[config objectForKey:@"searchable"] boolValue];
    }
    return self;
}

- (void)reloadField:(UIView *)cell
{
    [super reloadField:cell];
    // Config input text
    if (self.required && self.form.isShowRequiredText) {
        self.inputText.attributedPlaceholder = [[NSAttributedString alloc]initWithString:[self.title stringByAppendingString:@" (*)"] attributes:@{NSForegroundColorAttributeName:THEME_CONTENT_PLACEHOLDER_COLOR}];
    } else {
        self.inputText.attributedPlaceholder = [[NSAttributedString alloc]initWithString:self.title attributes:@{NSForegroundColorAttributeName:THEME_CONTENT_PLACEHOLDER_COLOR}];
    }
    // Add Input Text for Select
    [self addSubview:self.inputText];
    self.inputText.frame = CGRectMake(15, 0, self.bounds.size.width - 30, 24);
    self.inputText.center = CGPointMake(self.center.x - self.frame.origin.x, self.center.y);
    if ([cell isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *tableCell = (UITableViewCell *)cell;
        if ([self.optionType isEqualToString:SimiFormOptionNavigation]) {
            CGRect frame = self.inputText.frame;
            frame.size.width -= 24;
            self.inputText.frame = frame;
            tableCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            tableCell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

- (void)reloadFieldData
{
    id currentValue = [self.form objectForKey:self.simiObjectName];
    if (currentValue == nil) {
        self.inputText.text = nil;
    } else {
        for (NSDictionary *value in self.dataSource) {
            if ([[value objectForKey:self.valueField] isEqual:currentValue]) {
                self.inputText.text = [value objectForKey:self.labelField];
                return;
            }
        }
        if ([currentValue isKindOfClass:[NSString class]]) {
            self.inputText.text = currentValue;
        } else {
            self.inputText.text = [currentValue stringValue];
        }
    }
}

#pragma mark - Text field and select data
- (void)updateSelectInput:(NSArray *)selected
{
    for (NSDictionary *select in selected) {
        [self addSelected:select];
    }
    [self reloadFieldData];
}

- (void)addSelected:(NSDictionary *)selected
{
    [self updateFormData:[selected objectForKey:self.valueField]];
    [self reloadFieldData];
}

- (NSArray *)selectedOptions
{
    id currentValue = [self.form objectForKey:self.simiObjectName];
    if (currentValue) {
        for (NSDictionary *value in self.dataSource) {
            if ([[value objectForKey:self.valueField] isEqual:currentValue]) {
                return @[value];
            }
        }
    }
    return nil;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.inputText.text = nil;
    [self updateFormData:nil];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self.optionType isEqualToString:SimiFormOptionActionSheet]) {
        // Action Sheet
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:self.title delegate:self cancelButtonTitle:SCLocalizedString(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:nil];
        for (NSDictionary *option in self.dataSource) {
            [actionSheet addButtonWithTitle:[option objectForKey:self.labelField]];
        }
        [actionSheet showFromRect:textField.bounds inView:textField animated:YES];
    } else if ([self.optionType isEqualToString:SimiFormOptionNavigation]) {
        // Push to navigation
        if (self.optionsViewController == nil) {
            self.optionsViewController = [SimiFormSelectOptions new];
            self.optionsViewController.alphabetIndexTitles = self.indexTitles;
            self.optionsViewController.searchable = self.searchable;
        }
        self.optionsViewController.formSelect = self;
        [self.navController pushViewController:self.optionsViewController animated:YES];
        // Reload Selected
        [self.optionsViewController.selected removeAllObjects];
        for (NSDictionary *option in [self selectedOptions]) {
            [self.optionsViewController.selected addObject:option];
        }
        [self.optionsViewController reloadData];
    } else if ([self.optionType isEqualToString:SimiFormOptionPopover]) {
        // Popover
        if (self.optionsPopover == nil) {
            if (self.optionsViewController == nil) {
                self.optionsViewController = [SimiFormSelectOptions new];
                self.optionsViewController.alphabetIndexTitles = self.indexTitles;
                self.optionsViewController.searchable = self.searchable;
            }
            self.optionsViewController.formSelect = self;
            self.optionsPopover = [[UIPopoverController alloc] initWithContentViewController:self.optionsViewController];
            self.optionsPopover.delegate = self.optionsViewController;
        }
        self.optionsPopover.popoverContentSize = [self.optionsViewController reloadContentSize];
        [self.optionsPopover presentPopoverFromRect:self.inputText.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        // Reload Selected
        [self.optionsViewController.selected removeAllObjects];
        for (NSDictionary *option in [self selectedOptions]) {
            [self.optionsViewController.selected addObject:option];
        }
        [self.optionsViewController reloadData];
    }
    return NO;
}

#pragma mark - Actionsheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        [self addSelected:[self.dataSource objectAtIndex:buttonIndex - 1]];
    }
}

#pragma mark - Implement abstract methods
- (NSUInteger)numberOfSubRows
{
    if (isShowSubRows && [self hasInlineOptions]) {
        return [self.dataSource count];
    }
    return 0;
}

- (BOOL)hasInlineOptions
{
    return (BOOL)(self.optionType == SimiFormOptionInline && [self.dataSource count]);
}

- (void)toggleShowSubRows
{
    isShowSubRows = !isShowSubRows;
}

- (UITableViewCell *)cellForSubRowAtIndex:(NSUInteger)index inTable:(UITableView *)tableView
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FormSelect"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FormSelect"];
        cell.textLabel.font = self.inputText.font;
        cell.backgroundColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1];
    }
    
    NSDictionary *option = [self.dataSource objectAtIndex:index];
    cell.textLabel.text = [option objectForKey:self.labelField];
    
    id currentValue = [self.form objectForKey:self.simiObjectName];
    if ([[option objectForKey:self.valueField] isEqual:currentValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        [cell.textLabel setTextAlignment:NSTextAlignmentRight];
    }
    
    return cell;
}

- (CGFloat)heightForSubRowAtIndex:(NSUInteger)index
{
    return self.optionHeight;
}

- (void)selectSubRowAtIndex:(NSUInteger)index inTable:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    // Deselect Old
    NSUInteger start = [indexPath row] - index;
    for (NSUInteger i = 0; i < [self numberOfSubRows]; i++) {
        if (i == index) {
            continue;
        }
        [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:start+i inSection:[indexPath section]]].accessoryType = UITableViewCellAccessoryNone;
    }
    // Select Value
    [self addSelected:[self.dataSource objectAtIndex:index]];
    // Select current
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)selectTableViewCell:(UITableViewCell *)cell
{
    [self textFieldShouldBeginEditing:self.inputText];
}

@end
