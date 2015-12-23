//
//  ZThemeCartViewControllerPad.h
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 5/28/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCCartViewController.h"
#import "SCCartCellPad.h"


static NSString *CART_BUTTON        = @"cart_button";

@interface SCCartViewControllerPad : SCCartViewController <UITableViewDataSource, UITableViewDelegate, SCCartCellDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UILabel * emptyLabel;
@property (strong, nonatomic) UITableView * tableviewProduct;
@property (strong, nonatomic) UIPopoverController * popController;
@property (strong, nonatomic) SimiTable * productCells;

@end
