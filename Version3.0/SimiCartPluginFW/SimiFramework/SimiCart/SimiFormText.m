//
//  SimiFormText.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiFormText.h"

@implementation SimiFormText

- (instancetype)initWithConfig:(NSDictionary *)config
{
    if (self = [super initWithConfig:config]) {
        // init input text element
        self.inputText = [UITextField new];
        self.inputText.delegate = self;
        self.inputText.clearsOnBeginEditing = NO;
        
        [self.inputText addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingChanged];
        [self.inputText addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
        self.inputText.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
        [self.inputText setTextColor:THEME_CONTENT_COLOR];
        self.inputText.clearButtonMode = UITextFieldViewModeWhileEditing;
        //  Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [self.inputText setTextAlignment:NSTextAlignmentRight];
        }
        //  End RTL
    }
    return self;
}

- (BOOL)isDataValid
{
    if (self.required && self.enabled) {
        NSString *value = [self.form objectForKey:self.simiObjectName];
        if (!value || [value isEqualToString:@""]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Text field delegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self updateFormData:textField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return ![self moveToNextTextInput];
}

#pragma mark - Text Input
- (BOOL)isTextInput
{
    return YES;
}

- (BOOL)moveToNextTextInput
{
    BOOL nextField = NO;
    for (SimiFormAbstract *field in self.form.fields) {
        if ([field.children count]) {
            for (SimiFormAbstract *child in field.children) {
                if ([child isEqual:self]) {
                    nextField = YES;
                    continue;
                }
                if (nextField && [child isTextInput] && field.enabled) {
                    [child becomeCurrentTextInput];
                    return nextField;
                }
            }
        }
        if ([field isEqual:self]) {
            nextField = YES;
            continue;
        }
        if (nextField && [field isTextInput] && field.enabled) {
            [field becomeCurrentTextInput];
            return nextField;
        }
    }
    return NO;
}

- (void)becomeCurrentTextInput
{
    if ([self.form.view isKindOfClass:[UITableView class]]) {
        // Scroll to current view
        SimiFormAbstract *current = self;
        if ([[self superview] isKindOfClass:[SimiFormAbstract class]]) {
            current = (SimiFormAbstract *)[self superview];
        }
        NSUInteger row = [self.form.fields indexOfObject:current];
        if (self.form.selected && row > [self.form.fields indexOfObject:self.form.selected]) {
            row += [self.form.selected numberOfSubRows];
        }
        [(UITableView *)self.form.view scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:self.tblSection] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    [self.inputText performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.25];
}

#pragma mark - Display text input
- (void)reloadField:(UIView *)cell
{
    [super reloadField:cell];
    // Config input text
    if (self.required && self.form.isShowRequiredText) {
        self.inputText.placeholder = [self.title stringByAppendingString:@" (*)"];
        self.inputText.attributedPlaceholder = [[NSAttributedString alloc]initWithString:[self.title stringByAppendingString:@" (*)"] attributes:@{NSForegroundColorAttributeName:THEME_CONTENT_PLACEHOLDER_COLOR}];
        //  Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            self.inputText.placeholder = [NSString stringWithFormat:@"(*) %@",self.title];
        }
        //  End RTL
    } else {
        self.inputText.attributedPlaceholder = [[NSAttributedString alloc]initWithString:self.title attributes:@{NSForegroundColorAttributeName:THEME_CONTENT_PLACEHOLDER_COLOR}];
    }
    [self addSubview:self.inputText];
    self.inputText.frame = CGRectMake(15, 0, self.bounds.size.width - 30, 24);
    self.inputText.center = CGPointMake(self.center.x - self.frame.origin.x, self.center.y);
}

- (void)reloadFieldData
{
    self.inputText.text = [self.form objectForKey:self.simiObjectName];
}

- (void)selectTableViewCell:(UITableViewCell *)cell
{
    [self.inputText becomeFirstResponder];
}

@end
