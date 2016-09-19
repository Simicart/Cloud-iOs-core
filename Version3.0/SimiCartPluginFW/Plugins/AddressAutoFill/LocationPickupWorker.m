//
//  LocationPickupWorker.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/17/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "LocationPickupWorker.h"
#import <SimiCartBundle/SCNewAddressViewController.h>
#import <CoreLocation/CoreLocation.h>
@implementation LocationPickupWorker
{
    SCNewAddressViewController *newAddressViewController;
}
- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidCreateAddressAutofill" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SimiFormMapAPI_DidGetAddress" object:nil];
    }
    return self;
}

- (void)didReceiveNotification:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"DidCreateAddressAutofill"]) {
        newAddressViewController = [noti.userInfo valueForKey:@"newAddressView"];
        [newAddressViewController.form addField:@"MapAPI" config:@{@"name": @"latlng",
                                                                  @"title": SCLocalizedString(@"Country"),
                                                                   @"sort_order":@10000,
                                                                   @"height":[NSNumber numberWithFloat:[SimiGlobalVar scaleValue:300]]}];
    }else if([noti.name isEqualToString:@"SimiFormMapAPI_DidGetAddress"])
    {
        CLPlacemark *place = noti.object;
        if (place != nil)
        {
            if (newAddressViewController.countries != nil && [place.addressDictionary valueForKey:@"CountryCode"]) {
                for (SimiAddressModel *country in newAddressViewController.countries) {
                    if ([[country valueForKey:@"code"] isEqualToString:[place.addressDictionary valueForKey:@"CountryCode"]]) {
                        [newAddressViewController.form setValue:[country valueForKey:@"code"] forKey:@"country_code"];
                        [newAddressViewController.form setValue:[country valueForKey:@"name"] forKey:@"country_name"];
                        newAddressViewController.states = [country valueForKey:@"states"];
                        if (newAddressViewController.stateId == nil) {
                            // NOTHING
                        } else if ([newAddressViewController.states isKindOfClass:[NSNull class]] || newAddressViewController.states.count == 0) {
                            if ([newAddressViewController.form.fields indexOfObject:newAddressViewController.stateId] != NSNotFound) {
                                [newAddressViewController.form.fields removeObject:newAddressViewController.stateId];
                                [newAddressViewController.form.fields addObject:newAddressViewController.stateName];
                            }
                            if ([place.addressDictionary valueForKey:@"State"]) {
                                [newAddressViewController.form setValue:[place.addressDictionary valueForKey:@"State"] forKey:@"state_name"];
                            } else {
                                [newAddressViewController.form removeObjectForKey:@"state_name"];
                            }
                        } else {
                            if ([newAddressViewController.form.fields indexOfObject:newAddressViewController.stateName] != NSNotFound) {
                                [newAddressViewController.form.fields removeObject:newAddressViewController.stateName];
                                [newAddressViewController.form.fields addObject:newAddressViewController.stateId];
                            }
                            [newAddressViewController.stateId setDataSource:newAddressViewController.states];
                            if ([place.addressDictionary valueForKey:@"State"]) {
                                BOOL stateExisted = NO;
                                for (SimiAddressModel *state in newAddressViewController.states) {
                                    if ([[state objectForKey:@"name"] isEqualToString:[place.addressDictionary valueForKey:@"State"]] || [[state objectForKey:@"code"] isEqualToString:[place.addressDictionary valueForKey:@"State"]]) {
                                        [newAddressViewController.form setValue:[state objectForKey:@"state_id"] forKey:@"state_id"];
                                        [newAddressViewController.form setValue:[state objectForKey:@"code"] forKey:@"state_code"];
                                        [newAddressViewController.form setValue:[state objectForKey:@"name"] forKey:@"state_name"];
                                        stateExisted = YES;
                                        break;
                                    }
                                }
                                if (!stateExisted) {
                                    [newAddressViewController.form setValue:[place.addressDictionary valueForKey:@"State"] forKey:@"state_name"];
                                    [newAddressViewController.form removeObjectForKey:@"state_id"];
                                }
                            } else {
                                [newAddressViewController.form removeObjectForKey:@"state_id"];
                            }
                        }
                        [newAddressViewController.form sortFormFields];
                        break;
                    }
                }
            }
            
            if ([place.addressDictionary valueForKey:@"City"]) {
                [newAddressViewController.form setValue:[place.addressDictionary valueForKey:@"City"] forKey:@"city"];
            }
            
            NSString *street = @"";
            if ([place.addressDictionary valueForKey:@"Street"]) {
                street = [place.addressDictionary valueForKey:@"Street"];
            }
            if ([place.addressDictionary valueForKey:@"SubLocality"]) {
                if(street.length > 0) {
                    street = [street stringByAppendingString:@", "];
                }
                street = [street stringByAppendingString:[place.addressDictionary valueForKey:@"SubLocality"]];
            }
            if ([place.addressDictionary valueForKey:@"SubAdministrativeArea"]) {
                if(street.length > 0) {
                    street = [street stringByAppendingString:@", "];
                }
                street = [street stringByAppendingString:[place.addressDictionary valueForKey:@"SubAdministrativeArea"]];
            }
            [newAddressViewController.form setValue:street forKey:@"street"];
            
            if (place.postalCode && place.postalCode.length > 0) {
                [newAddressViewController.form setValue:place.postalCode forKey:@"zip"];
            }
        }
        
        [newAddressViewController.tableViewAddress reloadData];
    }
}
@end
