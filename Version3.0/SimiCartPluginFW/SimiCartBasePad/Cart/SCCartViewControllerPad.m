//
//  ZThemeCartViewControllerPad.m
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 5/28/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCCartViewControllerPad.h"

#import "SimiProductModel.h"
#import "SimiResponder.h"
#import "SCOrderFeeCell.h"
#import "UIImage+SimiCustom.h"
#import "SCLoginViewController.h"
#import "SCOrderViewControllerPad.h"
#import "SCProductViewControllerPad.h"
#import "SCThemeWorker.h"

@interface SCCartViewControllerPad ()

@end

@implementation SCCartViewControllerPad
{
    UIView * verticalBorder;
}

@synthesize cartCells = _cartCells, emptyLabel, qtyArray, currentQtyButton, btnCheckout;

+ (instancetype)sharedInstance{
    static SCCartViewControllerPad * _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SCCartViewControllerPad alloc] init];
    });
    return _sharedInstance;
}

- (void)viewDidLoadBefore
{
    [self configureLogo];
    [self configureNavigationBarOnViewDidLoad];
    
    if (self.tableviewProduct ==nil) {
        self.tableviewProduct = [UITableView new];
        self.tableviewProduct.delegate = self;
        self.tableviewProduct.dataSource = self;
        self.tableviewProduct.frame = CGRectMake(0, 0, 600, SCREEN_HEIGHT - 64);
        [self.tableviewProduct setContentOffset:CGPointMake(0, 0)];
        [self.tableviewProduct setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:self.tableviewProduct];
    }
    
    self.tableViewCart = [[SimiTableView alloc] initWithFrame:CGRectMake(600, 0, 420, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableViewCart.dataSource = self;
    self.tableViewCart.delegate = self;
    self.tableViewCart.delaysContentTouches = NO;
    self.tableViewCart.allowsSelection = NO;
    [self.tableViewCart setScrollEnabled:NO];
    [self.tableViewCart setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.tableViewCart];
    
    if (verticalBorder ==nil) {
        verticalBorder = [[UIView alloc]initWithFrame:CGRectMake(599, 0, 1, 768)];
        [verticalBorder setBackgroundColor:THEME_LINE_COLOR];
        [verticalBorder setHidden:YES];
        [self.view addSubview:verticalBorder];
    }
    
    btnCheckout = [[UIButton alloc]initWithFrame:CGRectMake(20, 30, 380, 50)];
    [btnCheckout setTitle:[SCLocalizedString(@"Checkout") uppercaseString] forState:UIControlStateNormal];
    [btnCheckout addTarget:self action:@selector(checkout) forControlEvents:UIControlEventTouchUpInside];
    btnCheckout.backgroundColor = THEME_BUTTON_BACKGROUND_COLOR;
    btnCheckout.layer.masksToBounds = NO;
    btnCheckout.layer.shadowColor = [[SimiGlobalVar sharedInstance] darkerColorForColor:THEME_BUTTON_BACKGROUND_COLOR].CGColor;
    btnCheckout.layer.shadowOpacity = 0.7;
    btnCheckout.layer.shadowRadius = -1;
    btnCheckout.layer.shadowOffset = CGSizeMake(-0, 5);
    
    self.navigationController.navigationBar.tintColor = THEME_APP_BACKGROUND_COLOR;
    if (qtyButtonList == nil) {
        qtyButtonList = [[NSMutableDictionary alloc] init];
    }
    self.cart = [[SimiGlobalVar sharedInstance] cart];
//    if ([SimiGlobalVar sharedInstance].isGettingCart) {
//        [self startLoadingData];
//    }
    if(self.cartQuote)
        self.cartQuote = [SimiCartModel new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin:) name:PushLoginInCheckout object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCart) name:DidPlaceOrderAfter object:nil];
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    [super viewWillAppearBefore:YES];
    [self updateSubViews];
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

- (void)reloadData
{
    _cartCells = nil;
    _productCells = nil;
    [self.tableViewCart reloadData];
    [self.tableviewProduct reloadData];
    [self updateSubViews];
}

- (SimiTable *)cartCells
{
    if (_cartCells) {
        return _cartCells;
    }
    _cartCells = [SimiTable new];
    [[NSNotificationCenter defaultCenter] postNotificationName:InitCartCellBefore object:_cartCells];
    if ([self.cart count]) {
        SimiSection *sectionPrice = [_cartCells addSectionWithIdentifier:CART_TOTALS];
        if(![[SimiGlobalVar sharedInstance] isReverseLanguage]){
            [sectionPrice addRowWithIdentifier:CART_TOTALS_ROW height:(30 + 27 * self.cartPrices.count)];
        }else{
            [sectionPrice addRowWithIdentifier:CART_TOTALS_ROW height:(30 + 50 * self.cartPrices.count)];
        }
        [sectionPrice addRowWithIdentifier:CART_CHECKOUT_ROW height:SCREEN_HEIGHT];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:InitCartCellAfter object:_cartCells];
    return _cartCells;
}

- (SimiTable *)productCells
{
    if (_productCells) {
        return _productCells;
    }
    _productCells = [SimiTable new];
    [[NSNotificationCenter defaultCenter] postNotificationName:InitProductCellBefore object:_productCells];
    
    if ([self.cart count]) {
        SimiSection *products = [_productCells addSectionWithIdentifier:CART_PRODUCTS];
        for (NSInteger i = 0; i < [self.cart count]; i++) {
            SimiRow *row = [[SimiRow alloc]initWithIdentifier:[NSString stringWithFormat:@"%@_%@",CART_PRODUCTS, [[self.cart objectAtIndex:i] valueForKey:@"_id"]] height:210];
            [products addObject:row];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:InitProductCellAfter object:_cartCells];
    return _cartCells;
}

#pragma mark Table View Data Source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableviewProduct)
        return [[[self.productCells objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]] height];
    return [[[self.cartCells objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]] height];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableviewProduct)
        return [[self.productCells objectAtIndex:section] count];
    return [[self.cartCells objectAtIndex:section] count];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableviewProduct)
        return [self.productCells count];
    return [self.cartCells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tableviewProduct) {
        SimiSection *section = [self.productCells objectAtIndex:[indexPath section]];
        SimiRow *row = [section objectAtIndex:[indexPath row]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:InitializedProductCartCellBefore object:self userInfo:@{@"tableView": tableView, @"indexPath": indexPath, @"section": section, @"row": row}];
        if (self.isDiscontinue) {
            self.isDiscontinue = NO;
            return (UITableViewCell *)self.simiObjectIdentifier;
        }
        UITableViewCell *aCell;
        if ([section.identifier isEqualToString:CART_PRODUCTS]) {
            SCCartCellPad *cell = [tableView dequeueReusableCellWithIdentifier:row.identifier];
            SimiCartModel *item = [self.cart objectAtIndex:indexPath.row];
            if (cell == nil) {
                cell = [[SCCartCellPad alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
                if ([item valueForKeyPath:@"name"] == nil) {
                    NSString *cartItemName = [item valueForKeyPath:@"name"];
                    for (NSDictionary *option in [item valueForKeyPath:@"options"]) {
                        cartItemName = [NSString stringWithFormat:@"%@, %@", cartItemName, [option valueForKeyPath:@"option_value"]];
                    }
                    [item setValue:cartItemName forKeyPath:@"name"];
                }
                cell.indexPath = indexPath;
                [cell setItem:item];
                [cell setName:[item valueForKeyPath:@"name"]];
                [cell setPrice:[item valueForKey:@"price"]];
                [cell setQty:[NSString stringWithFormat:@"%@", [item valueForKey:@"qty"]]];
                NSString *cartItemID = [item valueForKey:@"_id"];
                [cell setCartItemId:cartItemID];
                cell.delegate = self;
                [cell setImagePath:[item valueForKey:@"image"]];
                if(qtyButtonList == nil){
                    qtyButtonList = [[NSMutableDictionary alloc] init];
                }
                [qtyButtonList setValue:cell.qtyButton forKey:cartItemID];
                [cell setInterfaceCell];
            }
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell setPrice:[item valueForKey:@"price"]];
            [cell setQty:[NSString stringWithFormat:@"%@", [item valueForKey:@"qty"]]];
            aCell = cell;
        }
        
        if (aCell == nil) {
            aCell = [UITableViewCell new];
        }
        
        self.simiObjectIdentifier = aCell;
        [[NSNotificationCenter defaultCenter] postNotificationName:InitializedProductCartCellAfter object:self userInfo:@{@"tableView": tableView, @"indexPath": indexPath, @"section": section, @"row": row, @"cell": aCell}];
        return aCell;
    }
    else {
        SimiSection *section = [self.cartCells objectAtIndex:[indexPath section]];
        SimiRow *row = [section objectAtIndex:[indexPath row]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:InitializedCartCellBefore object:self userInfo:@{@"tableView": tableView, @"indexPath": indexPath, @"section": section, @"row": row}];
        if (self.isDiscontinue) {
            self.isDiscontinue = NO;
            return (UITableViewCell *)self.simiObjectIdentifier;
        }
        UITableViewCell *aCell;
        if([section.identifier isEqualToString:CART_TOTALS])
        {
            if ([row.identifier isEqualToString:CART_TOTALS_ROW]) {
                SCOrderFeeCell *  cell = [[SCOrderFeeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
                [cell setFrame:CGRectMake(0, 0, self.tableViewCart.frame.size.width, row.height)];
                if (self.cart.count <= 0) {
                    return cell;
                }
                [cell setData:self.cartPrices];
                cell.userInteractionEnabled = NO;
                [cell setBackgroundColor:[UIColor clearColor]];
                aCell = cell;
            }
            else if ([row.identifier isEqualToString:CART_CHECKOUT_ROW]) {
                UITableViewCell * cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
                [cell addSubview:btnCheckout];
                [cell setBackgroundColor:[UIColor clearColor]];
                aCell = cell;
            }
        }
        if (aCell == nil) {
            aCell = [UITableViewCell new];
        }
        
        self.simiObjectIdentifier = aCell;
        [[NSNotificationCenter defaultCenter] postNotificationName:InitializedCartCellAfter object:self userInfo:@{@"tableView": tableView, @"indexPath": indexPath, @"section": section, @"row": row, @"cell": aCell}];
        return aCell;
    }
}

#pragma mark Empty Label
- (void)updateSubViews
{
    if (emptyLabel == nil) {
        emptyLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 300, 824, 80)];
        emptyLabel.text = SCLocalizedString(@"You have no items in your shopping cart.");
        emptyLabel.textColor = THEME_CONTENT_COLOR;
        emptyLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE+3];
        [emptyLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [emptyLabel setTextAlignment:NSTextAlignmentCenter];
        [emptyLabel setNumberOfLines:2];
        [self.view addSubview:emptyLabel];
    }
    
    if (self.cart.count ==0) {
        [emptyLabel setHidden:NO];
        [verticalBorder setHidden:YES];
        [self.tableViewCart setHidden:YES];
        [self.tableviewProduct setHidden:YES];
    }
    else {
        [emptyLabel setHidden:YES];
        [verticalBorder setHidden:NO];
        [self.tableviewProduct setHidden:NO];
        [self.tableViewCart setHidden:NO];
    }
}

#pragma mark SCCartCell Delegate
-(void) productImageClicked:(NSIndexPath* )indexPath{
    SimiSection *section = [self.productCells objectAtIndex:[indexPath section]];
    if ([section.identifier isEqualToString:CART_PRODUCTS]) {
        NSString *productID = [[self.cart objectAtIndex:indexPath.row] valueForKey:@"_id"];
        SCProductViewControllerPad *nextController = [[SCProductViewControllerPad alloc]init];
        [nextController setProductId:productID];
        [self.navigationController pushViewController:nextController animated:YES];
    }
}

-(void) qtyButtonClicked:(UIButton *)button cellIndexPath:(NSIndexPath *)indexPath{
    self.currentItemIndex = indexPath.row;
    currentQtyButton = button;
    SimiCartModel * product = [(SCCartCell *)[self.tableviewProduct cellForRowAtIndexPath:indexPath] item];
    qtyArray = [[NSMutableArray alloc] init];
    //set max qty is 10 by default
    int maxQtyAllowed = 999;
    if ([product objectForKey:@"product_max_qty_alow"])
        maxQtyAllowed = [[product objectForKey:@"product_max_qty_alow"] intValue];
    for (int i = 1; i <= maxQtyAllowed; i++) {
        [qtyArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
    currentQtyButton = button;
    int qty = [[button titleForState:UIControlStateNormal] intValue];
    if(qty > [[self.qtyArray objectAtIndex:self.qtyArray.count - 1] intValue]) qty = [[self.qtyArray objectAtIndex:self.qtyArray.count - 1] intValue];
    ActionSheetStringPicker* qtyPicker = [[ActionSheetStringPicker alloc]initWithTitle:@"" rows:self.qtyArray initialSelection:qty - 1 target:self successAction:@selector(didSelectValue:element:) cancelAction:@selector(cancelActionSheet:) origin:currentQtyButton];
    qtyPicker.pickerView.backgroundColor = [UIColor redColor];
    [qtyPicker showActionSheetPicker];
}


#pragma mark Qty Button Delegates

- (void)didSelectValue:(NSNumber *)selectedIndex element:(id)element
{
    if(![[currentQtyButton titleForState:UIControlStateNormal] isEqual: [self.qtyArray objectAtIndex: [selectedIndex intValue]]])
    {
        [currentQtyButton setTitle:[self.qtyArray objectAtIndex: [selectedIndex intValue]] forState:UIControlStateNormal];
        NSMutableArray *qtyDictArr = [[NSMutableArray alloc] init];
        qtyDictArr = [self.cart objectAtIndex:self.currentItemIndex];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEditItemQty:) name:DidEditQty object:self.cartQuote];
        [self.cartQuote editQtyInCartWithData:qtyDictArr cartId:[SimiGlobalVar sharedInstance].quoteId];
        [self startLoadingData];
    }
}


-(void) cancelActionSheet:(id)sender{
    NSLog(@"cancelActionSheet");
}


#pragma mark Cart Actions
- (void)checkout {
    if ([[SimiGlobalVar sharedInstance]isLogin]) {
        SCAddressViewController *addressViewController = [SCAddressViewController new];
        addressViewController.delegate = self;
        UINavigationController *navi;
        navi = [[UINavigationController alloc]initWithRootViewController:addressViewController];
        
        _popController = [[UIPopoverController alloc] initWithContentViewController:navi];
        addressViewController.popover = _popController;
        _popController.delegate = self;
        navi.navigationBar.tintColor = THEME_COLOR;
        if (SIMI_SYSTEM_IOS >= 8) {
            navi.navigationBar.tintColor = THEME_APP_BACKGROUND_COLOR;
        }
        navi.navigationBar.barTintColor = THEME_COLOR;
        [self hiddenScreenWhenShowPopOver];
        [_popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:self.view permittedArrowDirections:0 animated:YES];
        return;
    }
    [self askCustomerRole];
}
#pragma mark BeforeOrder Delegate
- (void)didCancelCheckout
{
    if (_popController) {
        [_popController dismissPopoverAnimated:YES];
    }
}

- (void)reloadCartDetail
{
    [self getCart];
}

- (void)didGetAddressModelForCheckOut:(SimiAddressModel *)addressModel andIsNewCustomer:(BOOL)isNewCus
{
    [_popController dismissPopoverAnimated:YES];
    SCOrderViewControllerPad *orderViewController = [[SCOrderViewControllerPad alloc]init];
    orderViewController.isNewCustomer = isNewCus;
    orderViewController.shippingAddress = [addressModel mutableCopy];
    orderViewController.billingAddress = [addressModel mutableCopy];
    if (orderViewController.isNewCustomer) {
        orderViewController.addressNewCustomerModel = addressModel;
    }
    orderViewController.cart = [self.cart mutableCopy];
    orderViewController.cartPrices = [self.cartPrices mutableCopy];
    [self.navigationController pushViewController:orderViewController animated:YES];
}

#pragma  mark UIPopover Delegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    _popController = nil;
    [self showScreenWhenHiddenPopOver];
}

- (void)askCustomerRole{
    UIActionSheet *actionSheet;
    SimiStoreModel *store = [[SimiGlobalVar sharedInstance] store];
    if ([[[store valueForKey:@"checkout_config"] valueForKey:@"enable_guest_checkout"] boolValue]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:SCLocalizedString(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:SCLocalizedString(@"Checkout as existing customer"), SCLocalizedString(@"Checkout as new customer"), SCLocalizedString(@"Checkout as guest"), nil];
    }else{
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:SCLocalizedString(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:SCLocalizedString(@"Checkout as existing customer"), SCLocalizedString(@"Checkout as new customer"), nil];
    }
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    SimiStoreModel *store = [[SimiGlobalVar sharedInstance] store];
    BOOL isEnableGuestCheckout = [[[store valueForKey:@"checkout_config"] valueForKey:@"enable_guest_checkout"] boolValue];
    if (isEnableGuestCheckout) {
        switch (buttonIndex) {
            case 0: //Checkout as existing customer
            {
                self.isNewCustomer = NO;
                SCLoginViewController *nextController = [[SCLoginViewController alloc] init];
                nextController.isLoginInCheckout = YES;
                
                UINavigationController *navi;
                navi = [[UINavigationController alloc]initWithRootViewController:nextController];
                
                _popController = [[UIPopoverController alloc] initWithContentViewController:navi];
                nextController.popover = _popController;
                _popController.delegate = self;
                navi.navigationBar.tintColor = THEME_COLOR;
                if (SIMI_SYSTEM_IOS >= 8) {
                    navi.navigationBar.tintColor = THEME_APP_BACKGROUND_COLOR;
                }
                navi.navigationBar.barTintColor = THEME_COLOR;
                [self hiddenScreenWhenShowPopOver];
                [_popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:self.view permittedArrowDirections:0 animated:YES];
                
            }
                break;
            case 1: //Checkout as new customer
            {
                self.isNewCustomer = YES;
                SCNewAddressViewController *nextController = [[SCNewAddressViewController alloc]init];
                nextController.isNewCustomer = YES;
                nextController.delegate = self;
                UINavigationController *navi;
                navi = [[UINavigationController alloc]initWithRootViewController:nextController];
                
                _popController = [[UIPopoverController alloc] initWithContentViewController:navi];
                nextController.popover = _popController;
                _popController.delegate = self;
                navi.navigationBar.tintColor = THEME_COLOR;
                if (SIMI_SYSTEM_IOS >= 8) {
                    navi.navigationBar.tintColor = THEME_APP_BACKGROUND_COLOR;
                }
                navi.navigationBar.barTintColor = THEME_COLOR;
                [self hiddenScreenWhenShowPopOver];
                [_popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:self.view permittedArrowDirections:0 animated:YES];
            }
                break;
            case 2: //Checkout as guest
            {
                self.isNewCustomer = NO;
                SCNewAddressViewController *nextController = [[SCNewAddressViewController alloc]init];
                nextController.delegate = self;
                UINavigationController *navi;
                navi = [[UINavigationController alloc]initWithRootViewController:nextController];
                
                _popController = [[UIPopoverController alloc] initWithContentViewController:navi];
                nextController.popover = _popController;
                _popController.delegate = self;
                navi.navigationBar.tintColor = THEME_COLOR;
                if (SIMI_SYSTEM_IOS >= 8) {
                    navi.navigationBar.tintColor = THEME_APP_BACKGROUND_COLOR;
                }
                navi.navigationBar.barTintColor = THEME_COLOR;
                [self hiddenScreenWhenShowPopOver];
                [_popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:self.view permittedArrowDirections:0 animated:YES];
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
                self.isNewCustomer = NO;
                SCLoginViewController *nextController = [[SCLoginViewController alloc] init];
                nextController.isLoginInCheckout = YES;
                
                UINavigationController *navi;
                navi = [[UINavigationController alloc]initWithRootViewController:nextController];
                
                _popController = [[UIPopoverController alloc] initWithContentViewController:navi];
                nextController.popover = _popController;
                _popController.delegate = self;
                navi.navigationBar.tintColor = THEME_COLOR;
                if (SIMI_SYSTEM_IOS >= 8) {
                    navi.navigationBar.tintColor = THEME_APP_BACKGROUND_COLOR;
                }
                navi.navigationBar.barTintColor = THEME_COLOR;
                [self hiddenScreenWhenShowPopOver];
                [_popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:self.view permittedArrowDirections:0 animated:YES];
            }
                break;
            case 1: //Checkout as new customer
            {
                self.isNewCustomer = YES;
                SCNewAddressViewController *nextController = [[SCNewAddressViewController alloc]init];
                nextController.isNewCustomer = YES;
                nextController.delegate = self;
                
                UINavigationController *navi;
                navi = [[UINavigationController alloc]initWithRootViewController:nextController];
                
                _popController = [[UIPopoverController alloc] initWithContentViewController:navi];
                nextController.popover = _popController;
                _popController.delegate = self;
                navi.navigationBar.tintColor = THEME_COLOR;
                if (SIMI_SYSTEM_IOS >= 8) {
                    navi.navigationBar.tintColor = THEME_APP_BACKGROUND_COLOR;
                }
                navi.navigationBar.barTintColor = THEME_COLOR;
                [self hiddenScreenWhenShowPopOver];
                [_popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:self.view permittedArrowDirections:0 animated:YES];
            }
                break;
            default: //Cancel
                break;
        }
    }
}

#pragma mark New Address Delegate
- (void)didSaveAddress:(SimiAddressModel *)address
{
    [_popController dismissPopoverAnimated:YES];
    [self showScreenWhenHiddenPopOver];
    SCOrderViewControllerPad *orderViewController = [[SCOrderViewControllerPad alloc]init];
    orderViewController.shippingAddress = [address mutableCopy];
    orderViewController.billingAddress = [address mutableCopy];
    orderViewController.isNewCustomer = self.isNewCustomer;
    if (self.isNewCustomer) {
        orderViewController.addressNewCustomerModel = address;
    }else{
        orderViewController.checkoutGuest = YES;
    }
    orderViewController.cart = [self.cart mutableCopy];
    orderViewController.cartPrices = [self.cartPrices mutableCopy];
    [self.navigationController pushViewController:orderViewController animated:YES];
}

#pragma mark Address Delegate
- (void)selectAddress:(SimiAddressModel *)address
{
    [_popController dismissPopoverAnimated:YES];
    [self showScreenWhenHiddenPopOver];
    SCOrderViewControllerPad *orderViewController = [[SCOrderViewControllerPad alloc]init];
    orderViewController.shippingAddress = [address mutableCopy];
    orderViewController.billingAddress = [address mutableCopy];
    orderViewController.cart = [self.cart mutableCopy];
    orderViewController.cartPrices = [self.cartPrices mutableCopy];
    [self.navigationController pushViewController:orderViewController animated:YES];
}

#pragma mark Notification Action
- (void)didLogin:(NSNotification*)noti
{
    [_popController dismissPopoverAnimated:YES];
    [self getCart];
    
    SCAddressViewController *addressViewController = [SCAddressViewController new];
    addressViewController.delegate = self;
    UINavigationController *navi;
    navi = [[UINavigationController alloc]initWithRootViewController:addressViewController];
    
    _popController = [[UIPopoverController alloc] initWithContentViewController:navi];
    addressViewController.popover = _popController;
    _popController.delegate = self;
    navi.navigationBar.tintColor = THEME_COLOR;
    if (SIMI_SYSTEM_IOS >= 8) {
        navi.navigationBar.tintColor = THEME_APP_BACKGROUND_COLOR;
    }
    navi.navigationBar.barTintColor = THEME_COLOR;
    [_popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:self.view permittedArrowDirections:0 animated:YES];
}
@end
