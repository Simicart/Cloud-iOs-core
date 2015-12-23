//
//  SCThankYouPageViewController.m
//  SimiCartPluginFW
//
//  Created by Gin-Wishky on 9/28/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCThankYouPageViewController.h"
#import "SimiSection.h"
#import "SCOrderDetailViewController.h"
#import "SCOrderViewController.h"
NSString * THANK_YOU = @"THANK_YOU";
NSString * NUMBER = @"NUMBER";
NSString * DESCRIBLE = @"DESCRIBLE";
NSString * BUTTON = @"BUTTON";

@interface SCThankYouPageViewController ()

@end

@implementation SCThankYouPageViewController{
    float heightLabel ;
    float padding;
    float numberHeight;
    float heightTable;
    float oriYButton;
    float paddingButton;
    float heightButton;
}
@synthesize tableThank,btnContinue,number,des,isGuest;

- (void)viewDidLoadBefore {
    self.navigationItem.title = [self formatTitleString:SCLocalizedString(@"Thank You Page")];
    
    heightLabel = 60;
    padding = 15;
    paddingButton = [SimiGlobalVar scaleValue:65];
    heightButton = 44;
    des = @"You have placed an order successfully";
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        oriYButton = [SimiGlobalVar scaleValue:170];
    }else
        oriYButton = [SimiGlobalVar scaleValue:200];
   
    if (isGuest == NO) {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            heightTable = [SimiGlobalVar scaleValue:210];
        }else{
            heightTable =  [SimiGlobalVar scaleValue:192];
        }
    }else{
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            heightTable = [SimiGlobalVar scaleValue:170];
        }else{
            heightTable = [SimiGlobalVar scaleValue:150];
        }
    }
    
    tableThank = [[SimiTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH , heightTable) style:UITableViewStylePlain];
    tableThank.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    if (SIMI_SYSTEM_IOS >= 9.0) {
        tableThank.cellLayoutMarginsFollowReadableWidth = NO;
    }
    tableThank.dataSource = self;
    tableThank.delegate = self;
    [self.view addSubview:tableThank];
    
    [self setCells:nil];
    btnContinue = [[UIButton alloc] initWithFrame:CGRectMake(paddingButton,oriYButton, SCREEN_WIDTH - 2*paddingButton, heightButton)];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [btnContinue setFrame:CGRectMake(paddingButton,oriYButton , self.view.frame.size.width*2/3 - 2*paddingButton, heightButton)];
    }
    [btnContinue setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnContinue.titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:18]];
    [btnContinue setTitle:[SCLocalizedString(@"Continue Shopping") uppercaseString] forState:UIControlStateNormal];
    btnContinue.backgroundColor =THEME_COLOR;
    [btnContinue addTarget:self action:@selector(didContinueShopping) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnContinue];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewDidLoadBefore];
    }
}
- (void)viewWillAppearBefore:(BOOL)animated
{
    
}
-(void)setCells:(NSMutableArray *)cells{
    if (cells) {
        _cells = cells;
    }else{
        _cells = [[NSMutableArray alloc] init];
        SimiSection *section = [[SimiSection alloc] init];
        
        SimiRow *row1 = [[SimiRow alloc] init];
        row1.identifier = THANK_YOU;
        row1.height = [SimiGlobalVar scaleValue:44];
        [section addRow:row1];
        
        SimiRow *row3 = [[SimiRow alloc] init];
        row3.identifier = DESCRIBLE;
        row3.height = [SimiGlobalVar scaleValue:60];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            row3.height = 44;
        };
        [section addRow:row3];
        
        if (isGuest != YES ) {
            SimiRow *row2 = [[SimiRow alloc] init];
            row2.identifier = NUMBER;
            row2.height = [SimiGlobalVar scaleValue:44];
            [section addRow:row2];
        }

        [_cells addObject:section];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:simiRow.identifier];
    if ([simiRow.identifier isEqualToString:THANK_YOU]){
        if (cell == nil) {
            cell = [tableView dequeueReusableCellWithIdentifier:simiRow.identifier];
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel *lbThank = [[UILabel alloc]initWithFrame:CGRectMake(padding, 0, SCREEN_WIDTH - 20, heightLabel)];
            lbThank.text = SCLocalizedString(@"Thank you for your purchase");
            lbThank.textColor = COLOR_WITH_HEX(@"#aa2929");
            [lbThank setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
            [cell addSubview:lbThank];
            }
    }else if ([simiRow.identifier isEqualToString:NUMBER]){
        if (cell == nil) {
            cell = [tableView dequeueReusableCellWithIdentifier:simiRow.identifier];
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel *lbNumber = [[UILabel alloc]initWithFrame:CGRectMake(padding, 0, SCREEN_WIDTH - 20, heightLabel)];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            lbNumber.text = [NSString stringWithFormat:@"%@: #%@",SCLocalizedString(@"View detail of your order"),[self.order valueForKey:@"_id"]];
            [lbNumber setFont:[UIFont fontWithName:THEME_FONT_NAME size:15]];
            [cell addSubview:lbNumber];
        }
    }else if ([simiRow.identifier isEqualToString:DESCRIBLE]){
        if (cell == nil) {
            cell = [tableView dequeueReusableCellWithIdentifier:simiRow.identifier];
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel *lbDes = [[UILabel alloc]initWithFrame:CGRectMake(padding, 0, SCREEN_WIDTH - 20, heightLabel)];
            lbDes.text = [NSString stringWithFormat:@"%@!",SCLocalizedString(des)];
            lbDes.numberOfLines = 3.0f;
            [lbDes setFont:[UIFont fontWithName:THEME_FONT_NAME size:15]];
            [cell addSubview:lbDes];
        }
    }
    return cell;
}
-(void)didContinueShopping{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [_popOver dismissPopoverAnimated:YES];
    }else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    if([simiRow.identifier isEqualToString:NUMBER]){
        SCOrderDetailViewController *placeOderNumber = [[SCOrderDetailViewController alloc] init];
        placeOderNumber.orderId = [self.order valueForKey:@"_id"];
        placeOderNumber.order = self.order;
        [self.navigationController pushViewController:placeOderNumber animated:YES];
    }
}
@end
