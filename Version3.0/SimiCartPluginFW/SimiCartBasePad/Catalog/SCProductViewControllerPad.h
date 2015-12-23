//
//  SCProductViewControllerPad.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/20/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimiCartBundle.h"
#import "SCProductViewController.h"
@interface SCProductViewControllerPad : SCProductViewController<UIPopoverControllerDelegate, SCProductMoreViewControllerDelegate>
{
    UIPopoverController * productOptionPopOver;
    UIScrollView * invisibleScrollView;
    UIView * leftFog;
    UIView * rightFog;
    CGPoint currentScollviewContentOffset;
}
@end
