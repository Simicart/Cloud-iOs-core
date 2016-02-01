//
//  SimiFormSelectOptions.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiFormSelectOptions.h"
#import "SimiFormSelect.h"

@interface SimiFormSelectOptions()
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation SimiFormSelectOptions {
    NSMutableDictionary *dataSource;
    NSMutableArray *allKeys;
    NSMutableDictionary *data;
    NSMutableArray *keys;
}
@synthesize formSelect = _formSelect;
@synthesize isMultipleSelect = _isMultipleSelect, alphabetIndexTitles = _alphabetIndexTitles, searchable = _searchable;
@synthesize selected = _selected;

@synthesize searchBar = _searchBar, tableView = _tableView;

- (void)viewDidLoadBefore:(BOOL)animated
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewDidLoadBefore];
    }else
        [self configureNavigationBarOnViewDidLoad];
}
- (void)viewDidLoadAfter
{
    [self setToSimiView];
    [super viewDidLoadAfter];
    // Init some element here
    self.navigationItem.title = self.formSelect.title;
    
    if (self.isMultipleSelect) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:SCLocalizedString(@"Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneEditing)];
    }
    
    CGRect cacheFrame;
    // Check iPad and Popup
    if (self.formSelect.optionType == SimiFormOptionNavigation) {
        cacheFrame = self.formSelect.form.view.bounds;
        cacheFrame.origin.y = 0;
        cacheFrame.size.height = self.view.bounds.size.height - 20;
    } else {
        cacheFrame = self.view.bounds;
    }
    if (self.searchable) {
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, cacheFrame.origin.y, cacheFrame.size.width, 44)];
        self.searchBar.placeholder = SCLocalizedString(@"Search");
        self.searchBar.delegate = self;
        self.searchBar.showsCancelButton = NO;
        [self.view addSubview:self.searchBar];
        cacheFrame.origin.y += 44;
        cacheFrame.size.height -= 44;
    }
    if (self.alphabetIndexTitles) {
        self.tableView = [[UITableView alloc] initWithFrame:cacheFrame style:UITableViewStyleGrouped];
    } else {
        self.tableView = [[UITableView alloc] initWithFrame:cacheFrame style:UITableViewStylePlain];
    }
    self.view.autoresizesSubviews = YES;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    // Selected
    self.selected = [NSMutableArray new];
    NSArray *selectedOptions = [self.formSelect selectedOptions];
    if ([selectedOptions count]) {
        [self.selected addObjectsFromArray:selectedOptions];
    }
    
    // Data Source
    dataSource = [NSMutableDictionary new];
    data = dataSource;
    if (!self.alphabetIndexTitles) {
        allKeys = [NSMutableArray new];
        [allKeys addObject:@"#"];
        [dataSource setValue:self.formSelect.dataSource forKey:[allKeys objectAtIndex:0]];
        keys = allKeys;
        [self reloadData];
        return;
    }
    
    // Convert Data
    for (NSDictionary *option in self.formSelect.dataSource) {
        NSString *key = [[option objectForKey:self.formSelect.labelField] substringToIndex:1];
        NSMutableArray *options = [dataSource objectForKey:key];
        if (options == nil) {
            options = [NSMutableArray new];
            [dataSource setValue:options forKey:key];
        }
        [options addObject:option];
    }
    
    // Sort Data
    allKeys = [[NSMutableArray alloc] initWithArray:[[dataSource allKeys] sortedArrayUsingSelector:@selector(compare:)]];
    keys = allKeys;
    for (NSString *key in keys) {
        [(NSMutableArray *)[dataSource objectForKey:key] sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[obj1 objectForKey:self.formSelect.labelField] compare:[obj2 objectForKey:self.formSelect.labelField] options:NSNumericSearch];
        }];
    }
    
    [self reloadData];
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewWillAppearBefore:YES];
    }
}

#pragma mark - Search Bar Delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0) {
        data = dataSource;
        keys = allKeys;
        [self.tableView reloadData];
        return;
    }
    
    // Search in DataSource
    data = [NSMutableDictionary new];
    keys = [NSMutableArray new];
    for (NSString *key in allKeys) {
        NSMutableArray *options = [dataSource objectForKey:key];
        for (NSDictionary *option in options) {
            if ([[option objectForKey:self.formSelect.labelField] rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
                NSMutableArray *tmp = [data objectForKey:key];
                if (tmp == nil) {
                    [keys addObject:key];
                    tmp = [NSMutableArray new];
                    [data setValue:tmp forKey:key];
                }
                [tmp addObject:option];
            }
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [keys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[data objectForKey:[keys objectAtIndex:section]] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.alphabetIndexTitles) {
        return [keys objectAtIndex:section];
    }
    return nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (self.alphabetIndexTitles) {
        return keys;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellOptionId = @"OptionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellOptionId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellOptionId];
        cell.textLabel.font = self.formSelect.inputText.font;
    }
    
    NSDictionary *option = [[data objectForKey:[keys objectAtIndex:[indexPath section]]] objectAtIndex:[indexPath row]];
    
    cell.textLabel.text = [option objectForKey:self.formSelect.labelField];
    
    if ([self.selected indexOfObject:option] == NSNotFound) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        [cell.textLabel setTextAlignment:NSTextAlignmentRight];
    }
    
    return cell;
}

#pragma mark - Table view Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *option = [[data objectForKey:[keys objectAtIndex:[indexPath section]]] objectAtIndex:[indexPath row]];
    if (self.isMultipleSelect) {
        // Multiple Select
        if ([self.selected indexOfObject:option] == NSNotFound) {
            [self.selected addObject:option];
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            [self.selected removeObject:option];
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        [self.selected removeAllObjects];
        [self.selected addObject:option];
        [self doneEditing];
    }
}

#pragma mark - Scroll view delegate
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - Option methods
- (void)reloadData
{
    [self.tableView reloadData];
    if ([self.selected count]) {
        NSDictionary *option = [self.selected objectAtIndex:0];
        for (NSUInteger section = 0; section < [keys count]; section++) {
            NSArray *options = [data objectForKey:[keys objectAtIndex:section]];
            NSUInteger row = [options indexOfObject:option];
            if (row != NSNotFound) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                return;
            }
        }
    }
}

- (CGSize)reloadContentSize
{
    self.preferredContentSize = CGSizeMake(320, 480);
    return self.preferredContentSize;
}

- (void)doneEditing
{
    [self.formSelect updateSelectInput:self.selected];
    // Put Back
    if ([self.formSelect.optionType isEqualToString:SimiFormOptionPopover]) {
        [self.formSelect.optionsPopover dismissPopoverAnimated:YES];
    } else {
        [self.formSelect.navController popViewControllerAnimated:YES];
    }
}

@end
