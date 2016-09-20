//
//  SCPaypalExpressShippingMethodViewController.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/22/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SCPaypalExpressShippingMethodViewController.h"
#import <SimiCartBundle/SimiShippingModel.h>
#import <SimiCartBundle/SimiFormatter.h>

@interface SCPaypalExpressShippingMethodViewController ()


@end

@implementation SCPaypalExpressShippingMethodViewController
{
    UIView * placeOrderView;
    UIButton * placeOrderButton;
    NSIndexPath * checkedData;
}
@synthesize paypalModel, shippingMethodTableView, paypalModelCollection
;

#pragma mark Get Shipping Methods
- (void)getShippingMethod
{
    [self startLoadingData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetShippingMethods:) name:@"DidGetPaypalCheckoutShippingMethods" object:nil];
    paypalModelCollection = [SCPaypalExpressModelCollection new];
    [paypalModelCollection getShippingMethods];
}

- (void)didGetShippingMethods:(NSNotification *)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    [self removeObserverForNotification:noti];
    [self stopLoadingData];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        self.title = SCLocalizedString(@"Shipping Method");
        shippingMethodTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
        shippingMethodTableView.dataSource = self;
        shippingMethodTableView.delegate = self;
        shippingMethodTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        shippingMethodTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:shippingMethodTableView];
    }
    else {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:SCLocalizedString(@"Error") message:responder.responseMessage delegate:self cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [paypalModelCollection count];
    }
    return 1;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString * title = @"";
    switch (section) {
        case 0:
            title = SCLocalizedString(@"Please select shipping method");
            break;
        default:
            break;
    }
    return title;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
   }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    if ((checkedData.row != indexPath.row)||(checkedData.section != indexPath.section))
        cell.accessoryType = UITableViewCellAccessoryNone;
    else
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    if (paypalModelCollection!=nil) {
        if (indexPath.section == 0) {
            
            UILabel * methodName = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, self.view.frame.size.width *2/3 , 30)];
            UILabel * methodPrice = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width -  200 , 5, 150 , 30)];
            [methodPrice setTextColor:[UIColor redColor]];
            [methodName setText: [(SCPaypalExpressModel *)[paypalModelCollection objectAtIndex:indexPath.row] objectForKey:@"s_method_title"]];
            NSNumber * fee = (NSNumber *)[(SCPaypalExpressModel *)[paypalModelCollection objectAtIndex:indexPath.row] objectForKey:@"s_method_fee"];
            NSString * price = [[SimiFormatter sharedInstance] priceByLocalizeNumber:fee] ;
            [methodPrice setText:price];
            [methodPrice setTextAlignment:NSTextAlignmentRight];
            
            [cell addSubview:methodName];
            [cell addSubview:methodPrice];
        }
        else {
            if (placeOrderView == nil) {
                placeOrderView = [[UIView alloc]init];
                placeOrderView.frame = CGRectMake(0, 0, self.view.frame.size.width, 500);
                placeOrderButton = [[UIButton alloc]initWithFrame:CGRectMake(30,5 , 250, 40)];
                //Ravi fix color
//                [placeOrderButton setBackgroundColor:THEME_COLOR];
                [placeOrderButton setBackgroundColor:THEME_BUTTON_BACKGROUND_COLOR];
                placeOrderButton.tintColor = THEME_BUTTON_TEXT_COLOR;
                //End
                [placeOrderButton setTitle:SCLocalizedString(@"Place Order") forState:UIControlStateNormal];
                [placeOrderButton.layer setCornerRadius:5.0f];
                [placeOrderButton addTarget:self action:@selector(placeOrder:) forControlEvents:UIControlEventTouchUpInside];
                [placeOrderView addSubview:placeOrderButton];
                UIButton * hidingButton = [[UIButton alloc]initWithFrame:placeOrderView.frame];
                [hidingButton addTarget:self action:@selector(placeOrder:) forControlEvents:UIControlEventTouchUpInside];
                [placeOrderView addSubview:hidingButton];
            }
            [placeOrderView bringSubviewToFront:placeOrderButton];
            [cell addSubview:placeOrderView];
            [cell setBackgroundColor:[UIColor clearColor]];
        }
    }
    return cell;

}


#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        checkedData = indexPath;
        [tableView reloadData];
    }
    
}

#pragma mark Place Order
- (IBAction)placeOrder :(id)sender
{
    [self startLoadingData];
    
    if (paypalModel == nil) {
        paypalModel = [[SCPaypalExpressModel alloc]init];
    }
    
    SimiShippingModel *method = [[SimiShippingModel alloc]init];
    SCPaypalExpressModel *selected;
    if (checkedData == nil) {
        selected = [paypalModelCollection objectAtIndex:0];
    }
    else {
        selected = [paypalModelCollection objectAtIndex:checkedData.row];
    }
    [method setValue:[selected objectForKey:@"s_method_code"] forKey:@"shipping_method"];
    for (NSString * key in selected) {
        [method setValue:[selected objectForKey:key] forKey:key];
    }
    
    [paypalModel placeOrderWithParam:method];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlaceOrder:) name:@"PaypalExpressDidPlaceOrder" object:nil];
}

- (void)didPlaceOrder:(NSNotification *)noti
{
    [self stopLoadingData];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:SCLocalizedString(@"Thank you for your purchase") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
    }
    else {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:responder.responseMessage delegate:self cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alert show];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark Dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
