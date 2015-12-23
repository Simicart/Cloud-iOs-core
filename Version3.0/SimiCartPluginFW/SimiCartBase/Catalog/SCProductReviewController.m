//
//  SCReviewDetailController.m
//  SimiCart
//
//  Created by Tan on 7/2/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import "SCProductReviewController.h"
#import "SCProductInfoView.h"
#import "SCProductReviewView.h"
#import "SimiResponder.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "SCProductReviewShortCell.h"
#import "SimiGlobalVar.h"
#import "SimiSection.h"
#import "SCAppDelegate.h"

NSString *REVIEW_PRODUCT_CELL = @"REVIEW_PRODUCT_CELL";
NSString *REVIEW_REVIEWVIEW_CELL = @"REVIEW_REVIEWVIEW_CELL";
NSString *REVIEW_SHORT_REVIEW_CELL = @"REVIEW_SHORT_REVIEW_CELL";
@interface SCProductReviewController ()
@end

@implementation SCProductReviewController

@synthesize tableViewReviewCollection, reviewCollection, reviewCount, product;

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
    [self setToSimiView];
    selectedStar = 0;
    if (tableViewReviewCollection == nil) {
        tableViewReviewCollection = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [tableViewReviewCollection setFrame:CGRectMake(0, 0, SCREEN_WIDTH *2/3, SCREEN_HEIGHT *2/3)];
        }
        tableViewReviewCollection.dataSource = self;
        tableViewReviewCollection.delegate = self;
        [self.view addSubview:tableViewReviewCollection];
    }
    __weak UITableView *tableView = tableViewReviewCollection;
    [tableView addInfiniteScrollingWithActionHandler:^{
        [self getReviews];
    }];
    [self setCells:nil];
    isFirstGet = YES;
    [self getReviews];
    [super viewDidLoadBefore];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppearAfter:(BOOL)animated{
    [tableViewReviewCollection deselectRowAtIndexPath:[tableViewReviewCollection indexPathForSelectedRow] animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self setTableViewReviewCollection:nil];
    [super viewDidDisappear:YES];
}

- (void)setCells:(NSMutableArray *)cells{
    if (cells) {
        _cells = cells;
    }else{
        _cells = [[NSMutableArray alloc] init];
        SimiSection *section = [[SimiSection alloc] init];
        for (int i = 0; i < 2; i++) {
            SimiRow *row = [[SimiRow alloc] init];
            switch (i) {
                case 0:{
                    row.identifier =REVIEW_PRODUCT_CELL;
                    row.height = [SimiGlobalVar scaleValue:40];
                }
                    break;
                case 1:{
                    row.identifier = REVIEW_REVIEWVIEW_CELL;
                    row.height = [SimiGlobalVar scaleValue:185];
                }
                    break;
                            }
            [section addRow:row];
        }
        if (self.reviewCollection.count > 0) {
            for (int i = 0; i < self.reviewCollection.count; i++) {
                SimiRow *row = [[SimiRow alloc] init];
                row.identifier = REVIEW_SHORT_REVIEW_CELL;
                row.height = [SimiGlobalVar scaleValue:115];
                [section addRow:row];
            }
        
        }
        [_cells addObject:section];
    }
    [tableViewReviewCollection reloadData];
}

- (void)getReviews{
    if (self.self.reviewCollection == nil) {
        self.reviewCollection = [[SimiReviewModelCollection alloc] init];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetReviewCollection:) name:@"DidGetReviewCollection" object:self.reviewCollection];
    
    [self.reviewCollection getReviewCollectionWithProductId:[self.product valueForKey:@"product_id"] star:@"0" offset:self.reviewCollection.count limit:6];
}

- (void)didGetReviewCollection:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if (responder.error) {
        NSLog(@"Error: %@", responder.responseMessage);
       
    }else{
        if ([noti.name isEqualToString:@"DidGetReviewCollection"]) {
            [self setCells:nil];
        }
        [self.tableViewReviewCollection reloadData];
    }
    [self.tableViewReviewCollection.infiniteScrollingView stopAnimating];
    [self removeObserverForNotification:noti];
}

#pragma mark Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _cells.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    SimiSection *simiSection = [_cells objectAtIndex:section];
    return simiSection.rows.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    return simiRow.height;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection objectAtIndex:indexPath.row];
    UITableViewCell *cell;
    if([simiRow.identifier isEqualToString:REVIEW_PRODUCT_CELL])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:simiRow.identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
            UILabel *nameProduct = [[UILabel alloc]initWithFrame:[SimiGlobalVar scaleFrame:CGRectMake(15, 0, 250, 40)]];
            nameProduct.text = [self.product valueForKey:@"product_name"];
            if([[SimiGlobalVar sharedInstance] isReverseLanguage]){
                [nameProduct setFrame:[SimiGlobalVar scaleFrame:CGRectMake(55, 0, 250, 40)]];
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                   [nameProduct setFrame:[SimiGlobalVar scaleFrame:CGRectMake(418, 0, 250, 40)]];
                }
                [nameProduct setTextAlignment:NSTextAlignmentRight];
            }
            [ nameProduct setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:[SimiGlobalVar scaleValue:18]]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell addSubview:nameProduct];
        }
    }else if([simiRow.identifier isEqualToString:REVIEW_REVIEWVIEW_CELL]){
        
        cell = [tableView dequeueReusableCellWithIdentifier:simiRow.identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
            SCProductReviewView *reviewView = [[SCProductReviewView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, [SimiGlobalVar scaleValue:160])];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                [reviewView setFrame:CGRectMake(0, 0, SCREEN_WIDTH *2/3, [SimiGlobalVar scaleValue:160])];
            }
            reviewView.backgroundColor = THEME_APP_BACKGROUND_COLOR;
            [reviewView setReviewType:SCLocalizedString(@"Customer Reviews")];
            [reviewView setRatePoint: [[self.product valueForKey:@"product_rate"] floatValue]];
            [reviewView setReviewNumber:[[self.product valueForKey:@"product_review_number"] integerValue]];
            NSString *fiveStar = [self.product valueForKey:@"5_star_number"];
            NSString *fourStar = [self.product valueForKey:@"4_star_number"];
            NSString *threeStar = [self.product valueForKey:@"3_star_number"];
            NSString *twoStar = [self.product valueForKey:@"2_star_number"];
            NSString *oneStar = [self.product valueForKey:@"1_star_number"];
            [reviewView setStarCollectionWithFiveStar:fiveStar fourStar:fourStar threeStar:threeStar twoStar:twoStar oneStar:oneStar];
            reviewView.userInteractionEnabled = NO;
            [cell addSubview:reviewView];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }else if ([simiRow.identifier isEqualToString:REVIEW_SHORT_REVIEW_CELL]){
        NSInteger row = [indexPath row] - 2;
        NSString *cellIdentifier = [NSString stringWithFormat:@"%@_%@",simiRow.identifier,[[self.reviewCollection objectAtIndex:row] valueForKey:@"review_id"]];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            SCProductReviewShortCell *cellShort = [[SCProductReviewShortCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            [cellShort setRatePoint:[[[self.reviewCollection objectAtIndex:row] valueForKey:@"rate_point"] floatValue]];
            [cellShort setReviewTitle:[[self.reviewCollection objectAtIndex:row] valueForKey:@"review_title"]];
            [cellShort setReviewBody:[[self.reviewCollection objectAtIndex:row] valueForKey:@"review_body"]];
            [cellShort setReviewTime:[[self.reviewCollection objectAtIndex:row] valueForKey:@"review_time"]];
            [cellShort setCustomerName:[[self.reviewCollection objectAtIndex:row] valueForKey:@"customer_name"]];
            [cellShort reArrangeLabelWithTitleLine:1 BodyLine:2];
            cell = cellShort;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath *)indexPath
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


#pragma mark Table View Delegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectReviewCellAtIndexPath" object:tableView userInfo:@{@"indexPath": indexPath}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    NSInteger row = [indexPath row];

    if ([simiRow.identifier isEqualToString:REVIEW_SHORT_REVIEW_CELL]) {
         row = row - 2;
        UIViewController *nextController = [[UIViewController alloc]init];
        nextController.title = [[self.reviewCollection objectAtIndex:row] valueForKey:@"review_title"];
        
        UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:nextController.view.bounds];
        
        SCProductReviewShortCell *reviewCell = [[SCProductReviewShortCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [reviewCell setFrame:scrollView.bounds];
        
        [reviewCell setRatePoint:[[[self.reviewCollection objectAtIndex:row] valueForKey:@"rate_point"] floatValue]];
        [reviewCell setReviewTitle:[[self.reviewCollection objectAtIndex:row] valueForKey:@"review_title"]];
        [reviewCell setReviewBody:[[self.reviewCollection objectAtIndex:row] valueForKey:@"review_body"]];
        [reviewCell setReviewTime:[[self.reviewCollection objectAtIndex:row] valueForKey:@"review_time"]];
        [reviewCell setCustomerName:[[self.reviewCollection objectAtIndex:row] valueForKey:@"customer_name"]];
        
        [reviewCell reArrangeLabelWithTitleLine:2 BodyLine:0];
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,  [reviewCell getActualCellHeight]);
        [scrollView addSubview:reviewCell];
        scrollView.backgroundColor = THEME_APP_BACKGROUND_COLOR;
        [nextController.view addSubview:scrollView];
    
        [self.delegate didSelectReviewDetail:nextController];
            
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Review Filter Delegate
- (void)didSelectedStar:(NSInteger)star{
    if (star > 5 || star < 0) {
        star = 0;
    }
    if (selectedStar != star) {
        isFirstGet = YES;
        selectedStar = star;
        [self.reviewCollection removeAllObjects];
        [self getReviews];
    }
}

@end
