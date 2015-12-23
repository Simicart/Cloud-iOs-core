//
//  CountryStateViewController.m
//  SimiCart
//
//  Created by Tan Hoang on 10/2/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import "SCStoreViewController.h"

@interface SCStoreViewController ()

@end

@implementation SCStoreViewController

@synthesize fixedData, keys;

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
    //Axe add to remove ixb file
    CGRect frame = self.view.bounds;
    frame.size.height = 50;
    _searchBar = [[UISearchBar alloc] initWithFrame:frame];
    frame = self.view.bounds;
    frame.size.height -= 114;
    frame.origin.y += 50;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        frame.size.width = SCREEN_WIDTH*2/3;
    }
    _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _searchBar.delegate = self;
    
    [self.view addSubview:_tableView];
    [self.view addSubview:_searchBar];
    //End
    self.searchBar.placeholder = [NSString stringWithFormat:@"%@", SCLocalizedString(@"Search")];
    //Gin edit RTL
    [[NSClassFromString(@"UISearchBarTextField") appearanceWhenContainedIn:[UISearchBar class], nil] setBorderStyle:UITextBorderStyleNone];
    for ( UIView * subview in [[_searchBar.subviews objectAtIndex:0] subviews] )
    {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarTextField") ] ) {
            UITextField *searchView = (UITextField *)subview ;
            if ([[SimiGlobalVar sharedInstance] isReverseLanguage]) {
                [searchView setTextAlignment:NSTextAlignmentRight];
            }
        }
    }
    //End
    //Convert Data Array to Dictionary
    allData = [[NSMutableDictionary alloc] init];
    for (id obj in fixedData) {
//        NSLog(@"%@",[obj valueForKey:[NSString stringWithFormat:@"%@_name", _dataType]]);
        NSString *key = [[obj valueForKey:[NSString stringWithFormat:@"%@_name", _dataType]] substringToIndex:1];
        NSMutableArray *temp = [allData valueForKey:key];
        if (temp == nil) {
            temp = [[NSMutableArray alloc] initWithObjects:obj, nil];
        }else if (![temp containsObject:obj]) {
            [temp addObject:obj];
        }
        [allData setObject:temp forKey:key];
    }
    
    //Sort Dictionary
    keys = [[NSMutableArray alloc] initWithArray:[[allData allKeys] sortedArrayUsingSelector:@selector(compare:)]];
    for (NSString *key in keys) {
        NSArray *values = [allData valueForKey:key];
        NSArray *sortedValue = [values sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
            NSString *name1 = [obj1 valueForKey:[NSString stringWithFormat:@"%@_name", _dataType]];
            NSString *name2 = [obj2 valueForKey:[NSString stringWithFormat:@"%@_name", _dataType]];
            return [name1 compare:name2];
        }];
        [allData setValue:sortedValue forKey:key];
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewDidLoadBefore];
    }
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewWillAppearBefore:YES];
    }
    [self resetSearch];
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setDataType:(NSString *)dataType{
    if (![_dataType isEqualToString:dataType]) {
        _dataType = [dataType copy];
        _dataType = [_dataType lowercaseString];
    }
}

- (void)resetSearch {
    keys = [[NSMutableArray alloc] initWithArray:[[allData allKeys] sortedArrayUsingSelector:@selector(compare:)]];
    data = [allData mutableDeepCopy];
}

- (void)handleSearchForTerm:(NSString *)searchTerm {
    NSMutableArray *sectionsToRemove = [[NSMutableArray alloc] init];
    [self resetSearch];
    for (NSString *key in keys) {
        NSMutableArray *dataList = [data valueForKey:key];
        NSMutableArray *toRemove = [[NSMutableArray alloc] init];
        for (id object in dataList) {
            NSString *name = [object valueForKey:[NSString stringWithFormat:@"%@_name", _dataType]];
            if ([[name uppercaseString] rangeOfString:[searchTerm uppercaseString]].location == NSNotFound) {
                [toRemove addObject:object];
            }
        }
        if ([dataList count] == [toRemove count]){
            [sectionsToRemove addObject:key];
        }
        [dataList removeObjectsInArray:toRemove];
    }
    [keys removeObjectsInArray:sectionsToRemove];
    [_tableView reloadData];
}

#pragma mark Search Bar Delegates
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    searchBar.showsCancelButton = YES;
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length == 0) {
        [self resetSearch];
        [_tableView reloadData];
        return;
    }
    [self handleSearchForTerm:searchText];
}

#pragma mark Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return keys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString *key = [keys objectAtIndex:section];
    return [[data objectForKey:key] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [keys objectAtIndex:section];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        UIView *view = [UIView new];
        UILabel *labelHeader = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, CGRectGetWidth(tableView.frame) - 30 , 44)];
        [labelHeader setTextAlignment:NSTextAlignmentRight];
        [labelHeader setTextColor:[UIColor lightGrayColor]];
        [labelHeader setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2]];
        [labelHeader setText:[[keys objectAtIndex:section] uppercaseString]];
        [view addSubview:labelHeader];
        return view;
    }
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"CountryStateCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedCountryStateCell-Before" object:cell];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return cell;
    }
    NSString *key = [keys objectAtIndex:indexPath.section];
    NSArray *objects = [data objectForKey:key];
    cell.textLabel.text = [[objects objectAtIndex:indexPath.row] valueForKey:[NSString stringWithFormat:@"%@_name", _dataType]];
    if ([cell.textLabel.text isEqualToString:_selectedName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        [cell.textLabel setTextAlignment:NSTextAlignmentRight];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedCountryStateCell-After" object:cell];
    return cell;
}

#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectCountryStateCellAtIndexPath" object:tableView userInfo:@{@"indexPath": indexPath}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    NSString *key = [keys objectAtIndex:indexPath.section];
    NSArray *objects = [data objectForKey:key];
    _selectedName = [[objects objectAtIndex:indexPath.row] valueForKey:[NSString stringWithFormat:@"%@_name", _dataType]];
    _selectedCode = [[objects objectAtIndex:indexPath.row] valueForKey:[NSString stringWithFormat:@"%@_code", _dataType]];
    _selectedId = [[objects objectAtIndex:indexPath.row] valueForKey:[NSString stringWithFormat:@"%@_id", _dataType]];
    [self.delegate didSelectDataWithID:_selectedId dataCode:_selectedCode dataName:_selectedName dataType:_dataType];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Scroll View Delegate
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    [_searchBar resignFirstResponder];
}


@end
