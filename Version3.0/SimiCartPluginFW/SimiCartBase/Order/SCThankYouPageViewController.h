//
//  SCThankYouPageViewController.h
//  SimiCartPluginFW
//
//  Created by Gin-Wishky on 9/28/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimiCartBundle.h"
#import "SimiTableView.h"
#import "SCOrderViewController.h"

@interface SCThankYouPageViewController : SimiViewController<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong) NSMutableArray *cells;
@property(nonatomic,strong) UIButton *btnContinue;
@property(nonatomic,strong) NSString *number;
@property(nonatomic,strong) NSString *des;
@property BOOL isGuest;
@property (strong, nonatomic) UIPopoverController* popOver;
@property(nonatomic,strong) SimiOrderModel *order;
@property(nonatomic,strong) SimiTableView *tableThank;
@end
