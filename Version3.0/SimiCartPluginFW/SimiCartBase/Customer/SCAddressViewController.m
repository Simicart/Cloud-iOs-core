//
//  SCAddressViewController.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/19/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SCAddressViewController.h"
#import "SimiResponder.h"
#import "SimiRow.h"
#import "SimiSection.h"

@interface SCAddressViewController () {
}

@end

@implementation SCAddressViewController
@synthesize addressCells = _addressCells;
@synthesize tableViewAddress, isGetOrderAddress, enableEditing, customer;

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
    self.navigationItem.title = [self formatTitleString:SCLocalizedString(@"Address Book")];
    customer = [[SimiGlobalVar sharedInstance] customer];
    tableViewAddress = [[SimiTableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    [tableViewAddress setBackgroundColor:[UIColor clearColor]];
    tableViewAddress.dataSource = self;
    tableViewAddress.delegate = self;
    tableViewAddress.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:tableViewAddress];
    addressCollection = [[SimiGlobalVar sharedInstance]addressBookCollection];
    if (addressCollection == nil) {
        addressCollection = [SimiAddressModelCollection new];
        [SimiGlobalVar sharedInstance].isNeedReloadAddressBookCollection = YES;
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewDidLoadBefore];
    }
}
- (void)viewWillAppearBefore:(BOOL)animated
{
    if (!self.isSelectAddressFromCartForCheckOut) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [super viewWillAppearBefore:YES];
        }
    }
}

- (void)viewWillAppearAfter:(BOOL)animated{
    [super viewWillAppearAfter:animated];
    [tableViewAddress deselectRowAtIndexPath:[tableViewAddress indexPathForSelectedRow] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([SimiGlobalVar sharedInstance].isNeedReloadAddressBookCollection) {
        [self getAddresses];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getAddresses{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetAddresses:) name:DidGetAddressCollection object:customer];
    if (customer != nil) {        
        [self startLoadingData];
        self.isGettingAddress = YES;
        [customer getAddressCollection];
    }
}

- (void)didGetAddresses:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([[responder.status uppercaseString]isEqualToString:@"SUCCESS"]) {
        SimiAddressModelCollection *addressModelCollection = [SimiAddressModelCollection new];
        addressCollection = [customer valueForKey:@"addresses"];
        for (int i = (int)(addressCollection.count -1); i >= 0; i--) {
            SimiAddressModel *addressModel = [addressCollection objectAtIndex:i];
            [addressModelCollection addObject:addressModel];
        }
        addressCollection = [[SimiAddressModelCollection alloc] initWithArray:addressModelCollection];
        if ([[SimiGlobalVar sharedInstance]isDefaultAddress] && self.isSelectAddressFromCartForCheckOut) {
            if (addressCollection.count > 0) {
                for (int i = 0; i < addressCollection.count; i++) {
                    SimiAddressModel *addressModel = [addressCollection objectAtIndex:i];
                    [addressModel setValue:[customer valueForKey:@"email"] forKey:@"email"];
                    if ([[addressModel valueForKey:@"is_default"]boolValue]) {
                        [self.navigationController popViewControllerAnimated:NO];
                        [_delegate selectAddress:addressModel];
                        return;
                    }
                }
            }
        }
        self.isGettingAddress = NO;
        [SimiGlobalVar sharedInstance].isNeedReloadAddressBookCollection = NO;
        [SimiGlobalVar sharedInstance].addressBookCollection = addressCollection;
        [tableViewAddress reloadData];
    }
    [self stopLoadingData];
}

- (NSMutableArray *)addressCells
{
    if (_addressCells) {
        return _addressCells;
    }
    _addressCells = [NSMutableArray new];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitAddressCells-Before" object:_addressCells];
    
    SimiSection *add = [[SimiSection alloc] initWithIdentifier:ADDRESS_ADD_SECTION];
    [_addressCells addObject:add];
    [add addRowWithIdentifier:ADDRESS_ADD_SECTION height:40];
    
    SimiSection *edit = [[SimiSection alloc] initWithIdentifier:ADDRESS_EDIT_SECTION];
    [_addressCells addObject:edit];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitAddressCells-After" object:_addressCells];
    return _addressCells;
}

#pragma mark Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.addressCells count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    SimiSection *aSection = [self.addressCells objectAtIndex:section];
    if ([aSection.identifier isEqualToString:ADDRESS_EDIT_SECTION]) {
        return addressCollection.count;
    }
    if ([aSection.identifier isEqualToString:ADDRESS_ADD_SECTION] && self.isGettingAddress) {
        return 0;
    }
    return [aSection count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    SimiSection *aSection = [self.addressCells objectAtIndex:section];
    if ([aSection.identifier isEqualToString:ADDRESS_EDIT_SECTION] && addressCollection.count) {
        if (enableEditing) {
            return SCLocalizedString(@"Or choose an address for editing");
        } else {
            return SCLocalizedString(@"Or choose an address");
        }
    }
    return aSection.headerTitle;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        SimiSection *aSection = [self.addressCells objectAtIndex:section];
        UIView *view = [UIView new];
        UILabel *lblHeader = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, CGRectGetWidth(tableView.frame) - 20, 44)];
        [lblHeader setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2]];
        [lblHeader setTextColor:THEME_LIGHT_TEXT_COLOR];
        [lblHeader setTextAlignment:NSTextAlignmentRight];
        [view addSubview:lblHeader];
        if ([aSection.identifier isEqualToString:ADDRESS_EDIT_SECTION] && addressCollection.count) {
            if (enableEditing) {
                [lblHeader setText: [[NSString stringWithFormat:@"Or choose an address for editing"] uppercaseString]];
            }else
            {
                [lblHeader setText: [[NSString stringWithFormat:@"Or choose an address"] uppercaseString]];
            }
        }else
        {
            [lblHeader setText: [aSection.headerTitle uppercaseString]];
        }
        return view;
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [[self.addressCells objectAtIndex:section] footerTitle];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *aSection = [self.addressCells objectAtIndex:indexPath.section];
    if ([aSection.identifier isEqualToString:ADDRESS_EDIT_SECTION]) {
        return 140;
    }
    return [[aSection objectAtIndex:indexPath.row] height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddressCell"];
    SimiSection *aSection = [self.addressCells objectAtIndex:indexPath.section];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedAddressCell-Before" object:cell userInfo:@{@"tableView": tableView, @"indexPath": indexPath, @"section": aSection}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return cell;
    }
    if ([aSection.identifier isEqualToString:ADDRESS_EDIT_SECTION]) {
        SimiAddressModel *address = (SimiAddressModel *)[addressCollection objectAtIndex:indexPath.row];
        cell.textLabel.text = [address formatAddress];
        cell.textLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
        CGSize labelSize = [cell.textLabel.text sizeWithFont:cell.textLabel.font
                                           constrainedToSize:cell.textLabel.frame.size
                                               lineBreakMode:cell.textLabel.lineBreakMode];
        cell.textLabel.frame = CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y, 320.0f, labelSize.height);
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textColor = THEME_CONTENT_COLOR;
        //  Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [cell.textLabel setTextAlignment:NSTextAlignmentRight];
        }
        //  End Update RTL
        if (enableEditing) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }else if ([aSection.identifier isEqualToString:ADDRESS_ADD_SECTION]){
        cell.textLabel.text = SCLocalizedString(@"Add an address");
        cell.textLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
        cell.textLabel.textColor = THEME_CONTENT_COLOR;
        //  Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [cell.textLabel setTextAlignment:NSTextAlignmentRight];
        }
        //  End Update RTL
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [button setTitleColor:THEME_COLOR forState:UIControlStateNormal];
        cell.imageView.image = [button imageForState:UIControlStateNormal];
    }
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedAddressCell-After" object:cell userInfo:@{@"tableView": tableView, @"indexPath": indexPath, @"section": aSection}];
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        return YES;
    }
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *aSection = [self.addressCells objectAtIndex:indexPath.section];
    [[NSNotificationCenter defaultCenter] postNotificationName:DidSelectAddressCellAtIndexPath object:aSection userInfo:@{@"tableView": tableView, @"indexPath": indexPath}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    if ([aSection.identifier isEqualToString:ADDRESS_EDIT_SECTION]) {
        if (enableEditing) {
            SCNewAddressViewController *nextController = [[SCNewAddressViewController alloc]init];
            nextController.delegate = self;
            SimiAddressModel *address = [[SimiAddressModel alloc] initWithDictionary:[addressCollection objectAtIndex:indexPath.row]];
            nextController.address = address;
            nextController.isEditing = YES;
            [self.navigationController pushViewController:nextController animated:YES];
        }else{
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                if(SIMI_SYSTEM_IOS >=8){
                    [self.navigationController popViewControllerAnimated:YES];
                }else{
                    [self.navigationController popViewControllerAnimated:NO];
                }
            }
            [_delegate selectAddress:[addressCollection objectAtIndex:indexPath.row]];
        }
    } else if ([aSection.identifier isEqualToString:ADDRESS_ADD_SECTION]) {
        SCNewAddressViewController *nextController = [[SCNewAddressViewController alloc]init];
        nextController.delegate = self;
        [self.navigationController pushViewController:nextController animated:YES];
    }
}

#pragma mark New Address Delegate
- (void)didSaveAddress:(SimiAddressModel *)address{
    if (enableEditing) {
        [self getAddresses];
    }else{
        if (addressCollection == nil) {
            addressCollection = [[SimiAddressModelCollection alloc] init];
        }
        [addressCollection insertObject:address atIndex:0];
    }
    [SimiGlobalVar sharedInstance].addressBookCollection = addressCollection;
    [tableViewAddress reloadData];
}

@end
