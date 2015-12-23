//
//  SimiFormDate.h
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiFormAbstract.h"

@interface SimiFormDate : SimiFormAbstract
@property (nonatomic) UIDatePickerMode datePickerMode; // config @"date_type" : "date" | "time" | "datetime"
@property (copy, nonatomic) NSString *dateFormat; // Example: @"yyyy-MM-dd HH:mm:ss"

- (void)dateChanged:(UIDatePicker *)datePicker;

@end
