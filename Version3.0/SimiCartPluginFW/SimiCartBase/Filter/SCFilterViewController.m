//
//  SCFilterViewController.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 3/13/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCFilterViewController.h"
@interface SCFilterViewController ()

@end

@implementation SCFilterViewController
@synthesize filterContent, filterTableView, arrActivedFilter, arrSelectFilter;
@synthesize attributeSelected, arrFilterLabel, arrFilterValue, delegate, paramFilter;


- (void)viewDidLoadAfter
{
    [self setToSimiView];
    self.navigationItem.title = [self formatTitleString:SCLocalizedString(@"Filter")];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:SCLocalizedString(@"Cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonClicked:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    filterTableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    // Liam Update RTL
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            filterTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*2/3, CGRectGetHeight(self.view.frame)) style:UITableViewStyleGrouped];
        }
    }
    // End RTL
    filterTableView.delegate = self;
    filterTableView.dataSource = self;
    [self.view addSubview:filterTableView];
}

- (void)viewWillAppearAfter:(BOOL)animated
{
    [self setCells:nil];
    [filterTableView reloadData];
}

- (void)viewDidAppearBefore:(BOOL)animated
{
    if (SIMI_SYSTEM_IOS >= 9 && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [filterTableView setFrame:CGRectMake(0, 0, SCREEN_WIDTH*2/3, CGRectGetHeight(self.view.frame))];
    }
}

- (void)popPreviousController{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {        
        [UIView beginAnimations:@"View Flip" context:nil];
        [UIView setAnimationDuration: 0.5];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
        [UIView commitAnimations];
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (void)cancelButtonClicked:(id)sender{
    [self popPreviousController];
}

- (void)setCells:(SimiTable *)cells
{
    if (cells) {
        _cells = cells;
    }else
    {
        _cells = [SimiTable new];
        arrActivedFilter = [NSMutableArray new];
        arrSelectFilter = [NSMutableArray new];
        paramFilter = [NSMutableDictionary new];
        if ([filterContent valueForKey:@"layer_state"]) {
            arrActivedFilter = (NSMutableArray*)[filterContent valueForKey:@"layer_state"];
        }
        if([filterContent valueForKey:@"layer_filter"]){
            arrSelectFilter = (NSMutableArray*)[filterContent valueForKey:@"layer_filter"];
        }
        if (arrActivedFilter.count > 0) {
            SimiSection *section01 = [[SimiSection alloc]initWithIdentifier:FILTER_SECTION_ACTIVED];
            section01.headerTitle = SCLocalizedString(@"Activated");
            for (int i = 0; i < arrActivedFilter.count; i++) {
                NSDictionary *dictActiveUnit = (NSDictionary*)[arrActivedFilter objectAtIndex:i];
                SimiRow *row = [SimiRow new];
                row.title = [NSString stringWithFormat:@"%@(%@)",[dictActiveUnit valueForKey:@"title"],[dictActiveUnit valueForKey:@"label"]];
                row.accessoryType = UITableViewCellAccessoryNone;
                [section01 addObject:row];
                [paramFilter setObject:[dictActiveUnit valueForKey:@"value"] forKey:[dictActiveUnit valueForKey:@"attribute"]];
                
            }
            [_cells addObject:section01];
            
        }
        
        if (arrSelectFilter.count > 0) {
            SimiSection *section02 = [[SimiSection alloc]initWithIdentifier:FILTER_SECTION_SELECTED];
            section02.headerTitle = SCLocalizedString(@"Select a filter");
            for (int i = 0; i < arrSelectFilter.count; i++) {
                SimiRow *row = [SimiRow new];
                row.title = [(NSMutableDictionary*)[arrSelectFilter objectAtIndex:i] valueForKey:@"title"];
                [section02 addObject:row];
                row.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            [_cells addObject:section02];
        }
    }
}

#pragma mark TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _cells.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SimiSection *simiSection = (SimiSection*)[_cells objectAtIndex:section];
    return [simiSection count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        return 44;
    }
    return 50;
}

// Liam Update RTL
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    SimiSection *simiSection = [_cells objectAtIndex:section];
    return simiSection.headerTitle;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        SimiSection *simiSection = [_cells objectAtIndex:section];
        UIView *view = [UIView new];
        UILabel *lblHeader = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, CGRectGetWidth(tableView.frame) - 20, 44)];
        [lblHeader setText:[simiSection.headerTitle uppercaseString]];
        [lblHeader setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2]];
        [lblHeader setTextColor:THEME_LIGHT_TEXT_COLOR];
        [lblHeader setTextAlignment:NSTextAlignmentRight];
        [view addSubview:lblHeader];
        return view;
    }
    return nil;
}
// End RTL

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *row = [simiSection objectAtIndex:indexPath.row];
    if ([simiSection.identifier isEqualToString:FILTER_SECTION_SELECTED]) {
        cell = [tableView dequeueReusableCellWithIdentifier:row.title];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.title];
            [cell.textLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:14]];
            cell.textLabel.text = row.title;
            cell.accessoryType = row.accessoryType;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //  Liam Update RTL
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                [cell.textLabel setTextAlignment:NSTextAlignmentRight];
            }
            //  End RTL
        }
    }
    if ([simiSection.identifier isEqualToString:FILTER_SECTION_ACTIVED]) {
        cell = [tableView dequeueReusableCellWithIdentifier:row.title];
        if (cell == nil) {
            NSDictionary *activedUnit = (NSDictionary*)[arrActivedFilter objectAtIndex:indexPath.row];
            cell = [[SCFilterTableViewCell alloc]initWithAttributeTitle:[activedUnit valueForKey:@"title"] attributeValue:[activedUnit valueForKey:@"label"] attributeName:[activedUnit valueForKey:@"attribute"]];
            ((SCFilterTableViewCell*)cell).delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    if (cell == nil) {
        cell = [UITableViewCell new];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    SimiSection *simiSection = [_cells objectAtIndex:section];
    if ([simiSection.identifier isEqualToString:FILTER_SECTION_ACTIVED]) {
        return 60;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    SimiSection *simiSection = [_cells objectAtIndex:section];
    if ([simiSection.identifier isEqualToString:FILTER_SECTION_ACTIVED]) {
        UIView *viewFooter = [[UIView alloc]initWithFrame:CGRectMake(0, 0, filterTableView.frame.size.width, 60)];
        [viewFooter setBackgroundColor:[UIColor clearColor]];
        
        UIButton *btnClearAll = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnClearAll.layer.borderWidth = 0.5;
        btnClearAll.layer.borderColor = [UIColor colorWithRed:183.0/255 green:183.0/255 blue:183.0/255 alpha:1.0].CGColor;
        btnClearAll.layer.cornerRadius = 5;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [btnClearAll setFrame:CGRectMake(viewFooter.frame.size.width/2, 10, 64, 24)];
            [btnClearAll.titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE - 6]];
        }else
        {
            [btnClearAll setFrame:CGRectMake(CGRectGetWidth(viewFooter.frame)/2, 10, 100, 40)];
            [btnClearAll.titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE - 2]];
        }
        [btnClearAll setTitle:SCLocalizedString(@"Clear All") forState:UIControlStateNormal];
        [btnClearAll setTitleColor:THEME_CONTENT_COLOR forState:UIControlStateNormal];
        [btnClearAll setBackgroundColor:THEME_APP_BACKGROUND_COLOR];
        [btnClearAll addTarget:self action:@selector(clearAll) forControlEvents:UIControlEventTouchUpInside];
        [viewFooter addSubview:btnClearAll];
        return viewFooter;
    }
    return nil;
}

- (void)clearAll
{
    [paramFilter removeAllObjects];
    [self popPreviousController];
    [self.delegate filterWithParam:paramFilter];
}

#pragma  UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    UITableViewCell *cell = [filterTableView cellForRowAtIndexPath:indexPath];
    if ([simiSection.identifier isEqualToString:FILTER_SECTION_SELECTED]) {
        attributeSelected = (NSDictionary*)[arrSelectFilter objectAtIndex:indexPath.row];
        NSMutableArray *arrFilter = [attributeSelected valueForKey:@"filter"];
        arrFilterValue = [NSMutableArray new];
        arrFilterLabel = [NSMutableArray new];
        for (int i = 0; i < arrFilter.count; i++) {
            NSDictionary *filterUnit = (NSDictionary*)[arrFilter objectAtIndex:i];
            [arrFilterValue addObject:[filterUnit objectForKey:@"value"]];
            [arrFilterLabel addObject:[filterUnit objectForKey:@"label"]];
        }
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            ActionSheetStringPicker *stringPicket = [[ActionSheetStringPicker alloc]initWithTitle:@"" rows:arrFilterLabel initialSelection:0 target:self successAction:@selector(didSelectValue:element:) cancelAction:@selector(cancelActionSheet:) origin:self.view];
            [stringPicket showActionSheetPicker];
        }else
        {
            ActionSheetStringPicker *stringPicket = [[ActionSheetStringPicker alloc]initWithTitle:@"" rows:arrFilterLabel initialSelection:0 target:self successAction:@selector(didSelectValue:element:) cancelAction:@selector(cancelActionSheet:) origin:cell];
            [stringPicket showActionSheetPicker];
        }
    }

}

- (void)didSelectValue:(NSNumber *)selectedIndex element:(id)element
{
    NSLog(@"%d",[selectedIndex intValue]);
    [paramFilter setObject:[arrFilterValue objectAtIndex:[selectedIndex intValue]] forKey:[attributeSelected valueForKey:@"attribute"]];
    [self popPreviousController];
    [self.delegate filterWithParam:paramFilter];
}

- (void)cancelActionSheet:(id)sender
{
    
}

- (void)didSelectAttributeDeletete:(NSString *)attributeName
{
    [paramFilter removeObjectForKey:attributeName];
    [self popPreviousController];
    [self.delegate filterWithParam:paramFilter];
}
@end

@implementation SCFilterTableViewCell
@synthesize lblAttributeName, lblAttributeValue, btnDeleteAttribute, delegate;
- (instancetype)initWithAttributeTitle:(NSString*)title attributeValue:(NSString*)value attributeName:(NSString *)attribute
{
    self = [super init];
    if (self) {
        lblAttributeName = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 100, self.frame.size.height)];
        [lblAttributeName setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
        lblAttributeName.text = title;
        lblAttributeName.textAlignment = NSTextAlignmentLeft;
        CGSize textSize = [[lblAttributeName text] sizeWithAttributes:@{NSFontAttributeName:[lblAttributeName font]}];
        CGFloat strikeWidth = textSize.width;
        CGRect frame = lblAttributeName.frame;
        frame.size.width = strikeWidth;
        [lblAttributeName setFrame:frame];
        [self addSubview:lblAttributeName];
        
        lblAttributeValue = [[UILabel alloc]initWithFrame:CGRectMake(frame.origin.x + frame.size.width, 0, 100, self.frame.size.height)];
        [lblAttributeValue setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 4]];
        lblAttributeValue.text = [NSString stringWithFormat:@" (%@)",value];
        lblAttributeValue.textAlignment = NSTextAlignmentLeft;
        textSize = [[lblAttributeValue text] sizeWithAttributes:@{NSFontAttributeName:[lblAttributeValue font]}];
        strikeWidth = textSize.width;
        frame = lblAttributeValue.frame;
        frame.size.width = strikeWidth;
        [lblAttributeValue setFrame:frame];
        [self addSubview:lblAttributeValue];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            btnDeleteAttribute = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 64, 0, 64, CGRectGetHeight(self.frame))];
        }else
        {
            btnDeleteAttribute = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH*2/3 - 64, 0, 64, CGRectGetHeight(self.frame))];
        }
        btnDeleteAttribute.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [btnDeleteAttribute setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [btnDeleteAttribute setImageEdgeInsets:UIEdgeInsetsMake(10, 20, 10, 20)];
        [btnDeleteAttribute setBackgroundColor:[UIColor clearColor]];
        [btnDeleteAttribute addTarget:self action:@selector(touchButtonDelete:) forControlEvents:UIControlEventTouchUpInside];
        btnDeleteAttribute.simiObjectIdentifier = attribute;
        [self addSubview:btnDeleteAttribute];
        // Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            CGRect frame = lblAttributeName.frame;
            frame.origin.x = CGRectGetWidth(self.frame) - 10 - frame.size.width;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                frame.origin.x = SCREEN_WIDTH*2/3 - 10 - frame.size.width;
            }
            [lblAttributeName setFrame:frame];
            
            CGRect frame2 = lblAttributeValue.frame;
            frame2.origin.x = frame.origin.x - frame2.size.width;
            [lblAttributeValue setFrame:frame2];
            
            [btnDeleteAttribute setFrame:CGRectMake(0, 0, 64, CGRectGetHeight(self.frame))];
        }
        //  End RTL
    }
    return self;
}

- (void)touchButtonDelete:(id)sender
{
    UIButton *deleteButton = (UIButton*)sender;
    [self.delegate didSelectAttributeDeletete:(NSString*)deleteButton.simiObjectIdentifier];
}

@end
