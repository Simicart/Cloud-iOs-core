//
//  SimiFormEmail.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiFormEmail.h"

@implementation SimiFormEmail

- (instancetype)initWithConfig:(NSDictionary *)config
{
    if (self = [super initWithConfig:config]) {
        [self.inputText setKeyboardType:UIKeyboardTypeEmailAddress];
        self.inputText.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.inputText.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    return self;
}

- (BOOL)isDataValid
{
    if ((self.required || [self.form objectForKey:self.simiObjectName]) && self.enabled) {
        return [self validateEmail:[self.form objectForKey:self.simiObjectName]];
    }
    return YES;
}

- (BOOL)validateEmail:(NSString *)email
{
    if (email == nil || ![email isKindOfClass:[NSString class]]) {
        return NO;
    }
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailPredicate evaluateWithObject:email];
}

@end
