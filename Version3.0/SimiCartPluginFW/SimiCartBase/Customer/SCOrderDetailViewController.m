//
//  SCOrderDetailViewController.m
//  SimiCart
//
//  Created by Tan on 7/30/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import "SCOrderDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SCCartCell.h"
#import "SCOrderFeeCell.h"
#import "SimiFormatter.h"
#import "SimiSection.h"
#import "SimiRow.h"
#import "SCThemeWorker.h"
#import "SimiOrderModel.h"

@interface SCOrderDetailViewController ()
@end

@implementation SCOrderDetailViewController
NSString *currencyPosition, *currencySymbol;
@synthesize order, productCollection, shippingAddress, billingAddress, orderId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoadBefore
{
    [self setToSimiView];
    [self.tabBarController.tabBar setHidden:YES];
    self.navigationItem.title = [self formatTitleString:SCLocalizedString(@"Order Detail")];
    self.tableViewOrder = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableViewOrder.delegate = self;
    self.tableViewOrder.dataSource = self;
    [self.tableViewOrder setContentInset:UIEdgeInsetsMake(0, 0, 50, 0)];
    [self.tableViewOrder setHidden:YES];
    [self.view addSubview:self.tableViewOrder];
    [self viewReoder];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewDidLoadBefore];
    }
   
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewWillAppearBefore:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    if(!order)
        [self getOrder];
    else{
        productCollection = [order valueForKey:@"items"];
        shippingAddress = [order valueForKey:@"shipping_address"];
        billingAddress = [order valueForKey:@"billing_address"];
        if (shippingAddress && ![shippingAddress isKindOfClass:[SimiAddressModel class]]) {
            shippingAddress = [[SimiAddressModel alloc] initWithDictionary:shippingAddress];
        }
        if (billingAddress && ![billingAddress isKindOfClass:[SimiAddressModel class]]) {
            billingAddress = [[SimiAddressModel alloc] initWithDictionary:billingAddress];
        }
        [self setCells:nil];
        [self.tableViewOrder setHidden:NO];
        [self.tableViewOrder reloadData];
    }
    [self.tableViewOrder setFrame:self.view.bounds];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIFont *)getFontLabel
{
    return [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
}



- (NSString *)priceFormat: (NSString *)price
{
    SimiGlobalVar *config = [SimiGlobalVar sharedInstance];
    currencyPosition = [config currencyPosition]? [config currencyPosition]:@"right";
    currencySymbol = [config currencySymbol]? [config currencySymbol]:@"";
    
    NSString *getPriceWithCurrency = @"";
    NSString *orderPrice = [NSString stringWithFormat:@"%0.2f", [price floatValue]];
    if([currencyPosition isEqualToString:@"right"]){
        getPriceWithCurrency = [NSString stringWithFormat:@"%2@ %@", orderPrice,currencySymbol ];
    }else{
        getPriceWithCurrency = [NSString stringWithFormat:@"%@%2@",currencySymbol, orderPrice];
    }
    return getPriceWithCurrency;
}

- (void)getOrder{
    if (order == nil) {
        order = [[SimiOrderModel alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetOrder" object:order];
        [order getOrderWithId:orderId];
        [self startLoadingData];
    }
}
//Gin 030815
-(void)viewReoder{
    
    CGRect frameButon = CGRectMake(0, SCREEN_HEIGHT - 64 - 40, SCREEN_WIDTH, 40);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        frameButon = CGRectMake(0, SCREEN_HEIGHT*2/3 - 40, SCREEN_WIDTH *2/3, 40);
    }
    UIButton *btReoder = [[UIButton alloc] initWithFrame:frameButon];
    [btReoder setTitle:SCLocalizedString(@"Reorder") forState:UIControlStateNormal];
    [btReoder setTitleColor:THEME_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
   
    btReoder.backgroundColor = THEME_BUTTON_BACKGROUND_COLOR;
    btReoder.titleLabel.textColor = THEME_BUTTON_TEXT_COLOR;
    btReoder.titleLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
    
    [btReoder addTarget:self action:@selector(reOrder:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:btReoder];
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    float h;
    if(section >= 1){
        h = 20;
    }else{
        h = 40;
    }
    return h;
}
//end
- (void)didReceiveNotification:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        //Gin Edit 030815
        //hainhf//        UIBarButtonItem * reOrderButton = [[UIBarButtonItem alloc]initWithTitle:SCLocalizedString(@"Reorder") style:UIBarButtonItemStylePlain target:self action:@selector(reOrder:)];
        //        self.navigationItem.rightBarButtonItem = reOrderButton;
        //end editing
        //        [self viewReoder];
        
        //End 030815
//        for (SimiProductModel *product in productCollection) {
//            NSString *name = [product valueForKey:@"name"];
//            for (NSDictionary *option in [product valueForKey:@"options"]) {
//                name = [NSString stringWithFormat:@"%@%@", name, [option valueForKey:@"option_title"]];
//            }
//            [product setValue:name forKey:@"product_name"];
//        }
        
        productCollection = [order valueForKey:@"items"];
        shippingAddress = [order valueForKey:@"shipping_address"];
        billingAddress = [order valueForKey:@"billing_address"];
        
        if (shippingAddress && ![shippingAddress isKindOfClass:[SimiAddressModel class]]) {
            shippingAddress = [[SimiAddressModel alloc] initWithDictionary:shippingAddress];
        }
        if (billingAddress && ![billingAddress isKindOfClass:[SimiAddressModel class]]) {
            billingAddress = [[SimiAddressModel alloc] initWithDictionary:billingAddress];
        }
        [self setCells:nil];
        [self.tableViewOrder setHidden:NO];
        [self.tableViewOrder reloadData];
    }
    [super didReceiveNotification:noti];
}

- (void)setCells:(NSMutableArray *)cells{
    if (cells) {
        _cells = cells;
    }else{
        _cells = [[NSMutableArray alloc] init];
        //Add summary section
        SimiSection *summarySection = [[SimiSection alloc] init];
        SimiRow *summaryRow = [[SimiRow alloc] initWithIdentifier:ORDER_DETAIL_SUMMARY height:75];
        [summarySection addRow:summaryRow];
        [_cells addObject:summarySection];
        
        //Add shipping section
        //Axe fixed by edit paramaters and values returned
       
        SimiSection *shippingSection = [[SimiSection alloc] initWithHeaderTitle:SCLocalizedString(@"Shipping") footerTitle:nil];
        if([order objectForKey:@"shipping_address"]){
            SimiRow *shippingAddressRow = [[SimiRow alloc] initWithIdentifier:ORDER_DETAIL_SHIPPING_ADDRESS height:130];
            shippingAddressRow.title = SCLocalizedString(@"Shipping address");
            [shippingSection addRow:shippingAddressRow];
        }
        if([order objectForKey:@"shipping"]){
            NSDictionary* shipping  = [order objectForKey:@"shipping"];
            SimiRow *shippingMethodRow = [[SimiRow alloc] initWithIdentifier:ORDER_DETAIL_SHIPPING_METHOD height:40];
            shippingMethodRow.title = SCLocalizedString([shipping valueForKey:@"title"]);
            [shippingSection addRow:shippingMethodRow];
        }
        [_cells addObject:shippingSection];
        
        //Add cart item section
        SimiSection *cartSection = [[SimiSection alloc] initWithHeaderTitle:SCLocalizedString(@"Items") footerTitle:nil];
        if(productCollection.count > 0){
            for(int i=0; i<productCollection.count; i++){
                SimiRow *cartItemRow = [[SimiRow alloc] initWithIdentifier:ORDER_DETAIL_CART height:[SimiGlobalVar scaleValue:107]];
                [cartSection addRow:cartItemRow];
            }
        }
        [_cells addObject:cartSection];
        
        //Add billing & payment & coupon section
        //Axe fixed
        SimiSection *paymentSection = [[SimiSection alloc] initWithHeaderTitle:SCLocalizedString(@"Payment") footerTitle:nil];
        if([order objectForKey:@"payment"]){
            SimiRow *paymentRow = [[SimiRow alloc] initWithIdentifier:ORDER_DETAIL_PAYMENT_METHOD height:40];
            paymentRow.title = SCLocalizedString(@"Payment method");
            [paymentSection addRow:paymentRow];
        }
        if([order objectForKey:@"billing_address"]){
            SimiRow *billingAddressRow = [[SimiRow alloc] initWithIdentifier:ORDER_DETAIL_BILLING_ADDRESS height:130];
            billingAddressRow.title = SCLocalizedString(@"Billing address");
            [paymentSection addRow:billingAddressRow];
        }
        if([order objectForKey:@"coupon"]){
        SimiRow *couponcode = [[SimiRow alloc]initWithIdentifier:ORDER_DETAIL_COUPONCODE height:40];
            [paymentSection addRow:couponcode];
            couponcode.title = SCLocalizedString(@"Coupon");
        }
        [_cells addObject:paymentSection];
        
        //Add order total section
        SimiSection *orderTotalSection = [[SimiSection alloc]initWithHeaderTitle:SCLocalizedString(@"Fee Detail") footerTitle:nil];
        CGFloat height = 26 * 6;
//        NSArray * totalV2 = [order valueForKey:@"total_v2"];
//        if(![order valueForKey:@"total_v2"]){
//            NSArray *fee= [order valueForKey:@"fee"];
//            totalV2 = [fee valueForKey:@"v2"];
//        }
//        if(totalV2.count > 0 ){
//            if(![[SimiGlobalVar sharedInstance] isReverseLanguage]){
//                height = 26 * totalV2.count;
//            }else{
//                height = [SimiGlobalVar scaleValue:45] * totalV2.count;
//            }
//        }
        [orderTotalSection addRowWithIdentifier:ORDER_DETAIL_TOTAL height:height];
        [_cells addObject:orderTotalSection];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"DidSetOrderDetailCell" object:_cells];
    }
}

#pragma mark Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_cells != nil) {
        return _cells.count;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_cells != nil) {
        return [[_cells objectAtIndex:section] count];
    }
    return 0;
}
//  Liam Update RTL
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        SimiSection *simiSection = [_cells objectAtIndex:section];
        NSString *headerTitle = simiSection.headerTitle;
        UIView *view = [UIView new];
        UILabel *lblHeader = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, CGRectGetWidth(tableView.frame) - 20, 20)];
        [lblHeader setText:[headerTitle uppercaseString]];
        [lblHeader setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2]];
        [lblHeader setTextColor:[UIColor lightGrayColor]];
        [lblHeader setTextAlignment:NSTextAlignmentRight];
        [view addSubview:lblHeader];
        return view;
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (_cells != nil) {
        SimiSection *simiSection = [_cells objectAtIndex:section];
        NSString *headerTitle = simiSection.headerTitle;
        
        return headerTitle;
    }
    return @"";
}
//  End Update RTL

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *row = [simiSection.rows objectAtIndex:indexPath.row];
    CGFloat heightRow = row.height;
    return heightRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];

    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedOrderDetailCell-Before" object:cell];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return cell;
    }
//Axe edited
    if(simiRow.identifier == ORDER_DETAIL_SUMMARY){
      
        cell = [tableView dequeueReusableCellWithIdentifier:ORDER_DETAIL_SUMMARY];
        if (cell == nil) {
        
            OrderDetailCell *orderDetailCell = [[OrderDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_DETAIL_SUMMARY];
            orderDetailCell.dateValueLabel.text = [order valueForKey:@"created_at"];
            orderDetailCell.codeValueLabel.text = [NSString stringWithFormat:@"%@",[order valueForKey:@"seq_no"]];
            orderDetailCell.totalValueLabel.text = [self priceFormat:[order valueForKey:@"grand_total"]];
            cell = orderDetailCell;
        }
    }else if(simiRow.identifier == ORDER_DETAIL_SHIPPING_ADDRESS){
        cell = [tableView dequeueReusableCellWithIdentifier:ORDER_DETAIL_SHIPPING_ADDRESS];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_DETAIL_SHIPPING_ADDRESS];
            cell.textLabel.text = [shippingAddress formatAddress];
            CGSize labelSize = [cell.textLabel.text boundingRectWithSize:cell.textLabel.frame.size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:cell.textLabel.font} context:nil].size;
            cell.textLabel.frame = CGRectMake(
                                              cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y,
                                              cell.textLabel.frame.size.width, labelSize.height);
            cell.textLabel.numberOfLines = 0;
            //  Liam Update RTL
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                [cell.textLabel setTextAlignment:NSTextAlignmentRight];
            }
            //  End RTL
        }
    }else if (simiRow.identifier == ORDER_DETAIL_SHIPPING_METHOD){
        cell = [tableView dequeueReusableCellWithIdentifier:ORDER_DETAIL_SHIPPING_METHOD];
        if (cell== nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_DETAIL_SHIPPING_METHOD];
            cell.textLabel.text = [[order valueForKey:@"shipping"] valueForKey:@"title"];
            //  Liam Update RTL
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                [cell.textLabel setTextAlignment:NSTextAlignmentRight];
            }
            //  End RTL
        }
    }else if (simiRow.identifier == ORDER_DETAIL_CART){
        NSInteger row = [indexPath row];
        SimiProductModel *productModel = [productCollection objectAtIndex:row];
        NSString *CartCellIdentifier = [NSString stringWithFormat:@"%@_%d",@"SCCartCellIdentifier",(int)row];
        SCCartCell *cartCell = [tableView dequeueReusableCellWithIdentifier:CartCellIdentifier];
        if (cartCell == nil) {
            cartCell = [[SCCartCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CartCellIdentifier];
            [cartCell setName:[productModel valueForKeyPath:@"name"]];
            [cartCell setPrice:[productModel valueForKey:@"price"]];
            [cartCell setQty:[NSString stringWithFormat:@"%d", [[productModel valueForKey:@"qty_ordered"] intValue]]];
            NSArray* images = [productModel valueForKey:@"images"];
            if(images && images.count > 0)
                [cartCell setImagePath:[[images objectAtIndex:0] valueForKey:@"url" ]];
            [cartCell setInterfaceCell];
            if (cartCell.heightCell > [SimiGlobalVar scaleValue:107]) {
                ((SimiRow*)[[_cells objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]).height = cartCell.heightCell;
            }
            [cartCell.deleteButton removeFromSuperview];
        }
        //Set cell data
        cell = cartCell;
    }else if (simiRow.identifier == ORDER_DETAIL_PAYMENT_METHOD){
        cell = [tableView dequeueReusableCellWithIdentifier:ORDER_DETAIL_PAYMENT_METHOD];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_DETAIL_PAYMENT_METHOD];
            
            NSString *fourDigit = [order valueForKey:@"card_digit"];
            
            NSString* paymentMethod = [[order valueForKey:@"payment"]valueForKey:@"title"];
            if(paymentMethod){
                if (fourDigit && fourDigit.length > 0) {
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ ***-%@", paymentMethod,fourDigit];
                }else{
                    cell.textLabel.text = [NSString stringWithFormat:@"%@", paymentMethod];
                }
            }
            //  Liam Update RTL
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                [cell.textLabel setTextAlignment:NSTextAlignmentRight];
            }
            //  End RTL
        }
    }else if (simiRow.identifier == ORDER_DETAIL_BILLING_ADDRESS){
        cell = [tableView dequeueReusableCellWithIdentifier:ORDER_DETAIL_BILLING_ADDRESS];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_DETAIL_BILLING_ADDRESS];
            cell.textLabel.text = [billingAddress formatAddress];;
            CGSize labelSize = [cell.textLabel.text boundingRectWithSize:cell.textLabel.frame.size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:cell.textLabel.font} context:nil].size;
            cell.textLabel.frame = CGRectMake(
                                              cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y,
                                              cell.textLabel.frame.size.width, labelSize.height);
            cell.textLabel.numberOfLines = 0;
            //  Liam Update RTL
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                [cell.textLabel setTextAlignment:NSTextAlignmentRight];
            }
            //  End RTL
        }
    }else if (simiRow.identifier == ORDER_DETAIL_COUPONCODE){
        cell = [tableView dequeueReusableCellWithIdentifier:ORDER_DETAIL_COUPONCODE];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_DETAIL_COUPONCODE];
            NSArray* coupons = [order objectForKey:@"coupon"];
            NSString* couponCode = @"";
            if(coupons && coupons.count > 0){
                for(NSDictionary* coupon in coupons){
                    couponCode = [NSString stringWithFormat:@"%@ %@", couponCode, [coupon valueForKey:@"code"] ];
                }
            }
            cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", SCLocalizedString(@"Coupon code"), couponCode];
            //  Liam Update RTL
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                [cell.textLabel setTextAlignment:NSTextAlignmentRight];
            }
            //  End RTL
        }
    }else if (simiRow.identifier == ORDER_DETAIL_TOTAL){
        SCOrderFeeCell *totalCell = [tableView dequeueReusableCellWithIdentifier:ORDER_DETAIL_TOTAL];
        if (totalCell == nil) {
            totalCell = [[SCOrderFeeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_DETAIL_TOTAL];
            [totalCell setOrder:order withCurencyPosition:currencyPosition withCurrencySymbol:currencySymbol];
        }
        cell = totalCell;
    }
    [cell setUserInteractionEnabled:NO];
    
    if (cell == nil) {
        cell = [UITableViewCell new];
    }
    cell.textLabel.font = [self getFontLabel];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedOrderDetailCell-After" object:simiRow userInfo:@{@"tableView": tableView, @"indexPath": indexPath, @"cell": cell}];
    return cell;
}

//hainh
- (void)reOrder:(id)sender
{
//    [order reOrder:orderId];
//    [self startLoadingData];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCompleteReorder:) name:@"DidCompleteReOrder" object:nil];
}

- (void)didCompleteReorder: (NSNotification *)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"") message:SCLocalizedString(@"Reordering Completed") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
            [[SCThemeWorker sharedInstance].navigationBarPhone.cartViewController getCart];
        }else
            [[SCThemeWorker sharedInstance].navigationBarPad.cartViewControllerPad getCart];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:responder.responseMessage delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
    }
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
}
//end editing

@end

@implementation OrderDetailCell
@synthesize dateLabel, dateValueLabel, totalLabel, totalValueLabel, codeLabel, codeValueLabel;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        float titleX = 15;
        float valueX = 140;
        float widthTitle = 100;
        float widthValue = 160;
        float heightLabel = 20;
        float heightCell = 5;
        
        //  Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            titleX = 205;
            valueX = 15;
            //Gin edit
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                titleX = SCREEN_WIDTH *2/3 - widthTitle -15;
                valueX = titleX - 20 - widthValue;
            }
            //end
        }
        
        //  End RTL
        dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(titleX, heightCell, widthTitle, heightLabel)];
        dateLabel.text = SCLocalizedString(@"Order Date");
        [dateLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR]];
        [dateLabel setTextColor:THEME_CONTENT_COLOR];
        [self addSubview:dateLabel];
        dateValueLabel = [[UILabel alloc]initWithFrame:CGRectMake(valueX, heightCell, widthValue, heightLabel)];
        [dateValueLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE]];
        [dateValueLabel setTextColor:THEME_CONTENT_COLOR];
        [self addSubview:dateValueLabel];
        heightCell += heightLabel;
        
        codeLabel = [[UILabel alloc]initWithFrame:CGRectMake(titleX, heightCell, widthTitle, heightLabel)];
        codeLabel.text = SCLocalizedString(@"Order #");
        [codeLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR]];
        [codeLabel setTextColor:THEME_CONTENT_COLOR];
        [self addSubview:codeLabel];
        
        codeValueLabel = [[UILabel alloc]initWithFrame:CGRectMake(valueX, heightCell, widthValue, heightLabel)];
        [codeValueLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE]];
        [codeValueLabel setTextColor:THEME_CONTENT_COLOR];
        [self addSubview:codeValueLabel];
        heightCell += heightLabel;
        
        totalLabel= [[UILabel alloc]initWithFrame:CGRectMake(titleX, heightCell, widthTitle, heightLabel)];
        totalLabel.text = SCLocalizedString(@"Order Total");
        [totalLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME_REGULAR] size:THEME_FONT_SIZE_REGULAR]];
        [totalLabel setTextColor:THEME_CONTENT_COLOR];
        [self addSubview:totalLabel];
        
        totalValueLabel = [[UILabel alloc]initWithFrame:CGRectMake(valueX, heightCell, widthValue, heightLabel)];
        [totalValueLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE]];
        [totalValueLabel setTextColor:THEME_CONTENT_COLOR];
       
        [self addSubview:totalValueLabel];
        //  Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            for (UIView *view in self.subviews) {
                if ([view isKindOfClass:[UILabel class]]) {
                    UILabel *label = (UILabel*)view;
                    [label setTextAlignment:NSTextAlignmentRight];
                }
            }
        }
        //  End RTL
    }
    return self;
}


@end
