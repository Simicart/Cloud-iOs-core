//
//  SCShippingViewController.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/20/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SCShippingViewController.h"
#import "SimiFormatter.h"

@interface SCShippingViewController ()

@end

@implementation SCShippingViewController

@synthesize methodCollection, tableViewShipping;

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
    self.title = [self formatTitleString:SCLocalizedString(@"Shipping Method")];
	self.tableViewShipping = [[SimiTableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableViewShipping.dataSource = self;
    self.tableViewShipping.delegate = self;
    [self.view addSubview:self.tableViewShipping];
    [super viewDidLoadBefore];
}

- (void)viewWillAppearAfter:(BOOL)animated
{
    [super viewWillAppearAfter:animated];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.tableViewShipping.frame = self.view.frame;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.methodCollection.count;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return SCLocalizedString(@"Select a shipping method");
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *shippingCell = @"ShippingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:shippingCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:shippingCell];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedShippingCell-Before" object:cell];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return cell;
    }
    cell.textLabel.text = [[self.methodCollection objectAtIndex:indexPath.row] valueForKey:@"s_method_title"];
    cell.textLabel.textColor = THEME_CONTENT_COLOR;
    NSString *methodName = [[self.methodCollection objectAtIndex:indexPath.row] valueForKey:@"s_method_title"];
    if (![methodName isKindOfClass:[NSNull class]]) {
        if (methodName.length > 0){
            cell.detailTextLabel.text = [[self.methodCollection objectAtIndex:indexPath.row] valueForKey:@"s_method_name"];
        }
    }
    UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width - 60, 0, 40, cell.frame.size.height)];
    priceLabel.backgroundColor = [UIColor clearColor];
    priceLabel.textColor = THEME_PRICE_COLOR;
    priceLabel.text = [[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%@",[[self.methodCollection objectAtIndex:indexPath.row] valueForKey:@"s_method_fee"]]];
    CGRect frame = priceLabel.frame;
    frame.origin.x = cell.frame.size.width - 30 - [priceLabel.text sizeWithFont:priceLabel.font].width;
    frame.size.width = [priceLabel.text sizeWithFont:priceLabel.font].width;
    priceLabel.frame = frame;
    [cell addSubview:priceLabel];
    if (indexPath.row == self.selectedMethodRow) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    //Gin edit
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        for (UIView *view in cell.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel*)view;
                [label setTextAlignment:NSTextAlignmentRight];
            }
        }
    }
    //End

    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedShippingCell-After" object:cell userInfo:@{@"indexPath": indexPath}];
    return cell;
}

#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectShippingCellAtIndexPath" object:tableView userInfo:@{@"indexPath": indexPath}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    [self.delegate didSelectShippingMethodAtIndex:indexPath.row];
    [self.navigationController popToViewController:(UIViewController *)self.delegate animated:YES];
}

@end
