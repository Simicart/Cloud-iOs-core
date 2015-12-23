//
//  SimiFormTextArea.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiFormTextArea.h"

@implementation SimiFormTextArea
@synthesize textArea = _textArea;

- (instancetype)initWithConfig:(NSDictionary *)config
{
    if (self = [super initWithConfig:config]) {
        self.textArea = [UITextView new];
        self.textArea.delegate = self;
        self.textArea.font = self.inputText.font;
        
        self.inputText.clearButtonMode = UITextFieldViewModeNever;
    }
    return self;
}

- (void)initTableViewCell:(UITableViewCell *)cell
{
    [super initTableViewCell:cell];
    self.textArea.returnKeyType = self.inputText.returnKeyType;
}

- (void)reloadField:(UIView *)cell
{
    [super reloadField:cell];
    // Modify input text
    self.inputText.frame = CGRectMake(15, 7, self.bounds.size.width - 30, 24);
    
    [self addSubview:self.textArea];
    self.textArea.frame = CGRectMake(15, 7, self.bounds.size.width - 30, self.bounds.size.height - 14);
}

- (void)reloadFieldData
{
    self.textArea.text = [self.form objectForKey:self.simiObjectName];
    [self textViewDidChange:self.textArea];
}

#pragma mark - Text view methods
- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text == nil || [textView.text isEqualToString:@""]) {
        self.inputText.hidden = NO;
    } else {
        self.inputText.hidden = YES;
    }
    [self updateFormData:textView.text];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self moveToNextTextInput];
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
        [(UITableView *)self.form.view scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:self.tblSection] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    [self.textArea performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.25];
}

@end
