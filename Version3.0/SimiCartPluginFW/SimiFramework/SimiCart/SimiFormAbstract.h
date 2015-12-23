//
//  SimiFormAbstract.h
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiFormBlock.h"

extern NSString *const SimiFormOptionInline;
extern NSString *const SimiFormOptionActionSheet;
extern NSString *const SimiFormOptionPopover;
extern NSString *const SimiFormOptionNavigation;

@interface SimiFormAbstract : UIView
@property (weak, nonatomic) SimiFormBlock *form;
@property (strong, nonatomic) NSMutableArray *children;

@property (copy, nonatomic) NSString *title;
@property (nonatomic) BOOL required;
@property (nonatomic) NSInteger sortOrder;
@property (nonatomic) CGFloat height;
// Enabled / Disabled Input Element
@property (nonatomic) BOOL enabled;

- (instancetype)initWithConfig:(NSDictionary *)config;

- (CGFloat)getFieldHeight;

// Update form data & valid data
- (void)updateFormData:(id)value; // Called when form data input changed
- (BOOL)isDataValid;

// Text Input Elements
@property (strong, nonatomic) UITextField *inputText;
- (BOOL)isTextInput;
- (BOOL)moveToNextTextInput;
- (void)becomeCurrentTextInput;

// Non-Text Input Elements
@property (strong, nonatomic) NSString *optionType;
- (NSUInteger)numberOfSubRows;
- (BOOL)hasInlineOptions;
- (void)toggleShowSubRows;
- (UITableViewCell *)cellForSubRowAtIndex:(NSUInteger)index inTable:(UITableView *)tableView;
- (CGFloat)heightForSubRowAtIndex:(NSUInteger)index;
- (void)selectSubRowAtIndex:(NSUInteger)index inTable:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

// Row Element
- (SimiFormAbstract *)addField:(NSString *)type config:(NSDictionary *)config;

// Row display methods
@property (nonatomic) NSUInteger tblSection;

-(void)initTableViewCell:(UITableViewCell *)cell; // First time init table view cell
-(void)reloadField:(UIView *)cell; // Update cell when reloadData called
-(void)reloadFieldData; // Called after reload field

// Row action
-(void)selectTableViewCell:(UITableViewCell *)cell; // Table row selected

@end
