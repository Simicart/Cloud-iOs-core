//
//  SCCartViewController.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/11/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SCCartViewController.h"
#import "SimiResponder.h"
#import "SCOrderViewController.h"
#import "SimiFormatter.h"
#import "SCOrderFeeCell.h"
#import "ActionSheetStringPicker.h"
#import "SCLoginViewController.h"
#import "OrderWebViewController.h"
#import "KeychainItemWrapper.h"
@interface SCCartViewController ()

@end

static NSString *actionSheetCustomer = @"actionSheetCustomer";

@implementation SCCartViewController
{
    NSString* orderWebURL;
}
@synthesize cartCells = _cartCells;
@synthesize tableViewCart, cart, isPresentingKeyboard, heightRow, cartPrices, currentQtyButton, currentItemIndex;
@synthesize qtyArray,btnCheckout, quotes;


#pragma mark Init

-(id) init{
    if(self = [super init]){
        
    }
    return self;
}

+ (instancetype)sharedInstance{
    static SCCartViewController *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SCCartViewController alloc] init];
    });
    return _sharedInstance;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoadBefore
{
    [super viewDidLoadBefore];
    [self setToSimiView];
    
    if (qtyButtonList == nil) {
        qtyButtonList = [[NSMutableDictionary alloc] init];
    }
    float btnCheckoutHeight = [SimiGlobalVar scaleValue:45];
    CGRect frame = self.view.frame;
    frame.size.height -= btnCheckoutHeight;
    [self.view setBackgroundColor:THEME_APP_BACKGROUND_COLOR];
    self.tableViewCart = [[SimiTableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    [self.tableViewCart setBackgroundColor:[UIColor clearColor]];
    self.tableViewCart.dataSource = self;
    self.tableViewCart.delegate = self;
    self.tableViewCart.delaysContentTouches = NO;
    self.tableViewCart.autoresizingMask =  UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableViewCart.contentInset = UIEdgeInsetsMake(0, 0, 25, 0);
    [self.view addSubview:self.tableViewCart];
    
    btnCheckout = [[UIButton alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - btnCheckoutHeight - 64, SCREEN_WIDTH, btnCheckoutHeight)];
    [btnCheckout setTitle:[SCLocalizedString(@"Checkout") uppercaseString] forState:UIControlStateNormal];
    [btnCheckout setTitleColor:THEME_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
    [btnCheckout addTarget:self action:@selector(checkout) forControlEvents:UIControlEventTouchUpInside];
    btnCheckout.layer.masksToBounds = NO;
    btnCheckout.layer.shadowColor = THEME_CONTENT_COLOR.CGColor;
    btnCheckout.layer.shadowOpacity = 0.2;
    btnCheckout.layer.shadowRadius = 1;
    btnCheckout.layer.shadowOffset = CGSizeMake(-0, -1);
    btnCheckout.backgroundColor = THEME_BUTTON_BACKGROUND_COLOR;
    
    [self.view addSubview:btnCheckout];
    self.cart = [[SimiGlobalVar sharedInstance] cart];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCart) name:DidPlaceOrderAfter object:nil];
    if(!self.cartQuote)
        self.cartQuote = [SimiCartModel new];
}

- (void)viewWillAppearBefore:(BOOL)animated{
    if ([SimiGlobalVar sharedInstance].cart.count < 1) {
        [btnCheckout setHidden:YES];
    }
    if ([SimiGlobalVar sharedInstance].needGetCart) {
        [SimiGlobalVar sharedInstance].needGetCart = NO;
        [self getCart];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"isLogin"]) {
        SimiCustomerModel *customer = [[SimiGlobalVar sharedInstance] customer];
        if([customer valueForKey:@"_id"] != nil && ![[customer valueForKey:@"_id"] isEqualToString:@""]){
            [self getQuotesWithCustomerId:[customer valueForKey:@"_id"]];
        }else{
            SimiCartModel *quote = [[SimiCartModel alloc]init];
            [self setDataForCart:quote];
        }
    }
}

#pragma mark Get Quote List
- (void)getQuotesWithCustomerId:(NSString *) customerId{
    if (self.quotes == nil) {
        self.quotes = [[SimiCartModelCollection alloc] init];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetQuotes:) name:DidGetQuotes object:self.quotes];
    [self.quotes getQuotesWithCustomerId:customerId];
}

#pragma mark Get Cart Data
- (void)getCart{
    if (![SimiGlobalVar sharedInstance].isGettingCart && [SimiGlobalVar sharedInstance].quoteId != nil) {
        [SimiGlobalVar sharedInstance].isGettingCart = YES;
        tableViewCart.hidden = YES;
        btnCheckout.hidden = YES;
        if (self.cartQuote == nil) {
            self.cartQuote = [[SimiCartModel alloc] init];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCart:) name:DidGetCart object:nil];
        [self startLoadingData];
        [self.cartQuote getCartItemsWithParams:nil cartId:[SimiGlobalVar sharedInstance].quoteId];
    }
}

#pragma mark Notification Action

- (void)didGetQuotes:(NSNotification*)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        if([self.quotes count] > 0){
            SimiCartModel *quote = quotes[0];
            if([SimiGlobalVar sharedInstance].quoteId != nil && ![[SimiGlobalVar sharedInstance].quoteId isEqualToString:@""] && ![[SimiGlobalVar sharedInstance].quoteId isEqualToString:[quote valueForKey:@"_id"]]){
                [self mergeQuote:[SimiGlobalVar sharedInstance].quoteId withQuote:[quote valueForKey:@"_id"]];
                [[SimiGlobalVar sharedInstance] setQuoteId:[quote valueForKey:@"_id"]];
            }else{
                [[SimiGlobalVar sharedInstance] setQuoteId:[quote valueForKey:@"_id"]];
                [self setDataForCart:quote];
            }
        }
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(responder.responseMessage) delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
    }
    [self removeObserverForNotification:noti];
}

- (void)didMergeQuote:(NSNotification*)noti
{
    tableViewCart.hidden = NO;
    [SimiGlobalVar sharedInstance].isGettingCart = NO;
    [self changeCartData:noti];
}

- (void)didGetCart:(NSNotification*)noti
{
    tableViewCart.hidden = NO;
    [SimiGlobalVar sharedInstance].isGettingCart = NO;
    [self removeObserverForNotification:noti];
    [self changeCartData:noti];
}

- (void)didEditItemQty:(NSNotification*)noti
{
    [self changeCartData:noti];
    [self removeObserverForNotification:noti];
}


- (void)changeCartData:(NSNotification *)noti
{
    [self stopLoadingData];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        [self setDataForCart:self.cartQuote];
        if ([responder responseMessage] != nil && ![[responder responseMessage] isEqualToString:@""] && [[responder responseMessage] rangeOfString:@"NOT CHECKOUT"].location != NSNotFound) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[responder.responseMessage stringByReplacingOccurrencesOfString:@"NOT CHECKOUT" withString:@""] delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
            [alertView show];
            [self.btnCheckout setEnabled:NO];
        }
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(responder.responseMessage) delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
    }
}

- (void)setDataForCart:(SimiCartModel *)cartQuote{
    self.cart = [[SimiGlobalVar sharedInstance] cart];
    [self.cart setData:[cartQuote valueForKey:@"items"]];
    self.cartPrices = [[NSMutableDictionary alloc]init];
    if([cartQuote valueForKey:@"subtotal"]!= [NSNull null] && [[cartQuote valueForKey:@"subtotal"] integerValue] >= 0)
        [self.cartPrices setValue:[cartQuote valueForKey:@"subtotal"] forKey:@"subtotal"];
    if([self.cartQuote valueForKey:@"grand_total"]!= [NSNull null] && [[cartQuote valueForKey:@"grand_total"] integerValue]>=0)
        [self.cartPrices setValue:[cartQuote valueForKey:@"grand_total"] forKey:@"grand_total"];
    if([self.cartQuote valueForKey:@"shipping_amount"]!= [NSNull null] && [[cartQuote valueForKey:@"shipping_amount"] integerValue] > 0)
        [self.cartPrices setValue:[cartQuote valueForKey:@"shipping_amount"] forKey:@"shipping_amount"];
    if([self.cartQuote valueForKey:@"discount_amount"]!= [NSNull null] && [[cartQuote valueForKey:@"discount_amount"] integerValue] > 0)
        [self.cartPrices setValue:[cartQuote valueForKey:@"discount_amount"] forKey:@"discount_amount"];
    if([self.cartQuote valueForKey:@"tax_amount"]!= [NSNull null] && [[cartQuote valueForKey:@"tax_amount"] integerValue] > 0)
        [self.cartPrices setValue:[cartQuote valueForKey:@"tax_amount"] forKey:@"tax_amount"];
    self.tableViewCart.hidden = NO;
    if(![self.cart count])
        [btnCheckout setHidden:YES];
    else
        [btnCheckout setHidden:NO];
    
    [self reloadData];
    [self.btnCheckout setEnabled:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:DidChangeCart object:self.cart];
}

-(void)mergeQuote:(NSString *)sourceQuoteId withQuote:(NSString *)desQuoteId{
    [SimiGlobalVar sharedInstance].isGettingCart = YES;
    tableViewCart.hidden = YES;
    btnCheckout.hidden = YES;
    if (self.cartQuote == nil) {
        self.cartQuote = [[SimiCartModel alloc] init];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didMergeQuote:) name:DidMergeQuote object:self.cartQuote];
    [self startLoadingData];
    [self.cartQuote mergeQuote:sourceQuoteId withQuote:desQuoteId];
}

#pragma mark Cart Edit Action

- (void)clearCart{
    [qtyButtonList removeAllObjects];
    [self.cart removeAllObjects];
    [SimiGlobalVar sharedInstance].cart = nil;
    [self setDataForCart:[SimiCartModel new]];
    [[NSNotificationCenter defaultCenter] postNotificationName:DidChangeCart object:cart];
}
//  Liam Update Select Address on Cart 150622
#pragma mark Check out
- (void)checkout{
    if(orderWebURL){
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        NSString *bundleIdentifier = [NSString stringWithFormat:@"%@", [info objectForKey:@"CFBundleIdentifier"]];
        if([[SimiGlobalVar sharedInstance]isLogin]){
            KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:bundleIdentifier accessGroup:nil];
            NSString *email = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
            NSString *password = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
            
            orderWebURL = [orderWebURL stringByReplacingOccurrencesOfString:@"email_value" withString:email];
            orderWebURL = [orderWebURL stringByReplacingOccurrencesOfString:@"password_value" withString:password];
        }
        OrderWebViewController* orderWebVC = [[OrderWebViewController alloc] init];
        orderWebVC.stringURL = orderWebURL;
        [self.navigationController pushViewController:orderWebVC animated:YES];
    }else{
        if([[SimiGlobalVar sharedInstance]isLogin]) {
            
                SCAddressViewController *nextController = [[SCAddressViewController alloc]init];
                nextController.isSelectAddressFromCartForCheckOut = YES;
                [nextController setDelegate:self];
                [nextController setIsGetOrderAddress:YES];
                [self.navigationController pushViewController:nextController animated:NO];
                return;
        }else
            {
                [self askCustomerRole];
            }
    }
}
#pragma mark Address Delegate
- (void)selectAddress:(SimiAddressModel *)address
{
    _billingAddress = address;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCart) name:DidPlaceOrderAfter object:nil];
    SCOrderViewController *orderController = [[SCOrderViewController alloc] init];
    [orderController setCart:self.cart];
    [orderController setCartPrices:[self.cartPrices mutableCopy]];
    [orderController setBillingAddress:_billingAddress];
    [orderController setShippingAddress:_billingAddress];
    [self.navigationController pushViewController:orderController animated:NO];
}
#pragma mark Login When Check Out
- (void)askCustomerRole{
    UIActionSheet *actionSheet;
    SimiStoreModel *store = [[SimiGlobalVar sharedInstance] store];
    isEnableGuestCheckout = YES;
//    isEnableGuestCheckout = [[[store valueForKey:@"checkout_config"] valueForKey:@"enable_guest_checkout"] boolValue];
    if (isEnableGuestCheckout) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:SCLocalizedString(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:SCLocalizedString(@"Checkout as existing customer"), SCLocalizedString(@"Checkout as new customer"), SCLocalizedString(@"Checkout as guest"), nil];
    }else{
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:SCLocalizedString(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:SCLocalizedString(@"Checkout as existing customer"), SCLocalizedString(@"Checkout as new customer"), nil];
    }
    actionSheet.simiObjectIdentifier = actionSheetCustomer;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UITabBarController *currentVC = (UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController];
        [actionSheet showFromTabBar:currentVC.tabBar];
    }else{
        [actionSheet showInView:self.view];
    }
}

- (void)didLoginOnCheckout:(NSNotification*)noti
{
    [[NSNotificationCenter defaultCenter]removeObserverForNotification:noti];
    SCAddressViewController *nextController = [[SCAddressViewController alloc]init];
    nextController.isSelectAddressFromCartForCheckOut = YES;
    [nextController setDelegate:self];
    [nextController setIsGetOrderAddress:YES];
    [self.navigationController pushViewController:nextController animated:NO];
}


#pragma mark Action Sheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([(NSString*)actionSheet.simiObjectIdentifier isEqualToString:actionSheetCustomer]) {
        if (isEnableGuestCheckout) {
                switch (buttonIndex) {
                    case 0: //Checkout as existing customer
                    {
                        self.isNewCustomer = NO;
                        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didLoginOnCheckout:) name:@"PushLoginInCheckout" object:nil];
                        SCLoginViewController *nextController = [[SCLoginViewController alloc] init];
                        nextController.isLoginInCheckout = YES;
                        if (SIMI_SYSTEM_IOS >= 8) {
                            [self presentViewController:nextController animated:YES completion: nil];
                        }else
                            [self.navigationController pushViewController:nextController animated:NO];
                    }
                        
                        break;
                    case 1: //Checkout as new customer
                    {
                        self.isNewCustomer = YES;
                        SCNewAddressViewController *nextController = [[SCNewAddressViewController alloc]init];
                        nextController.isNewCustomer = YES;
                        nextController.delegate = self;
                        [self.navigationController pushViewController:nextController animated:YES];
                    }
                        break;
                    case 2: //Checkout as guest
                    {
                        self.isNewCustomer = NO;
                        SCNewAddressViewController *nextController = [[SCNewAddressViewController alloc]init];
                        nextController.delegate = self;
                        [self.navigationController pushViewController:nextController animated:YES];
                    }
                        break;
                    default: //Cancel
                        
                        break;
                }
        }else
        {
                switch (buttonIndex) {
                    case 0: //Checkout as existing customer
                    {
                        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didLoginOnCheckout:) name:PushLoginInCheckout object:nil];
                        self.isNewCustomer = NO;
                        SCLoginViewController *nextController = [[SCLoginViewController alloc] init];
                        nextController.isLoginInCheckout = YES;
                        [self presentViewController:nextController animated:YES completion: nil];
                    }
                        
                        break;
                    case 1: //Checkout as new customer
                    {
                        self.isNewCustomer = YES;
                        SCNewAddressViewController *nextController = [[SCNewAddressViewController alloc]init];
                        nextController.isNewCustomer = YES;
                        nextController.delegate = self;
                        [self.navigationController pushViewController:nextController animated:YES];
                    }
                        break;
                    default: //Cancel
                        
                        break;
                }
            
        }
    }
}



#pragma mark New Address Delegate
//  End 150622
- (void)didSaveAddress:(SimiAddressModel *)address
{
    _billingAddress = address;
    SCOrderViewController *orderController = [[SCOrderViewController alloc] init];
    [orderController setCart:self.cart];
    [orderController setCartPrices:[self.cartPrices mutableCopy]];
    [orderController setBillingAddress:_billingAddress];
    [orderController setShippingAddress:_billingAddress];
    if (self.isNewCustomer) {
        orderController.addressNewCustomerModel = address;
        orderController.isNewCustomer = self.isNewCustomer;
    }else{
        orderController.checkoutGuest = YES;
    }
    [self.navigationController pushViewController:orderController animated:YES];
}

#pragma mark Qty Button Delegates
-(void) qtyButtonClicked:(UIButton *)button cellIndexPath:(NSIndexPath *)indexPath{
    self.currentItemIndex = indexPath.row;
    currentQtyButton = button;
    SimiCartModel * product = [(SCCartCell *)[self.tableViewCart cellForRowAtIndexPath:indexPath] item];
    qtyArray = [[NSMutableArray alloc] init];
    //set max qty is 10 by default
    int maxQtyAllowed = 999;
    if ([product objectForKey:@"product_max_qty_alow"])
        maxQtyAllowed = [[product objectForKey:@"product_max_qty_alow"] intValue];
    for (int i = 1; i <= maxQtyAllowed; i++) {
        [qtyArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        currentQtyButton = button;
        int qty = [[button titleForState:UIControlStateNormal] intValue];
        if(qty > [[qtyArray objectAtIndex:qtyArray.count - 1] intValue]) qty = [[qtyArray objectAtIndex:qtyArray.count - 1] intValue];
        ActionSheetStringPicker* qtyPicker = [[ActionSheetStringPicker alloc]initWithTitle:@"" rows:qtyArray initialSelection:qty - 1 target:self successAction:@selector(didSelectValue:element:) cancelAction:@selector(cancelActionSheet:) origin:self.view];
        [qtyPicker showActionSheetPicker];
    }
}

- (void)didSelectValue:(NSNumber *)selectedIndex element:(id)element
{
    if(![[currentQtyButton titleForState:UIControlStateNormal] isEqual: [qtyArray objectAtIndex: [selectedIndex intValue]]])
    {
        NSString* qty = [qtyArray objectAtIndex: [selectedIndex intValue]];
        [currentQtyButton setTitle:qty forState:UIControlStateNormal];
        NSMutableArray *qtyDictArr = [[NSMutableArray alloc] init];
        qtyDictArr = [self.cart objectAtIndex:self.currentItemIndex];
        //Axe added
        [qtyDictArr setValue:qty forKey:@"qty"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEditItemQty:) name:DidEditQty object:self.cartQuote];
        [self.cartQuote editQtyInCartWithData:qtyDictArr cartId:[SimiGlobalVar sharedInstance].quoteId];
        [self startLoadingData];
    }
}
-(void) cancelActionSheet:(id)sender{
    NSLog(@"cancelActionSheet");
}

#pragma mark Cart Cell Delegates
- (void)removeProductFromCart:(NSString *)cartItemId{
    for (SimiCartModel *obj in self.cart) {
        if ([[obj valueForKey:@"_id"] isEqualToString:cartItemId]) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEditItemQty:) name:DidEditQty object:self.cartQuote];
            [self startLoadingData];
            [self.cartQuote deleteCartItemWithCartId:[SimiGlobalVar sharedInstance].quoteId itemId:cartItemId];
            break;
        }
    }
}

-(void) productImageClicked:(NSIndexPath* )indexPath{
    
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    SimiSection *section = [self.cartCells objectAtIndex:[indexPath section]];
    if ([section.identifier isEqualToString:CART_PRODUCTS]) {
        NSString *productID = [[self.cart objectAtIndex:indexPath.row] valueForKey:@"product_id"];
        SCProductViewController *nextController = [[SCProductViewController alloc]init];
        [nextController setProductId:productID];
        [self.navigationController pushViewController:nextController animated:YES];
    }
}

#pragma mark - Init Cart Cells
- (SimiTable *)cartCells
{
    if (_cartCells) {
        return _cartCells;
    }
    _cartCells = [SimiTable new];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitCartCell-Before" object:_cartCells];
    
    //  Liam Update 150611
    if ([self.cart count]) {
        SimiSection *products = [_cartCells addSectionWithIdentifier:CART_PRODUCTS];
        for (NSInteger i = 0; i < [self.cart count]; i++) {
            // May start edited 20151022
            SimiRow *row = nil;
            SimiCartModel *cartModel = [self.cart objectAtIndex:i];
            NSMutableArray *itemOptions = [cartModel valueForKey:@"options"];
            if (SIMI_SYSTEM_IOS >=8) {
               	row = [[SimiRow alloc]initWithIdentifier:[NSString stringWithFormat:@"%@_%@",CART_PRODUCTS, [[self.cart objectAtIndex:i] valueForKey:@"_id"]] height:[SimiGlobalVar scaleValue:107]];
            }else{
                if (itemOptions.count >= 2) {
                    row = [[SimiRow alloc]initWithIdentifier:[NSString stringWithFormat:@"%@_%@",CART_PRODUCTS, [[self.cart objectAtIndex:i] valueForKey:@"_id"]] height:[SimiGlobalVar scaleValue:175]];
                }else if (itemOptions.count >= 1)
                {
                    row = [[SimiRow alloc]initWithIdentifier:[NSString stringWithFormat:@"%@_%@",CART_PRODUCTS, [[self.cart objectAtIndex:i] valueForKey:@"_id"]] height:[SimiGlobalVar scaleValue:150]];
                }else
                    row = [[SimiRow alloc]initWithIdentifier:[NSString stringWithFormat:@"%@_%@",CART_PRODUCTS, [[self.cart objectAtIndex:i] valueForKey:@"_id"]] height:[SimiGlobalVar scaleValue:125]];
            }
            // May end 20151022
            
            [products addObject:row];
        }
        SimiSection *sectionPrice = [_cartCells addSectionWithIdentifier:CART_TOTALS];
        if (![SimiGlobalVar sharedInstance].isReverseLanguage) {
            [sectionPrice addRowWithIdentifier:CART_TOTALS height:(27 * self.cartPrices.count)];
        }else
            [sectionPrice addRowWithIdentifier:CART_TOTALS height:(45 * self.cartPrices.count)];
    } else {
        SimiSection *sectionEmpty = [_cartCells addSectionWithIdentifier:CART_EMPTY];
        [sectionEmpty addRowWithIdentifier:CART_EMPTY height:125];
    }
    //  End Update 150611
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitCartCell-After" object:_cartCells];
    return _cartCells;
}


- (void)reloadData
{
    _cartCells = nil;
    [self.tableViewCart reloadData];
}

#pragma mark Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.cartCells count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self.cartCells objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[[self.cartCells objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]] height];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self.cartCells objectAtIndex:section] headerTitle];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [[self.cartCells objectAtIndex:section] footerTitle];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cartCells objectAtIndex:[indexPath section]];
    SimiRow *row = [section objectAtIndex:[indexPath row]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedCartCell-Before" object:self userInfo:@{@"tableView": tableView, @"indexPath": indexPath, @"section": section, @"row": row}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return (UITableViewCell *)self.simiObjectIdentifier;
    }
    UITableViewCell *aCell;
    if ([section.identifier isEqualToString:CART_PRODUCTS]) {
        SCCartCell *cell = [tableView dequeueReusableCellWithIdentifier:row.identifier];
        SimiCartModel *item = [self.cart objectAtIndex:indexPath.row];
        if (cell == nil) {
            cell = [[SCCartCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
            if ([item valueForKeyPath:@"name"] == nil) {
                NSString *cartItemName = [item valueForKeyPath:@"name"];
                for (NSDictionary *option in [item valueForKeyPath:@"options"]) {
                    cartItemName = [NSString stringWithFormat:@"%@, %@", cartItemName, [option valueForKeyPath:@"option_value"]];
                }
                [item setValue:cartItemName forKeyPath:@"cart_item_name"];
            }
            cell.indexPath = indexPath;
            [cell setItem:item];
            [cell setName:[item valueForKeyPath:@"name"]];
            [cell setPrice:[item valueForKey:@"price"]];
            [cell setQty:[NSString stringWithFormat:@"%@", [item valueForKey:@"qty"]]];
            NSString *cartItemID = [item valueForKey:@"_id"];
            [cell setCartItemId:cartItemID];
            cell.delegate = self;
            if ([item valueForKey:@"images"] && [[item valueForKey:@"images"] isKindOfClass:[NSArray class]]) {
                NSMutableArray *images = [[NSMutableArray alloc]initWithArray:[item valueForKey:@"images"]];
                if (images.count > 0) {
                    NSDictionary *image = [images objectAtIndex:0];
                     [cell setImagePath:[image valueForKey:@"url"]];
                }
            }
            if(qtyButtonList == nil){
                qtyButtonList = [[NSMutableDictionary alloc] init];
            }
            [qtyButtonList setValue:cell.qtyButton forKey:cartItemID];
            [cell setInterfaceCell];
        }
        [cell setPrice:[item valueForKey:@"price"]];
        [cell setQty:[NSString stringWithFormat:@"%@", [item valueForKey:@"qty"]]];
        //Axe fix to match cell height
        if (cell.heightCell > [SimiGlobalVar scaleValue:107]) {
            ((SimiRow*)[[_cartCells objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]).height = cell.heightCell;
        }
        aCell = cell;
    }else if([section.identifier isEqualToString:CART_TOTALS])
    {
        if ([row.identifier isEqualToString:CART_TOTALS]) {
            SCOrderFeeCell *cell = [[SCOrderFeeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
            if (self.cart.count <= 0) {
                return cell;
            }
            [cell setData:self.cartPrices];
            cell.userInteractionEnabled = NO;
            aCell = cell;
        }
    }else if ([section.identifier isEqualToString:CART_EMPTY])
    {
        if ([row.identifier isEqualToString:CART_EMPTY]) {
            static NSString *EmptyCartCellIdentifier = @"SCEmptyCartCellIdentifier";
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:EmptyCartCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel *emptyLabel = [[UILabel alloc]init];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                //Axe Edit 150805 width
                [emptyLabel setFrame:CGRectMake(50, 50, SCREEN_WIDTH - 100, cell.frame.size.height)];
                //End
            }else
            {
                [emptyLabel setFrame:CGRectMake(40, 50, 600, cell.frame.size.height)];
            }
            emptyLabel.text = SCLocalizedString(@"You have no items in your shopping cart.");
            [emptyLabel setLineBreakMode:NSLineBreakByTruncatingTail];
            [emptyLabel setTextAlignment:NSTextAlignmentCenter];
            [emptyLabel setNumberOfLines:2];
            [cell addSubview:emptyLabel];
            aCell = cell;
        }
    }
    if (aCell == nil) {
        aCell = [UITableViewCell new];
    }
    [aCell setBackgroundColor:[UIColor clearColor]];
    self.simiObjectIdentifier = aCell;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedCartCell-After" object:self userInfo:@{@"tableView": tableView, @"indexPath": indexPath, @"section": section, @"row": row, @"cell": aCell}];
    return aCell;
}


// To make full width tableView Separating Lines
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
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


#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[NSNotificationCenter defaultCenter] postNotificationName:DidSelectCartCellAtIndexPath object:self userInfo:@{@"tableView": tableView, @"indexPath": indexPath, @"cart": self.cart}];
    }
#pragma mark Dealloc
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    @try {
        [[SimiGlobalVar sharedInstance] removeObserver:self forKeyPath:@"isLogin" context:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    @finally {
        
    }
}

@end
