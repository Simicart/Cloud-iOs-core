//
//  RefineViewController.m
//  SimiCart
//
//  Created by Tan on 7/31/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import "SCRefineViewController.h"
#import "SCProductListViewController.h"

@interface SCRefineViewController ()

@end

@implementation SCRefineViewController

@synthesize tableViewRefine, sortType, sortTypeLabels;

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
    self.preferredContentSize = CGSizeMake(SCREEN_WIDTH/3, SCREEN_HEIGHT/2);
    [self setToSimiView];
    self.navigationItem.title = [self formatTitleString:SCLocalizedString(@"Refine")];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:SCLocalizedString(@"Cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonClicked:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    sortTypeLabels = [[NSMutableArray alloc]initWithObjects:SCLocalizedString(@"None"), SCLocalizedString(@"Price: Low to High"), SCLocalizedString(@"Price: High to Low"), SCLocalizedString(@"Name: A -> Z"), SCLocalizedString(@"Name: Z -> A"), nil];
    if (tableViewRefine == nil) {
        tableViewRefine = [[SimiTableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
        tableViewRefine.dataSource = self;
        tableViewRefine.delegate = self;
        tableViewRefine.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        [self.view addSubview:tableViewRefine];
    }
    [super viewDidLoadBefore];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)popPreviousController{
    [UIView beginAnimations:@"View Flip" context:nil];
    [UIView setAnimationDuration: 0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
    [UIView commitAnimations];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)cancelButtonClicked:(id)sender{
    [self popPreviousController];
}

- (void)getDepartmentList{
}

#pragma mark Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    int count = 0;
    if (sortTypeLabels.count > 0) {
        count++;
    }
    return count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return sortTypeLabels.count;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return SCLocalizedString(@"Sort By");;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        UIView *view = [UIView new];
        UILabel *labelHeader = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, CGRectGetWidth(tableView.frame) - 30 , 44)];
        [labelHeader setTextAlignment:NSTextAlignmentRight];
        [labelHeader setTextColor:THEME_LIGHT_TEXT_COLOR];
        [labelHeader setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2]];
        [labelHeader setText:[SCLocalizedString(@"Sort By") uppercaseString]];
        [view addSubview:labelHeader];
        return view;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RefineCell"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedRefineCell-Before" object:cell];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return cell;
    }
    cell.textLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:14];
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        [cell.textLabel setTextAlignment:NSTextAlignmentRight];
        CGRect frame = cell.accessoryView.frame;
        frame.origin.x = 0;
        [cell.accessoryView setFrame:frame];
    }
    cell.textLabel.text = [sortTypeLabels objectAtIndex:indexPath.row];
    if (indexPath.row == sortType) {
        chosenSortOptionIndexPath = indexPath;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedRefineCell-After" object:cell userInfo:@{@"indexPath": indexPath}];
    return cell;
}

#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectRefineCellAtIndexPath" object:tableView userInfo:@{@"indexPath": indexPath}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    NSString *sortOptionValue;
    if (chosenSortOptionIndexPath != nil) {
        cell = [tableView cellForRowAtIndexPath:chosenSortOptionIndexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    chosenSortOptionIndexPath = indexPath;
    cell = [tableView cellForRowAtIndexPath:chosenSortOptionIndexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    sortType = indexPath.row;
    cell = [tableView cellForRowAtIndexPath:chosenSortOptionIndexPath];
    sortOptionValue = [cell.textLabel.text copy];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.delegate didRefineWithSortType:sortType];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self popPreviousController];
    }
}
@end
