//
//  SCPaypalExpressAddressReviewViewController.h
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/22/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SimiCartBundle/SimiTableView.h>
#import <SimiCartBundle/SimiAddressModel.h>
#import <SimiCartBundle/SimiViewController.h>

#import "SCPaypalExpressModel.h"
#import "SCPaypalExpressModelCollection.h"

@protocol SCPaypalExpressAddressReviewViewController_Delegate <NSObject>
@optional
- (void)completedReviewAddress;
@end


@interface SCPaypalExpressAddressReviewViewController : SimiViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) SCPaypalExpressModel * paypalModel;
@property (strong, nonatomic) SCPaypalExpressModelCollection * paypalModelCollection;

@property (strong, nonatomic) SimiTableView * addressTableView;
@property (strong, nonatomic) SimiAddressModel * shippingAddress;
@property (strong, nonatomic) SimiAddressModel * billingAddress;

@property (strong, nonatomic) UIButton * updateButton;
@property (strong, nonatomic) UIView * updateAddressView;

@property (strong, nonatomic) id<SCPaypalExpressAddressReviewViewController_Delegate> delegate;

-(void)getAddresses;

@end
