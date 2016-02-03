//
//  SCOrderHistoryViewController.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/4/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SCOrderHistoryViewController.h"
#import "OrderListCell.h"
#import "SCOrderDetailViewController.h"

@interface SCOrderHistoryViewController ()

@end

@implementation SCOrderHistoryViewController

@synthesize orderCollection, tableViewOrder, isLoadData;

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
    self.navigationItem.title = [self formatTitleString:SCLocalizedString(@"Order History")];
    [self setToSimiView];
	[self initView];
    [self getOrderCollection];
    isLoadData= false;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewDidLoadBefore];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewWillAppearBefore:YES];
    }
}

- (void)viewWillAppearAfter:(BOOL)animated{
    [super viewWillAppearAfter:animated];
    [tableViewOrder deselectRowAtIndexPath:[tableViewOrder indexPathForSelectedRow] animated:YES];
    if(!isLoadData)
        [self startLoadingData];
}

- (void)initView{
    tableViewOrder = [[SimiTableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    [tableViewOrder setBackgroundColor:[UIColor clearColor]];
    tableViewOrder.dataSource = self;
    tableViewOrder.delegate = self;
    tableViewOrder.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:tableViewOrder];
    __weak SimiTableView *tableView = tableViewOrder;
    [tableView addInfiniteScrollingWithActionHandler:^{
        [self getOrderCollection];
    }];
}

- (void)getOrderCollection{
    if (orderCollection == nil) {
        orderCollection = [[SimiOrderModelCollection alloc] init];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetOrderCollection" object:orderCollection];
    NSString* customerID;
    if([[SimiGlobalVar sharedInstance] isLogin]){
        SimiCustomerModel * customer = [[SimiGlobalVar sharedInstance] customer];
        customerID = [NSString stringWithFormat:@"%@",[customer objectForKey:@"_id"]];
        [orderCollection getCustomerOrderCollectionWithParams:@{@"filter[customer|customer_id]":customerID, @"offset":[NSString stringWithFormat:@"%ld",(unsigned long)orderCollection.count] , @"limit":@"6", @"dir":@"desc", @"order":@"updated_at"}];
    }
}

- (void)didReceiveNotification:(NSNotification *)noti{
    isLoadData = true;
    [tableViewOrder reloadData];
    [self stopLoadingData];
    [tableViewOrder.infiniteScrollingView stopAnimating];
}

#pragma mark Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(isLoadData)
        return 1;
    else
        return 0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(orderCollection.count>0)
        return orderCollection.count;
    else return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 125.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(orderCollection.count>0)
    {
        NSString *orderCellIdentifier = [NSString stringWithFormat: @"%@_%@", @"OrderListCellIdentifier", [[orderCollection objectAtIndex:indexPath.row] valueForKey:@"_id"]];
        OrderListCell *cell = [tableView dequeueReusableCellWithIdentifier:orderCellIdentifier];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedOrderHistoryCell-Before" object:cell];
        if (self.isDiscontinue) {
            self.isDiscontinue = NO;
            return cell;
        }
        if (cell == nil) {
            cell = [[OrderListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:orderCellIdentifier];
            [cell setOrderModel:[orderCollection objectAtIndex:indexPath.row]];
        }
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedOrderHistoryCell-After" object:cell];
        return cell;
    }
    else
    {
        static NSString *EmptyCartCellIdentifier = @"SCEmptyHistoryCellIdentifier";
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:EmptyCartCellIdentifier];
        [cell setBackgroundColor:[UIColor clearColor]];
        UILabel *emptyLabel = [[UILabel alloc]init];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [emptyLabel setFrame:CGRectMake(50, 50, cell.bounds.size.width-100, cell.frame.size.height)];
        }else
        {
            [emptyLabel setFrame:CGRectMake(40, 50, 600, cell.frame.size.height)];
        }
        emptyLabel.text = SCLocalizedString(@"You have placed no orders.");
        [emptyLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [emptyLabel setTextAlignment:NSTextAlignmentCenter];
        [emptyLabel setNumberOfLines:2];
        [emptyLabel setTextColor:THEME_CONTENT_COLOR];
        [cell addSubview:emptyLabel];
        return cell;
    }
}
#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(orderCollection.count>0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectOrderHistoryCellAtIndexPath" object:tableView userInfo:@{@"indexPath": indexPath}];
        if (self.isDiscontinue) {
            self.isDiscontinue = NO;
            return;
        }
        SCOrderDetailViewController *nextController = [[SCOrderDetailViewController alloc] init];
        nextController.order = [self.orderCollection objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:nextController animated:YES];
    }
}

@end
