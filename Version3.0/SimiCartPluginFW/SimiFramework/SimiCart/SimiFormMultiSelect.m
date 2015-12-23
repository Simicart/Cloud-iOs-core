//
//  SimiFormMultiSelect.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/24/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiFormMultiSelect.h"

@implementation SimiFormMultiSelect

- (void)reloadFieldData
{
    NSArray *currentValues = [self.form objectForKey:self.simiObjectName];
    if (currentValues == nil || [currentValues count] == 0) {
        self.inputText.text = nil;
    } else {
        NSMutableArray *labels = [NSMutableArray new];
        for (NSDictionary *option in self.dataSource) {
            if ([currentValues indexOfObject:[option objectForKey:@"value"]] != NSNotFound) {
                [labels addObject:[option objectForKey:@"label"]];
            }
        }
        self.inputText.text = [labels componentsJoinedByString:@", "];
    }
}

- (void)updateSelectInput:(NSArray *)selected
{
    if ([selected count]) {
        NSMutableArray *values = [NSMutableArray new];
        for (NSDictionary *option in selected) {
            [values addObject:[option objectForKey:@"value"]];
        }
        [self updateFormData:values];
    } else {
        [self updateFormData:nil];
    }
    [self reloadFieldData];
}

- (void)addSelected:(NSDictionary *)selected
{
    NSMutableArray *currentValues = [self.form objectForKey:self.simiObjectName];
    id selectedValue = [selected objectForKey:@"value"];
    if (currentValues == nil) {
        currentValues = [NSMutableArray new];
        [currentValues addObject:selectedValue];
        [self.form setValue:currentValues forKey:self.simiObjectName];
        return;
    }
    if ([currentValues indexOfObject:selectedValue] == NSNotFound) {
        if ([currentValues isKindOfClass:[NSMutableArray class]]) {
            [(NSMutableArray *)currentValues addObject:selectedValue];
        } else {
            // Convert to Mutable Array
            NSMutableArray *values = [NSMutableArray new];
            [values addObjectsFromArray:currentValues];
            [values addObject:selectedValue];
            [self.form setValue:values forKey:self.simiObjectName];
        }
    }
}

- (void)removeSelected:(NSDictionary *)selected
{
    NSMutableArray *currentValues = [self.form objectForKey:self.simiObjectName];
    if (currentValues == nil || [currentValues count] == 0) {
        return;
    }
    if (![currentValues isKindOfClass:[NSMutableArray class]]) {
        // Convert to Mutable Array
        NSMutableArray *values = [NSMutableArray new];
        [values addObjectsFromArray:currentValues];
        currentValues = values;
        [self.form setValue:currentValues forKey:self.simiObjectName];
    }
    [currentValues removeObject:[selected objectForKey:@"value"]];
}

- (NSArray *)selectedOptions
{
    NSArray *currentValues = [self.form objectForKey:self.simiObjectName];
    if (currentValues && [currentValues count]) {
        NSMutableArray *options = [NSMutableArray new];
        for (NSDictionary *option in self.dataSource) {
            if ([currentValues indexOfObject:[option objectForKey:@"value"]] != NSNotFound) {
                [options addObject:option];
            }
        }
        return options;
    }
    return nil;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self.optionType isEqualToString:SimiFormOptionNavigation]
        || [self.optionType isEqualToString:SimiFormOptionPopover]
    ) {
        if (self.optionsViewController == nil) {
            self.optionsViewController = [SimiFormSelectOptions new];
            self.optionsViewController.alphabetIndexTitles = YES;
            self.optionsViewController.isMultipleSelect = YES;
        }
    }
    return [super textFieldShouldBeginEditing:textField];
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
    cell.textLabel.text = [option objectForKey:@"label"];
    
    NSArray *currentValues = [self.form objectForKey:self.simiObjectName];
    if ([currentValues count] && [currentValues indexOfObject:[option objectForKey:@"value"]] != NSNotFound) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)selectSubRowAtIndex:(NSUInteger)index inTable:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        // Add Option
        [self addSelected:[self.dataSource objectAtIndex:index]];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        // Remove Option
        [self removeSelected:[self.dataSource objectAtIndex:index]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

@end
