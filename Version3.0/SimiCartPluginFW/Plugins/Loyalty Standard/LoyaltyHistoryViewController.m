//
//  LoyaltyHistoryViewController.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 1/21/15.
//  Copyright (c) 2015 Magestore. All rights reserved.
//

#import <SimiCartBundle/UIScrollView+SVInfiniteScrolling.h>
#import <SimiCartBundle/SimiDateTime.h>

#import "LoyaltyHistoryViewController.h"
#import "LoyaltyModelCollection.h"

@interface LoyaltyHistoryViewController () {
    LoyaltyModelCollection *transactions;
}
@end

@implementation LoyaltyHistoryViewController
@synthesize tableView = _tableView;

- (void)viewDidLoadBefore
{
    [self setToSimiView];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewDidLoadBefore];
    }
    self.title = SCLocalizedString(@"Rewards History");
    
    // Start load transactions
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _tableView.rowHeight = 108;
    } else {
        _tableView.rowHeight = 130;
    }
    [self.view addSubview:_tableView];
    
    __block __weak id weakSelf = self;
    [_tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadTransactions];
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoadTransactions:) name:@"DidGetLoyaltyTransactions" object:nil];
    
    [self startLoadingData];
    [self loadTransactions];
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    _tableView.frame = self.view.frame;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewWillAppearBefore:animated];
    }else{
        if (SIMI_SYSTEM_IOS >= 9.0) {
            _tableView.frame = CGRectMake(SCREEN_WIDTH/3, SCREEN_HEIGHT/3, SCREEN_WIDTH*2/3, SCREEN_HEIGHT*2/3);
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadTransactions
{
    if (transactions == nil) {
        transactions = [LoyaltyModelCollection new];
    }
    if (transactions.count && transactions.count < 12) {
        [_tableView.infiniteScrollingView stopAnimating];
    } else {
        [transactions getTransactionsWithOffset:transactions.count limit:12];
    }
}

- (void)didLoadTransactions:(NSNotification *)noti
{
    if (self.simiLoading) {
        [self stopLoadingData];
    }
    [_tableView.infiniteScrollingView stopAnimating];
    // Process Reload Data
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        if (transactions.count) {
            [_tableView reloadData];
        } else {
            // Show No Transaction Label
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.view.bounds.size.width - 40, self.view.bounds.size.height - 40)];
            label.font = [UIFont fontWithName:THEME_FONT_NAME size:24];
            label.textColor = [UIColor grayColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = SCLocalizedString(@"You currently have no activity");
            label.numberOfLines = 0;
            [self.view addSubview:label];
            [_tableView removeFromSuperview];
        }
    }
}

#pragma mark - Table View DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return transactions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LOYALTYTRAN"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LOYALTYTRAN"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        // Title / Content
        CGFloat width = tableView.frame.size.width - 61;
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(46, 10, width, 44)];
        title.tag = 1;
        title.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
        title.numberOfLines = 2;
        title.adjustsFontSizeToFitWidth = YES;
        title.minimumScaleFactor = 0.5;
        [cell addSubview:title];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(46, 54, width, 66)];
        view.tag = 11;
        [cell addSubview:view];
        
        UILabel *pointAmount = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 22)];
        pointAmount.tag = 2;
        pointAmount.font = [UIFont fontWithName:[THEME_FONT_NAME stringByAppendingString:@"-Bold"] size:THEME_FONT_SIZE + 2];
        [view addSubview:pointAmount];
        
        UILabel *created = [[UILabel alloc] initWithFrame:CGRectMake(0, 22, width, 22)];
        created.tag = 3;
        created.font = title.font;
        [view addSubview:created];
        
        UILabel *expires = [[UILabel alloc] initWithFrame:CGRectMake(0, 44, width, 22)];
        expires.tag = 4;
        expires.font = title.font;
        [view addSubview:expires];
    }
    SimiModel *transaction = [transactions objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[@"loyalty_" stringByAppendingString:[transaction objectForKey:@"status"]]];
    
    UILabel *title  = (UILabel *)[cell viewWithTag:1];
    UIView *view    = [cell viewWithTag:11];
    UILabel *amount = (UILabel *)[view viewWithTag:2];
    UILabel *created= (UILabel *)[view viewWithTag:3];
    UILabel *expires= (UILabel *)[view viewWithTag:4];
    
    CGFloat top = 10, width = title.frame.size.width, height = 44;
    title.text = [transaction objectForKey:@"title"];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        height = 22;
    } else {
        CGRect frame = [title textRectForBounds:CGRectMake(46, top, width, height) limitedToNumberOfLines:2];
        if (frame.size.height < 22) {
            top += 11;
            height = 22;
        }
    }
    amount.text = [transaction objectForKey:@"point_label"];
    created.text = [SimiDateTime formatDateTime:[transaction objectForKey:@"created_time"]];
    if ([[transaction objectForKey:@"expiration_date"] isEqualToString:@""]) {
        top += 11;
    } else {
        expires.text = [SCLocalizedString(@"Expire on: ") stringByAppendingString:[SimiDateTime formatDate:[transaction objectForKey:@"expiration_date"]]];
    }
    title.frame = CGRectMake(46, top, width, height);
    view.frame = CGRectMake(46, top + height, width, 66);
    
    return cell;
}

@end
