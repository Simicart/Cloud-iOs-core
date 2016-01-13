//
//  SCOrderViewController.h
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 8/17/14.
//  Copyright (c) 2015 SimiTeam. All rights reserved.
//

#import "SimiViewController.h"
#import "SimiTableView.h"
#import "SimiAddressModel.h"
#import "SimiCartModelCollection.h"
#import "SimiPaymentModelCollection.h"
#import "SimiShippingModelCollection.h"
#import "SimiShippingModel.h"
#import "SimiOrderModel.h"
#import "SCAddressViewController.h"
#import "SimiToolbar.h"
#import "SCCreditCardViewController.h"
#import "SCOrderMethodCell.h"
#import "SimiTable.h"
#import "SimiCheckbox.h"
#import "SimiProductModelCollection.h"

static NSString *const ORDER_SHIPPING_ADDRESS_SECTION   = @"shipping_address";
static NSString *const ORDER_BILLING_ADDRESS_SECTION    = @"billing_address";
static NSString *const ORDER_PAYMENT_SECTION            = @"payment";
static NSString *const ORDER_SHIPMENT_SECTION           = @"shipment";
static NSString *const ORDER_ITEMS_ROW                  = @"items";
static NSString *const ORDER_TOTALS_SECTION             = @"totals";
static NSString *const ORDER_BUTTON_SECTION             = @"placeorderbutton";

static NSString *ORDER_VIEW_SHIPPING_ADDRESS     = @"OrderViewShippingAddress";
static NSString *ORDER_VIEW_BILLING_ADDRESS      = @"OrderViewBillingAddress";
static NSString *ORDER_VIEW_PAYMENT_METHOD       = @"OrderViewPaymentMethod";
static NSString *ORDER_VIEW_CART                 = @"OrderViewCart";
static NSString *ORDER_VIEW_TOTAL                = @"OrderViewTotal";
static NSString *ORDER_VIEW_SHIPPING_METHOD      = @"OrderViewShippingMethod";
static NSString *ORDER_VIEW_COUPONCODE           = @"OrderViewCouponCode";
static NSString *ORDER_VIEW_TERM                 = @"OrderViewTerm";
static NSString *ORDER_VIEW_PLACE                = @"OrderViewPlace";
static NSString *ORDER_SHIPPING_METHOD_SECTION   = @"ShippingMethod";

static NSString *hasData = @"hasData";
static NSString *saveCreditCardsToLocal = @"saveCreditCardsToLocal";

@interface SCOrderViewController : SimiViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, SCAddressDelegate, SimiToolbarDelegate, UIAlertViewDelegate, SCCreditCardViewDelegates, UITabBarControllerDelegate,UIPopoverControllerDelegate>
{
    SimiCartModel *cartModel;
    BOOL didAddBilling;
    BOOL didSaveShipping;
}

/*
 The function tableView cellForRowAtIndexPath raise notification name: "InitializedOrderCell-After" after created a cell.
 The function tableView didSelectRowAtIndexPath raise notification name: "DidSelectOrderCellAtIndexPath" before TO-DO list in the function.
 */
@property (strong, nonatomic) SimiTable *orderTable;
/**
 Notification: SCOrderViewController-InitTableBefore
 Notification: SCOrderViewController-InitTableAfter
 */

@property (strong, nonatomic) SimiTableView *tableViewOrder;
@property (strong, nonatomic) SimiOrderModel *order;
@property (strong, nonatomic) NSMutableDictionary *expandableSections;

@property (strong, nonatomic) SimiAddressModel *shippingAddress;
@property (strong, nonatomic) SimiAddressModel *billingAddress;
@property (strong, nonatomic) SimiPaymentModelCollection *paymentCollection;
@property (strong, nonatomic) SimiShippingModelCollection *shippingCollection;

@property (strong, nonatomic) SimiCartModelCollection *cart;
@property (strong, nonatomic) NSMutableDictionary *cartPrices;
@property (strong, nonatomic) SimiAddressModel *addressNewCustomerModel;

@property (strong, nonatomic) NSString *isReloadPayment;
@property (strong, nonatomic) SimiModel *creditCardAuthorize;
@property (strong, nonatomic) SimiModel *creditCardPaypalDirect;
@property (strong, nonatomic) SimiModel *creditCardSaved;
@property (strong, nonatomic) NSMutableArray *creditCards;

@property (strong, nonatomic) NSString *currentCouponCode;
@property (strong, nonatomic) UITextField *textFieldCouponCode;
@property (strong, nonatomic) NSMutableArray *termAndConditions;

@property (strong, nonatomic) UIButton *btnPlaceNow;

@property (nonatomic) BOOL isNewCustomer;
@property (nonatomic) BOOL isSelectBillingAddress;
@property (nonatomic) BOOL accept;
//Gin edit
@property (nonatomic) BOOL checkoutGuest;
@property (strong, nonatomic) UIPopoverController * popThankController;
//end
@property (nonatomic) NSInteger selectedShippingMedthod;
@property (nonatomic) NSInteger selectedPayment;
@property (nonatomic) NSInteger heightRow;
@property (nonatomic) float magin_left ;
@property (nonatomic) BOOL firstScrollToShippingMethod;
@property (nonatomic) BOOL firstScrollToPaymentMethod;

- (void)getOrderConfig;
- (void)placeOrder;
- (void)didSaveShippingMethod:(NSNotification *)noti;
- (void)didReloadShoppingCart:(NSNotification *)noti;
- (void)savePaymentMethod:(SimiModel *)payment;
- (void)didGetOrderConfig:(NSNotification *)noti;
- (void)didSetCouponCode:(NSNotification *)noti;
- (void)didPlaceOrder:(NSNotification *)noti;
- (void)didClickHeader:(id)sender;
- (void)toggleCheckBox:(SimiCheckbox *)sender;
- (SimiModel*)convertShippingData:(SimiShippingModel *)method;
- (void)addShippingAddressForQuote;
- (void)addBillingAddressForQuote;
- (void)didAddNewCustomerToQuote:(NSNotification*)noti;

@end

@interface UITableSubtitleCell : UITableViewCell;
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UILabel *lblBody;
@end

@interface UITableAddressCell : UITableViewCell
@property (strong, nonatomic) SimiAddressModel *address;
- (void)setAddressModel:(SimiAddressModel*)addressModel;
@end

@interface SCOrderViewControllerHeaderButton : UIButton
@property (nonatomic, strong) UIImageView *narrowImage;
@end