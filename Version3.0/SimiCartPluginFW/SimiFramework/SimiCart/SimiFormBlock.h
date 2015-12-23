//
//  SimiFormBlock.h
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiBlock.h"
#import "NSObject+SimiObject.h"

@class SimiFormBlock;
@class SimiFormAbstract;

extern NSString *const SimiFormDataChangedNotification;
extern NSString *const SimiFormFieldDataChangedNotification;

@protocol SimiFormDelegate <SimiBlockDelegate>
@optional
- (void)didFormDataChanged:(SimiFormBlock *)form field:(SimiFormAbstract *)field;
@end

@interface SimiFormBlock : SimiBlock <SimiFormDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) SimiFormAbstract *selected; // Selected Item, for option field only
@property (strong, nonatomic) NSMutableArray *fields; // Item List
@property (nonatomic) CGFloat height; // Default Field Height (44)

- (SimiFormAbstract *)addField:(NSString *)type config:(NSDictionary *)config;
- (SimiFormAbstract *)getFieldByName:(NSString *)name;
- (void)sortFormFields;

- (SimiFormAbstract *)getFieldAtIndex:(NSUInteger)index subIndex:(NSUInteger *)subIndex;

- (void)setFormData:(NSDictionary *)data;

// Button Actions
@property (strong, nonatomic) UIButton *actionBtn;
@property (copy, nonatomic) NSString *actionTitle;

- (void)addTarget:(id)target action:(SEL)action;
- (void)addTargetUsingBlock:(void(^)())block;
- (void)invokeActions;

// Valid Form Data
@property (nonatomic) BOOL isShowRequiredText; // Show Required Text on Field Title
- (BOOL)hasRequiredField; // Check Form has Required Field
- (BOOL)isDataValid;

// Form Data Changed
- (void)formDataChanged:(SimiFormAbstract *)field;

@end
