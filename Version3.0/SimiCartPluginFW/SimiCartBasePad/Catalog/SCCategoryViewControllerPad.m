//
//  SCCategoryViewController.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/11/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SCCategoryViewControllerPad.h"

static CGFloat VIEW_CONTROLLER_WIDTH = 328;
static NSString *CATEGORY_CURRENT_ROW_TITLE   = @"CATEGORY_CURRENT_ROW_TITLE";
static NSString *CATEGORY_PARENT_ROW_TITLE    = @"CATEGORY_PARENT_ROW_TITLE";

@implementation SCCategoryViewControllerPad

@synthesize cells = _cells;

- (void)viewDidLoadBefore
{
    [self configureLogo];
    [self configureNavigationBarOnViewDidLoad];
    [self setToSimiView];
    heightTopCell = 50;
    widthViewAll = 80;
    sizeImageViewAll = 8;
    itemHeight = 165;
    itemWidth = 110;
    if (self.categoryId == nil) {
        self.categoryId = @"";
    }
    
    self.tableViewCategory = [[SimiTableView alloc] initWithFrame:CGRectMake(0, 0, VIEW_CONTROLLER_WIDTH, SCREEN_HEIGHT - 65) style:UITableViewStylePlain];
    self.tableViewCategory.dataSource = self;
    self.tableViewCategory.delegate = self;
    [self.tableViewCategory setBackgroundColor:[UIColor clearColor]];
    [self.tableViewCategory setSeparatorColor:[UIColor clearColor]];
    self.tableViewCategory.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.tableViewCategory];
    
    [self setCells:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationWillResignActive" object:nil];
    [self getCategoryProducts];
    [self getCategoryCollection];
    [self.tableViewCategory setHidden:YES];
    [self startLoadingData];
    [self.view setBackgroundColor:[UIColor clearColor]];
}

#pragma mark setCells


- (void)setCells:(NSMutableArray *)inputCells{
    if (inputCells) {
        _cells = inputCells;
    }else{
        _cells = [[SimiTable alloc] init];
        SimiSection *section = [[SimiSection alloc] init];
        if (![self.categoryId isEqualToString: @""]) {
            if (self.parentId == nil) {
                self.parentId = @"";
            }
            SimiRow *row = [[SimiRow alloc] init];
            row.identifier = CATEGORY_PARENT_ROW_TITLE;
            row.height = 50;
            [section addRow:row];
        }
        if (self.categoryName) {
            SimiRow *row = [[SimiRow alloc] init];
            row.identifier = CATEGORY_CURRENT_ROW_TITLE;
            row.height = 50;
            [section addRow:row];
        }
        if (self.categoryCollection.count > 0) {
            for (int i = 0; i < self.categoryCollection.count; i++) {
                SimiCategoryModel *model = [self.categoryCollection objectAtIndex:i];
                SimiRow *row = [[SimiRow alloc] init];
                row.identifier = CATEGORY_ROW_CHILD;
                row.height = 50;
                row.data = model;
                [section addRow:row];
            }
        }
        [_cells addObject:section];
    }
    [self.tableViewCategory reloadData];
}

#pragma mark Update Data

- (void)getCategoryProducts {
    return;
}

- (void)updateCategoryTitle: (NSString *)categoryTitle withParentTitle:(NSString *)parentTitle andParentId: (NSString *)parentId
{
    self.categoryName = categoryTitle;
    self.parentName = parentTitle;
    self.parentId = parentId;
    [self setCells:nil];
    [self.tableViewCategory reloadData];
}


#pragma mark getCategoryColection
- (void)didGetCategories:(NSNotification *)noti
{
    [self didReceiveNotification:noti];
    [self stopLoadingData];
}

#pragma mark Event Handlers
- (void)didReceiveNotification:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        if ([noti.name isEqualToString:DidGetCategoryCollection]) {
            [self saveCategory];
            [self setCells:nil];
            [self stopLoadingData];
            [self.tableViewCategory setHidden:NO];
        }
    }
    if ([noti.name isEqualToString:ApplicationWillResignActive]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:ApplicationDidBecomeActive object:nil];
        return;
    }
    if ([noti.name isEqualToString:ApplicationDidBecomeActive]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ApplicationDidBecomeActive object:nil];
        return;
    }
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
    SimiSection *simiSection = [self.cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    SCCategoryViewControllerPadCell *cell = [[SCCategoryViewControllerPadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    if (simiRow.identifier == CATEGORY_ROW_CHILD) {
        cell.textLabel.text =  [simiRow.data valueForKey:@"name"];
        if (self.categoryCollection.count > 0){
            BOOL hasChild = [[simiRow.data valueForKey:@"has_children"] boolValue];
            if (hasChild)
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else if (simiRow.identifier == CATEGORY_PARENT_ROW_TITLE) {
        cell.textLabel.text = SCLocalizedString(@"Back");
        if (self.parentName!=nil) {
            cell.textLabel.text = self.parentName;
        }
        cell.isBackCell = YES;
    }
    else if (simiRow.identifier == CATEGORY_CURRENT_ROW_TITLE) {
        cell.textLabel.text = self.categoryName;
        cell.isTitleCell = YES;
    }
    return cell;
}
#pragma mark TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [self.cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    if (simiRow.identifier == CATEGORY_CURRENT_ROW_TITLE) {
        [self.delegate openCategoryProductsListWithCategoryId:self.categoryId];
    }
    else if (simiRow.identifier == CATEGORY_PARENT_ROW_TITLE) {
        self.categoryId = self.parentId;
        self.categoryName = self.parentName;
        self.categoryRealName = [simiRow.data valueForKey:@"name"];
        if ([self getSavedCategory]) {
            [self setCells:nil];
            [self.tableViewCategory reloadData];
        }
        else {
            [self startLoadingData];
            [self getCategoryCollection];
        }
    }
    else if (simiRow.identifier == CATEGORY_ROW_CHILD) {
        if (self.categoryCollection.count > 0){
            BOOL hasChild = [[simiRow.data valueForKey:@"has_children"] boolValue];
            if (hasChild){
                self.categoryRealName = [simiRow.data valueForKey:@"name"];
                [self updateCategoryTitle:self.categoryRealName withParentTitle:self.categoryName andParentId:self.categoryId];
                [self setCategoryId:[simiRow.data valueForKey:@"_id"]];
                if ([self getSavedCategory]) {
                    [self setCells:nil];
                    [self stopLoadingData];
                    [self.tableViewCategory setHidden:NO];
                    return;
                }
                [self startLoadingData];
                [self getCategoryCollection];
            }else{
                [self.delegate openCategoryProductsListWithCategoryId:[simiRow.data valueForKey:@"_id"]];
            }
        }else{
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

#pragma mark Catgory Saved
- (void)saveCategory
{
    if (self.categoriesSaved == nil)
        self.categoriesSaved = [NSMutableDictionary new];
    
    if ([self.categoriesSaved objectForKey:self.categoryId])
        return;
    
    NSMutableDictionary * newItem = [[NSMutableDictionary alloc]init];
    if (self.categoryName != nil) {
        [newItem setObject:[self.categoryName copy] forKey:@"name"];
    }
    if (self.parentName != nil) {
        [newItem setObject:[self.parentName copy] forKey:@"parent_name"];
    }
    if (self.parentId != nil) {
        [newItem setObject:[self.parentId copy] forKey:@"parent_id"];
    }
    if (self.categoryCollection != nil) {
        [newItem setObject:[self.categoryCollection mutableCopy] forKey:@"category_model_collection"];
    }
    [self.categoriesSaved setObject:newItem forKey:self.categoryId];
}

- (BOOL)getSavedCategory
{
    if ([self.categoriesSaved objectForKey:self.categoryId] != nil) {
        NSDictionary * newObject = [self.categoriesSaved objectForKey:self.categoryId];
        self.parentName = [newObject objectForKey:@"parent_name"];
        self.parentId = [newObject objectForKey:@"parent_id"];
        self.categoryName = [newObject objectForKey:@"name"];
        self.categoryCollection = [[SimiCategoryModelCollection alloc] initWithArray:(NSArray *)[newObject objectForKey:@"category_model_collection"]];
        return YES;
    }
    else {
        return NO;
    }
}
@end

#pragma mark Category ViewController Pad Cell

@implementation SCCategoryViewControllerPadCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.userInteractionEnabled = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE_REGULAR+3];
        self.accessoryType = UITableViewCellAccessoryNone;
        [self.textLabel setTextColor:THEME_MENU_TEXT_COLOR];
        [self setBackgroundColor:[UIColor clearColor]];
        if([[SimiGlobalVar sharedInstance]isReverseLanguage])
            [self.textLabel setTextAlignment:NSTextAlignmentRight];
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.isTitleCell) {
        self.textLabel.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE_REGULAR+5];
    }
    else if (self.isBackCell) {
        self.textLabel.text = [self.textLabel.text uppercaseString];
        self.textLabel.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE_REGULAR+5];
        [self.textLabel setFrame:CGRectMake(self.textLabel.frame.origin.x + 45, self.textLabel.frame.origin.y, self.textLabel.frame.size.width, self.frame.size.height)];
       //Gin edit
        if ([[SimiGlobalVar sharedInstance] isReverseLanguage]) {
            [self.textLabel setFrame:CGRectMake(self.frame.size.width - self.textLabel.frame.origin.x - 305, self.textLabel.frame.origin.y,self.textLabel.frame.size.width, self.frame.size.height)];
        }
        //end
        UIImageView * backIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Ic_back_ipad"]];
        [backIcon setFrame:CGRectMake(5, 0, 50, 50)];
        [self addSubview:backIcon];
    }
    else {
        [self.textLabel setFrame:CGRectMake(self.textLabel.frame.origin.x + 20, self.textLabel.frame.origin.y, self.textLabel.frame.size.width, self.frame.size.height)];
       //Gin edit
        if ([[SimiGlobalVar sharedInstance] isReverseLanguage]) {
            [self.textLabel setFrame:CGRectMake(self.frame.size.width - self.textLabel.frame.origin.x - 285, self.textLabel.frame.origin.y,250, self.frame.size.height)];
        }
       //end
    }
    UIView * separatingLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1)];
    separatingLine.backgroundColor = THEME_MENU_LINE_COLOR;
    [self addSubview:separatingLine];
}

@end

