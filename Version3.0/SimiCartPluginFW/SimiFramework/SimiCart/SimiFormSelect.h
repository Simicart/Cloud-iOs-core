//
//  SimiFormSelect.h
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiFormAbstract.h"
#import "SimiFormSelectOptions.h"

@interface SimiFormSelect : SimiFormAbstract <UITextFieldDelegate, UIActionSheetDelegate>
@property (strong, nonatomic) NSArray *dataSource;
@property (nonatomic) CGFloat optionHeight;

// Custom option fields
@property (copy, nonatomic) NSString *valueField, *labelField;
@property (nonatomic) BOOL indexTitles, searchable;

@property (strong, nonatomic) SimiFormSelectOptions *optionsViewController;
// Option Show Types - Popover
@property (strong, nonatomic) UIPopoverController *optionsPopover;
// Option Show Types - Navigation
@property (weak, nonatomic) UINavigationController *navController;

- (void)updateSelectInput:(NSArray *)selected;
- (void)addSelected:(NSDictionary *)selected;

- (NSArray *)selectedOptions;

@end
