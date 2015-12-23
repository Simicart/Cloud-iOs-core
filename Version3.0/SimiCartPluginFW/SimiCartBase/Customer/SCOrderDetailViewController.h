//
//  SCOrderDetailViewController.h
//  SimiCart
//
//  Created by Tan on 7/30/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import "SimiViewController.h"
#import "SimiOrderModel.h"
#import "SimiProductModelCollection.h"
#import "SimiAddressModel.h"

static NSString *ORDER_DETAIL_SUMMARY              = @"OrderDetailSummary";
static NSString *ORDER_DETAIL_SHIPPING_ADDRESS     = @"OrderDetailShippingAddress";
static NSString *ORDER_DETAIL_SHIPPING_METHOD      = @"OrderDetailShippingMethod";
static NSString *ORDER_DETAIL_CART                 = @"OrderDetailCart";
static NSString *ORDER_DETAIL_BILLING_ADDRESS      = @"OrderDetailBillingAddress";
static NSString *ORDER_DETAIL_PAYMENT_METHOD       = @"OrderDetailPaymentMethod";
static NSString *ORDER_DETAIL_COUPONCODE           = @"OrderDetailCouponCode";
static NSString *ORDER_DETAIL_TOTAL                = @"OrderDetailTotal";

@interface SCOrderDetailViewController : SimiViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSString *orderId;
@property (strong, nonatomic) SimiOrderModel *order;
@property (strong, nonatomic) SimiProductModelCollection *productCollection;
@property (strong, nonatomic) SimiAddressModel *shippingAddress;
@property (strong, nonatomic) SimiAddressModel *billingAddress;
@property (strong, nonatomic) UITableView *tableViewOrder;
@property (strong, nonatomic) NSMutableArray *cells;

//- (void)getOrder;
@end

@interface OrderDetailCell : UITableViewCell
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *dateValueLabel;
@property (nonatomic, strong) UILabel *codeLabel;
@property (nonatomic, strong) UILabel *codeValueLabel;
@property (nonatomic, strong) UILabel *totalLabel;
@property (nonatomic, strong) UILabel *totalValueLabel;
@end
