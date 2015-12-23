//
//  SCSettingViewController.h
//  SimiCartPluginFW
//
//  Created by Axe on 8/8/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimiSection.h"
#import "SCStoreViewController.h"
#import "SimiTable.h"
@interface SCSettingViewController : SimiViewController<UITableViewDelegate, UITableViewDataSource,SCStoreViewDelegate>

@property (strong, nonatomic) UILabel* lblLang;
@property (strong, nonatomic) UITableView* tableViewSetting;
@property (strong,nonatomic) SimiTable* cells;

@end
