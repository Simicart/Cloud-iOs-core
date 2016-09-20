//
//  SCPaypalExpressAddressReviewViewController.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/22/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SCPaypalExpressAddressReviewViewController.h"
#import "SCPaypalExpressAddressEditViewController.h"


@interface SCPaypalExpressAddressReviewViewController ()

@end

@implementation SCPaypalExpressAddressReviewViewController

@synthesize addressTableView, shippingAddress, billingAddress, paypalModelCollection, paypalModel, updateButton, updateAddressView
;

#pragma mark TableView Datasource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section < 2) {
        UIView * headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 25)];
        NSString * title = @"";
        switch (section) {
            case 0:
                title = SCLocalizedString(@"Billing Address");
                break;
            case 1:
                title = SCLocalizedString(@"Shipping Address");
                break;
            default:
                break;
        }
        UILabel * name = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, 280, 15)];
        [name setTextColor:[UIColor grayColor]];
        name.font = [UIFont systemFontOfSize:14];
        [name setText:title];
        [headerView addSubview:name];
        return headerView;
    }
    else return [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section<2) {
        return 25;
    }
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddressCell"];
    
    if (indexPath.section < 2) {
        SimiAddressModel *address;
        if (indexPath.section == 0)
            address = billingAddress;
        else
            address = shippingAddress;
        
        cell.textLabel.text = [address formatAddress];
        CGSize labelSize = [cell.textLabel.text sizeWithFont:cell.textLabel.font
                                           constrainedToSize:cell.textLabel.frame.size
                                               lineBreakMode:cell.textLabel.lineBreakMode];
        cell.textLabel.frame = CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y, 320.0f, labelSize.height);
        cell.textLabel.numberOfLines = 0;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 2) {
        if (updateAddressView == nil) {
            updateAddressView = [[UIView alloc]init];
            updateAddressView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
            updateButton = [[UIButton alloc]initWithFrame:CGRectMake(20,0 , 200, 40)];
            //Ravi fix color
//            [updateButton setBackgroundColor:THEME_COLOR];
            [updateButton setBackgroundColor:THEME_BUTTON_BACKGROUND_COLOR];
            updateButton.tintColor = THEME_BUTTON_TEXT_COLOR;
            //End
            [updateButton setTitle:SCLocalizedString(@"Confirm Address") forState:UIControlStateNormal];
            [updateButton.layer setCornerRadius:5.0f];
            [updateButton addTarget:self action:@selector(updateAddressInformation:) forControlEvents:UIControlEventTouchUpInside];
            [updateAddressView addSubview:updateButton];
            UIButton * hidingButton = [[UIButton alloc]initWithFrame:updateAddressView.frame];
            [hidingButton addTarget:self action:@selector(updateAddressInformation:) forControlEvents:UIControlEventTouchUpInside];
            [updateAddressView addSubview:hidingButton];
        }
        [updateAddressView bringSubviewToFront:updateButton];
        [cell addSubview:updateAddressView];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
    }
    
    return cell;
}

#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.section < 2) {
        SCPaypalExpressAddressEditViewController *nextController = [[SCPaypalExpressAddressEditViewController alloc]init];
        SimiAddressModel *address;
        if (indexPath.section == 0)
            address = billingAddress;
        else
            address = shippingAddress;
        
        nextController.address = address;
        nextController.isEditing = YES;
        [self.navigationController pushViewController:nextController animated:YES];
        UIBarButtonItem *button = [[UIBarButtonItem alloc]initWithTitle:SCLocalizedString(@"Save") style:UIBarButtonItemStyleDone target:self action:@selector(saveAddress)];
        self.navigationItem.rightBarButtonItem = button;
    }
}

#pragma mark Get Address
-(void)getAddresses
{
    [self startLoadingData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetPaypalAdressInformation:) name:@"DidGetPaypalAdressInformation" object:nil];
    paypalModelCollection = [SCPaypalExpressModelCollection new];
    paypalModel = [SCPaypalExpressModel new];
    [paypalModel reviewAddress];
}

- (void)didGetPaypalAdressInformation: (NSNotification *)noti
{
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        self.title = SCLocalizedString(@"Address Confirmation");
        
        billingAddress = [SimiAddressModel new];
        [billingAddress addEntriesFromDictionary:[paypalModel objectForKey:@"billing_address"]];
        shippingAddress = [SimiAddressModel new];
        [shippingAddress addEntriesFromDictionary:[paypalModel objectForKey:@"shipping_address"]];
        
        addressTableView = [[SimiTableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStyleGrouped];
        addressTableView.dataSource = self;
        addressTableView.delegate = self;
        addressTableView.frame = CGRectMake(0, 15, self.view.frame.size.width, self.view.frame.size.height);
        addressTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:addressTableView];
    }
    else {
        UIAlertView * a = [[UIAlertView alloc]initWithTitle:@"" message:responder.responseMessage delegate:self cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [a show];
    }
}

#pragma mark Update Address Information

- (IBAction)updateAddressInformation :(id)sender
{
    [self startLoadingData];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:shippingAddress forKey:@"shippingAddress"];
    [params setValue:billingAddress forKey:@"billingAddress"];
    [params setValue:[billingAddress valueForKey:@"customer_password"] forKey:@"customer_password"];
    [params setValue:[billingAddress valueForKey:@"confirm_password"] forKey:@"confirm_password"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paypalDidCompleteReviewAddress:) name:@"DidUpdatePaypalCheckoutAddress" object:nil];
    [paypalModelCollection updateAddressWithParam:params];
}

-(void)paypalDidCompleteReviewAddress:(NSNotification *)noti
{
    
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    [self removeObserverForNotification:noti];
    [self stopLoadingData];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        [self.delegate completedReviewAddress];
    }
    else {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:responder.responseMessage delegate:self cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alert show];
    }
}


#pragma mark -
#pragma mark dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
