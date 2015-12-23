//
//  SCProductListViewControllerPad.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/18/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimiCartBundle.h"
#import "SCProductListViewController.h"

@interface SCProductListViewControllerPad : SCProductListViewController<UIPopoverControllerDelegate>
@property (nonatomic, strong) SCProductCollectionViewController *productCollectionViewControllerPad;
@property (nonatomic, strong) UILabel *numberProductLabel;
@property (nonatomic, strong) UIPopoverController *popController;
@end
