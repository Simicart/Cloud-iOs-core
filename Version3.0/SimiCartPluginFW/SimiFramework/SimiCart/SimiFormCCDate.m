//
//  SimiFormCCDate.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiFormCCDate.h"

@implementation SimiFormCCDate {
    NSUInteger length;
}
@synthesize yearName = _yearName;

- (instancetype)initWithConfig:(NSDictionary *)config
{
    if (self = [super initWithConfig:config]) {
        [self.inputText setKeyboardType:UIKeyboardTypeNumberPad];
        
        self.yearName = [config objectForKey:@"year_name"];
    }
    return self;
}

- (void)reloadField:(UIView *)cell
{
    [super reloadField:cell];
    self.inputText.placeholder = self.title;
}

- (void)reloadFieldData
{
    NSString *month = [self.form objectForKey:self.simiObjectName];
    NSString *year  = [self.form objectForKey:self.yearName];
    if (month && year && [month isKindOfClass:[NSString class]] && [year isKindOfClass:[NSString class]]) {
        while ([month length] < 2) {
            month = [@"0" stringByAppendingString:month];
        }
        year = [year substringFromIndex:2];
        while ([year length] < 2) {
            year = [@"0" stringByAppendingString:year];
        }
        self.inputText.text = [NSString stringWithFormat:@"%@/%@", month, year];
    }
}

#pragma mark - Update form Data
- (void)updateFormData:(NSString *)value
{
    // Refine Text
    if (length > [value length]) {
        // Deleting Text
        if ([value length] == 2) {
            value = [value substringToIndex:1];
            self.inputText.text = value;
        }
    } else {
        // Typing
        if ([value length] == 2) {
            value = [value stringByAppendingString:@"/"];
            self.inputText.text = value;
        }
        if ([value length] > 5) {
            value = [value substringToIndex:5];
            self.inputText.text = value;
        }
    }
    length = [value length];
    
    // Rewrite parent method
    if ([value length] < 5) {
        [self.form removeObjectForKey:self.simiObjectName];
        [self.form removeObjectForKey:self.yearName];
    } else {
        NSArray *values = [value componentsSeparatedByString:@"/"];
        [self.form setValue:values[0] forKey:self.simiObjectName];
        [self.form setValue:[@"20" stringByAppendingString:values[1]] forKey:self.yearName];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:SimiFormFieldDataChangedNotification object:self];
    [self.form formDataChanged:self];
}

@end
