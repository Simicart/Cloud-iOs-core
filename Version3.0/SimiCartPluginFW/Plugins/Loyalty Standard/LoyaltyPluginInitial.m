//
//  LoyaltyPluginInitial.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 12/31/14.
//  Copyright (c) 2014 Magestore. All rights reserved.
//

#import "LoyaltyPluginInitial.h"

#import <SimiCartBundle/SCProductViewController.h>
#import <SimiCartBundle/SCCartViewController.h>
#import <SimiCartBundle/SCAccountViewController.h>
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SimiGlobalVar.h>
#import <SimiCartBundle/SimiTable.h>
#import <SimiCartBundle/SCOrderFeeCell.h>
#import <SimiCartBundle/SimiFormatter.h>

#import <SimiCartBundle/SCProductViewControllerPad.h>
#import "LoyaltyViewController.h"
#import "SimiOrderModel+Loyalty.h"

#import <SimiCartBundle/SCOrderViewControllerPad.h>
#import <SimiCartBundle/SCLeftMenuViewController.h>
#import <SimiCartBundle/SCThemeWorker.h>
#import <SimiCartBundle/SCProductInfoView.h>


static NSString *ACCOUNT_REWARDS_ROW     = @"account_rewards";
static NSString *LEFTMENU_REWARDS_ROW     = @"leftmenu_rewards";


@implementation LoyaltyPluginInitial

- (instancetype)init
{
    if (self = [super init]) {
        
        // Show Label on Shopping Cart
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"InitCartCell-Before" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"InitializedCartCell-Before" object:nil];
        
        //My Account Screen
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializedAccountCellAfter:) name:@"SCAccountViewController-InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectAccountCellAtIndexPath:) name:@"DidSelectAccountCellAtIndexPath" object:nil];
        
        //Left Menu
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listMenuInitCellsAfter:) name:@"SCLeftMenu_InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listMenuDidSelectRow:) name:SCLeftMenuDidSelectRow object:nil];
        
        //Product Info View
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productInforViewSetInterfacecellAfter:) name:@"SCProductInforViewSetInterfacecell_After" object:nil];
        
        // Spend Point when Checkout
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderViewControllerViewDidLoad:) name:@"SCOrderViewControllerViewDidLoad" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetOrderConfig" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidSetCouponCode" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidSaveShippingMethod" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidSpendPointsOrder" object:nil];
        
        //Order screen init order table on iphone
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCOrderViewController-InitTableBefore" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCOrderViewController-InitTableAfter" object:nil];
        
        //Order screen init order table on ipad
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCOrderViewController-InitRightTableAfter" object:nil];
        
        //Order screen init cell
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializeOrderCellAfter:) name:@"InitializedOrderCell-After" object:nil];
        
        //Update Point balance after checkout
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidPlaceOrder" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"LoadedProgramOverview" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveNotification:(NSNotification *)noti
{
#pragma mark set Order Table
    if (([noti.name isEqualToString:@"DidGetOrderConfig"] || [noti.name isEqualToString:@"DidSpendPointsOrder"] || [noti.name isEqualToString:@"DidSetCouponCode"] || [noti.name isEqualToString:@"DidSaveShippingMethod"] || [noti.name isEqualToString:@"SCOrderViewController-InitTableBefore"] || [noti.name isEqualToString:@"SCOrderViewController-InitTableAfter"]||[noti.name isEqualToString:@"SCOrderViewController-InitRightTableAfter"]) && self.orderViewController) {
        SimiOrderModel *order = [self.orderViewController order];
        SimiTable *orderTable = [self.orderViewController orderTable];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            orderTable = [(SCOrderViewControllerPad *)self.orderViewController orderTableRight];
        }
       
        if ([orderTable getSectionIndexByIdentifier:LOYALTY_CHECKOUT] == NSNotFound) {
            NSUInteger index = [orderTable getSectionIndexByIdentifier:ORDER_TOTALS_SECTION];
            if (index != NSNotFound) {
                SimiSection *section = [orderTable addSectionWithIdentifier:LOYALTY_CHECKOUT atIndex:index];
                section.headerTitle = SCLocalizedString(@"Spend my Points");
                CGFloat height = 40;
                if (![[SimiGlobalVar sharedInstance] isLogin]) height = 40;
                [section addRowWithIdentifier:LOYALTY_CHECKOUT height:height];
            }
        }
        /*
        SimiRow *totalRow;
        for (SimiRow * row in [orderTable getSectionByIdentifier:ORDER_TOTALS_SECTION].rows) {
            if (row.identifier == ORDER_VIEW_TOTAL) {
                totalRow = row;
                break;
            }
        }
        
        NSDictionary *fee = [order objectForKey:@"fee"];
        NSMutableDictionary *v2 = [fee valueForKey:@"v2"];
        if (![v2 isKindOfClass:[NSMutableDictionary class]]) {
            v2 = [[NSMutableDictionary alloc] initWithDictionary:v2];
            [fee setValue:v2 forKey:@"v2"];
        }
        if ([[fee objectForKey:@"loyalty_spend"] integerValue]) {
            [v2 setValue:[fee objectForKey:@"loyalty_spending"] forKey:@"loyalty_spend"];
            [v2 setValue:[fee objectForKey:@"loyalty_discount"] forKey:@"loyalty_discount"];
            totalRow.height += 25;
        } else {
            [v2 removeObjectForKey:@"loyalty_spend"];
            [v2 removeObjectForKey:@"loyalty_discount"];
        }
        if ([[fee objectForKey:@"loyalty_earn"] integerValue]) {
            [v2 setValue:[fee objectForKey:@"loyalty_earning"] forKey:@"loyalty_earn"];
            totalRow.height += 25;
        } else {
            [v2 removeObjectForKey:@"loyalty_earn"];
        }
        if ([noti.name isEqualToString:@"DidSpendPointsOrder"]) {
            if([[order valueForKey:@"payment_method_list"] isKindOfClass:[NSArray class]])
            {
                self.orderViewController.paymentCollection = [[SimiPaymentModelCollection alloc]initWithArray:[order valueForKey:@"payment_method_list"]];
                self.orderViewController.orderTable = nil;
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    [(SCOrderViewControllerPad *)self.orderViewController configOrderTableLeft];
                    [[(SCOrderViewControllerPad *)self.orderViewController tableLeft] reloadData];
                }
            }
            [[self.orderViewController tableViewOrder]reloadData];
        }
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [[(SCOrderViewControllerPad *)self.orderViewController tableRight] reloadData];
        }
         */
#pragma mark init Cart Cell
    } else if ([noti.name isEqualToString:@"InitCartCell-Before"]) {
            // Add Row to show Loyalty Labels
        SimiTable *cartCells = (SimiTable *)noti.object;
        SimiSection *loyaltySection = [cartCells addSectionWithIdentifier:LOYALTY_CART];
        [loyaltySection addRowWithIdentifier:LOYALTY_CART height:44];
    } else if ([noti.name isEqualToString:@"InitializedCartCell-Before"]) {
        SimiRow *row = [noti.userInfo objectForKey:@"row"];
        if ([row.identifier isEqualToString:LOYALTY_CART]) {
            SCCartViewController *controller = noti.object;
            controller.isDiscontinue = YES;
            
            UITableView *tableView = (UITableView *)[noti.userInfo objectForKey:@"tableView"];
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LOYALTY_CART];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LOYALTY_CART];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UIView *loyalty = [UIView new];
                loyalty.tag = LOYALTY_TAG;
                [cell addSubview:loyalty];
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                    loyalty.frame = CGRectMake(10, 2, SCREEN_WIDTH - 20, 40);
                } else {
                    loyalty.frame = CGRectMake(10, 2, 380, 40);
                }
                
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 11, 18, 18)];
                imageView.tag = 3821;
                [loyalty addSubview:imageView];
                
                UILabel *label = [UILabel new];
                label.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
                label.numberOfLines = 2;
                label.adjustsFontSizeToFitWidth = YES;
                label.minimumScaleFactor = 0.7f;
                label.tag = 3822;
                [loyalty addSubview:label];
            }
            
            UIView *loyalty = [cell viewWithTag:LOYALTY_TAG];
            UIImageView *imageView = (UIImageView *)[loyalty viewWithTag:3821];
            UILabel *label = (UILabel *)[loyalty viewWithTag:3822];
            
            [imageView sd_setImageWithURL:[NSURL URLWithString:@"http://demo.magestore.com/simicart/simipos3/skin/frontend/base/default/images/rewardpoints/point.png"] placeholderImage:nil options:SDWebImageRetryFailed];
            label.text = @"Checkout now and earn 1000 Point in rewards";
            
            // Center label and image
            CGFloat textWidth = [label textRectForBounds:CGRectMake(24, 0, loyalty.frame.size.width - 24, 40) limitedToNumberOfLines:2].size.width;
            imageView.frame = CGRectMake((loyalty.frame.size.width - textWidth - 24) / 2, 11, 18, 18);
            label.frame = CGRectMake(imageView.frame.origin.x + 24, 0, textWidth, 40);
            
            controller.simiObjectIdentifier = cell;
        }
#pragma mark Did Place Order
    } else if ([noti.name isEqualToString:@"DidPlaceOrder"]) {
        if ([noti.object objectForKey:@"loyalty_balance"]) {
            SimiCustomerModel *customer = [[SimiGlobalVar sharedInstance] customer];
            if ([[SimiGlobalVar sharedInstance] isLogin] && customer) {
                [customer setValue:[noti.object objectForKey:@"loyalty_balance"] forKey:@"loyalty_balance"];
                [self.loyaltyMenuRow setTitle:[self rewardMenuLabel]];
            }
        }
#pragma mark Loaded Program OverView
    } else if ([noti.name isEqualToString:@"LoadedProgramOverview"]) {
        if ([noti.object objectForKey:@"loyalty_redeem"]) {
            SimiCustomerModel *customer = [[SimiGlobalVar sharedInstance] customer];
            if ([[SimiGlobalVar sharedInstance] isLogin] && customer) {
                [customer setValue:[noti.object objectForKey:@"loyalty_redeem"] forKey:@"loyalty_balance"];
                [self.loyaltyMenuRow setTitle:[self rewardMenuLabel]];
            }
        }
    }
}


- (void)changeSpendingPoints:(UISlider *)slider
{
    UILabel *points = (UILabel *)slider.simiObjectIdentifier;
    NSInteger pointStep = [(NSNumber *)points.simiObjectIdentifier integerValue];
    NSInteger pointValue = (NSInteger)roundf(slider.value / pointStep);
    pointValue *= pointStep;
    points.text = [[SCLocalizedString(@"Spending") stringByAppendingString:@": "] stringByAppendingString:[NSString stringWithFormat:@"%ld", (long)pointValue]];
}

- (void)stopSpendingPointsSlide:(UISlider *)slider
{
    UILabel *points = (UILabel *)slider.simiObjectIdentifier;
    NSInteger pointStep = [(NSNumber *)points.simiObjectIdentifier integerValue];
    NSInteger pointValue = (NSInteger)roundf(slider.value / pointStep);
    pointValue *= pointStep;
    slider.value = (float)pointValue;
    
    SimiOrderModel *order = [self.orderViewController order];
    if ([[[order objectForKey:@"fee"] objectForKey:@"loyalty_spend"] integerValue] == pointValue) {
        return;
    }
    NSDictionary *rule = [[[order objectForKey:@"fee"] objectForKey:@"loyalty_rules"] objectAtIndex:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.orderViewController selector:@selector(didReceiveNotification:) name:@"DidSpendPointsOrder" object:order];
    [order spendPoints:pointValue ruleId:[rule objectForKey:@"id"]];
    [self.orderViewController startLoadingData];
}

- (NSString *)rewardMenuLabel
{
    SimiCustomerModel *customer = [[SimiGlobalVar sharedInstance] customer];
    if ([[SimiGlobalVar sharedInstance] isLogin] && customer && [customer objectForKey:@"loyalty_balance"]) {
        return [[SCLocalizedString(@"My Rewards") stringByAppendingString:@" "] stringByAppendingString:[customer objectForKey:@"loyalty_balance"]];
    }
    return SCLocalizedString(@"My Rewards");
}

#pragma mark Add to My Account Screen
-(void)initializedAccountCellAfter:(NSNotification *)noti
{
    NSArray * cells = noti.object;
    for (SimiSection *section in cells) {
        if (section.identifier != ACCOUNT_MAIN_SECTION)
            return;
        if ([section isKindOfClass:[SimiSection class]]) {
            float rowHeight;
            for (SimiRow *row in section.rows) {
                rowHeight = row.height;
                if (row.identifier == ACCOUNT_REWARDS_ROW)
                    return;
            }
            SimiRow *wishlistRow = [[SimiRow alloc]initWithIdentifier:ACCOUNT_REWARDS_ROW height:rowHeight sortOrder:310];
            wishlistRow.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            wishlistRow.title = SCLocalizedString(@"My Rewards");
            wishlistRow.image = [UIImage imageNamed:@"loyalty_reward"];
            [section addRow:wishlistRow];
            [section sortItems];
        }
    }
}

-(void)didSelectAccountCellAtIndexPath:(NSNotification *)noti
{
    if ([(SimiRow *)noti.object identifier] == ACCOUNT_REWARDS_ROW) {
        SCAccountViewController *accountVC = [noti.userInfo objectForKey:@"self"];
        LoyaltyViewController *loyalty = [LoyaltyViewController new];
        [accountVC.navigationController pushViewController:loyalty animated:YES];
        accountVC.isDiscontinue = YES;
    }
}

#pragma mark Add to Left Menu
-(void)listMenuInitCellsAfter:(NSNotification *)noti
{
    NSArray * cells = noti.object;
    if ([[SimiGlobalVar sharedInstance] isLogin]) {
        for (SimiSection *section in cells) {
            if ([section isKindOfClass:[SimiSection class]]) {
                if (section.identifier != LEFTMENU_SECTION_MAIN)
                    return;
                float rowHeight = 50;
                for (SimiRow *row in section.rows) {
                    rowHeight = row.height;
                    if (row.identifier == LEFTMENU_REWARDS_ROW)
                        return;
                }
                
                SimiRow *wishlistRow = [[SimiRow alloc]initWithIdentifier:LEFTMENU_REWARDS_ROW height:rowHeight sortOrder:310];
                wishlistRow.title = SCLocalizedString(@"My Rewards");
                wishlistRow.image = [UIImage imageNamed:@"loyalty_reward_invert"];
                [section addRow:wishlistRow];
                [section sortItems];
            }
        }
    }
}

-(void)listMenuDidSelectRow:(NSNotification *)noti
{
    
    if ([(SimiRow *)[noti.userInfo objectForKey:@"simirow"] identifier] == LEFTMENU_REWARDS_ROW) {
        UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
        LoyaltyViewController *loyalty = [LoyaltyViewController new];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [[[SCThemeWorker sharedInstance] navigationBarPad].popController  dismissPopoverAnimated:NO];
            [[SCThemeWorker sharedInstance] navigationBarPad].popController = [[UIPopoverController alloc] initWithContentViewController:[[UINavigationController alloc] initWithRootViewController:loyalty]];
            [[[SCThemeWorker sharedInstance] navigationBarPad].popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1)  inView:currentVC.view  permittedArrowDirections:0 animated:YES];
            loyalty.isInPopover = YES;
        }
        else
            [(UINavigationController *)currentVC pushViewController:loyalty animated:YES];
        [(SCNavigationBarPhone*)noti.object setIsDiscontinue:YES];
    }
}

#pragma mark Set Product Info View
-(void)productInforViewSetInterfacecellAfter:(NSNotification *)noti
{
    SCProductInfoView *productInfoView = noti.object;
    UIView *loyalty = [productInfoView viewWithTag:LOYALTY_TAG];
    if (loyalty == nil) {
        loyalty = [[UIView alloc] initWithFrame:CGRectMake(productInfoView.productNameLabel.frame.origin.x , productInfoView.heightCell+10, productInfoView.productNameLabel.frame.size.width, 44)];
        loyalty.tag = LOYALTY_TAG;
        [productInfoView addSubview:loyalty];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 13, 18, 18)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageView sd_setImageWithURL:[NSURL URLWithString:@"http://demo.magestore.com/simicart/simipos3/skin/frontend/base/default/images/rewardpoints/point.png"] placeholderImage:nil options:SDWebImageRetryFailed];
        [loyalty addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(24, 0, loyalty.frame.size.width - 24, 44)];
        label.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE_REGULAR];
        label.text = @"You could receive some Points for purchasing this product";
        label.numberOfLines = 2;
        [loyalty addSubview:label];
    }
}

#pragma mark Add to Order Screen

-(void)orderViewControllerViewDidLoad:(NSNotification *)noti
{
    self.orderViewController = noti.object;
}

- (void)initOrderRightTableAfter:(NSNotification *)noti
{
    SimiOrderModel *order = [self.orderViewController order];
    NSArray *rules = [[order objectForKey:@"fee"] objectForKey:@"loyalty_rules"];
    if ([rules count]) {
        NSDictionary *rule = [rules objectAtIndex:0];
        SimiTable *orderTable = [self.orderViewController orderTable];
        SimiSection *shipment = [orderTable getSectionByIdentifier:ORDER_TOTALS_SECTION];
        shipment.headerTitle = SCLocalizedString(@"Shipment Details");
        shipment = [orderTable getSectionByIdentifier:ORDER_SHIPMENT_SECTION];
        shipment.headerTitle = SCLocalizedString(@"Shipping Method");
        if ([orderTable getSectionIndexByIdentifier:LOYALTY_CHECKOUT] == NSNotFound) {
            SimiSection *section = [orderTable addSectionWithIdentifier:LOYALTY_CHECKOUT atIndex:0];
            section.headerTitle = SCLocalizedString(@"Spend my Points");
            CGFloat height = [[rule objectForKey:@"optionType"] isEqualToString:@"slider"] ? 105 : 40;
            if (![[SimiGlobalVar sharedInstance] isLogin]) height = 40;
            [section addRowWithIdentifier:LOYALTY_CHECKOUT height:height];
        }
    }
}

- (void)initializeOrderCellAfter:(NSNotification *)noti
{
    SimiRow *row = noti.object;
    if ([row.identifier isEqualToString:LOYALTY_CHECKOUT]) {
        UITableViewCell *cell = (UITableViewCell *)[noti.userInfo objectForKey:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (![[SimiGlobalVar sharedInstance] isLogin]) {
            cell.textLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
            cell.textLabel.numberOfLines = 2;
            cell.textLabel.text = SCLocalizedString(@"Please login before using points to spend");
            return;
        }
        // Need Points
        cell.textLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.text = SCLocalizedString(@"You need to earn more 1000 points to use this rule.");
    }
    /*
    SCOrderFeeCell *cell = [noti.userInfo objectForKey:@"cell"];
    NSDictionary *fee    = [[[self.orderViewController order] objectForKey:@"fee"] objectForKey:@"v2"];
    if ([cell isKindOfClass:[SCOrderFeeCell class]] && fee) {
        for (UIView *subView in cell.subviews) {
            [subView removeFromSuperview];
        }
        [cell setData:(NSMutableArray *)fee];
        float heightCell = 5;
        float widthTitle = [SimiGlobalVar scaleValue:190];
        float widthValue = [SimiGlobalVar scaleValue:97];
        float origionTitleX = [SimiGlobalVar scaleValue:16];
        float origionValueX = [SimiGlobalVar scaleValue:206];
        float heightLabel = 22;
        float heightLabelWithDistance = 25;
        
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            heightCell = 30;
            origionValueX = cell.frame.size.width - 120;
            widthValue = 100;
            origionTitleX = 10;
            widthTitle = cell.frame.size.width - 130;
            heightLabel = 22;
            heightLabelWithDistance = 25;
        }
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            origionTitleX = 115;
            widthTitle = 195;
            origionValueX = 15;
            widthValue = 120;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                origionTitleX = 460;
                widthTitle = 195;
                origionValueX = 320;
                widthValue = 120;
            }
        }
        
        
        UILabel *earn, *earnValue, *spend, *spendValue, *discount, *discountValue;
        CGFloat marginTop     = 0;
        if ([fee objectForKey:@"loyalty_earn"]) {
            earn = [[UILabel alloc] initWithFrame:CGRectMake(origionTitleX, 5, widthTitle, 22)];
            earn.text = [SCLocalizedString(@"You will earn") stringByAppendingString:@":"];
            earn.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
            earn.textAlignment = NSTextAlignmentRight;
            earnValue = [[UILabel alloc] initWithFrame:CGRectMake(origionValueX, 5, widthValue, 22)];
            earnValue.text = [fee objectForKey:@"loyalty_earn"];
            earnValue.font = earn.font;
            earnValue.textColor = THEME_PRICE_COLOR;
            earnValue.textAlignment = NSTextAlignmentRight;
            marginTop += 25;
        }
        CGFloat subThreshold   = 0;
        CGFloat subTotalMargin = marginTop;
        if ([fee objectForKey:@"loyalty_spend"]) {
            for (UIView *view in cell.subviews) {
                if ([view isEqual:cell.subTotalExclLabel] || [view isEqual:cell.subTotalLabel] || [view isEqual:cell.subTotalInclLabel]) {
                    subThreshold = MAX(subThreshold, view.frame.origin.y);
                }
            }
            spend = [[UILabel alloc] initWithFrame:CGRectMake(origionTitleX, marginTop + 5, widthTitle, 22)];
            spend.text = [SCLocalizedString(@"You will spend") stringByAppendingString:@":"];
            spend.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
            spend.textAlignment = NSTextAlignmentRight;
            spendValue = [[UILabel alloc] initWithFrame:CGRectMake(origionValueX, marginTop + 5, widthValue, 22)];
            spendValue.text = [fee objectForKey:@"loyalty_spend"];
            spendValue.font = spend.font;
            spendValue.textColor = THEME_PRICE_COLOR;
            spendValue.textAlignment = NSTextAlignmentRight;
            marginTop += 25;
            subTotalMargin = marginTop + 25;
            discount = [spend clone];
            discountValue = [spendValue clone];
            discount.frame = CGRectMake(origionTitleX, subThreshold + subTotalMargin, widthTitle, 22);
            discount.text = [[[[fee objectForKey:@"loyalty_spend"] stringByAppendingString:@" "] stringByAppendingString:SCLocalizedString(@"Discount")] stringByAppendingString:@":"];
            discountValue.frame = CGRectMake(origionValueX, subThreshold + subTotalMargin, widthValue, 22);
            discountValue.text = [[SimiFormatter sharedInstance] priceByLocalizeNumber:[fee objectForKey:@"loyalty_discount"]];
        }
        if (marginTop > 1) {
            for (UIView *view in cell.subviews) {
                CGRect frame = view.frame;
                if (frame.origin.y > subThreshold) {
                    frame.origin.y += subTotalMargin;
                } else {
                    frame.origin.y += marginTop;
                }
                view.frame = frame;
            }
        }
        if (earnValue) {
            [cell addSubview:earn];
            [cell addSubview:earnValue];
        }
        if (spendValue) {
            [cell addSubview:spend];
            [cell addSubview:spendValue];
            [cell addSubview:discount];
            [cell addSubview:discountValue];
        }
    }
     */
}

@end
