//
//  SCOrderViewControllerPad.h
//  SimiCartPluginFW
//
//  Created by Axe on 8/13/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimiCartBundle.h"
#import "SCOrderViewController.h"

@interface SCOrderViewControllerPad : SCOrderViewController<SimiToolbarDelegate, UIPopoverControllerDelegate, SCAddressDelegate,SCCreditCardViewDelegates>

@property (nonatomic, strong) UITableView* tableLeft;
@property (nonatomic, strong) UITableView* tableRight;
@property (nonatomic, strong) SimiTable *orderTableLeft;
@property (nonatomic, strong) SimiTable *orderTableRight;
@property (strong, nonatomic) UIPopoverController *popController;
@property (strong, nonatomic) UIView *separatingLine;


@end
