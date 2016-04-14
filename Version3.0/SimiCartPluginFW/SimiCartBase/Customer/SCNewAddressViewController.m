//
//  SCNewAddressViewController.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/19/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SCNewAddressViewController.h"
#import "SimiResponder.h"
#import "SimiSection.h"

@interface SCNewAddressViewController ()

@end

@implementation SCNewAddressViewController
@synthesize address, states, countries, tableViewAddress;
@synthesize form, country = _country, stateId = _stateId, stateName = _stateName;
@synthesize isEditing, isNewCustomer, customerId;

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
    CGRect frame = self.view.frame;
    if([[SimiGlobalVar sharedInstance] isLogin]){
        SimiCustomerModel * customer = [[SimiGlobalVar sharedInstance] customer];
        customerId = [customer valueForKey:@"_id"];
    }
    tableViewAddress = [[SimiTableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    [tableViewAddress setBackgroundColor:[UIColor clearColor]];
    tableViewAddress.contentInset = UIEdgeInsetsMake(0, 0, 80, 0);
    tableViewAddress.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.navigationItem.title = [self formatTitleString:SCLocalizedString(@"New Address")];
    UIBarButtonItem *button = [[UIBarButtonItem alloc]initWithTitle:SCLocalizedString(@"Save") style:UIBarButtonItemStyleDone target:self action:@selector(saveAddress)];
    self.navigationItem.rightBarButtonItem = button;
    
    form = (SimiFormBlock *)[SimiCart createBlock:@"SimiFormBlock"];
    form.isShowRequiredText = YES;
    form.height = 50;
    SimiGlobalVar *config = [SimiGlobalVar sharedInstance];
    
    [form addField:@"Name"
            config:@{
                     @"name": @"first_name",
                     @"title": SCLocalizedString(@"First Name"),
                     @"required": @1
                     }];
    
    [form addField:@"Name"
            config:@{
                     @"name": @"last_name",
                     @"title": SCLocalizedString(@"Last Name"),
                     @"required": @1
                     }];
    
    if (![config isLogin]) {
        [form addField:@"Email"
                config:@{
                         @"name": @"email",
                         @"title": SCLocalizedString(@"Email"),
                         @"required": @1
                         }];
    }
    self.country = (SimiFormSelect *)[form addField:@"Select"
                                             config:@{
                                                      @"name": @"country_code",
                                                      @"title": SCLocalizedString(@"Country"),
                                                      @"option_type": SimiFormOptionNavigation,
                                                      @"nav_controller": self.navigationController,
                                                      @"value_field": @"code",
                                                      @"label_field": @"name",
                                                      @"index_titles": @1,
                                                      @"searchable": @1,
                                                      @"required": @1
                                                      }];
    self.stateName = (SimiFormText *)[form addField:@"Text"
                                             config:@{
                                                      @"name": @"state_name",
                                                      @"title": SCLocalizedString(@"State"),
                                                      }];
    
    self.stateId = (SimiFormSelect *)[form addField:@"Select"
                                             config:@{
                                                      @"name": @"state_code",
                                                      @"title": SCLocalizedString(@"State"),
                                                      @"option_type": SimiFormOptionNavigation,
                                                      @"nav_controller": self.navigationController,
                                                      @"value_field": @"code",
                                                      @"label_field": @"name",
                                                      @"index_titles": @1,
                                                      @"searchable": @1,
                                                      @"required": @1
                                                      }];
    
    [form addField:@"Text"
            config:@{
                     @"name": @"city",
                     @"title": SCLocalizedString(@"City"),
                     @"required": @1
                     }];
    
    [form addField:@"Text"
            config:@{
                     @"name": @"street",
                     @"title": SCLocalizedString(@"Street"),
                     @"required": @1
                     }];
    
    [form addField:@"Text"
            config:@{
                     @"name": @"zip",
                     @"title": SCLocalizedString(@"Post/Zip Code"),
                     @"required": @1
                     }];

    [form addField:@"Phone"
            config:@{
                     @"name": @"phone",
                     @"title": SCLocalizedString(@"Phone"),
                     @"required": @1
                     }];
    
    
    if (isNewCustomer) {
        [form addField:@"Password"
                config:@{
                         @"name": @"customer_password",
                         @"title": SCLocalizedString(@"Password"),
                         @"required": @1
                         }];
        [form addField:@"Password"
                config:@{
                         @"name": @"confirm_password",
                         @"title": SCLocalizedString(@"Confirm Password"),
                         @"required": @1
                         }];
    }
    
    if (address == nil) {
        address = [[SimiAddressModel alloc] init];
        [address setValue:@"" forKey:@"_id"];
    } else {
        // Prepare Data for Form
        //       DOB
        if ([address objectForKey:@"state"] && [address objectForKey:@"state"] != (id)[NSNull null]) {
            [address setValue:[[address objectForKey:@"state"] objectForKey:@"code"] forKey:@"state_code"];
            [address setValue:[[address objectForKey:@"state"] objectForKey:@"name"] forKey:@"state_name"];
        }
        if ([address objectForKey:@"country"] && [address objectForKey:@"country"] != (id)[NSNull null]) {
            [address setValue:[[address objectForKey:@"country"] objectForKey:@"code"] forKey:@"country_code"];
        }
        // Add data to form
         self.navigationItem.title = [self formatTitleString:SCLocalizedString(@"Edit Address")];
        [form setFormData:address];
    }
    //  Liam Update Solve issue with HiddenAddress
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SCNewAddressViewController-ViewDidLoadBefore" object:self];
    //  End Update
    [super viewDidLoadBefore];
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    
}

- (void)viewDidLoadAfter
{
    [super viewDidLoadAfter];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(formDataChanged:) name:SimiFormDataChangedNotification object:form];
    if (!self.isDiscontinue) {
        form.view = tableViewAddress;
        [form showView];
        [self.view addSubview:tableViewAddress];
        // Hide State before get countries
        [form.fields removeObject:self.stateName];
        [form.fields removeObject:self.stateId];
        //
        //  Liam Update 150402
        [self didGetCountries];
        //  End 150402
    }
    
    self.navigationItem.rightBarButtonItem.enabled = [form isDataValid];
}

- (void)viewWillAppearAfter:(BOOL)animated{
    [super viewWillAppearAfter:animated];
    [tableViewAddress deselectRowAtIndexPath:[tableViewAddress indexPathForSelectedRow] animated:YES];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard) name:UIKeyboardDidHideNotification object:nil];
    }
}

- (void)viewWillDisappearBefore:(BOOL)animated
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    }
    [super viewWillDisappearBefore:animated];
}

- (void)didReceiveNotification:(NSNotification *)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"FAIL"]) {
        if ([noti.name isEqualToString:DidRegister]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:responder.responseMessage delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
            [alertView show];
        }
    }
    else if ([responder.status isEqualToString:@"SUCCESS"] && [noti.name isEqualToString:DidRegister])
        [self addAddressRequest];
    [super didReceiveNotification:noti];
}

- (void)saveAddress{
    if (isNewCustomer) {
        NSString *password = [form objectForKey:@"customer_password"];
        NSString *confirm  = [form objectForKey:@"confirm_password"];
        
        if ([password length] < 6) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(@"Please enter 6 or more characters.") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
            [alertView show];
            return;
        }
        if (![password isEqualToString:confirm]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(@"Password and Confirm password don't match.") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
            [alertView show];
            return;
        }
    }
    // Valid Form
    if (![form isDataValid]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(@"Please select all (*) fields") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
        return;
    }
    [address removeAllObjects];
    [address addData:form];
    if([address valueForKey:@"_id"] == nil || [[address valueForKey:@"_id"] isEqualToString:@""]){
        [address setValue:@"1" forKey:@"default_billing"];
        [address setValue:@"1" forKey:@"default_shipping"];
    }
    if ([form objectForKey:@"name"]) {
        [address setValue:[[form objectForKey:@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"name"];
    }
    if ([[SimiGlobalVar sharedInstance]isLogin] && ![address valueForKey:@"email"]) {
        [address setValue:[[[SimiGlobalVar sharedInstance]customer] valueForKey:@"email"] forKey:@"email"];
    }
    // POST data to server
    if (isEditing || [[SimiGlobalVar sharedInstance] isLogin]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSaveCustomerAddress:) name:DidSaveAddress object:address];
        [address saveToServerWithCustomerId:customerId];
        [self startLoadingData];
    }else{
        [address saveToLocal];
        [self.navigationController popViewControllerAnimated:YES];
        [self.delegate didSaveAddress:address];
    }
}

- (void)addAddressRequest
{
    [address removeAllObjects];
    [address addData:form];
    if ([form objectForKey:@"name"]) {
        [address setValue:[[form objectForKey:@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"name"];
    }
    // POST data to server
    if (isEditing || [[SimiGlobalVar sharedInstance] isLogin]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSaveCustomerAddress:) name:@"DidSaveAddress" object:address];
        [address saveToServerWithCustomerId:customerId];
        [self startLoadingData];
    }else{
        [address saveToLocal];
        [self.delegate didSaveAddress:address];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didSaveCustomerAddress:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        [self.delegate didSaveAddress:address];
        [self.navigationController popViewControllerAnimated:YES];
    } else if ([responder.status isEqualToString:@"FAIL"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:responder.responseMessage delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
    }
    [self removeObserverForNotification:noti];
    [self stopLoadingData];
}

// Liam Update 150402
- (void)didGetCountries{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidCreateAddressAutofill" object:tableViewAddress userInfo:@{@"newAddressView": self}];
    countries = [SimiGlobalVar sharedInstance].countryColllection;
    [self.country setDataSource:countries];
    if (self.stateId == nil) {
        // NOTHING
    } else if (!isEditing) {
        for (int i = 0; i < countries.count; i++) {
            SimiAddressModel *addressModel = [countries objectAtIndex:i];
            if ([[[addressModel valueForKey:@"code"]uppercaseString] isEqualToString:[[SimiGlobalVar sharedInstance].countryCode uppercaseString]]) {
                [self.country addSelected:addressModel];
                states = [addressModel valueForKey:@"states"];
                break;
            }
        }
        if ([states isKindOfClass:[NSNull class]] || states.count == 0) {
            // Show State Name
            [form.fields removeObject:self.stateId];
            [form.fields addObject:self.stateName];
        } else {
            // Show State ID
            [form.fields removeObject:self.stateName];
            [form.fields addObject:self.stateId];
            // Make select fist state
            [self.stateId setDataSource:states];
            [self.stateId addSelected:[states objectAtIndex:0]];
        }
        [form sortFormFields];
    } else {
        for (SimiAddressModel *country in countries) {
            if ([[country valueForKey:@"code"] isEqualToString:[address valueForKey:@"country_code"]]) {
                states = [country valueForKey:@"states"];
                if ([states isKindOfClass:[NSNull class]] || states.count == 0) {
                    [form.fields removeObject:self.stateId];
                    [form.fields addObject:self.stateName];
                } else {
                    [form.fields removeObject:self.stateName];
                    [form.fields addObject:self.stateId];
                    [self.stateId setDataSource:states];
                }
                [form sortFormFields];
                break;
            }
        }
    }
    [tableViewAddress reloadData];
}
//  End 150402

- (void)saveCountriesToLocal{
    NSString *countryCollectionStorePath = [[SimiGlobalVar sharedInstance] countryCollectionStorePath];
    SimiAddressModelCollection *temp = [[SimiAddressModelCollection alloc] initWithContentsOfFile:countryCollectionStorePath];
    if (temp == nil) {
        if (countries.count > 0) {
            [countries writeToFile:countryCollectionStorePath atomically:YES];
        }
    }
}

- (void)keyboardWasShown{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(40, 0, 240, 0);
    tableViewAddress.contentInset = contentInsets;
    tableViewAddress.scrollIndicatorInsets = contentInsets;
}

- (void)hideKeyboard{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, 80, 0);
    tableViewAddress.contentInset = contentInsets;
    tableViewAddress.scrollIndicatorInsets = contentInsets;
}

#pragma mark - Form Data Change
- (void)formDataChanged:(NSNotification *)note
{
    SimiFormAbstract *field = [[note userInfo] objectForKey:@"field"];
    if ([field isEqual:self.country]) {
        // Update State Field
        for (SimiAddressModel *country in countries) {
            if ([[country valueForKey:@"code"] isEqualToString:[form valueForKey:@"country_code"]]) {
                [form setValue:[country valueForKey:@"name"] forKey:@"country_name"];
                NSMutableDictionary *newCountry = [[NSMutableDictionary alloc]init];
                [newCountry setValue:[country valueForKey:@"code"] forKey:@"code"];
                [newCountry setValue:[country valueForKey:@"name"] forKey:@"name"];
                [form setValue:newCountry forKey:@"country"];
                states = [country valueForKey:@"states"];
                if (self.stateId == nil) {
                    // NOTHING
                } else if ([states isKindOfClass:[NSNull class]] || states.count == 0) {
                    if ([form.fields indexOfObject:self.stateId] != NSNotFound) {
                        [form.fields removeObject:self.stateId];
                        [form.fields addObject:self.stateName];
                        [form removeObjectForKey:@"state_code"];
                        [form removeObjectForKey:@"state_name"];
                    }
                } else {
                    if ([form.fields indexOfObject:self.stateName] != NSNotFound) {
                        [form.fields removeObject:self.stateName];
                        [form.fields addObject:self.stateId];
                    }
                    [self.stateId setDataSource:states];
                    [self.stateId addSelected:[states objectAtIndex:0]];
                    self.stateId.optionsViewController = nil;
                }
                [form sortFormFields];
                break;
            }
        }
        [tableViewAddress reloadData];
    } else if ([field.simiObjectName isEqualToString:@"dob"]) {
        NSArray *dob = [[form objectForKey:@"dob"] componentsSeparatedByString:@"-"];
        if ([dob count] > 2) {
            [form setValue:[dob objectAtIndex:0] forKey:@"year"];
            [form setValue:[dob objectAtIndex:1] forKey:@"month"];
            [form setValue:[dob objectAtIndex:2] forKey:@"day"];
        }
    } else if ([field.simiObjectName isEqualToString:@"state_code"]) {
        for (NSDictionary *state in states) {
            if ([[state objectForKey:@"code"] isEqualToString:[form objectForKey:@"state_code"]]) {
                [form setValue:[state objectForKey:@"code"] forKey:@"state_code"];
                [form setValue:[state objectForKey:@"name"] forKey:@"state_name"];
                [form setValue:state forKey:@"state"];
                break;
            }
        }
    } else if ([field.simiObjectName isEqualToString:@"state_name"]) {
        NSMutableDictionary *newState = [[NSMutableDictionary alloc]init];
        [newState setValue:[form objectForKey:@"state_name"] forKey:@"name"];
        [newState setValue:@"" forKey:@"code"];
        [form setValue:newState forKey:@"state"];
        
    }
    self.navigationItem.rightBarButtonItem.enabled = [form isDataValid];
}

@end
