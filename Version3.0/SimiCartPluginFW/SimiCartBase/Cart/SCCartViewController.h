//
//  SCCartViewController.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/11/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiViewController.h"
#import "SimiTableView.h"
#import "SimiCartModelCollection.h"
#import "SimiProductModel.h"
#import "SCCartCell.h"
#import "SCProductViewController.h"
#import "SimiTable.h"
#import "SCAddressViewController.h"
#import "SCNewAddressViewController.h"
#import "ActionSheetStringPicker.h"

static NSString *CART_PRODUCTS      = @"productsrow";
static NSString *CART_TOTALS        = @"totalsection";
static NSString *CART_EMPTY         = @"emptyrow";
static NSString *CART_TOTALS_ROW    = @"cartTotalRow";
static NSString *CART_CHECKOUT_ROW  = @"checkoutrow";

@interface SCCartViewController : SimiViewController<UITableViewDataSource, UITableViewDelegate, SCCartCellDelegate, UIActionSheetDelegate, SCAddressDelegate, SCNewAddressDelegate>{
    CGFloat valuesOfCart;
//    BOOL isCancelClicked;
    NSMutableDictionary *qtyButtonList;
}

/**
 Notification Name: InitCartCell-Before
 Notification Name: InitCartCell-After
 */
@property (strong, nonatomic) SimiTable *cartCells;

- (void)reloadData;

/*
 The function tableView cellForRowAtIndexPath raise notification name: "InitializedCartCell-After" after created a cell.
 The function tableView didSelectRowAtIndexPath raise notification name: "DidSelectCartCellAtIndexPath" before TO-DO list in the function.
 */

@property (strong, nonatomic) SimiTableView *tableViewCart;
@property (strong, nonatomic) SimiCartModelCollection *cart;
@property (strong, nonatomic) SimiCartModelCollection *quotes;
@property (strong, nonatomic) SimiCartModel *cartQuote;
@property (nonatomic) BOOL isPresentingKeyboard;
@property (nonatomic) NSInteger heightRow;
@property (strong, nonatomic) NSMutableDictionary *cartPrices;
@property (nonatomic) BOOL isNewCustomer;
@property (nonatomic, strong) SimiAddressModel *billingAddress;
@property (nonatomic,strong) NSMutableArray* qtyArray;
@property (nonatomic,strong) UIButton *btnCheckout;
@property (nonatomic,strong) UIButton *currentQtyButton;
@property (nonatomic) NSUInteger currentItemIndex;

+ (instancetype)sharedInstance;
- (void)checkout;
- (void)getCart;
- (void)clearCart;
- (void)askCustomerRole;
- (void)getQuotesWithCustomerId:(NSString *)customerId;
- (void)didGetCart:(NSNotification*)noti;
- (void)didEditItemQty:(NSNotification*)noti;
- (void)changeCartData:(NSNotification *)noti;
- (void)setDataForCart:(SimiCartModel *)cartQuote;

@end
