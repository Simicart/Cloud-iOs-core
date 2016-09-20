//
//  SCPaypalExpressCoreWorker.h
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/17/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCPaypalExpressWebViewController.h"
#import "SCPaypalExpressAddressReviewViewController.h"
#import "SCPaypalExpressShippingMethodViewController.h"
#import <SimiCartBundle/SCThemeWorker.h>

#import <SimiCartBundle/SCOrderViewController.h>
#import <SimiCartBundle/SCCartViewController.h>

@interface SCPaypalExpressCoreWorker : NSObject <UIPopoverControllerDelegate, SCPaypalExpressWebViewController_Delegate, SCPaypalExpressAddressReviewViewController_Delegate>

//for product View
@property (strong, nonatomic) SCProductViewController *productViewController;
@property (strong, nonatomic) UIView *productActionView;

@property (strong, nonatomic) UIButton *btnPaypalProduct; //Paypal On Product Screen
@property (strong, nonatomic) UIButton *btnPaypalCart; //Paypal On Cart Screen

@property (strong, nonatomic) SCPaypalExpressWebViewController *webViewController;
@property (strong, nonatomic) SCPaypalExpressShippingMethodViewController *shippingMethodViewController;
@property (strong, nonatomic) SCPaypalExpressAddressReviewViewController *addressReviewViewController;


@property (nonatomic) CGRect productActionViewFrame;

@end
