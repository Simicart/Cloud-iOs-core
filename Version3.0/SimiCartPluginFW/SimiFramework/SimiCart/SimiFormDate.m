//
//  SimiFormDate.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiFormDate.h"

@implementation SimiFormDate {
    BOOL isShowSubRows;
}
@synthesize datePickerMode = _datePickerMode, dateFormat = _dateFormat;

- (instancetype)initWithConfig:(NSDictionary *)config
{
    if (self = [super initWithConfig:config]) {
        self.inputText = [UITextField new];
        self.inputText.clearsOnBeginEditing = NO;
        self.inputText.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
        self.inputText.clearButtonMode = UITextFieldViewModeNever;
        self.inputText.userInteractionEnabled = NO;
        self.inputText.textColor = THEME_CONTENT_COLOR;
        //  Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [self.inputText setTextAlignment:NSTextAlignmentRight];
        }
        //  End RTL
        isShowSubRows = NO;
        if ([[config objectForKey:@"date_type"] isEqualToString:@"date"]) {
            self.datePickerMode = UIDatePickerModeDate;
        } else if ([[config objectForKey:@"date_type"] isEqualToString:@"time"]) {
            self.datePickerMode = UIDatePickerModeTime;
        } else {
            self.datePickerMode = UIDatePickerModeDateAndTime;
        }
        self.dateFormat = [config objectForKey:@"date_format"];
    }
    return self;
}

- (void)reloadField:(UIView *)cell
{
    [super reloadField:cell];
    // Config input text
    if (self.required && self.form.isShowRequiredText) {
        self.inputText.placeholder = [self.title stringByAppendingString:@" (*)"];
    } else {
        self.inputText.placeholder = self.title;
    }
    // Input Text
    [self addSubview:self.inputText];
    self.inputText.frame = CGRectMake(15, 0, self.bounds.size.width - 30, 24);
    self.inputText.center = CGPointMake(self.center.x - self.frame.origin.x, self.center.y);
}

- (void)reloadFieldData
{
    NSString *currentValue = [self.form objectForKey:self.simiObjectName];
    if (currentValue == nil) {
        self.inputText.text = nil;
        return;
    }
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:self.dateFormat];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date = [dateFormatter dateFromString:currentValue];
    
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    if (self.datePickerMode == UIDatePickerModeTime) {
        [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    } else {
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    if (self.datePickerMode == UIDatePickerModeDate) {
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    } else {
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    }
    self.inputText.text = [dateFormatter stringFromDate:date];
}

#pragma mark - Implement abstract methods
- (NSUInteger)numberOfSubRows
{
    if (isShowSubRows) {
        return 1;
    }
    return 0;
}

- (BOOL)hasInlineOptions
{
    return YES;
}

- (void)toggleShowSubRows
{
    isShowSubRows = !isShowSubRows;
}

- (UITableViewCell *)cellForSubRowAtIndex:(NSUInteger)index inTable:(UITableView *)tableView
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FormDate"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FormDate"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIDatePicker *datePicker = [UIDatePicker new];
        datePicker.tag = 111;
        datePicker.backgroundColor = [UIColor whiteColor];
        [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        [cell addSubview:datePicker];
    }
    UIDatePicker *datePicker = (UIDatePicker *)[cell viewWithTag:111];
    datePicker.frame = CGRectMake(0, 0, tableView.bounds.size.width, 162);
    [datePicker setDatePickerMode:self.datePickerMode];
    
    NSString *currentDate = [self.form objectForKey:self.simiObjectName];
    if (currentDate) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:self.dateFormat];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [datePicker setDate:[dateFormatter dateFromString:currentDate] animated:YES];
    } else {
        [datePicker setDate:[NSDate date] animated:YES];
    }
    
    return cell;
}

- (CGFloat)heightForSubRowAtIndex:(NSUInteger)index
{
    return 162;
}

#pragma mark - Date Picker Methods
- (void)dateChanged:(UIDatePicker *)datePicker
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:self.dateFormat];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [self updateFormData:[dateFormatter stringFromDate:datePicker.date]];
    [self reloadFieldData];
}

@end
