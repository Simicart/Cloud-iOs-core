//
//  SimiFormSelectOptions.h
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimiViewController.h"

@class SimiFormSelect;

@interface SimiFormSelectOptions : SimiViewController <UITableViewDataSource, UITableViewDelegate, UIPopoverControllerDelegate, UISearchBarDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) SimiFormSelect *formSelect;
@property (nonatomic) BOOL isMultipleSelect, alphabetIndexTitles, searchable;
@property (strong, nonatomic) NSMutableArray *selected;

// Reload Table View
- (void)reloadData;
// Popover Content Size
- (CGSize)reloadContentSize;

// Done button tapped
- (void)doneEditing;

@end
