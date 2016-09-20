//
//  SCPaypalExpressWebViewController.h
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/19/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiViewController.h>

@protocol SCPaypalExpressWebViewController_Delegate <NSObject>
@optional
- (void)completedWebviewCheckout:(BOOL)needToReviewAddress;
@end

@interface SCPaypalExpressWebViewController : SimiViewController <UIWebViewDelegate>

@property (strong, nonatomic) id<SCPaypalExpressWebViewController_Delegate> delgate;
@property (strong, nonatomic) UIWebView * paypalExpCheckOutWebView;
@property (nonatomic) BOOL reviewAddress;

@end
