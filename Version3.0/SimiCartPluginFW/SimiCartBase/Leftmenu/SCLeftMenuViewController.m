//
//  SCLeftMenuPhoneViewController.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/4/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCLeftMenuViewController.h"
#import "UIImageView+WebCache.h"
#import "UIImage+SimiCustom.h"

#pragma mark LeftMenu Controller
@interface SCLeftMenuViewController ()

@end

static NSString *TABLE_MENU = @"TABLE_MENU";
static NSString *TABLE_LOGIN = @"TABLE_LOGIN";
@implementation SCLeftMenuViewController
#pragma mark Init Method
- (void)viewDidLoadBefore
{
    tableWidth = (SCREEN_WIDTH*4)/5;
    
    _tableViewLogin = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, tableWidth, 1) style:UITableViewStylePlain];
    _tableViewLogin.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    _tableViewLogin.dataSource = self;
    _tableViewLogin.delegate = self;
    _tableViewLogin.separatorColor = THEME_MENU_LINE_COLOR;
    _tableViewLogin.backgroundColor = THEME_MENU_BACKGROUND_COLOR;
    _tableViewLogin.simiObjectName = TABLE_LOGIN;
    _tableViewLogin.scrollEnabled = NO;
    [_tableViewLogin setShowsVerticalScrollIndicator:NO];
    
    _tableViewMenu = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, tableWidth, 1) style:UITableViewStyleGrouped];
    _tableViewMenu.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
    _tableViewMenu.delegate = self;
    _tableViewMenu.dataSource = self;
    _tableViewMenu.separatorColor = THEME_MENU_LINE_COLOR;
    _tableViewMenu.backgroundColor = THEME_MENU_BACKGROUND_COLOR;
    _tableViewMenu.simiObjectName = TABLE_MENU;
    
    self.view.backgroundColor = _tableViewMenu.backgroundColor;
    [_tableViewMenu setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:_tableViewLogin];
    [self.view addSubview:_tableViewMenu];
    [self setCells:nil];
    [self getCMSPages];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationWillResignActive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetStoreCollection" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoginOrLogout:) name:@"DidLogin" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoginOrLogout:) name:@"DidLogout" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DidChangeUserInfo object:nil];
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    
}

- (void)setCells:(SimiTable *)cells
{
    float rowHeight = 50;
    if (cells != nil) {
        _cells = cells;
    }else
    {
        _cells = [SimiTable new];
        SimiSection *section1 = [[SimiSection alloc]initWithIdentifier:LEFTMENU_SECTION_MAIN];
        
        SimiRow *row10 = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_HOME height:rowHeight sortOrder:100];
        row10.image = [UIImage imageNamed:@"ic_home"];
        row10.title = SCLocalizedString(@"Home");
        [section1 addRow:row10];
       
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            SimiRow *row11 = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_CATEGORY height:rowHeight sortOrder:200];
            row11.image = [UIImage imageNamed:@"ic_category"];
            row11.title = SCLocalizedString(@"Category");
            [section1 addRow:row11];
        }
        
        if ([[SimiGlobalVar sharedInstance]isLogin]) {
            SimiRow *row12 = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_ORDERHISTORY height:rowHeight sortOrder:300];
            row12.image = [UIImage imageNamed:@"ic_orderhistory"];
            row12.title = SCLocalizedString(@"Order History");
            [section1 addObject:row12];
        }
        
        SimiRow *row13 = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_SETTING height:rowHeight sortOrder:10000];
        row13.image = [UIImage imageNamed:@"ic_setting"];
        row13.title = SCLocalizedString(@"Setting");
        row13.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [section1 addObject:row13];
        
        [_cells addObject:section1];
        
        SimiSection *section2 = [[SimiSection alloc]initWithIdentifier:LEFTMENU_SECTION_MORE];
        section2.headerTitle = [SCLocalizedString(@"More")uppercaseString];
        if (_cmsPages.count > 0) {
            for (int i = 0; i < _cmsPages.count; i++) {
                SimiRow *row20 = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_CMS height:rowHeight sortOrder:400];
                row20.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                row20.data = [_cmsPages objectAtIndex:i];
                row20.title = [row20.data valueForKey:@"title"];
                [section2 addObject:row20];
            }
        }
        
        SimiRow *row21 = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_SETTING height:rowHeight sortOrder:10000];
        row21.image = [UIImage imageNamed:@"ic_setting"];
        row21.title = SCLocalizedString(@"Setting");
        row21.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [section2 addObject:row21];
        [_cells addObject:section2];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SCLeftMenu_InitCellsAfter" object:self.cells];
    [self.tableViewMenu reloadData];
    [self.tableViewLogin reloadData];
}
#pragma mark Get CMS Pages
- (void)getCMSPages{
    _cmsPages = [[SimiCMSPagesModelCollection alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DidGetCMSPages object:_cmsPages];
    [_cmsPages getCMSPagesWithParams:@{}];
}

- (void)didReceiveNotification:(NSNotification *)noti
{
    SimiResponder *responder = (SimiResponder *)[noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        if ([noti.name isEqualToString:DidGetCMSPages]) {
            [self removeObserverForNotification:noti];
            [self setCells:nil];
        }else if([noti.name isEqualToString:DidChangeUserInfo]){
            [self setCells:nil];
        }
    }
}

- (void)didLoginOrLogout:(NSNotification *)noti
{
    [self setCells:nil];
}

#pragma mark Table DataSource & Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimiSection *section = [_cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    SCLeftMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:row.identifier];
    if ([tableView.simiObjectName isEqualToString:TABLE_MENU]) {
        if (cell == nil) {
            cell = [[SCLeftMenuCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier rowHeight:row.height];
            if (row.image) {
//                [cell.rowIcon setImage:row.image];
                cell.rowIcon.image = [row.image imageWithColor:THEME_MENU_ICON_COLOR];
            }else if(row.data)
            {
                if ([[row.data valueForKey:@"icon"] isKindOfClass:[NSString class]]) {
                    [cell.rowIcon sd_setImageWithURL:[NSURL URLWithString:[row.data valueForKey:@"icon"]]];
                }
            }
            cell.accessoryType = row.accessoryType;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.rowName setText:row.title];
            [cell setBackgroundColor:[UIColor clearColor]];
        }
        return cell;
    }else if ([tableView.simiObjectName isEqualToString:TABLE_LOGIN])
    {
        SCLeftMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:LEFTMENU_ROW_LOGIN];
        if (cell == nil) {
            cell = [[SCLeftMenuCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LEFTMENU_ROW_LOGIN rowHeight:44];
//            [cell.rowIcon setImage:[UIImage imageNamed:@"ic_login"]];
            [cell.rowIcon setImage:[[UIImage imageNamed:@"ic_login"] imageWithColor:THEME_MENU_ICON_COLOR]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [cell setBackgroundColor:[UIColor clearColor]];
        }
        if ([[SimiGlobalVar sharedInstance]isLogin]) {
            [cell.rowName setText:[[[SimiGlobalVar sharedInstance] customer] valueForKey:@"name"]];
        }else
            [cell.rowName setText:SCLocalizedString(@"Login")];
        return cell;
    }
    if (cell == nil) {
        cell = [SCLeftMenuCell new];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    SCLeftMenuCell *cell = (SCLeftMenuCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell setBackgroundColor:[[SimiGlobalVar sharedInstance]colorWithHexString:@"#ffffff" alpha:0.05]];
    return YES;
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    SCLeftMenuCell *cell = (SCLeftMenuCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView.simiObjectName isEqualToString:TABLE_MENU]) {
        SimiSection *simiSection = [_cells objectAtIndex:section];
        SimiSection *section02 = [_cells getSectionByIdentifier:LEFTMENU_SECTION_MORE];
        if (section02.count > 1) {
            SimiSection *section01 = [_cells getSectionByIdentifier:LEFTMENU_SECTION_MAIN];
            [section01 removeRowByIdentifier:LEFTMENU_ROW_SETTING];
        }else
        {
            [section02 removeRowByIdentifier:LEFTMENU_ROW_SETTING];
        }
        return simiSection.count;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView.simiObjectName isEqualToString:TABLE_MENU]) {
        SimiSection *section = [_cells objectAtIndex:indexPath.section];
        SimiRow *row = [section objectAtIndex:indexPath.row];
        return row.height;
    }
    return 43;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([tableView.simiObjectName isEqualToString:TABLE_MENU]) {
        SimiSection *simiSection = [_cells objectAtIndex:section];
        if ([simiSection.identifier isEqualToString:LEFTMENU_SECTION_MAIN]) {
            return 0.001f;
        }else if ([simiSection.identifier isEqualToString:LEFTMENU_SECTION_MORE])
        {
            if (simiSection.count > 0) {
                return 30;
            }else
                return 0;
        }
        if (![simiSection.headerTitle isEqualToString:@""]) {
            return 30;
        }
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([tableView.simiObjectName isEqualToString:TABLE_MENU]) {
        SimiSection *simiSection = [_cells objectAtIndex:section];
        float iconOrigionX = 20;
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH *4/5, 30)];
        [view setBackgroundColor:[[SimiGlobalVar sharedInstance]colorWithHexString:@"#000000" alpha:0.3]];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(iconOrigionX, 0, CGRectGetWidth(view.frame) - iconOrigionX, CGRectGetHeight(view.frame))];
        [label setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:15]];
        [label setTextColor:THEME_MENU_TEXT_COLOR];
        [label setBackgroundColor:[UIColor clearColor]];
        //Gin edit
        if([[SimiGlobalVar sharedInstance] isReverseLanguage]){
            [label setTextAlignment:NSTextAlignmentRight];
            [label setFrame:CGRectMake(SCREEN_WIDTH *4/5 - CGRectGetWidth(view.frame) - iconOrigionX, 0, CGRectGetWidth(view.frame) - iconOrigionX, CGRectGetHeight(view.frame))];
        }
        //end
        [view addSubview:label];
        
        if ([simiSection.identifier isEqualToString:LEFTMENU_SECTION_MAIN]) {
            return [[UIView alloc]initWithFrame:CGRectZero];
        }else if ([simiSection.identifier isEqualToString:LEFTMENU_SECTION_MORE])
        {
            if (simiSection.count > 0) {
                [label setText:simiSection.headerTitle];
                return view;
            }else
                return [[UIView alloc]initWithFrame:CGRectZero];;
                
        }
        if (![simiSection.headerTitle isEqualToString:@""]) {
            return view;
        }
    }
    return [[UIView alloc]initWithFrame:CGRectZero];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc]initWithFrame:CGRectZero];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([tableView.simiObjectName isEqualToString:TABLE_MENU]) {
        return _cells.count;
    }
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView.simiObjectName isEqualToString:TABLE_MENU]) {
        SimiSection *section = [_cells objectAtIndex:indexPath.section];
        SimiRow *row = [section objectAtIndex:indexPath.row];
        [self.delegate menu:self didSelectRow:row withIndexPath:indexPath];
    }else if([tableView.simiObjectName isEqualToString:TABLE_LOGIN])
    {
        [self.delegate didSelectLoginRow];
    }
    [self didClickHide];
}

#pragma mark Show and Hide LeftMenu
- (void)didClickShow
{
    CGRect frame = self.view.frame;
    frame.size.height = SCREEN_HEIGHT;
    self.view.frame = frame;
    
    frame = self.tableViewLogin.frame;
    frame.size.height = 64;
    self.tableViewLogin.frame = frame;
    
    frame = self.tableViewMenu.frame;
    frame.size.height = SCREEN_HEIGHT - 64;
    self.tableViewMenu.frame = frame;
    [self.delegate menu:self didClickShowButonWithShow:YES];
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect frame = self.view.frame;
                         frame.origin.x += SCREEN_WIDTH *4/5;
                         self.view.frame = frame;
                         self.view.layer.shadowOffset = CGSizeMake(1, 1);
                         self.view.layer.shadowRadius = 10.0;
                         self.view.layer.shadowOpacity = 1;
                         self.view.layer.masksToBounds = NO;
                     }
                     completion:^(BOOL finished) {
                        
                     }];
}

- (void)didClickHide
{
    [self.delegate menu:self didClickShowButonWithShow:NO];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         CGRect frame = self.view.frame;
                         frame.origin.x -= SCREEN_WIDTH *4/5;
                         self.view.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         self.view.layer.shadowOffset = CGSizeMake(0, 0);
                         self.view.layer.shadowRadius = 0;
                         self.view.layer.shadowOpacity = 0;
                         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                     }];
}
@end

#pragma mark Left Menu Cell
@implementation SCLeftMenuCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier rowHeight:(CGFloat)rowHeight
{
    
    float iconSize = 20;
    float iconOrigionX = 20;
    float distanceIconandName = 25;
    float fontSize = 14;
    //gin end
    if ([[SimiGlobalVar sharedInstance] isReverseLanguage]) {
         if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
             iconOrigionX = SCREEN_WIDTH *4/5 - 40- iconSize;
         }else{
             iconOrigionX = [SimiGlobalVar scaleValue:328] - 40- iconSize;
         }
    }
    //end
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    _rowIcon = [[UIImageView alloc]initWithFrame:CGRectMake(iconOrigionX, (rowHeight - iconSize)/2, iconSize, iconSize)];
    [self addSubview:_rowIcon];
    
    CGRect rowNameFrame = CGRectZero;
    rowNameFrame.origin.x = iconOrigionX + iconSize + distanceIconandName;
    rowNameFrame.origin.y = (rowHeight - iconSize)/2;
    rowNameFrame.size.width = SCREEN_WIDTH *4/5 - rowNameFrame.origin.x - 30;
    //gin edit
    if ([[SimiGlobalVar sharedInstance] isReverseLanguage]) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            rowNameFrame.size.width = SCREEN_WIDTH *4/5 - iconSize - distanceIconandName - 30;
            rowNameFrame.origin.x  = iconOrigionX - iconSize - rowNameFrame.size.width;
        }else{
            rowNameFrame.size.width = [SimiGlobalVar scaleValue:328] - iconSize - distanceIconandName - 30;
            rowNameFrame.origin.x  = iconOrigionX - iconSize - rowNameFrame.size.width;
        }
    }
    //end
    rowNameFrame.size.height = iconSize;
    _rowName = [[UILabel alloc]initWithFrame:rowNameFrame];
    //gin edit
    if ([[SimiGlobalVar sharedInstance] isReverseLanguage]) {
        [_rowName setTextAlignment:NSTextAlignmentRight];
    }
    //end
    _rowName.textColor = THEME_MENU_TEXT_COLOR;
    [_rowName setFont:[UIFont fontWithName:THEME_FONT_NAME size:fontSize]];
    [self addSubview:_rowName];
    return self;
}
@end
