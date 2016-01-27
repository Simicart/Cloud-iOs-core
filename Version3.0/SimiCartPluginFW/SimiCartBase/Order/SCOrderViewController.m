
//
//  SCOrderViewController.m
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 8/17/14.
//  Copyright (c) 2015 SimiTeam. All rights reserved.
//

#import "SCOrderViewController.h"
#import "SCLoginViewController.h"
#import "SCOrderFeeCell.h"
#import "SCOrderProductCell.h"
#import "SCShippingViewController.h"
#import "NSObject+SimiObject.h"
#import "SimiResponder.h"
#import "InitWorker.h"
#import "SCTermConditionViewController.h"
#import "SimiGlobalVar.h"
#import "SimiFormatter.h"
#import "UILabelDynamicSize.h"
#import "SCThankYouPageViewController.h"
#import "SCAppDelegate.h"
#import "UIImage+SimiCustom.h"

#define CUSTOMER_ROLE_SELECTOR 0
#define CUSTOMER_ROLE_GUEST 2
#define CUSTOMER_ROLE_NEW 1
#define CUSTOMER_ROLE_CUSTOMER 0
#define AGREEMENT   4
#define TF_COUPON_CODE 1

@interface SCOrderViewController ()<SCShippingDelegate>
@end

@implementation SCOrderViewController
{
    float heightNavigation;
    float heightPlaceOrder;
}

@synthesize orderTable = _orderTable;
@synthesize tableViewOrder, order, shippingAddress, billingAddress, cart, cartPrices, paymentCollection, shippingCollection, selectedShippingMedthod, textFieldCouponCode, selectedPayment, termAndConditions,isSelectBillingAddress, magin_left, btnPlaceNow, currentCouponCode;



- (void)viewDidLoadBefore
{
    _firstScrollToShippingMethod = YES;
    _firstScrollToPaymentMethod = YES;
    magin_left = [SimiGlobalVar scaleValue:16];
    heightPlaceOrder = [SimiGlobalVar scaleValue:45];
    heightNavigation = 64;
    
    [super viewDidLoadBefore];
    [self setToSimiView];
    
    self.tableViewOrder = [[SimiTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - heightPlaceOrder) style:UITableViewStyleGrouped];
    [self.tableViewOrder setBackgroundColor:[UIColor clearColor]];
    self.tableViewOrder.dataSource = self;
    self.tableViewOrder.delegate = self;
    [self.tableViewOrder setContentInset:UIEdgeInsetsMake(0, 0, 25, 0)];
    self.tableViewOrder.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.tableViewOrder];
    self.selectedShippingMedthod = -1;
    self.selectedPayment = -1;
    
    self.isReloadPayment = [NSString stringWithFormat:@"%@",[[[[SimiGlobalVar sharedInstance]store] valueForKey:@"store_config"]valueForKey:@"is_reload_payment_method"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getOrderConfig) name:@"DidAddToCart" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidCreate2CheckoutPayment" object:nil userInfo:@{@"orderViewController": self}];
    [self.tableViewOrder setHidden:YES];
    
    
#pragma mark Create Place Now
    CGRect frame = self.view.frame;
    frame.origin.y = SCREEN_HEIGHT - heightNavigation - heightPlaceOrder;
    frame.size.width = SCREEN_WIDTH;
    frame.size.height = heightPlaceOrder;
    btnPlaceNow = [[UIButton alloc] initWithFrame: frame];
    btnPlaceNow.layer.masksToBounds = NO;
    btnPlaceNow.layer.shadowColor = THEME_CONTENT_COLOR.CGColor;
    btnPlaceNow.layer.shadowOpacity = 0.2;
    btnPlaceNow.layer.shadowRadius = 1;
    btnPlaceNow.layer.shadowOffset = CGSizeMake(-0, -1);
    [btnPlaceNow setBackgroundColor:THEME_BUTTON_BACKGROUND_COLOR];
    [btnPlaceNow setTitleColor:THEME_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
    [btnPlaceNow.titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:18]];
    [btnPlaceNow setTitle:[SCLocalizedString(@"Place Now") uppercaseString] forState:UIControlStateNormal];
    [btnPlaceNow addTarget:self action:@selector(placeOrder) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnPlaceNow];
    [btnPlaceNow setHidden:YES];
    [self addShippingAddressForQuote];
    [self addBillingAddressForQuote];
    if (![[SimiGlobalVar sharedInstance]isLogin]) {
        cartModel = [SimiCartModel new];
        NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithDictionary:@{@"address":self.shippingAddress,@"customer_email":[shippingAddress valueForKey:@"email"]}];
        if (self.isNewCustomer) {
            [params setValue:[shippingAddress valueForKey:@"customer_password"] forKey:@"password"];
            [params setValue:@"1" forKey:@"create_new_customer"];
        }
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didAddNewCustomerToQuote:) name:DidAddNewCustomerToQuote object:cartModel];
        [cartModel addNewCustomerToQuote:params];
    }
    if (self.order == nil) {
        self.order = [[SimiOrderModel alloc] init];
    }
    [SimiGlobalVar sharedInstance].needGetCart = YES;
}

- (void)viewWillAppearBefore:(BOOL)animated{
    if (![self.cart count]) {
        // Put back to shopping cart
        [self.navigationController popViewControllerAnimated:NO];
        return [super viewWillAppearBefore:animated];
    }
    [self.tableViewOrder deselectRowAtIndexPath:[self.tableViewOrder indexPathForSelectedRow] animated:YES];
}
-(void) viewDidLoad{
    [super viewDidLoad];
}

- (void)reloadData
{
    _orderTable = nil;
    [self.tableViewOrder reloadData];
}

- (void) setCart:(SimiCartModelCollection *)cart_
{
    cart = cart_;
}

- (void) setCartPrices:(NSMutableDictionary *)cartPrices_
{
    cartPrices = cartPrices_;
}

- (SimiTable *)orderTable
{
    if (_orderTable) {
        return _orderTable;
    }
    _orderTable = [SimiTable new];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SCOrderViewController-InitTableBefore" object:_orderTable];
    //Add Billing and Shipping Addresses Section
    SimiSection *billingAddressSection = [[SimiSection alloc] initWithIdentifier:ORDER_BILLING_ADDRESS_SECTION];
    billingAddressSection.headerTitle = SCLocalizedString(@"Billing Address");
    SimiRow *billingAddressRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_BILLING_ADDRESS height:160];
    [billingAddressSection addRow:billingAddressRow];
    [_orderTable addObject:billingAddressSection];
    
    if(self.shippingCollection.count > 0){
        SimiSection *shippingAddressSection = [[SimiSection alloc] initWithIdentifier:ORDER_SHIPPING_ADDRESS_SECTION];
        shippingAddressSection.headerTitle = SCLocalizedString(@"Shipping Address");
        SimiRow *shippingAddressRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_SHIPPING_ADDRESS height:160];
        [shippingAddressSection addRow:shippingAddressRow];
        [_orderTable addObject:shippingAddressSection];
    }
    
    CGFloat heightRow = 60;
    
    //Add Shipping Method Section
    if(self.shippingCollection.count > 0){
        SimiSection *shipmentSection = [[SimiSection alloc] initWithIdentifier:ORDER_SHIPMENT_SECTION];
        //Gin edit
        if([[self.shippingCollection objectAtIndex:self.selectedShippingMedthod] objectForKey:@"service_name"] == nil){
            shipmentSection.headerTitle = [NSString stringWithFormat:@"%@", SCLocalizedString(@"")];
        }else{
            shipmentSection.headerTitle = [NSString stringWithFormat:@": %@",[[self.shippingCollection objectAtIndex:self.selectedShippingMedthod] objectForKey:@"service_name"]];
        }
       //end
        if ([(NSString *)[self.expandableSections objectForKey:ORDER_SHIPMENT_SECTION] boolValue]) {
            for (int i = 0; i< self.shippingCollection.count; i++) {
                SimiRow *shipmentRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_SHIPPING_METHOD height:55];
                [shipmentRow setData:[self.shippingCollection objectAtIndex:i]];
                [shipmentSection addRow:shipmentRow];
            }
        }else {
            SimiRow * separatingRow = [[SimiRow alloc]initWithIdentifier:nil height:5];
            [shipmentSection addRow:separatingRow];
        }
        [_orderTable addObject:shipmentSection];
    }
        
    
    
    //Add Payment Method Section
    if(self.paymentCollection.count > 0){
        SimiSection *paymentSection = [[SimiSection alloc] initWithIdentifier:ORDER_PAYMENT_SECTION];
        //Gin edit
        if([[self.paymentCollection objectAtIndex:self.selectedPayment] objectForKey:@"title"] == nil){
            paymentSection.headerTitle = [NSString stringWithFormat:@"%@", SCLocalizedString(@"")];
        }else{
            paymentSection.headerTitle = [NSString stringWithFormat:@": %@",[[self.paymentCollection objectAtIndex:self.selectedPayment] objectForKey:@"title"]];
        }
        //end
        if ([(NSString *)[self.expandableSections objectForKey:ORDER_PAYMENT_SECTION] boolValue]) {
            for(int i=0; i<self.paymentCollection.count; i++){
                if (i == self.selectedPayment){
                    NSString *content = [[self.paymentCollection objectAtIndex:i] valueForKey:@"content"];
                    CGSize maxSize = CGSizeMake(300, 9999);
                    CGSize neededSize = [content sizeWithFont:[UIFont fontWithName:THEME_FONT_NAME size:15] constrainedToSize:maxSize lineBreakMode:NSLineBreakByTruncatingTail];
                    neededSize.height = neededSize.height > 10 ? neededSize.height : 10;
                    heightRow = neededSize.height + 50;
                }else{
                    heightRow = 40;
                }
                SimiRow *paymentRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_PAYMENT_METHOD height:heightRow];
                [paymentSection addRow:paymentRow];
            }
        }else {
            SimiRow * separatingRow = [[SimiRow alloc]initWithIdentifier:nil height:5];
            [paymentSection addRow:separatingRow];
        }
        [_orderTable addObject:paymentSection];
    }
    

    //Add Shippment Detail section
    SimiSection *shipmentDetailSection = [[SimiSection alloc]initWithIdentifier:ORDER_TOTALS_SECTION];
    shipmentDetailSection.headerTitle = SCLocalizedString(@"Shipment Details");
    if(self.cart.count > 0){
        for(int j=0; j<self.cart.count; j++){
            SimiRow *cartItemRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_CART height:155];
            [shipmentDetailSection addRow:cartItemRow];
        }
    }
    heightRow = 60;
    NSMutableDictionary * totalV2 = self.cartPrices;
    if(totalV2.count > 0 ){
        if(![[SimiGlobalVar sharedInstance] isReverseLanguage]){
            heightRow = 26 * totalV2.count;
        }else{
            heightRow = [SimiGlobalVar scaleValue:45] * totalV2.count;
        }

    }
    SimiRow *totalRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_TOTAL height:heightRow];
    [shipmentDetailSection addRow:totalRow];
    SimiRow *couponRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_COUPONCODE height:[SimiGlobalVar scaleValue:64]];
    [shipmentDetailSection addRow:couponRow];
    
    if(self.termAndConditions.count > 0){
        for(int m=0; m<self.termAndConditions.count; m++){
            SimiRow *termRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_TERM height:80];
            termRow.data = [self.termAndConditions objectAtIndex:m];
            [shipmentDetailSection addRow:termRow];
        }
    }
    
    [_orderTable addObject:shipmentDetailSection];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SCOrderViewController-InitTableAfter" object:_orderTable];
    return _orderTable;
}

#pragma mark Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.orderTable.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self.orderTable objectAtIndex:section] count];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *headerTitle = @"";
    SimiSection *simiSection = [self.orderTable objectAtIndex:section];
    headerTitle = simiSection.headerTitle;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, tableView.bounds.size.width, 30)];
    headerView.backgroundColor = THEME_SECTION_COLOR;
    UILabel *headerTitleSection = [[UILabel alloc]initWithFrame:CGRectMake(magin_left, 5, tableView.bounds.size.width - 20, 30)];
    headerTitleSection.text = headerTitle;
    [headerTitleSection setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
    //Gin edit
    if(([simiSection.identifier isEqualToString:ORDER_SHIPMENT_SECTION])||([simiSection.identifier isEqualToString:ORDER_PAYMENT_SECTION])){
        UIFont *fontHeader = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:18.0];
        NSDictionary *headerDict = [NSDictionary dictionaryWithObject: fontHeader forKey:NSFontAttributeName];
        NSMutableAttributedString *headerString ;
        if([simiSection.identifier isEqualToString:ORDER_SHIPMENT_SECTION]){
            headerString = [[NSMutableAttributedString alloc] initWithString:SCLocalizedString(@"Shipping Method") attributes: headerDict];
        }else if ([simiSection.identifier isEqualToString:ORDER_PAYMENT_SECTION]){
            headerString = [[NSMutableAttributedString alloc] initWithString:SCLocalizedString(@"Payment") attributes: headerDict];
        }
        UIFont *fontClick = [UIFont fontWithName:THEME_FONT_NAME size:18.0];
        NSDictionary *headerDictClick = [NSDictionary dictionaryWithObject:fontClick forKey:NSFontAttributeName];
        NSMutableAttributedString *clickHeaderString = [[NSMutableAttributedString alloc]initWithString: headerTitle attributes:headerDictClick];
        [headerString appendAttributedString:clickHeaderString];
        headerTitleSection.attributedText = headerString;
    }
    //End
    [headerTitleSection setTextColor:[UIColor blackColor]];
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        [headerTitleSection setFrame:CGRectMake([SimiGlobalVar scaleValue:5], 5,SCREEN_WIDTH - [SimiGlobalVar scaleValue:20], 30)];
        [headerTitleSection setTextAlignment:NSTextAlignmentRight];
    }
    [headerView addSubview:headerTitleSection];
    
    CGRect headerFrame = headerView.frame;
    headerFrame.origin.x = 0;
    
    SCOrderViewControllerHeaderButton * headerButton = [[SCOrderViewControllerHeaderButton alloc]initWithFrame:headerFrame];
    headerButton.simiObjectIdentifier = [NSNumber numberWithInteger:section];
    SimiSection * currentSection = [self.orderTable objectAtIndex:section];
    if ([self.expandableSections objectForKey:currentSection.identifier]!= nil) {
        headerButton.narrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(headerButton.frame.size.width - 26, 15, 10, 10)];
        //Gin edit
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [headerButton.narrowImage setFrame:CGRectMake(10, 15, 10, 10)];
        }
        //End
        if ([(NSString *)[self.expandableSections objectForKey:currentSection.identifier] boolValue]) {
            [headerButton.narrowImage setImage:[UIImage imageNamed:@"ic_narrow_up"]];
        }
        else
        {
            [headerButton.narrowImage setImage:[UIImage imageNamed:@"ic_narrow_down"]];
        }
        [headerButton addSubview:headerButton.narrowImage];
    }
    [headerButton addTarget:self action:@selector(didClickHeader:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:headerButton];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [self.orderTable objectAtIndex:indexPath.section];
    SimiRow *row = [simiSection.rows objectAtIndex:indexPath.row];
    CGFloat heightRow = row.height;
    return heightRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

// To make full width tableView Separating Lines
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //get the row before term row then remove separating line
    SimiSection *simiSection = [self.orderTable objectAtIndex:indexPath.section];
    if ((indexPath.row < (simiSection.rows.count -1)) && (simiSection.identifier == ORDER_TOTALS_SECTION)) {
        SimiRow *simiRow = [simiSection.rows objectAtIndex:(indexPath.row +1)];
        if (simiRow.identifier == ORDER_VIEW_TERM) {
            [cell setSeparatorInset:UIEdgeInsetsMake(0, SCREEN_WIDTH, 0, 0)];
            return;
        }
    }
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    SimiSection *simiSection = [self.orderTable objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedOrderCell-Before" object:cell];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return cell;
    }
    
#pragma mark Billing Address Section
    if ([simiSection.identifier isEqualToString:ORDER_BILLING_ADDRESS_SECTION]) {
        if(simiRow.identifier == ORDER_VIEW_BILLING_ADDRESS){
            cell = [[UITableAddressCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_VIEW_BILLING_ADDRESS];
            [cell setFrame:CGRectMake(0, 0, self.tableViewOrder.frame.size.width, simiRow.height)];
            [(UITableAddressCell*)cell setAddressModel:self.billingAddress];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
        }
    }
#pragma mark Shipping Address Section
    else if ([simiSection.identifier isEqualToString:ORDER_SHIPPING_ADDRESS_SECTION]){
        if(simiRow.identifier == ORDER_VIEW_SHIPPING_ADDRESS){
            cell = [[UITableAddressCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_VIEW_BILLING_ADDRESS];
            [cell setFrame:CGRectMake(0, 0, self.tableViewOrder.frame.size.width, simiRow.height)];
            [(UITableAddressCell*)cell setAddressModel:self.shippingAddress];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
#pragma mark Payment Section
    }else if ([simiSection.identifier isEqualToString:ORDER_PAYMENT_SECTION])
    {
        if(simiRow.identifier == ORDER_VIEW_PAYMENT_METHOD){
            NSString *PaymentShowTypeSDKCell = [NSString stringWithFormat:@"PaymentShowTypeSDKCell_%d",(int)indexPath.row];
            NSString *PaymentShowTypeNoneCell = [NSString stringWithFormat:@"PaymentShowTypeNoneCell_%d",(int)indexPath.row];
            NSString *PaymentShowTypeCreditCardCell = [NSString stringWithFormat:@"PaymentShowTypeCreditCardCell_%d",(int)indexPath.row];
            SimiModel *payment = [self.paymentCollection objectAtIndex:indexPath.row];
            
            NSString *paymentTitle = @"";
            NSString *paymentContent = @"";

            if ([[payment valueForKey:@"type"] integerValue] == PaymentShowTypeNone) {
                cell = [[SCOrderMethodCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PaymentShowTypeNoneCell];
                paymentTitle = [payment valueForKey:@"title"];
                if (![[payment valueForKey:@"description"] isKindOfClass:[NSNull class]] && indexPath.row == self.selectedPayment) {
                    paymentContent = [payment valueForKey:@"content"];
                }
            }else if ([[payment valueForKey:@"type"] integerValue] == PaymentShowTypeCreditCard){
                cell = [[SCOrderMethodCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:PaymentShowTypeCreditCardCell];
                paymentTitle = [payment valueForKey:@"title"];
                if (indexPath.row == self.selectedPayment) {
                    for (int i = 0; i < self.creditCards.count; i++) {
                        SimiModel *creditCard = [self.creditCards objectAtIndex:i];
                        if ([[creditCard valueForKey:@"method_code"] isEqualToString:[payment valueForKey:@"method_code"]]) {
                            if ([[creditCard valueForKey:hasData]boolValue]) {
                                paymentContent = [NSString stringWithFormat:@"****%@", [[creditCard valueForKey:@"card_number"] substringWithRange:NSMakeRange([[creditCard valueForKey:@"card_number"] length] - 4, 4)]];
                            }
                            break;
                        }
                    }
                }
            }else{
                cell = [[SCOrderMethodCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PaymentShowTypeSDKCell];
                paymentTitle = [payment valueForKey:@"title"];
            }
            
            BOOL isSelected = NO;
            if(self.selectedPayment == indexPath.row){
                isSelected = YES;
            }
            [(SCOrderMethodCell *)cell setTitle:paymentTitle andContent:paymentContent andIsSelected:isSelected];
            //Gin edit
            if (selectedPayment == -1 && _firstScrollToPaymentMethod && selectedShippingMedthod != -1) {
                _firstScrollToPaymentMethod = NO;
                 [self.tableViewOrder scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.orderTable getSectionIndexByIdentifier:ORDER_PAYMENT_SECTION]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
            //end
        }
#pragma mark Total Section
    }else if([simiSection.identifier isEqualToString:ORDER_TOTALS_SECTION])
    {
        if(simiRow.identifier == ORDER_VIEW_CART){
            //Init cell
            SimiCartModel *item = [self.cart objectAtIndex:indexPath.row];
            NSString *CartCellIdentifier = [NSString stringWithFormat:@"%@_%@", ORDER_VIEW_CART, [item valueForKey:@"_id"]];
            cell = [tableView dequeueReusableCellWithIdentifier:CartCellIdentifier];
            if (cell == nil) {
                SCOrderProductCell *cartCell = [[SCOrderProductCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CartCellIdentifier];
                if ([item valueForKeyPath:@"cart_item_name"] == nil) {
                    NSString *cartItemName = [item valueForKeyPath:@"name"];
                    for (NSDictionary *option in [item valueForKeyPath:@"options"]) {
                        cartItemName = [NSString stringWithFormat:@"%@, %@", cartItemName, [option valueForKeyPath:@"option_value"]];
                    }
                    [item setValue:cartItemName forKeyPath:@"cart_item_name"];
                }
                [cartCell setItem:item];
                [cartCell setName:[item valueForKeyPath:@"name"]];
                [cartCell setPrice:[item valueForKey:@"price"]];
                [cartCell setQty:[NSString stringWithFormat:@"%@", [item valueForKey:@"qty"]]];
                NSString *cartItemID = [item valueForKey:@"_id"];
                [cartCell setCartItemId:cartItemID];
                NSString *imgPath = @"";
                if([[item valueForKey:@"images"] count] > 0){
                    imgPath = [[item valueForKey:@"images"][0] valueForKey:@"url"];
                }
                [cartCell setImagePath:imgPath];
                [cartCell setInterfaceCell];
                cell = cartCell;
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                cell.userInteractionEnabled = NO;
            }
            //Set cell data
        }else if(simiRow.identifier == ORDER_VIEW_TOTAL){
            
            cell = [[SCOrderFeeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_VIEW_TOTAL];
            [(SCOrderFeeCell *)cell setData:self.cartPrices];
            cell.userInteractionEnabled = NO;
        }
#pragma mark Coupon Section
        //coupon code row
        else if(simiRow.identifier == ORDER_VIEW_COUPONCODE){
            cell = [tableView dequeueReusableCellWithIdentifier:ORDER_VIEW_COUPONCODE];
            if (cell == nil) {
                cell =  [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_VIEW_COUPONCODE];
                if (self.textFieldCouponCode == nil) {
                    self.textFieldCouponCode = [[UITextField alloc]initWithFrame: cell.bounds];
                    if([[self.order valueForKey:@"coupon"] count]>0){
                        if (![[[self.order valueForKey:@"coupon"][0] valueForKey:@"code"] isKindOfClass:[NSNull class]]){
                            self.textFieldCouponCode.text = [[self.order valueForKey:@"coupon"][0] valueForKey:@"code"];
                            self.currentCouponCode = [[self.order valueForKey:@"coupon"][0] valueForKey:@"code"];
                        }
                    }
                    CGRect frame = self.textFieldCouponCode.frame;
                    frame.origin.x = magin_left;
                    frame.size.width = SCREEN_WIDTH - [SimiGlobalVar scaleValue:30];
                    frame.origin.y = [SimiGlobalVar scaleValue:10];
                    frame.size.height = [SimiGlobalVar scaleValue:44];
                    self.textFieldCouponCode.frame = frame;
                    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.textFieldCouponCode.frame.size.height)];
                    self.textFieldCouponCode.leftView = paddingView;
                    self.textFieldCouponCode.leftViewMode = UITextFieldViewModeAlways;
                    [self.textFieldCouponCode setBackgroundColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#e8e8e8"]];
                    self.textFieldCouponCode.placeholder = SCLocalizedString(@"Enter a coupon code");
                    self.textFieldCouponCode.autocorrectionType = UITextAutocorrectionTypeNo;
                    self.textFieldCouponCode.delegate = self;
                    [self.textFieldCouponCode setClearButtonMode:UITextFieldViewModeUnlessEditing];
                    SimiToolbar *toolBar = [[SimiToolbar alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH, 40)];
                    toolBar.delegate = self;
                    self.textFieldCouponCode.inputAccessoryView.backgroundColor = THEME_CONTENT_COLOR;
                    self.textFieldCouponCode.inputAccessoryView = toolBar;
                    [self.textFieldCouponCode setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:16]];
                    [self.textFieldCouponCode setTextColor:THEME_CONTENT_COLOR];
                    
                    
                    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                        [self.textFieldCouponCode setTextAlignment:NSTextAlignmentRight];
                    }
                }
                [cell addSubview:self.textFieldCouponCode];
            }
        }
        //term  and condition row
        if(simiRow.identifier == ORDER_VIEW_TERM){
            if([self.termAndConditions count] > 0){
                if(cell == nil){
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_VIEW_TERM];
                }
                cell.accessoryType = UITableViewCellAccessoryNone;
                NSDictionary *term = simiRow.data;
                if([term objectForKey:@"name"]){
                    UILabel *termLabel = [[UILabel alloc]initWithFrame:CGRectMake(magin_left, 8, CGRectGetWidth(self.view.frame) - 30, 20)];
                    if ([[SimiGlobalVar sharedInstance] isReverseLanguage]) {
                        [termLabel setFrame: CGRectMake(magin_left , 8, CGRectGetWidth(self.view.frame) - 45, 20)];
                        [termLabel setTextAlignment:NSTextAlignmentRight];
                    }
                    termLabel.text = [term objectForKey:@"name"];
                    [termLabel setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:16]];
                    [termLabel setTextColor:THEME_CONTENT_COLOR];
                    [termLabel resizLabelToFit];
                    [cell addSubview:termLabel];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                SimiCheckbox *checkbox = [[SimiCheckbox alloc] initWithTitle:[term objectForKey:@"title"]];
                [checkbox.titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:16]];
                [checkbox.titleLabel setTextColor:THEME_CONTENT_COLOR];
                checkbox.strokeColor = THEME_TEXT_COLOR;
                checkbox.frame = CGRectMake(magin_left, 30, SCREEN_WIDTH - 30, 35);
                //Gin eidt
                if ([[SimiGlobalVar sharedInstance] isReverseLanguage]) {
                    [checkbox setFrame: CGRectMake(magin_left, 30, SCREEN_WIDTH - 46, 35)];
                    [checkbox.titleLabel setTextAlignment:NSTextAlignmentRight];
                    [checkbox setCheckAlignment:M13CheckboxAlignmentRight];
                }
                //End
                if ([[term objectForKey:@"checked"] boolValue]) {
                    [checkbox setCheckState:M13CheckboxStateChecked];
                }
                checkbox.radius = 1.0f;
                checkbox.simiObjectIdentifier = simiRow.data;
                [cell addSubview:checkbox];
                [checkbox addTarget:self action:@selector(toggleCheckBox:) forControlEvents:UIControlEventValueChanged];
            }
        }
#pragma mark Shipment Section
    }else if([simiSection.identifier isEqualToString:ORDER_SHIPMENT_SECTION])
    {
        NSString *identi = [ simiRow.data valueForKey:@"code"];
        if(simiRow.identifier == ORDER_VIEW_SHIPPING_METHOD){
            cell = [tableView dequeueReusableCellWithIdentifier:ORDER_VIEW_SHIPPING_METHOD];
            if (cell == nil) {
                cell = [[SCOrderMethodCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identi];
            }
            
            NSString *methodName = [simiRow.data valueForKey:@"service_name"];
            NSString *methodContent = @"";
            if (![methodName isKindOfClass:[NSNull class]]) {
                if (methodName.length > 0){
                    methodContent = [ simiRow.data valueForKey:@"description"];
                }
            }
            UILabel *priceLabel = [[UILabel alloc] initWithFrame: [SimiGlobalVar scaleFrame:CGRectMake(cell.frame.size.width - 58, 0, 44, cell.frame.size.height)]];
            [priceLabel setTextAlignment:NSTextAlignmentRight];
            [priceLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE_REGULAR]];
            priceLabel.backgroundColor = [UIColor clearColor];
            priceLabel.textColor = THEME_PRICE_COLOR;
            priceLabel.text = [[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%@",[simiRow.data valueForKey:@"price"]]];
            float widthPrice = [priceLabel.text sizeWithFont:priceLabel.font].width;
            [priceLabel setFrame:[SimiGlobalVar scaleFrame:CGRectMake(cell.frame.size.width - widthPrice -14, 0,widthPrice, cell.frame.size.height)]];
            if ([[SimiGlobalVar sharedInstance] isReverseLanguage]) {
                [priceLabel setFrame:[SimiGlobalVar scaleFrame:CGRectMake(10, 0,widthPrice, cell.frame.size.height)]];
                [priceLabel setTextAlignment:NSTextAlignmentLeft];
            }
            [cell addSubview:priceLabel];
            BOOL isSelected = NO;
            if (indexPath.row == self.selectedShippingMedthod) {
                isSelected = YES;
            }
            [(SCOrderMethodCell *)cell setTitle:methodName andContent:methodContent andIsSelected:isSelected];
            //Gin edit
            if(selectedShippingMedthod == -1 && _firstScrollToShippingMethod){
                _firstScrollToShippingMethod = NO;
                [self.tableViewOrder scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.orderTable getSectionIndexByIdentifier:ORDER_SHIPMENT_SECTION]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
            //end
        }
    }
    if (cell == nil) {
        cell = [UITableViewCell new];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedOrderCell-After" object:simiRow userInfo:@{@"tableView": tableView, @"indexPath": indexPath, @"cell": cell}];
    return cell;
}

- (void)toggleCheckBox:(SimiCheckbox *)sender
{
    NSMutableDictionary *term = (NSMutableDictionary *)sender.simiObjectIdentifier;
    if ([sender checkState] == M13CheckboxStateChecked) {
        [term setValue:[NSNumber numberWithBool:YES] forKey:@"checked"];
    } else {
        [term removeObjectForKey:@"checked"];
    }
    [self.termAndConditions replaceObjectAtIndex:sender.tag withObject:term];
}

#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [self.orderTable objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectOrderCellAtIndexPath" object:simiSection userInfo:@{@"tableView": tableView, @"indexPath": indexPath}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    
    if(simiRow.identifier == ORDER_VIEW_BILLING_ADDRESS){
        self.isSelectBillingAddress = YES;
        SCAddressViewController *nextController = [[SCAddressViewController alloc]init];
        [nextController setDelegate:self];
        [nextController setIsGetOrderAddress:YES];
        if (SIMI_SYSTEM_IOS>=8) {
            [self.navigationController pushViewController:nextController animated:YES];
        }else{
            [self.navigationController pushViewController:nextController animated:NO];
        }
        
    }if(simiRow.identifier == ORDER_VIEW_SHIPPING_ADDRESS){
        self.isSelectBillingAddress = NO;
        SCAddressViewController *nextController = [[SCAddressViewController alloc]init];
        [nextController setDelegate:self];
        [nextController setIsGetOrderAddress:YES];
        if (SIMI_SYSTEM_IOS>=8) {
            [self.navigationController pushViewController:nextController animated:YES];
        }else{
            [self.navigationController pushViewController:nextController animated:NO];
        }
    }else if(simiRow.identifier == ORDER_VIEW_PAYMENT_METHOD){
        self.selectedPayment  = indexPath.row;
        SimiModel *payment = [self.paymentCollection objectAtIndex:self.selectedPayment];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectPaymentMethod" object:payment userInfo:@{@"payment": payment}];
        if ([[payment valueForKey:@"type"] integerValue] == PaymentShowTypeCreditCard) {
            NSArray *creditCardTypes = [payment valueForKey:@"cc_types"];
            if (creditCardTypes != nil) {
                //   Liam Update Credit Card
                SCCreditCardViewController *nextController = [[SCCreditCardViewController alloc] init];
                nextController.delegate = self;
                for (int i = 0; i < self.creditCards.count; i++) {
                    SimiModel *creditCard = [self.creditCards objectAtIndex:i];
                    if ([[creditCard valueForKey:@"payment_method"] isEqualToString:[payment valueForKey:@"payment_method"]]) {
                        if ([[creditCard valueForKey:hasData]boolValue]) {
                            nextController.defaultCard = [[NSDictionary alloc]initWithObjectsAndKeys:
                                                          [creditCard valueForKey:@"card_type"],@"card_type",
                                                          [creditCard valueForKey:@"card_number"],@"card_number",
                                                          [creditCard valueForKey:@"expired_month"], @"expired_month",
                                                          [creditCard valueForKey:@"expired_year"], @"expired_year",
                                                          [creditCard valueForKey:@"cc_id"] , @"cc_id", nil];
                        }
                        nextController.creditCardList = [payment valueForKey:@"cc_types"];
                        nextController.isUseCVV = [[payment valueForKey:@"useccv"] boolValue];
                    }
                }
                //  End Update Credit Card
                [self.navigationController pushViewController:nextController animated:YES];
            }
        }else if ([[payment valueForKey:@"type"] integerValue] == PaymentShowTypeSDK){
            NSLog(@"zzzz");
        }else{
                [self savePaymentMethod:payment];
        }
        _orderTable = nil;
       [simiSection setHeaderTitle:[payment valueForKey:@"payment_method"]];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:[self.orderTable getSectionIndexByIdentifier:ORDER_PAYMENT_SECTION]] withRowAnimation:UITableViewRowAnimationNone];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if ((selectedShippingMedthod != -1)){
            [self.tableViewOrder scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([self.tableViewOrder numberOfRowsInSection:[self.orderTable getSectionIndexByIdentifier:ORDER_TOTALS_SECTION]] - 1) inSection:[self.orderTable getSectionIndexByIdentifier:ORDER_TOTALS_SECTION]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }else{
            if ([self.orderTable getSectionIndexByIdentifier:ORDER_SHIPMENT_SECTION]) {
                [self.tableViewOrder scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.orderTable getSectionIndexByIdentifier:ORDER_SHIPMENT_SECTION]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
        }
    }else if(simiRow.identifier == ORDER_VIEW_SHIPPING_METHOD){
        [self didSelectShippingMethodAtIndex: indexPath.row];
    }else if(simiRow.identifier == ORDER_VIEW_TERM){
        // Show term and condition
        SCTermConditionViewController *termView = [[SCTermConditionViewController alloc] init];
        termView.termAndCondition = simiRow.data;
        [self.navigationController pushViewController:termView animated:YES];
    }
}

- (void)didClickHeader:(id)sender
{
    SCOrderViewControllerHeaderButton * headerButton = (SCOrderViewControllerHeaderButton *)sender;
    int section = [(NSNumber *)headerButton.simiObjectIdentifier intValue];
    SimiSection *currentSection = [self.orderTable objectAtIndex:section];
    if ([self.expandableSections objectForKey:currentSection.identifier] != nil) {
        BOOL currentlyExpanding = [(NSString *)[self.expandableSections objectForKey:currentSection.identifier] boolValue];
        NSMutableArray * indexPathsArray = [NSMutableArray new];
        //if it's expanding already, close it
        if (currentlyExpanding) {
            [headerButton.narrowImage setImage:[UIImage imageNamed:@"ic_narrow_down"]];
            
            for (int i = 0; i < currentSection.count; i++) {
                NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:section];
                [indexPathsArray addObject:path];
            }
            [self.tableViewOrder beginUpdates];
            [self.tableViewOrder deleteRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationFade];
            [self.expandableSections setValue:@"NO" forKey:currentSection.identifier];
            self.orderTable = nil;
            [self.tableViewOrder insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:section]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableViewOrder endUpdates];
        }
        //if it's not expanded yet, expand it
        else {
            [headerButton.narrowImage setImage:[UIImage imageNamed:@"ic_narrow_up"]];
            
            self.orderTable = nil;
            [self.expandableSections setValue:@"YES" forKey:currentSection.identifier];
            currentSection = [self.orderTable objectAtIndex:section];
            for (int i = 0; i < currentSection.count; i++) {
                NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:section];
                [indexPathsArray addObject:path];
            }
            [self.tableViewOrder beginUpdates];
            [self.tableViewOrder deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:section]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableViewOrder insertRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationFade];
            [self.tableViewOrder endUpdates];
        }
    }
}

#pragma mark Select Shipping Method
- (int)getSelectedShippingMedthodId
{
    for (int i=0; i< self.shippingCollection.count; i++){
        NSArray *shippingMethods = [self.shippingCollection objectAtIndex:i];
        NSInteger selectedId = [[shippingMethods valueForKey:@"s_method_selected"] integerValue];
        if(selectedId == 1){
            return i;
        }
    }
    return 0;
}

- (void)didSelectShippingMethodAtIndex:(NSInteger)index{
    self.selectedShippingMedthod = index;
    SimiShippingModel *method = (SimiShippingModel *)[self.shippingCollection objectAtIndex:self.selectedShippingMedthod];
    SimiModel *shippingMethod = [self convertShippingData:method];
    [self.expandableSections setValue:@"YES" forKey:ORDER_PAYMENT_SECTION];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSaveShippingMethod:) name:DidSaveShippingMethod object:self.order];
    [self startLoadingData];
    if([SimiGlobalVar sharedInstance].quoteId != nil)
        [self.order selectShippingMethod:shippingMethod quoteId:[SimiGlobalVar sharedInstance].quoteId];
    if (selectedPayment != -1){
        [self.tableViewOrder scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.orderTable getSectionIndexByIdentifier:ORDER_TOTALS_SECTION]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

-(SimiModel*)convertShippingData:(SimiShippingModel *)method{
    [method setValue:[method valueForKey:@"price"] forKey:@"cost"];
    [method setValue:[method valueForKey:@"service_name"] forKey:@"title"];
    [method setValue:@"0" forKey:@"shiping_tax_percent"];
    [method removeObjectForKey:@"params"];
    SimiModel *shippingMethod = [[SimiModel alloc]init];
    [shippingMethod setObject:method forKey:@"shipping"];
    return shippingMethod;
}

#pragma mark Save Shipping Method
- (void)didSaveShippingMethod:(NSNotification *)noti{
    didSaveShipping = YES;
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        [self setOrderTotalData:self.order];
        [self didGetOrderConfig:noti];
        if (selectedPayment == -1 && _firstScrollToPaymentMethod && selectedShippingMedthod != -1 && [self.orderTable getSectionIndexByIdentifier:ORDER_PAYMENT_SECTION] != NSNotFound) {
            _firstScrollToPaymentMethod = NO;
            [self.tableViewOrder scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.orderTable getSectionIndexByIdentifier:ORDER_PAYMENT_SECTION]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:responder.responseMessage delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
    }
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
}

#pragma mark Add Address for quote
- (void)addShippingAddressForQuote{
    if (self.shippingCollection == nil) {
        self.shippingCollection = [[SimiShippingModelCollection alloc] init];
    }
    if(self.shippingAddress != nil)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddShippingAddress:) name:DidGetShippingMethod object:self.shippingCollection];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:self.shippingAddress forKey:@"shipping_address"];
        if([SimiGlobalVar sharedInstance].quoteId != nil)
            [self.shippingCollection addShippingAddressForQuote:[SimiGlobalVar sharedInstance].quoteId withParams:params];
        [self startLoadingData];
        didSaveShipping = NO;
    }
}

- (void)addBillingAddressForQuote{
    if (self.paymentCollection == nil) {
        self.paymentCollection = [[SimiPaymentModelCollection alloc] init];
    }
    if(self.billingAddress != nil)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddBillingAddress:) name:DidGetPaymentMethod object:self.paymentCollection];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:self.shippingAddress forKey:@"billing_address"];
        if([SimiGlobalVar sharedInstance].quoteId != nil)
            [self.paymentCollection addBillingAddressForQuote:[SimiGlobalVar sharedInstance].quoteId withParams:params];
        [self startLoadingData];
        didAddBilling = NO;
    }
}

- (void)didAddShippingAddress:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        if (self.shippingCollection.count == 0) {
            self.selectedShippingMedthod = 0;
            self.expandableSections = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"YES",ORDER_PAYMENT_SECTION,@"NO",ORDER_SHIPMENT_SECTION, nil];
            didSaveShipping = YES;
            [self getOrderConfig];
        }else{
            self.selectedShippingMedthod = [self getSelectedShippingMedthodId];
            [self didSelectShippingMethodAtIndex:self.selectedShippingMedthod];
        }
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:responder.responseMessage delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
    }
    [self removeObserverForNotification:noti];
    [self stopLoadingData];
}

- (void)didAddBillingAddress:(NSNotification *)noti{
    didAddBilling  = YES;
    [self stopLoadingData];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:responder.responseMessage delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
    }
    [self removeObserverForNotification:noti];
    [self reloadData];
}

- (void)didAddNewCustomerToQuote:(NSNotification*)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
    }else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:responder.responseMessage delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self removeObserverForNotification:noti];
}

- (void)stopLoadingData
{
    if (didAddBilling && didSaveShipping) {
        [super stopLoadingData];
    }
}

#pragma mark Save Payment Method
- (void)savePaymentMethod:(SimiModel *)payment{
    [self startLoadingData];
    if([SimiGlobalVar sharedInstance].quoteId != nil)
        [self.order selectPaymentMethod:payment quoteId:[SimiGlobalVar sharedInstance].quoteId];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSavePaymentMethod:) name:DidSavePaymentMethod object:self.order];
}

- (void)didSavePaymentMethod:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        [self setOrderTotalData:self.order];
        [self reloadData];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:responder.responseMessage delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
    }
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
}

#pragma mark Place Order
- (void)placeOrder{
    //Gin edit
    if ((self.selectedPayment >= 0)&&(self.selectedShippingMedthod >=0)) {
        if ([self.termAndConditions count]) {
            self.accept = NO;
            for (NSDictionary *term in self.termAndConditions) {
                if (![[term objectForKey:@"checked"] boolValue]) {
                    // Scroll to term and condition
                    [self.tableViewOrder scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([self.tableViewOrder numberOfRowsInSection:[self.orderTable getSectionIndexByIdentifier:ORDER_TOTALS_SECTION]] - 1) inSection:[self.orderTable getSectionIndexByIdentifier:ORDER_TOTALS_SECTION]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    [self.tableViewOrder deselectRowAtIndexPath:[self.tableViewOrder indexPathForSelectedRow] animated:YES];
                    // Show alert
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(@"Please agree to all the terms and conditions before placing the order.") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles:nil];
                    [alertView show];
                    return;
                }
            }
            self.accept = YES;
        }
        if (self.isDiscontinue) {
            self.isDiscontinue = NO;
            return;
        }
        SimiModel *payment = [self.paymentCollection objectAtIndex:self.selectedPayment];
        [[NSNotificationCenter defaultCenter]postNotificationName:SCOrderViewControllerBeforePlaceOrder object:self userInfo:@{@"order":self.order,@"payment":payment}];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlaceOrder:) name:DidPlaceOrder object:self.order];
        [self startLoadingData];
        
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [self.order placeOrderWithParams:[SimiGlobalVar sharedInstance].quoteId];
        self.tabBarController.tabBar.userInteractionEnabled = NO;
    } else if(self.selectedShippingMedthod == -1){
        // Scroll to shipping methods
        
        if (![[self.expandableSections valueForKey:ORDER_SHIPMENT_SECTION]boolValue]) {
            [self.expandableSections setValue:@"YES" forKey:ORDER_SHIPMENT_SECTION];
            self.orderTable = nil;
            [self.tableViewOrder reloadSections:[NSIndexSet indexSetWithIndex:[self.orderTable getSectionIndexByIdentifier:ORDER_SHIPMENT_SECTION]] withRowAnimation:UITableViewRowAnimationFade];
        }
        [self.tableViewOrder scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.orderTable getSectionIndexByIdentifier:ORDER_SHIPMENT_SECTION]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        if (self.selectedPayment == -1) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(@"Please choose a shipping method and payment methods") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
            [alertView show];
        }else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(@"Please choose a shipping method") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
            [alertView show];
        }
    }else if(self.selectedPayment == -1){
        if (![[self.expandableSections valueForKey:ORDER_PAYMENT_SECTION]boolValue]) {
            [self.expandableSections setValue:@"YES" forKey:ORDER_PAYMENT_SECTION];
            self.orderTable = nil;
            [self.tableViewOrder reloadSections:[NSIndexSet indexSetWithIndex:[self.orderTable getSectionIndexByIdentifier:ORDER_PAYMENT_SECTION]] withRowAnimation:UITableViewRowAnimationFade];
        }
        [self.tableViewOrder scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.orderTable getSectionIndexByIdentifier:ORDER_PAYMENT_SECTION]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(@"Please choose a payment method") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
    }
}

#pragma mark Keyboard Delegate
- (void)keyboardWasShown
{
    UIEdgeInsets contentInsets = self.tableViewOrder.contentInset;
    contentInsets.bottom = 270;
    self.tableViewOrder.contentInset = contentInsets;
    self.tableViewOrder.scrollIndicatorInsets = contentInsets;
}

- (void)hideKeyboard{
    UIEdgeInsets contentInsets = self.tableViewOrder.contentInset;
    contentInsets.bottom = 0;
    self.tableViewOrder.contentInset = contentInsets;
    self.tableViewOrder.scrollIndicatorInsets = contentInsets;
}

#pragma mark Address Delegate
- (void)selectAddress:(SimiAddressModel *)address{
    if (self.isSelectBillingAddress) {
        self.billingAddress = address;
        [self addBillingAddressForQuote];
        if (self.shippingAddress == nil) {
            self.shippingAddress = address;
            [self addShippingAddressForQuote];
        }
    }else{
        self.shippingAddress = address;
        [self addShippingAddressForQuote];
    }
}

#pragma mark Credit Card View Delegate
- (void)didEnterCreditCardWithCardType:(NSString *)cardType cardNumber:(NSString *)number expiredMonth:(NSString *)expiredMonth expiredYear:(NSString *)expiredYear cvv:(NSString *)CVV{
    // Liam Update Credit Card
    SimiModel *payment = [self.paymentCollection objectAtIndex:self.selectedPayment];
    for (int i = 0; i < self.creditCards.count; i ++) {
        SimiModel *creditCard = [self.creditCards objectAtIndex:i];
        if ([[creditCard valueForKey:@"payment_method"] isEqualToString:[payment valueForKey:@"payment_method"]]) {
            [creditCard setValue:@"YES" forKey:hasData];
            [creditCard setValue:cardType forKey:@"card_type"];
            [creditCard setValue:number forKey:@"card_number"];
            [creditCard setValue:expiredMonth forKey:@"expired_month"];
            [creditCard setValue:expiredYear forKey:@"expired_year"];
            [creditCard setValue:CVV forKey:@"cc_id"];
            break;
        }
    }
    //  End Update Credit Card
    [[NSUserDefaults standardUserDefaults] setValue:self.creditCards forKey:saveCreditCardsToLocal];
    [self reloadData];
}

#pragma mark Get & Did Get Order Configure
- (void)getOrderConfig{
    if (self.order == nil) {
        self.order = [[SimiOrderModel alloc] init];
    }
    if(self.shippingAddress != nil && self.billingAddress != nil)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetOrderConfig:) name:DidGetOrderConfig object:self.order];
        if([SimiGlobalVar sharedInstance].quoteId != nil)
            [self.order getOrderConfigWithParams:nil quoteId:[SimiGlobalVar sharedInstance].quoteId];
    }
}

- (void)didGetOrderConfig:(NSNotification *)noti{
    [self.tableViewOrder setHidden:NO];
    [btnPlaceNow setHidden:NO];
    [self stopLoadingData];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        self.expandableSections = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"YES",ORDER_PAYMENT_SECTION,@"YES",ORDER_SHIPMENT_SECTION, nil];
        if (self.shippingCollection.count == 0) {
            self.selectedShippingMedthod = 0;
            self.expandableSections = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"YES",ORDER_PAYMENT_SECTION,@"NO",ORDER_SHIPMENT_SECTION, nil];
        }
        
        if (self.paymentCollection.count > 0) {
            if (self.creditCards == nil) {
                self.creditCards = [NSMutableArray new];
                for (int i = 0; i < self.paymentCollection.count; i++) {
                    SimiModel *payment = [self.paymentCollection objectAtIndex:i];
                    SimiModel *paymentModel = [SimiModel new];
                    [paymentModel setValue:@"NO" forKey:@"hasData"];
                    [paymentModel setValue:[payment valueForKey:@"method_code"] forKey:@"payment_method"];
                    if ([[payment valueForKey:@"type"]intValue] == PaymentShowTypeCreditCard) {
                        [self.creditCards addObject:paymentModel];
                    }
                }
                NSMutableArray *localCrediCardsData = [[NSUserDefaults standardUserDefaults]valueForKey:saveCreditCardsToLocal];
                if (localCrediCardsData != nil) {
                    for (int i = 0; i < localCrediCardsData.count; i++) {
                        SimiModel *localModel = [localCrediCardsData objectAtIndex:i];
                        for (int j = 0; j < self.creditCards.count; j++) {
                            SimiModel *currentData = [self.creditCards objectAtIndex:j];
                            if ([[currentData valueForKey:@"method_code"] isEqualToString:[localModel valueForKey:@"payment_method"]]) {
                                [currentData setValuesForKeysWithDictionary:localModel];
                                break;
                            }
                        }
                    }
                }
            }
        }
        
        // Term and conditions
        if (![[self.order valueForKey:@"condition"] isKindOfClass:[NSNull class]]) {
            self.termAndConditions = [NSMutableArray new];
            for (NSDictionary *data in [[self.order valueForKey:@"fee"] valueForKey:@"condition"]) {
                [self.termAndConditions addObject:data];
            }
        } else {
            self.termAndConditions = nil;
        }
        
        if (self.paymentCollection.count == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"FAIL") message:SCLocalizedString(@"") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
            alertView.message = SCLocalizedString(@"Couldn't get payment method information.");
            [alertView show];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            
            //  Liam Update for Default Payment Method
            if ([[SimiGlobalVar sharedInstance]isDefaultPayment]) {
                if (self.paymentCollection.count > 0 && self.selectedPayment < 0) {
                    for (int i = 0; i < self.paymentCollection.count; i++) {
                        SimiModel *payment = [self.paymentCollection objectAtIndex:i];
                        if ([[payment valueForKey:@"type"] integerValue] == PaymentShowTypeNone) {
                            self.selectedPayment = i;
                            if([self.isReloadPayment isEqualToString:@"1"]){
                                [self savePaymentMethod:payment];
                            }
                            break;
                        }
                    }
                }
            }
            //  End
        }
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:responder.responseMessage delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
    }
    [self reloadData];
    [self.tableViewOrder deselectRowAtIndexPath:[self.tableViewOrder indexPathForSelectedRow] animated:YES];
    [self removeObserverForNotification:noti];
}

#pragma mark Notification Action
- (void)didReloadShoppingCart:(NSNotification *)noti
{
    [self stopLoadingData];
    [self reloadData];
    [self removeObserverForNotification:noti];
}

- (void)didSetCouponCode:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        [self setOrderTotalData:self.order];
        NSString *message = SCLocalizedString(@"Couponcode was applied");
        if([[self.order valueForKey:@"coupon"] count] > 0){
            if (![[[self.order valueForKey:@"coupon"][0] valueForKey:@"code"] isKindOfClass:[NSNull class]]){
                self.currentCouponCode = [[self.order valueForKey:@"coupon"][0] valueForKey:@"code"];
                if(self.currentCouponCode == nil || [self.currentCouponCode isEqualToString:@""])
                    message = SCLocalizedString(@"Couponcode was removed");
            }
        }else{
            self.currentCouponCode = @"";
            message = SCLocalizedString(@"Couponcode was removed");
        }
        [self reloadData];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"SUCCESS") message:message delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"ERROR") message:responder.responseMessage delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
    }
    
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
}

- (void)setOrderTotalData:(NSMutableDictionary*)order_
{
    if([order_ valueForKey:@"subtotal"])
        [self.cartPrices setValue:[order_ valueForKey:@"subtotal"] forKey:@"subtotal"];
    if([order_ valueForKey:@"shipping_amount"] && [order_ valueForKey:@"shipping_amount"] > 0)
        [self.cartPrices setValue:[order_ valueForKey:@"shipping_amount"] forKey:@"shipping_amount"];
    if([order_ valueForKey:@"payment_amount"] && [order_ valueForKey:@"payment_amount"] > 0)
        [self.cartPrices setValue:[order_ valueForKey:@"payment_amount"] forKey:@"payment_amount"];
    if([order_ valueForKey:@"grand_total"])
        [self.cartPrices setValue:[order_ valueForKey:@"grand_total"] forKey:@"grand_total"];
    if([order_ valueForKey:@"tax_amount"] && [order_ valueForKey:@"tax_amount"] > 0)
        [self.cartPrices setValue:[order_ valueForKey:@"tax_amount"] forKey:@"tax_amount"];
    if([order_ valueForKey:@"discount_amount"] && [order_ valueForKey:@"discount_amount"] > 0)
        [self.cartPrices setValue:[order_ valueForKey:@"discount_amount"] forKey:@"discount_amount"];
}

- (void)didPlaceOrder:(NSNotification *)noti{
    [self stopLoadingData];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([noti.name isEqualToString:DidPlaceOrder]) {
        if ([responder.status isEqualToString:@"SUCCESS"]) {
            [SimiGlobalVar sharedInstance].needGetDownloadItems = YES;
            NSString *invoiceNumber = [self.order valueForKey:@"_id"];
            
            [self.order setValue:invoiceNumber forKey:@"invoice_number"];
            
            [self.order setValue:[self.paymentCollection objectAtIndex:self.selectedPayment] forKey:@"payment"];
            
            SimiShippingModel *shippingModel = (SimiShippingModel *)[self.shippingCollection objectAtIndex:self.selectedShippingMedthod];
            if (shippingModel == nil) {
                shippingModel = [SimiShippingModel new];
            }
            if (SIMI_DEVELOPMENT_ENABLE) {
                NSLog(@"%@", [self.paymentCollection objectAtIndex:self.selectedPayment]);
            }
            //Success
            if ([[[self.paymentCollection objectAtIndex:self.selectedPayment] valueForKey:@"type"] integerValue] == PaymentShowTypeRedirect) {
                [self.navigationController popToRootViewControllerAnimated:NO];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DidPlaceOrder-Before" object:self.order userInfo:@{@"data": self.order, @"payment": [self.order valueForKey:@"payment"], @"controller": self, @"responder":responder, @"cart":self.cart, @"shipping":shippingModel}];
                [[SimiGlobalVar sharedInstance]resetQuote];
            }else if ([[[self.paymentCollection objectAtIndex:self.selectedPayment] valueForKey:@"type"] integerValue] != PaymentShowTypeSDK){
               [[SimiGlobalVar sharedInstance]resetQuote];
                if ([self.order valueForKey:@"notification"]) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"DidCheckOut-Success" object:self.order];
                }else
                {
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                        if (!self.isNewCustomer) {
                            SCThankYouPageViewController *thankVC = [[SCThankYouPageViewController alloc] init];
                            thankVC.number = invoiceNumber;
                            thankVC.order = self.order;
                            if(self.checkoutGuest){
                                thankVC.isGuest = YES;
                            }else
                                thankVC.isGuest = NO;
                            [self.navigationController pushViewController:thankVC animated:YES];
                        };
                    }else{
                        if (!self.isNewCustomer) {
                            if (SIMI_SYSTEM_IOS >= 8) {
                                [self.navigationController popToRootViewControllerAnimated:YES];
                            }else
                            {
                                [self.navigationController popToRootViewControllerAnimated:NO];
                            }
                            UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
                            SCThankYouPageViewController *thankVC = [[SCThankYouPageViewController alloc] init];
                            thankVC.number = invoiceNumber;
                            thankVC.order = self.order;
                            if(self.checkoutGuest){
                                thankVC.isGuest = YES;
                            }else
                                thankVC.isGuest = NO;
                            UINavigationController *navi;
                            navi = [[UINavigationController alloc]initWithRootViewController:thankVC];
                            _popThankController = [[UIPopoverController alloc] initWithContentViewController:navi];
                            thankVC.popOver = _popThankController;
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                [_popThankController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:currentVC.view permittedArrowDirections:0 animated:YES];
                            });
                        }
                    }
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:DidPlaceOrderAfter object:self.order userInfo:@{@"data": self.order, @"payment": [self.order valueForKey:@"payment"], @"controller": self, @"responder":responder, @"cart":self.cart, @"shipping":shippingModel}];
        }else{
            //Fail
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:SCLocalizedString(responder.responseMessage) delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
            [alertView show];
            [self.tableViewOrder deselectRowAtIndexPath:[self.tableViewOrder indexPathForSelectedRow] animated:YES];
        }
    }
    if ([[[self.paymentCollection objectAtIndex:self.selectedPayment] valueForKey:@"type"] integerValue] == PaymentShowTypeSDK) {
        if (self.isDiscontinue) {
            self.isDiscontinue = NO;
        }else
        {
            [[SimiGlobalVar sharedInstance]resetQuote];
            if (SIMI_SYSTEM_IOS >= 8) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }else
            {
                [self.navigationController popToRootViewControllerAnimated:NO];
            }
        }
    }
    if (![[SimiGlobalVar sharedInstance]isLogin] && !self.isNewCustomer) {
        [SimiGlobalVar sharedInstance].addressBookCollection = nil;
    }
    [self removeObserverForNotification:noti];
}
#pragma mark Toolbar Delegates
- (void)toolbarDidClickCancelButton:(SimiToolbar *)toolbar{
    [self textFieldDidEndEditing:self.textFieldCouponCode];
}
- (void)toolbarDidClickDoneButton:(SimiToolbar *)toolbar{
    [self textFieldDidEndEditing:self.textFieldCouponCode];
    [self textFieldShouldReturn:self.textFieldCouponCode];
}
#pragma mark Alert View Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == TF_COUPON_CODE) {
        [self.textFieldCouponCode resignFirstResponder];
        if (buttonIndex == 0) {
            //Not cancel coupon code
            self.textFieldCouponCode.text = [[self.order valueForKey:@"fee"] valueForKey:@"coupon_code"];
        }else{
            //Cancel coupon code
            [[self.order valueForKey:@"fee"] setValue:@"" forKey:@"coupon_code"];
            self.textFieldCouponCode.text = [[self.order valueForKey:@"fee"] valueForKey:@"coupon_code"];
            [self toolbarDidClickDoneButton:nil];
            [self hideKeyboard];
        }
    }else if (alertView.tag == AGREEMENT){
        if (buttonIndex == 0) {
            self.accept = NO;
            [self.tableViewOrder deselectRowAtIndexPath:[self.tableViewOrder indexPathForSelectedRow] animated:YES];
        }else{
            self.accept = YES;
            [self placeOrder];
        }
    }
}

#pragma mark Text Field Delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self keyboardWasShown];
    }
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField{
    if ([textField isEqual:self.textFieldCouponCode]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(@"Do you want to cancel this coupon code ?") delegate:self cancelButtonTitle:SCLocalizedString(@"Cancel") otherButtonTitles:SCLocalizedString(@"OK"), nil];
        alertView.tag = TF_COUPON_CODE;
        [alertView show];
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField isEqual: self.textFieldCouponCode]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSetCouponCode:) name:DidSetCouponCode object:order];
        if([SimiGlobalVar sharedInstance].quoteId != nil){
            if(![currentCouponCode isEqualToString:@""] && [self.textFieldCouponCode.text isEqualToString:@""]){
                [self.order removeCouponCode:currentCouponCode quoteId:[SimiGlobalVar sharedInstance].quoteId];
            }else{
                 [self.order setCouponCode:self.textFieldCouponCode.text quoteId:[SimiGlobalVar sharedInstance].quoteId];
            }
        }
        [self startLoadingData];
        [self hideKeyboard];
    }
    [self reloadData];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if ([textField isEqual:self.textFieldCouponCode]) {
        [self hideKeyboard];
    }
    [self reloadData];
}

@end

#pragma mark UITableSubtitle Cell
@implementation UITableSubtitleCell
@synthesize lblBody, lblTitle;
@end


#pragma mark UITable Address Cell
@implementation UITableAddressCell
- (void)setAddressModel:(SimiAddressModel*)addressModel
{
    if(_address != addressModel)
    {
        _address = [addressModel copy];
        CGFloat heightCell = 13;
        int imageX = self.frame.size.width/20;
        int addressX = imageX + 25;
        int editImageX = self.frame.size.width - 30;
        int addressWidth = self.frame.size.width - 20;
        int addressHeight = 20;
        
        //gin edit RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            imageX = [SimiGlobalVar scaleValue:290];
            addressX = 10;
            addressWidth = [SimiGlobalVar scaleValue:270];
            editImageX = 10;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                imageX = [SimiGlobalVar scaleValue:484];
                addressX = 10;
                addressWidth = [SimiGlobalVar scaleValue:464];
                editImageX = 10;
            }
        }
        //gin end
        if (addressModel != nil) {
            //User Name
            UIImageView *userImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageX, heightCell + 3, 15, 15)];
            [userImageView setImage:[[UIImage imageNamed:@"ic_user"] imageWithColor:THEME_ICON_COLOR]];
            
            UIImageView *editImageView = [[UIImageView alloc]initWithFrame:CGRectMake(editImageX,  heightCell - 7, 15, 15)];
            [editImageView setImage:[[UIImage imageNamed:@"ic_address_edit"] imageWithColor:THEME_ICON_COLOR]];
            
            UILabel *userLabel = [[UILabel alloc]initWithFrame:CGRectMake(addressX, heightCell, addressWidth, addressHeight)];
            userLabel.text = [NSString stringWithFormat:@"%@%@%@", [addressModel valueForKey:@"first_name"], @" ", [addressModel valueForKey:@"last_name"]];
            userLabel.textColor =  THEME_TEXT_COLOR;
            userLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:16.0];
            CGFloat labelHeight = [userLabel.text sizeWithFont:userLabel.font].height;
            [self addSubview:userImageView];
            [self addSubview:editImageView];
            [self addSubview:userLabel];
            heightCell += labelHeight + 5;
            
            // User Address
            if([addressModel valueForKey:@"street"]){
                UIImageView *addressImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageX, heightCell + 3, 15, 15)];
                [addressImageView setImage:[[UIImage imageNamed:@"ic_street"] imageWithColor:THEME_ICON_COLOR]];
                
                UILabel *addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(addressX, heightCell, addressWidth - 5, addressHeight)];
                addressLabel.text = [NSString stringWithFormat:@"%@", [addressModel valueForKey:@"street"]];
                if([addressModel valueForKey:@"city"]){
                    addressLabel.text = [addressLabel.text stringByAppendingString:[NSString stringWithFormat:@", %@", [addressModel valueForKey:@"city"]]];
                }
                if([addressModel valueForKey:@"state"] &&
                   ![[addressModel valueForKey:@"state"] isKindOfClass:[NSNull class]]){
                    addressLabel.text = [addressLabel.text stringByAppendingString:[NSString stringWithFormat:@", %@", [[addressModel valueForKey:@"state"] valueForKey:@"name"]]];
                }
                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
                    NSRange stringRange = {0, MIN([userLabel.text length], 68)};
                    stringRange = [userLabel.text rangeOfComposedCharacterSequencesForRange:stringRange];
//                    if ([addressLabel.text length] > stringRange.length) {
//                        addressLabel.text = [addressLabel.text substringWithRange:stringRange];
//                    }
                    if([userLabel.text length] > 68){
                        userLabel.text = [userLabel.text stringByAppendingString:@"..."];
                    }
                }
                addressLabel.textColor = THEME_TEXT_COLOR;
                addressLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:16.0];
                labelHeight = [addressLabel.text sizeWithFont:addressLabel.font].height;
                [addressLabel resizLabelToFit];
                CGRect frame = addressLabel.frame;
                if(frame.size.height > 22){
                    frame.size.height = 40;
                    userLabel.numberOfLines = 2;
                    heightCell += frame.size.height;
                }else{
                    heightCell += labelHeight;
                }
                [self addSubview:addressImageView];
                [self addSubview:addressLabel];
            }
            UILabel *addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(addressX, heightCell, addressWidth, addressHeight)];
            addressLabel.text = @"";
            if([addressModel valueForKey:@"zip"]){
                if(![addressLabel.text isEqualToString:@""])
                    addressLabel.text = [addressLabel.text stringByAppendingString:@", "];
                addressLabel.text = [addressLabel.text stringByAppendingString:[NSString stringWithFormat:@"%@", [addressModel valueForKey:@"zip"]]];
            }
            if([addressModel valueForKey:@"country"]){
                if(![addressLabel.text isEqualToString:@""])
                    addressLabel.text = [addressLabel.text stringByAppendingString:@", "];
                addressLabel.text =[addressLabel.text stringByAppendingString:[NSString stringWithFormat:@"%@", [[addressModel valueForKey:@"country"] valueForKey:@"name"]]];
            }
            addressLabel.textColor = THEME_TEXT_COLOR;
            addressLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:16.0];
            labelHeight = [addressLabel.text sizeWithFont:addressLabel.font].height;
            [self addSubview:addressLabel];
            heightCell += labelHeight + 5;
            // User Phone
            if([addressModel valueForKey:@"phone"]){
                userImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageX, heightCell + 3, 15, 15)];
                [userImageView setImage:[[UIImage imageNamed:@"ic_phone"] imageWithColor:THEME_ICON_COLOR]];
                userLabel = [[UILabel alloc]initWithFrame:CGRectMake(addressX, heightCell, addressWidth, addressHeight)];
                userLabel.text = [NSString stringWithFormat:@"%@", [addressModel valueForKey:@"phone"]];
                userLabel.textColor = THEME_TEXT_COLOR;
                userLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:16.0];
                labelHeight = [userLabel.text sizeWithFont:userLabel.font].height;
                [self addSubview:userImageView];
                [self addSubview:userLabel];
                heightCell += labelHeight + 5;
            }
            // User Email
            if([addressModel valueForKey:@"email"]){
                userImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageX, heightCell + 3, 15, 15)];
                [userImageView setImage:[[UIImage imageNamed:@"ic_email"] imageWithColor:THEME_ICON_COLOR]];
                userLabel = [[UILabel alloc]initWithFrame:CGRectMake(addressX, heightCell, addressWidth, addressHeight)];
                userLabel.text = [NSString stringWithFormat:@"%@", [addressModel valueForKey:@"email"]];
                userLabel.textColor = THEME_TEXT_COLOR;
                userLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:16.0];
                labelHeight = [userLabel.text sizeWithFont:userLabel.font].height;
                [self addSubview:userImageView];
                [self addSubview:userLabel];
                heightCell += labelHeight + 5;
            }
        }
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            for (UIView *view in self.subviews) {
                if ([view isKindOfClass:[UILabel class]]) {
                    UILabel *label = (UILabel *)view;
                    [label setTextAlignment:NSTextAlignmentRight];
                }
            }
        }
    }
}

@end

#pragma mark Header Button
@implementation SCOrderViewControllerHeaderButton

@end