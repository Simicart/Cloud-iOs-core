//
//  SimiFormRow.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiFormRow.h"

@implementation SimiFormRow

- (SimiFormAbstract *)addField:(NSString *)type config:(NSDictionary *)config
{
    NSString *fieldClass = [@"SimiForm" stringByAppendingString:type];
    SimiFormAbstract *field = [[NSClassFromString(fieldClass) alloc] initWithConfig:config];
    field.form = self.form;
    if (self.children == nil) {
        self.children = [NSMutableArray new];
    }
    [self.children addObject:field];
    // Update Row Height
    if (self.height < field.height) {
        self.height = field.height;
    }
    // Add default Value
    if ([config objectForKey:@"value"]) {
        [self.form setValue:[config objectForKey:@"value"] forKey:field.simiObjectName];
    }
    if ([config objectForKey:@"enabled"]) {
        [field setEnabled:[[config objectForKey:@"enabled"] boolValue]];
    }
    return field;
}

- (void)reloadField:(UIView *)cell
{
    [super reloadField:cell];
    if (![self.children count]) {
        return;
    }
    CGFloat width = (self.form.view.frame.size.width + 1) / [self.children count];
    CGFloat x = 0;
    for (SimiFormAbstract *field in self.children) {
        [self addSubview:field];
        UIView *subField = [[UIView alloc] initWithFrame:CGRectMake(x, 0, width - 1, [field getFieldHeight])];
        [field reloadField:subField];
        x += width;
        // Separator
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(x-1, 0, 1, [self getFieldHeight])];
        separator.backgroundColor = [UIColor colorWithWhite:0.88f alpha:1.0f];
        [self addSubview:separator];
    }
}

- (void)reloadFieldData
{
    for (SimiFormAbstract *field in self.children) {
        [field reloadFieldData];
    }
}

@end
