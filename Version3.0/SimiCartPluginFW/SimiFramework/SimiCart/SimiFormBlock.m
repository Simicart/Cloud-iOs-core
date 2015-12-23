//
//  SimiFormBlock.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiFormBlock.h"
#import "SimiFormAbstract.h"
#import "SimiCartSelector.h"

NSString *const SimiFormDataChangedNotification         = @"SimiFormDataChangedNotification";
NSString *const SimiFormFieldDataChangedNotification    = @"SimiFormFieldDataChangedNotification";

@implementation SimiFormBlock {
    NSMutableArray *actions;
}
@synthesize selected = _selected, fields = _fields, height = _height;
@synthesize actionBtn = _actionBtn, actionTitle = _actionTitle, isShowRequiredText = _isShowRequiredText;

- (instancetype)init
{
    if (self = [super init]) {
        self.delegate = self;
        self.fields = [NSMutableArray new];
        self.height = 44;
    }
    return self;
}

#pragma mark - Form Methods
- (SimiFormAbstract *)addField:(NSString *)type config:(NSDictionary *)config
{
    NSString *fieldClass = [@"SimiForm" stringByAppendingString:type];
    SimiFormAbstract *field = [[NSClassFromString(fieldClass) alloc] initWithConfig:config];
    field.form = self;
    [self.fields addObject:field];
    // Sort order for fields
    if (!field.sortOrder) {
        field.sortOrder = [self.fields count] * 100;
    }
    // Add default Value
    if ([config objectForKey:@"value"]) {
        [self setValue:[config objectForKey:@"value"] forKey:field.simiObjectName];
    }
    if ([config objectForKey:@"enabled"]) {
        [field setEnabled:[[config objectForKey:@"enabled"] boolValue]];
    }
    return field;
}

- (SimiFormAbstract *)getFieldByName:(NSString *)name
{
    for (SimiFormAbstract *field in self.fields) {
        if ([field.simiObjectName isEqualToString:name]) {
            return field;
        } else if ([field.children count]) {
            for (SimiFormAbstract *child in field.children) {
                if ([child.simiObjectName isEqualToString:name]) {
                    return child;
                }
            }
        }
    }
    return nil;
}

- (void)sortFormFields
{
    [self.fields sortUsingComparator:^NSComparisonResult(SimiFormAbstract *field1, SimiFormAbstract *field2) {
        if (field1.sortOrder > field2.sortOrder) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
}

- (SimiFormAbstract *)getFieldAtIndex:(NSUInteger)index subIndex:(NSUInteger *)subIndex
{
    *subIndex = NSNotFound;
    if (self.selected == nil) {
        return [self.fields objectAtIndex:index];
    }
    NSUInteger selectedIndex = [self.fields indexOfObject:self.selected];
    NSUInteger numberOfSubRows = [self.selected numberOfSubRows];
    if (index <= selectedIndex) {
        return [self.fields objectAtIndex:index];
    }
    if (index > selectedIndex + numberOfSubRows) {
        return [self.fields objectAtIndex:(index - numberOfSubRows)];
    }
    *subIndex = index - selectedIndex - 1;
    return self.selected;
}

- (void)setFormData:(NSDictionary *)data
{
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isEqual:[NSNull null]]) {
            [self removeObjectForKey:key];
        } else {
            [self setValue:obj forKey:key];
        }
    }];
}

- (void)addTarget:(id)target action:(SEL)action
{
    if (actions == nil) {
        actions = [NSMutableArray new];
    }
    [actions addObject:[[SimiCartSelector alloc] initWithTarget:target action:action]];
}

- (void)addTargetUsingBlock:(void (^)())block
{
    if (actions == nil) {
        actions = [NSMutableArray new];
    }
    [actions addObject:block];
}

- (void)invokeActions
{
    for (id action in actions) {
        if ([action isKindOfClass:[SimiCartSelector class]]) {
            [(SimiCartSelector *)action invoke:self];
        } else {
            ((void (^)())action)();
        }
    }
}

- (BOOL)hasRequiredField
{
    for (SimiFormAbstract *field in self.fields) {
        if (field.required) {
            return YES;
        } else if ([field.children count]) {
            for (SimiFormAbstract *child in field.children) {
                if (child.required) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (BOOL)isDataValid
{
    for (SimiFormAbstract *field in self.fields) {
        if (![field isDataValid]) {
            return NO;
        }
    }
    return YES;
}

- (void)formDataChanged:(SimiFormAbstract *)field
{
    if ([self.delegate respondsToSelector:@selector(didFormDataChanged:field:)]) {
        [(id<SimiFormDelegate>)self.delegate didFormDataChanged:self field:field];
    }
    if (field) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SimiFormDataChangedNotification object:self userInfo:@{@"field":field}];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SimiFormDataChangedNotification object:self];
    }
}

#pragma mark - Form Block Delegate
- (void)didFormDataChanged:(id)form field:(SimiFormAbstract *)field
{
    // Form Block Delegate Method - Form Data Changed
    if (self.actionBtn) {
        [self.actionBtn setEnabled:[self isDataValid]];
    }
}

#pragma mark - Block Methods
- (UIView *)showingViewPhone:(UIView *)view on:(UIView *)parent
{
    UITableView *tableView = (UITableView *)view;
    if (tableView == nil) {
        tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    }
    [self sortFormFields];
    // Update Keyboard Input
    BOOL isLastItem = YES;
    for (NSInteger i = [self.fields count] - 1; i >= 0; i--) {
        SimiFormAbstract *field = [self.fields objectAtIndex:i];
        if ([field isTextInput]) {
            if (isLastItem) {
                field.inputText.returnKeyType = UIReturnKeyDone;
                isLastItem = NO;
            } else {
                field.inputText.returnKeyType = UIReturnKeyNext;
            }
        } else if ([field.children count]) {
            for (NSInteger j = [field.children count] - 1; j >= 0; j--) {
                SimiFormAbstract *child = [field.children objectAtIndex:j];
                if (isLastItem) {
                    child.inputText.returnKeyType = UIReturnKeyDone;
                    isLastItem = NO;
                } else {
                    child.inputText.returnKeyType = UIReturnKeyNext;
                }
            }
        }
    }
    // End Update Keyboard Input
    tableView.dataSource = self;
    tableView.delegate = self;
    [tableView reloadData];
    return tableView;
}

#pragma mark - Table View Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.fields count] + [self.selected numberOfSubRows];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger subIndex;
    SimiFormAbstract *field = [self getFieldAtIndex:[indexPath row] subIndex:&subIndex];
    if (subIndex != NSNotFound) {
        return [field cellForSubRowAtIndex:subIndex inTable:tableView];
    }
    NSString *CellID = field.simiObjectName ? field.simiObjectName : [[field class] description];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
        [field initTableViewCell:cell];
    }
    field.tblSection = indexPath.section;
    [field reloadField:cell];
    [field reloadFieldData];
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

#pragma mark - Table View Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger subIndex;
    SimiFormAbstract *field = [self getFieldAtIndex:[indexPath row] subIndex:&subIndex];
    if (subIndex != NSNotFound) {
        CGFloat height = [field heightForSubRowAtIndex:subIndex];
        if (height > 0.1f) {
            return height;
        }
    }
    return [field getFieldHeight];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 0;
//}

//  Liam Update RTL
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0 && self.isShowRequiredText && [self hasRequiredField]) {
        return [@"(*): " stringByAppendingString:SCLocalizedString(@"required")];
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        if (section == 0 && self.isShowRequiredText && [self hasRequiredField]) {
            UIView *view = [UIView new];
            UILabel *lblHeader = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, CGRectGetWidth(tableView.frame) - 20, 44)];
            [lblHeader setText:[NSString stringWithFormat:@"%@ :(*)", [SCLocalizedString(@"required") uppercaseString]]];
            [lblHeader setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2]];
            [lblHeader setTextColor:[UIColor lightGrayColor]];
            [lblHeader setTextAlignment:NSTextAlignmentRight];
            [view addSubview:lblHeader];
            return view;
        }
    }
    return nil;
}
//  End Update RTL

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (self.actionBtn == nil && self.actionTitle) {
        self.actionBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 22, tableView.frame.size.width - 30, self.height)];
        [self.actionBtn setTitle:self.actionTitle forState:UIControlStateNormal];
        [self.actionBtn setBackgroundImage:[[SimiGlobalVar sharedInstance] imageFromColor:THEME_COLOR] forState:UIControlStateNormal];
        [self.actionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.actionBtn.layer setCornerRadius:3.0f];
        [self.actionBtn.layer setMasksToBounds:YES];
        [self.actionBtn setAdjustsImageWhenHighlighted:YES];
        [self.actionBtn setAdjustsImageWhenDisabled:YES];
        [self.actionBtn setEnabled:[self isDataValid]];
    }
    if (self.actionBtn) {
        [self.actionBtn addTarget:self action:@selector(invokeActions) forControlEvents:UIControlEventTouchUpInside];
        return self.actionBtn.frame.size.height + 44;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (self.actionBtn || self.actionTitle) {
        return @"";
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    if (self.actionBtn) {
        [view addSubview:self.actionBtn];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger subIndex;
    SimiFormAbstract *field = [self getFieldAtIndex:[indexPath row] subIndex:&subIndex];
    if (subIndex != NSNotFound) {
        [field selectSubRowAtIndex:subIndex inTable:tableView indexPath:indexPath];
        [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:([indexPath row] - subIndex - 1) inSection:[indexPath section]]] withRowAnimation:UITableViewRowAnimationNone];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [field selectTableViewCell:cell];
    if ([field hasInlineOptions]) {
        if ([self.selected isEqual:field]) {
            if ([field numberOfSubRows]) {
                // Hide subrows
                NSUInteger numberOfSubRows = [field numberOfSubRows];
                [field toggleShowSubRows];
                [tableView deleteRowsAtIndexPaths:[self subRowIndexPaths:numberOfSubRows inSection:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                // Show subrows
                [field toggleShowSubRows];
                [tableView insertRowsAtIndexPaths:[self subRowIndexPaths:[field numberOfSubRows] inSection:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            }
        } else {
            if ([self.selected numberOfSubRows]) {
                // Hide old subrows
                NSUInteger numberOfSubRows = [self.selected numberOfSubRows];
                [self.selected toggleShowSubRows];
                [tableView deleteRowsAtIndexPaths:[self subRowIndexPaths:numberOfSubRows inSection:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            }
            // Show new subrows
            self.selected = field;
            [field toggleShowSubRows];
            [tableView insertRowsAtIndexPaths:[self subRowIndexPaths:[field numberOfSubRows] inSection:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSArray *)subRowIndexPaths:(NSUInteger)numberOfSubRows inSection:(NSUInteger)section
{
    NSMutableArray *result = [NSMutableArray new];
    NSUInteger startIndex = [self.fields indexOfObject:self.selected] + 1;
    for (NSUInteger i = 0; i < numberOfSubRows; i++) {
        [result addObject:[NSIndexPath indexPathForRow:(startIndex + i) inSection:section]];
    }
    return result;
}

#pragma mark - Scroll view delegate
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    for (SimiFormAbstract *field in self.fields) {
        if (field.inputText && [field.inputText isFirstResponder]) {
            [field.inputText resignFirstResponder];
            break;
        }
    }
}

@end
