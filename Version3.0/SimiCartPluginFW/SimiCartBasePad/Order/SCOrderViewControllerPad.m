//
//  SCOrderViewControllerPad.m
//  SimiCartPluginFW
//
//  Created by Axe on 8/13/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCOrderViewControllerPad.h"
#import "SCCartCellPad.h"
#import "SCOrderProductCell.h"
#import "UILabelDynamicSize.h"
#import "SimiFormatter.h"
#import "SCTermConditionViewController.h"
#import "SCOrderFeeCell.h"
#import "UIImage+SimiCustom.h"

#define ZTHEME_SUB_PART_COLOR [[SimiGlobalVar sharedInstance] colorWithHexString:@"#f0f2f2"]

#define ZTHEME_FONT_NAME_LIGHT THEME_FONT_NAME


@implementation SCOrderViewControllerPad


@synthesize shippingAddress = _shippingAddress, paymentCollection = _paymentCollection;;
@synthesize billingAddress = _billingAddress, shippingCollection = _shippingCollection, cart = _cart,  selectedShippingMedthod = _selectedShippingMedthod;
@synthesize selectedPayment = _selectedPayment, cartPrices = _cartPrices , magin_left, btnPlaceNow;

#pragma mark Main Method
-(void)viewDidLoadBefore
{
    [self setToSimiView];
    [self configureLogo];
    [self configureNavigationBarOnViewDidLoad];
    self.firstScrollToPaymentMethod = YES;
    self.firstScrollToShippingMethod = YES;
    self.selectedPayment = -1;
    //Gin edit
    self.expandableSections = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"NO",ORDER_PAYMENT_SECTION,@"YES",ORDER_SHIPMENT_SECTION, nil];
    //end
    self.selectedShippingMedthod = -1;
    self.selectedPayment = -1;
    self.isReloadPayment = [NSString stringWithFormat:@"%@",[[[[SimiGlobalVar sharedInstance]store] valueForKey:@"store_config"]valueForKey:@"is_reload_payment_method"]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getOrderConfig) name:@"DidAddToCart" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidCreate2CheckoutPayment" object:nil userInfo:@{@"orderViewController": self}];
    self.magin_left = 20;
    [self addShippingAddressForQuote];
    [self addBillingAddressForQuote];
    
    btnPlaceNow = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 472, 50)];
    btnPlaceNow.layer.masksToBounds = NO;
    btnPlaceNow.layer.shadowColor = THEME_BUTTON_BACKGROUND_COLOR.CGColor;
    btnPlaceNow.layer.shadowOpacity = 0.7;
    btnPlaceNow.layer.shadowRadius = -1;
    btnPlaceNow.layer.shadowOffset = CGSizeMake(-0, 5);
    [btnPlaceNow setBackgroundColor:THEME_BUTTON_BACKGROUND_COLOR];
    [btnPlaceNow setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnPlaceNow.titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:18]];
    [btnPlaceNow setTitle:[SCLocalizedString(@"Place Now") uppercaseString] forState:UIControlStateNormal];
    [btnPlaceNow setTitleColor:THEME_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
    [btnPlaceNow addTarget:self action:@selector(placeOrder) forControlEvents:UIControlEventTouchUpInside];
    [SimiGlobalVar sharedInstance].needGetCart = YES;

}

- (void)viewWillAppearBefore:(BOOL)animated
{

    if (_tableLeft == nil) {
        _tableLeft = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 512, SCREEN_HEIGHT - 64) style:UITableViewStyleGrouped];
        _tableLeft.backgroundColor = [UIColor clearColor];
        _tableLeft.showsVerticalScrollIndicator = NO;
        _tableLeft.showsHorizontalScrollIndicator = NO;
        _tableLeft.dataSource = self;
        _tableLeft.delegate = self;
        _tableLeft.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [_tableLeft setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:_tableLeft];
    }
    
    if (_tableRight == nil) {
        _tableLeft.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _tableRight = [[UITableView alloc]initWithFrame:CGRectMake(512, 0, 512 , SCREEN_HEIGHT - 64) style:UITableViewStyleGrouped];
        _tableRight.backgroundColor = [UIColor clearColor];
        _tableRight.showsHorizontalScrollIndicator = NO;
        _tableRight.showsVerticalScrollIndicator = NO;
        _tableRight.dataSource = self;
        _tableRight.delegate = self;
        [self.view addSubview:_tableRight];
    }
    if (self.separatingLine == nil) {
        self.separatingLine = [[UIView alloc]initWithFrame:CGRectMake(512, 0, 1, 768)];
        [self.separatingLine setBackgroundColor:THEME_LINE_COLOR];
        [self.separatingLine setHidden:YES];
        [self.view addSubview:self.separatingLine];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)reloadData
{
    [self.separatingLine setHidden:NO];
    [self configOrderTableLeft];
    [self configOrderTableRight];
    [self.tableLeft reloadData];
    [self.tableRight reloadData];
}


- (void)configOrderTableLeft
{
    _orderTableLeft = [SimiTable new];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SCOrderViewController-InitLeftTableBefore" object:_orderTableLeft];
    SimiSection *billingAddressSection = [[SimiSection alloc] initWithIdentifier:ORDER_BILLING_ADDRESS_SECTION];
    billingAddressSection.headerTitle = SCLocalizedString(@"Billing Address");
    SimiRow *billingAddressRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_BILLING_ADDRESS height:160];
    [billingAddressSection addRow:billingAddressRow];
    [_orderTableLeft addObject:billingAddressSection];
    if(self.shippingCollection.count > 0){
        SimiSection *shippingAddressSection = [[SimiSection alloc] initWithIdentifier:ORDER_SHIPPING_ADDRESS_SECTION];
        shippingAddressSection.headerTitle = SCLocalizedString(@"Shipping Address");
        SimiRow *shippingAddressRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_SHIPPING_ADDRESS height:160];
        [shippingAddressSection addRow:shippingAddressRow];
        [_orderTableLeft addObject:shippingAddressSection];
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
        }
        else {
            SimiRow * separatingRow = [[SimiRow alloc]initWithIdentifier:nil height:5];
            [shipmentSection addRow:separatingRow];
        }
        [_orderTableLeft addObject:shipmentSection];
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
                    NSString *content = [[self.paymentCollection objectAtIndex:i] valueForKey:@"description"];
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
        }
        else {
            SimiRow * separatingRow = [[SimiRow alloc]initWithIdentifier:nil height:5];
            [paymentSection addRow:separatingRow];
        }
        [_orderTableLeft addObject:paymentSection];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SCOrderViewController-InitLeftTableAfter" object:_orderTableLeft];
}


- (void)configOrderTableRight
{
    _orderTableRight = [SimiTable new];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SCOrderViewController-InitRightTableBefore" object:_orderTableRight];
    
    //Add Shippment Detail section
    SimiSection *shipmentDetailSection = [[SimiSection alloc]initWithIdentifier:ORDER_TOTALS_SECTION];
    shipmentDetailSection.headerTitle = SCLocalizedString(@"Shipment Details");
    if(self.cart.count > 0){
        for(int j=0; j<self.cart.count; j++){
            SimiRow *cartItemRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_CART height:155];
            [shipmentDetailSection addRow:cartItemRow];
        }
    }
    CGFloat heightRow = 60;
    NSMutableDictionary * totalV2 = self.cartPrices;
    if(totalV2.count > 0 ){
        if(![[SimiGlobalVar sharedInstance] isReverseLanguage]){
            heightRow = 26 * totalV2.count + 30;
        }else{
            heightRow = 45 * totalV2.count + 30;
        }
    }
    SimiRow *totalRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_TOTAL height:heightRow];
    [shipmentDetailSection addRow:totalRow];
    SimiRow *couponRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_COUPONCODE height:80];
    [shipmentDetailSection addRow:couponRow];
    
    if(self.termAndConditions.count > 0){
        for(int m=0; m<self.termAndConditions.count; m++){
            SimiRow *termRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_TERM height:80];
            termRow.data = [self.termAndConditions objectAtIndex:m];
            [shipmentDetailSection addRow:termRow];
        }
    }
    SimiRow *placeNowRow = [[SimiRow alloc] initWithIdentifier:ORDER_VIEW_PLACE height:90];
    [shipmentDetailSection addRow:placeNowRow];
    
    [_orderTableRight addObject:shipmentDetailSection];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SCOrderViewController-InitRightTableAfter" object:_orderTableRight];
}

#pragma mark Place Order
- (void)placeOrder{
    //Gin edit
    if ((self.selectedPayment >= 0)&&(self.selectedShippingMedthod >=0)) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        if ([self.termAndConditions count]) {
            self.accept = NO;
            for (NSDictionary *term in self.termAndConditions) {
                if (![[term objectForKey:@"checked"] boolValue]) {
                    // Scroll to term and condition
                    [self.tableRight scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([self.tableRight numberOfRowsInSection:[self.orderTableRight getSectionIndexByIdentifier:ORDER_TOTALS_SECTION]] - 1) inSection:[self.orderTableRight getSectionIndexByIdentifier:ORDER_TOTALS_SECTION]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    // Show alert
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(@"Please agree to all the terms and conditions before placing the order.") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles:nil];
                    [alertView show];
                    return;
                }
            }
            self.accept = YES;
        }
        if (self.accept) {
            [params setValue:@"1" forKey:@"condition"];
        }else{
            [params setValue:@"0" forKey:@"condition"];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DidPlaceOrder object:self.order];
        // Liam Update Credit Card
        SimiModel *payment = [self.paymentCollection objectAtIndex:self.selectedPayment];
        [[NSNotificationCenter defaultCenter]postNotificationName:SCOrderViewControllerBeforePlaceOrder object:self userInfo:@{@"order":self.order,@"payment":payment}];
        if (self.isDiscontinue) {
            self.isDiscontinue = NO;
            return;
        }
        [self startLoadingData];
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [self.order placeOrderWithParams:[SimiGlobalVar sharedInstance].quoteId];
        self.tabBarController.tabBar.userInteractionEnabled = NO;
    } else if(self.selectedShippingMedthod == -1){
        // Scroll to shipping methods
        
        if (![[self.expandableSections valueForKey:ORDER_SHIPMENT_SECTION]boolValue]) {
            [self.expandableSections setValue:@"YES" forKey:ORDER_SHIPMENT_SECTION];
            [self configOrderTableLeft];
            [self.tableLeft reloadSections:[NSIndexSet indexSetWithIndex:[self.orderTableLeft getSectionIndexByIdentifier:ORDER_SHIPMENT_SECTION]] withRowAnimation:UITableViewRowAnimationFade];
        }
        [self.tableLeft scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.orderTableLeft getSectionIndexByIdentifier:ORDER_SHIPMENT_SECTION]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
            [self configOrderTableLeft];
            [self.tableLeft reloadSections:[NSIndexSet indexSetWithIndex:[self.orderTableLeft getSectionIndexByIdentifier:ORDER_PAYMENT_SECTION]] withRowAnimation:UITableViewRowAnimationFade];
        }
        [self.tableLeft scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.orderTableLeft getSectionIndexByIdentifier:ORDER_PAYMENT_SECTION]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(@"Please choose a payment method") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
    }
}


#pragma mark TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == self.tableLeft) {
        return _orderTableLeft.count;
    }
    else
        return _orderTableRight.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tableLeft) {
        return [[_orderTableLeft objectAtIndex:section] count];
    }
    return [[_orderTableRight objectAtIndex:section] count];
}


- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *headerTitle = @"";
    SimiSection *simiSection;
    if (tableView == self.tableLeft)
        simiSection = [_orderTableLeft objectAtIndex:section];
    else
        simiSection = [_orderTableRight objectAtIndex:section];
    
    headerTitle = simiSection.headerTitle;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, tableView.bounds.size.width, 30)];
    headerView.backgroundColor = THEME_SECTION_COLOR;
    UILabel *headerTitleSection = [[UILabel alloc]initWithFrame:CGRectMake(self.magin_left, 5, tableView.bounds.size.width - 20, 30)];
    [headerTitleSection setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:18]];
     headerTitleSection.text = headerTitle;
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
        [headerTitleSection setFrame:CGRectMake([SimiGlobalVar scaleValue:5], 5,tableView.bounds.size.width - [SimiGlobalVar scaleValue:20], 30)];
        [headerTitleSection setTextAlignment:NSTextAlignmentRight];
    }
    [headerView addSubview:headerTitleSection];
    
    CGRect headerFrame = headerView.frame;
    headerFrame.origin.x = 0;
    
    SCOrderViewControllerHeaderButton * headerButton = [[SCOrderViewControllerHeaderButton alloc]initWithFrame:headerFrame];
    headerButton.simiObjectIdentifier = [NSNumber numberWithInteger:section];
    if ([self.expandableSections objectForKey:simiSection.identifier]!= nil) {
        headerButton.narrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(headerButton.frame.size.width - 26, 15, 10, 10)];
        //Gin edit
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [headerButton.narrowImage setFrame:CGRectMake(10, 15, 10, 10)];
        }
        //End
        if ([(NSString *)[self.expandableSections objectForKey:simiSection.identifier] boolValue]) {
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
    SimiSection *simiSection;
    if (tableView == self.tableLeft)
        simiSection = [_orderTableLeft objectAtIndex:indexPath.section];
    else
        simiSection = [_orderTableRight objectAtIndex:indexPath.section];
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
    return 0.001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc]initWithFrame:CGRectZero];
}

// To make full width tableView Separating Lines
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //get the row before term row then remove separating line
    if (tableView == self.tableRight) {
        SimiSection *simiSection = [self.orderTableRight objectAtIndex:indexPath.section];
        if ((indexPath.row < (simiSection.rows.count -1)) && (simiSection.identifier == ORDER_TOTALS_SECTION)) {
            SimiRow *simiRow = [simiSection.rows objectAtIndex:(indexPath.row +1)];
            if ((simiRow.identifier == ORDER_VIEW_TERM)|| (simiRow.identifier == ORDER_VIEW_PLACE)) {
                [cell setSeparatorInset:UIEdgeInsetsMake(0, SCREEN_WIDTH, 0, 0)];
                return;
            }
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

#pragma mark Cell for Row At IndexPath

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    SimiSection *simiSection;
    if (tableView == self.tableLeft)
        simiSection = [_orderTableLeft objectAtIndex:indexPath.section];
    else
        simiSection = [_orderTableRight objectAtIndex:indexPath.section];
    
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
            [cell setFrame:CGRectMake(0, 0, self.tableLeft.frame.size.width, simiRow.height)];
            [(UITableAddressCell*)cell setAddressModel:self.billingAddress];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
        }
    }
#pragma mark Shipping Address Section
    else if ([simiSection.identifier isEqualToString:ORDER_SHIPPING_ADDRESS_SECTION]){
        if(simiRow.identifier == ORDER_VIEW_SHIPPING_ADDRESS){
            cell = [[UITableAddressCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_VIEW_BILLING_ADDRESS];
            [cell setFrame:CGRectMake(0, 0, self.tableLeft.frame.size.width, simiRow.height)];
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
            
            UILabel *lblContentPayment = [[UILabel alloc]initWithFrame:CGRectMake(40, 30, 260, 20)];
            [lblContentPayment setFont:[UIFont fontWithName:THEME_FONT_NAME size:12]];
            
            if ([[payment valueForKey:@"type"] integerValue] == PaymentShowTypeNone) {
                cell = [[SCOrderMethodCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PaymentShowTypeNoneCell];
                paymentTitle = [payment valueForKey:@"title"];
                if (![[payment valueForKey:@"description"] isKindOfClass:[NSNull class]] && indexPath.row == self.selectedPayment) {
                    paymentContent = [payment valueForKey:@"description"];
                }
            }else if ([[payment valueForKey:@"type"] integerValue] == PaymentShowTypeCreditCard){
                cell = [[SCOrderMethodCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:PaymentShowTypeCreditCardCell];
                paymentTitle = [payment valueForKey:@"title"];
                if (indexPath.row == self.selectedPayment) {
                    for (int i = 0; i < self.creditCards.count; i++) {
                        SimiModel *creditCard = [self.creditCards objectAtIndex:i];
                        if ([[creditCard valueForKey:@"payment_method"] isEqualToString:[payment valueForKey:@"payment_method"]]) {
                            if ([[creditCard valueForKey:hasData]boolValue]) {
                                paymentContent = [NSString stringWithFormat:@"****%@", [[creditCard valueForKey:@"card_number"] substringWithRange:NSMakeRange([[creditCard valueForKey:@"card_number"] length] - 4, 4)]];
                                
                                lblContentPayment.text = [NSString stringWithFormat:@"****%@", [[creditCard valueForKey:@"card_number"] substringWithRange:NSMakeRange([[creditCard valueForKey:@"card_number"] length] - 4, 4)]];
                                [cell addSubview:lblContentPayment];
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
            if (self.selectedPayment == -1 && self.firstScrollToPaymentMethod){
                self.firstScrollToPaymentMethod = NO;
                [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.orderTableLeft getSectionIndexByIdentifier:ORDER_PAYMENT_SECTION]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
            // end
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
            [cell setFrame:CGRectMake(0, 0, self.tableLeft.frame.size.width, simiRow.height)];
            [(SCOrderFeeCell *)cell setData:self.cartPrices];
            cell.userInteractionEnabled = NO;
        }
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
                    frame.size.width = cell.frame.size.width - [SimiGlobalVar scaleValue:30];
                    frame.origin.y = [SimiGlobalVar scaleValue:10];
                    frame.size.height = [SimiGlobalVar scaleValue:20];
                    self.textFieldCouponCode.frame = frame;
                    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.textFieldCouponCode.frame.size.height)];
                    self.textFieldCouponCode.leftView = paddingView;
                    self.textFieldCouponCode.leftViewMode = UITextFieldViewModeAlways;
                    [self.textFieldCouponCode setBackgroundColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#e8e8e8"]];
                    self.textFieldCouponCode.placeholder = SCLocalizedString(@"Enter a coupon code");
                    self.textFieldCouponCode.autocorrectionType = UITextAutocorrectionTypeNo;
                    self.textFieldCouponCode.delegate = self;
                    [self.textFieldCouponCode setClearButtonMode:UITextFieldViewModeUnlessEditing];
                    self.textFieldCouponCode.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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
                cell = [tableView dequeueReusableCellWithIdentifier:ORDER_VIEW_TERM];
                if(cell == nil){
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_VIEW_TERM];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    NSDictionary *term = simiRow.data;
                    if([term objectForKey:@"name"]){
                        UILabel *termLabel = [[UILabel alloc]initWithFrame:CGRectMake(magin_left, 8, CGRectGetWidth(self.view.frame) - 30, 20)];
                        termLabel.text = [term objectForKey:@"name"];
                        [termLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:16]];
                        [termLabel setTextColor:THEME_CONTENT_COLOR];
                        [termLabel resizLabelToFit];
                        [cell addSubview:termLabel];
                        if ([[SimiGlobalVar sharedInstance] isReverseLanguage]) {
                            [termLabel setFrame: CGRectMake(magin_left , 8, [SimiGlobalVar scaleValue:512] - 45, 20)];
                            [termLabel setTextAlignment:NSTextAlignmentRight];
                        }
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    }
                    SimiCheckbox *checkbox = [[SimiCheckbox alloc] initWithTitle:[term objectForKey:@"title"]];
                    [checkbox.titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:16]];
                    [checkbox.titleLabel setTextColor:THEME_CONTENT_COLOR];
                    checkbox.strokeColor = THEME_TEXT_COLOR;
                    checkbox.frame = CGRectMake(magin_left, 30, SCREEN_WIDTH - 30, 35);
                    
                    if ([[SimiGlobalVar sharedInstance] isReverseLanguage]) {
                        [checkbox setFrame: CGRectMake(magin_left, 30, [SimiGlobalVar scaleValue:512] - 46, 35)];
                        [checkbox.titleLabel setTextAlignment:NSTextAlignmentRight];
                        [checkbox setCheckAlignment:M13CheckboxAlignmentRight];
                    }
                    if ([[term objectForKey:@"checked"] boolValue]) {
                        [checkbox setCheckState:M13CheckboxStateChecked];
                    }
                    checkbox.radius = 1.0f;
                    checkbox.simiObjectIdentifier = simiRow.data;
                    [cell addSubview:checkbox];
                    [checkbox addTarget:self action:@selector(toggleCheckBox:) forControlEvents:UIControlEventValueChanged];
                }
            }
        }
        //coupon code row
        else if(simiRow.identifier == ORDER_VIEW_PLACE){
            cell = [tableView dequeueReusableCellWithIdentifier:ORDER_VIEW_PLACE];
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_VIEW_PLACE];
                [cell addSubview:btnPlaceNow];
            }
        }
#pragma mark Shiment Section
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
            priceLabel.text = [[SimiFormatter sharedInstance] priceByLocalizeNumber:[NSNumber numberWithFloat:[[simiRow.data valueForKey:@"price"] floatValue]]];
            [cell addSubview:priceLabel];
            float widthPrice = [priceLabel.text sizeWithFont:priceLabel.font].width;
            [priceLabel setFrame:[SimiGlobalVar scaleFrame:CGRectMake(cell.frame.size.width - widthPrice -10, 0,widthPrice, cell.frame.size.height)]];
            if ([[SimiGlobalVar sharedInstance] isReverseLanguage]) {
                [priceLabel setFrame:[SimiGlobalVar scaleFrame:CGRectMake(10, 0,widthPrice, cell.frame.size.height)]];
                [priceLabel setTextAlignment:NSTextAlignmentLeft];
            }
            BOOL isSelected = NO;
            if (indexPath.row == self.selectedShippingMedthod) {
                isSelected = YES;
            }
            [(SCOrderMethodCell *)cell setTitle:methodName andContent:methodContent andIsSelected:isSelected];
            //Gin edit
            if (self.selectedShippingMedthod == -1 && self.firstScrollToShippingMethod){
                self.firstScrollToShippingMethod = NO;
                [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.orderTableLeft getSectionIndexByIdentifier:ORDER_SHIPMENT_SECTION]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
            // end
        }
    }
    if (cell == nil) {
        cell = [UITableViewCell new];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedOrderCell-After" object:simiRow userInfo:@{@"tableView": tableView, @"indexPath": indexPath, @"cell": cell}];
    return cell;
}
#pragma mark TableView Delegate

#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection;
    if (tableView == self.tableLeft)
        simiSection = [self.orderTableLeft objectAtIndex:indexPath.section];
    else
        simiSection = [self.orderTableRight objectAtIndex:indexPath.section];
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
        //[self.navigationController pushViewController:nextController animated:YES];
        
        UINavigationController *navi;
        navi = [[UINavigationController alloc]initWithRootViewController:nextController];
        _popController = [[UIPopoverController alloc] initWithContentViewController:navi];
        _popController.delegate = self;
        nextController.popover = _popController;
        navi.navigationBar.tintColor = THEME_COLOR;
        if (SIMI_SYSTEM_IOS >= 8) {
            navi.navigationBar.tintColor = THEME_APP_BACKGROUND_COLOR;
        }
        navi.navigationBar.barTintColor = THEME_COLOR;
        [_popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:self.view permittedArrowDirections:0 animated:YES];
        
    }if(simiRow.identifier == ORDER_VIEW_SHIPPING_ADDRESS){
        self.isSelectBillingAddress = NO;
        SCAddressViewController *nextController = [[SCAddressViewController alloc]init];
        [nextController setDelegate:self];
        [nextController setIsGetOrderAddress:YES];
        //[self.navigationController pushViewController:nextController animated:YES];
        
        UINavigationController *navi;
        navi = [[UINavigationController alloc]initWithRootViewController:nextController];
        _popController = [[UIPopoverController alloc] initWithContentViewController:navi];
        _popController.delegate = self;
        nextController.popover = _popController;
        navi.navigationBar.tintColor = THEME_COLOR;
        if (SIMI_SYSTEM_IOS >= 8) {
            navi.navigationBar.tintColor = [UIColor whiteColor];
        }
        navi.navigationBar.barTintColor = THEME_COLOR;
        [_popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:self.view permittedArrowDirections:0 animated:YES];
    }else if(simiRow.identifier == ORDER_VIEW_PAYMENT_METHOD){
        self.selectedPayment  = indexPath.row;
        SimiModel *payment = [self.paymentCollection objectAtIndex:self.selectedPayment];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectPaymentMethod" object:payment userInfo:@{@"payment": payment}];
        if ([[payment valueForKey:@"show_type"] integerValue] == PaymentShowTypeCreditCard) {
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
            
        }else{
//            if([self.isReloadPayment isEqualToString:@"1"]){
                [self savePaymentMethod:payment];
//            }
        }
        [self reloadData];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else if(simiRow.identifier == ORDER_VIEW_SHIPPING_METHOD){
        [self didSelectShippingMethodAtIndex: indexPath.row];
    }else if(simiRow.identifier == ORDER_VIEW_TERM){
        // Show term and condition
        SCTermConditionViewController *termView = [[SCTermConditionViewController alloc] init];
        termView.termAndCondition = simiRow.data;
        [self.navigationController pushViewController:termView animated:YES];
    }
}


#pragma mark Header Expanding

- (void)didClickHeader:(id)sender
{
    SCOrderViewControllerHeaderButton * headerButton = (SCOrderViewControllerHeaderButton *)sender;
    int section = [(NSNumber *)headerButton.simiObjectIdentifier intValue];

    SimiSection *currentSection = [self.orderTableLeft objectAtIndex:section];
    
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
            [self.tableLeft beginUpdates];
            [self.tableLeft deleteRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationFade];
            [self.expandableSections setValue:@"NO" forKey:currentSection.identifier];
            [self configOrderTableLeft];
            [self.tableLeft insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:section]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableLeft endUpdates];
        }
        //if it's not expanded yet, expand it
        else {
            [headerButton.narrowImage setImage:[UIImage imageNamed:@"ic_narrow_up"]];
            [self.expandableSections setValue:@"YES" forKey:currentSection.identifier];
            [self configOrderTableLeft];
            currentSection = [self.orderTableLeft objectAtIndex:section];
            for (int i = 0; i < currentSection.count; i++) {
                NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:section];
                [indexPathsArray addObject:path];
            }
            [self.tableLeft beginUpdates];
            [self.tableLeft deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:section]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableLeft insertRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationFade];
            [self.tableLeft endUpdates];
        }
        //Gin edit
        [self.tableLeft scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        // end
    }
}

#pragma mark SCShipping Delegate
- (void)didSelectShippingMethodAtIndex:(NSInteger)index{
    self.selectedShippingMedthod = index;
    //Gin edit
    if ([[self.expandableSections valueForKey:ORDER_PAYMENT_SECTION]boolValue]) {
        [self.tableLeft scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.orderTableLeft getSectionIndexByIdentifier:ORDER_PAYMENT_SECTION]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }else
    {
        [self.expandableSections setValue:@"YES" forKey:ORDER_PAYMENT_SECTION];
        [self configOrderTableLeft];
        if (self.selectedPayment != -1){
            [self.tableLeft reloadSections:[NSIndexSet indexSetWithIndex:[self.orderTableLeft getSectionIndexByIdentifier:ORDER_PAYMENT_SECTION]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableLeft scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.orderTableLeft getSectionIndexByIdentifier:ORDER_PAYMENT_SECTION]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
    //End
    SimiShippingModel *method = (SimiShippingModel *)[self.shippingCollection objectAtIndex:self.selectedShippingMedthod];
    SimiModel *shippingMethod = [self convertShippingData:method];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSaveShippingMethod:) name:DidSaveShippingMethod object:self.order];
    [self startLoadingData];
    if([SimiGlobalVar sharedInstance].quoteId != nil)
        [self.order selectShippingMethod:shippingMethod quoteId:[SimiGlobalVar sharedInstance].quoteId];
    
}

#pragma mark Keyboard Delegate
- (void)keyboardWasShown
{
    UIEdgeInsets contentInsets = self.tableViewOrder.contentInset;
    contentInsets.bottom = 360;
    self.tableLeft.contentInset = contentInsets;
    self.tableLeft.scrollIndicatorInsets = contentInsets;
    self.tableRight.contentInset = contentInsets;
    self.tableRight.scrollIndicatorInsets = contentInsets;
}

- (void)hideKeyboard{
    UIEdgeInsets contentInsets = self.tableViewOrder.contentInset;
    contentInsets.bottom = 0;
    self.tableLeft.contentInset = contentInsets;
    self.tableLeft.scrollIndicatorInsets = contentInsets;
    self.tableRight.contentInset = contentInsets;
    self.tableRight.scrollIndicatorInsets = contentInsets;
}

@end
