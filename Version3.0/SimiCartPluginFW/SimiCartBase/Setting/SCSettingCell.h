//
//  SCSettingCell.h
//  SimiCartPluginFW
//
//  Created by Axe on 8/8/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimiRow.h"

static NSString* const SETTING_SECTION = @"SETTING_SECTION";
static NSString* const LANGUAGE_CELL = @"LANGUAGE_CELL";
static NSString* const CURRENCY_CELL = @"CURRENCY_CELL";
static NSString* const APP_SETTING_CELL = @"APP_SETTING_CELL";

@interface SCSettingCell : UITableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withRow:(SimiRow*)row;
@property (strong, nonatomic) UIImageView* iconView;
@property (strong, nonatomic) UILabel* lblText;
@property (strong, nonatomic) UILabel* rightLabel;
@end
