//
//  SCLeftMenuPhoneViewController.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/4/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCLeftMenuViewControllerPad.h"


static NSString *TABLE_MENU = @"TABLE_MENU";
static NSString *TABLE_LOGIN = @"TABLE_LOGIN";

static CGFloat LOGIN_BUTTON_HEIGHT = 50;
static CGFloat MENU_WIDTH = 328;

@implementation SCLeftMenuViewControllerPad

@synthesize categoryViewController, leftMenuPageScrollView, menuView;

- (void)viewDidLoadBefore
{
    tableWidth = MENU_WIDTH;
    
    //Menu
    self.tableViewLogin = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, tableWidth, 1) style:UITableViewStylePlain];
    self.tableViewLogin.contentInset = UIEdgeInsetsMake(3, 0, 0, 0);
    self.tableViewLogin.dataSource = self;
    self.tableViewLogin.delegate = self;
    self.tableViewLogin.separatorColor = THEME_MENU_LINE_COLOR;
    self.tableViewLogin.simiObjectName = TABLE_LOGIN;
    [self.tableViewLogin setBackgroundColor:[UIColor clearColor]];
    [self.tableViewLogin setShowsVerticalScrollIndicator:NO];
    [self.tableViewLogin setScrollEnabled:NO];
     
    self.tableViewMenu = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, tableWidth, 1) style:UITableViewStyleGrouped];
    self.tableViewMenu.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableViewMenu.delegate = self;
    self.tableViewMenu.dataSource = self;
    self.tableViewMenu.separatorColor = THEME_MENU_LINE_COLOR;
    self.tableViewMenu.simiObjectName = TABLE_MENU;
    self.view.backgroundColor = self.tableViewMenu.backgroundColor;
    [self.tableViewMenu setBackgroundColor:[UIColor clearColor]];
    [self.tableViewMenu setShowsVerticalScrollIndicator:NO];
    
    //Category
    categoryViewController = [SCCategoryViewControllerPad new];
    categoryViewController.delegate = self;
    [categoryViewController.view setFrame:CGRectMake(0 , 0, tableWidth, SCREEN_HEIGHT - 65)];
    
    /*
    Left Menu ScrollView
    */
    
    //string and gap calculating
    NSString *menuString = [SCLocalizedString(@"Menu") uppercaseString];
    NSString *categoryString = [SCLocalizedString(@"Category") uppercaseString];
    CGFloat menuTitleWidth=[menuString sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:20]}].width;
    CGFloat categoryTitleWidth=[categoryString sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:20]}].width;
    CGFloat gapValue = fabs((tableWidth - menuTitleWidth - categoryTitleWidth -20)/2); //each button width is added by 10
    
    //init
    leftMenuPageScrollView = [[LazyPageScrollView alloc]initWithFrame:CGRectMake(0, 15, tableWidth, SCREEN_HEIGHT)];
    leftMenuPageScrollView.leftTopView = [[UIView alloc]initWithFrame:CGRectZero];
    leftMenuPageScrollView.rightTopView = [[UIView alloc]initWithFrame:CGRectZero];
    UIView *headerBottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 50, tableWidth, 1)];
    [headerBottomLine setBackgroundColor:THEME_TEXT_COLOR];
    [leftMenuPageScrollView addSubview:headerBottomLine];
    [leftMenuPageScrollView setBackgroundColor:[UIColor clearColor]];
    [leftMenuPageScrollView setDelegate:self];
    [leftMenuPageScrollView initTab:NO Gap:gapValue TabHeight:50 VerticalDistance:0 BkColor:[UIColor clearColor]];
    [leftMenuPageScrollView enableTabBottomLine:YES LineHeight:2 LineColor:[[SimiGlobalVar sharedInstance]colorWithHexString:@"#ffffff"] LineBottomGap:0 ExtraWidth:gapValue];
    [leftMenuPageScrollView setTitleStyle:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:20] Color:THEME_MENU_TEXT_COLOR SelColor:THEME_MENU_TEXT_COLOR];
    [leftMenuPageScrollView enableBreakLine:NO Width:1 TopMargin:0 BottomMargin:0 Color:THEME_MENU_BACKGROUND_COLOR];
    
    //subViews
    menuView  = [UIView new];
    [menuView addSubview:self.tableViewLogin];
    [menuView addSubview:self.tableViewMenu];
    
    //add tab and generate
    [leftMenuPageScrollView addTab:menuString View:menuView Info:nil];
    [leftMenuPageScrollView addTab:categoryString View:categoryViewController.view Info:nil];
    [self.view setBackgroundColor:THEME_MENU_BACKGROUND_COLOR];
    [self.view addSubview:leftMenuPageScrollView];
    [leftMenuPageScrollView generate];
    
    /*
     Completed ScrollView generating
    */
    
    /*
     login button
    */
    self.loginButton = [[UIButton alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - LOGIN_BUTTON_HEIGHT, 328, LOGIN_BUTTON_HEIGHT)];
    [self.loginButton setBackgroundColor:THEME_BUTTON_BACKGROUND_COLOR];
    [self.loginButton setTitleColor:THEME_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
    [self.loginButton setTitle:[SCLocalizedString(@"Login") uppercaseString] forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(didClickLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loginButton];
    
    [self setCells:nil];
    [self getCMSPages];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationWillResignActive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetStoreCollection" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoginOrLogout:) name:@"DidLogin" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoginOrLogout:) name:@"DidLogout" object:nil];
}
#pragma mark Show and Hide LeftMenu
- (void)didClickShow
{
    [self alignSubViews];
    [UIView animateWithDuration:0.2
            delay:0
            options:UIViewAnimationOptionCurveEaseOut
            animations:^{
                CGRect frame = self.view.frame;
                frame.origin.x  = 0;
                self.view.frame = frame;
                self.view.layer.masksToBounds = NO;
            }
            completion:^(BOOL finished) {
                [self.delegate menu:self didClickShowButonWithShow:YES];
            }];
}

- (void)didClickHide
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         CGRect frame = self.view.frame;
                         frame.origin.x = -328;
                         self.view.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         [self.delegate menu:self didClickShowButonWithShow:NO];
                         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                     }];
}

#pragma mark Actions
// tag 100 is menu button, 101 is category button
- (void)showMenu
{
    if ([[leftMenuPageScrollView.viewTopContent viewWithTag:100] isKindOfClass:[UIButton class]]) {
        [(UIButton *)[leftMenuPageScrollView.viewTopContent viewWithTag:100] sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)showCategory
{
    if ([[leftMenuPageScrollView.viewTopContent viewWithTag:101] isKindOfClass:[UIButton class]]) {
        [(UIButton *)[leftMenuPageScrollView.viewTopContent viewWithTag:101] sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)alignSubViews
{
    CGRect frame = self.view.frame;
    frame.size.height = SCREEN_HEIGHT;
    self.view.frame = frame;
    frame = self.tableViewLogin.frame;
    frame.size.height = 49;
    self.tableViewLogin.frame = frame;
    if ([[SimiGlobalVar sharedInstance] isLogin]) {
        [self.loginButton setHidden:YES];
        [self.tableViewLogin setHidden:NO];
        frame.origin.y += 50;
    }
    else {
        [self.tableViewLogin setHidden:YES];
        [self.loginButton setHidden:NO];
    }
    
    frame.size.height = SCREEN_HEIGHT - LOGIN_BUTTON_HEIGHT - frame.origin.y;
    self.tableViewMenu.frame = frame;
}
#pragma mark TableView Delegate and DataSource
// To make full width tableView Separating Lines
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([tableView.simiObjectName isEqualToString:TABLE_MENU]) {
        SimiSection *simiSection = [self.cells objectAtIndex:section];
        float iconOrigionX = 20;
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 325, 30)];
        [view setBackgroundColor:[[SimiGlobalVar sharedInstance]colorWithHexString:@"#000000" alpha:0.5]];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(iconOrigionX, 0, CGRectGetWidth(view.frame) - iconOrigionX, CGRectGetHeight(view.frame))];
        [label setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:15]];
        [label setTextColor:THEME_MENU_TEXT_COLOR];
        [label setBackgroundColor:[UIColor clearColor]];
        //Gin edit
        if ([[SimiGlobalVar sharedInstance] isReverseLanguage]) {
            [label setTextAlignment:NSTextAlignmentRight];
        }
        //End
        [view addSubview:label];
        
        if ([simiSection.identifier isEqualToString:LEFTMENU_SECTION_MAIN]) {
            return [[UIView alloc]initWithFrame:CGRectZero];
        }else if ([simiSection.identifier isEqualToString:LEFTMENU_SECTION_MORE])
        {
            if (simiSection.count > 0) {
                [label setText:simiSection.headerTitle];
                return view;
            }else
                return [[UIView alloc]initWithFrame:CGRectZero];
        }
        if (![simiSection.headerTitle isEqualToString:@""]) {
            return view;
        }
    }
    return [[UIView alloc]initWithFrame:CGRectZero];
}

#pragma mark Get CMS Pages
- (void)getCMSPages{
    self.cmsPages = [[SimiCMSPagesModelCollection alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetCMSPages" object:self.cmsPages];
    [self.cmsPages getCMSPagesWithParams:nil];
}

#pragma mark Event Handlers
- (void)didReceiveNotification:(NSNotification *)noti
{
    SimiResponder *responder = (SimiResponder *)[noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        if ([noti.name isEqualToString:@"DidGetCMSPages"]) {
            [self removeObserverForNotification:noti];
            [self setCells:nil];
        }
    }
}

- (void)didLoginOrLogout:(NSNotification *)noti
{
    [self setCells:nil];
}

- (void)didClickLogin
{
    [self didClickHide];
    [self.delegate didSelectLoginRow];
}


#pragma mark update Category
//update category list from child list
- (void)updateCategoryWithModel:(SimiCategoryModelCollection *)categoryModelCollection categoryId:(NSString *)categoryId categoryName:(NSString *)categoryName
{
    [self showCategory];
    categoryViewController.categoryRealName = categoryName;
    categoryViewController.categoryCollection = categoryModelCollection;
    [categoryViewController setCategoryId:categoryId];
    [categoryViewController updateCategoryTitle:categoryName withParentTitle:nil andParentId: nil];
}


//get category list from category id and category name
- (void)updateCategoryWithId:(NSString *)categoryId categoryName:(NSString *)categoryName
{
    [self showCategory];
    categoryViewController.categoryRealName = categoryName;
    [categoryViewController setCategoryId:categoryId];
    [categoryViewController getCategoryCollection];
    [categoryViewController updateCategoryTitle:categoryName withParentTitle:nil andParentId: nil];
}

#pragma mark SCCategoryViewControllerPad Delegate
- (void)openCategoryProductsListWithCategoryId:(NSString *)categoryId
{
    [self.delegate openCategoryProductsListWithCategoryId:categoryId];
    [self didClickHide];
}

#pragma mark Lazy page Delegate

- (void)LazyPageScrollViewPageChange:(LazyPageScrollView *)pageScrollView Index:(NSInteger)index PreIndex:(NSInteger)preIndex
{
    
}

- (void)LazyPageScrollViewEdgeSwipe:(LazyPageScrollView *)pageScrollView Left:(BOOL)bLeft
{
    
}
- (NSString *)convertToHTMLString:(NSArray *)arr{
    NSString *str = @"";
    for (NSDictionary *dict in arr) {
        str = [NSString stringWithFormat:@"%@<b>%@</b></br>", str, [dict valueForKeyPath:@"title"]];
        str = [NSString stringWithFormat:@"%@%@</br></br>", str, [dict valueForKeyPath:@"value"]];
        str = [NSString stringWithFormat:@"<span style=\"font-family: %@; font-size: %i\">%@</span>",
               @"Helvetica",
               14,
               str];
    }
    return str;
}

@end