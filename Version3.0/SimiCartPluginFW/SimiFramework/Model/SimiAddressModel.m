//
//  SimiAddressModel.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/19/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiAddressModel.h"
#import "SimiAddressAPI.h"

@implementation SimiAddressModel

- (void)saveToServerWithCustomerId:(NSString *)customerId{
    currentNotificationName = DidSaveAddress;
    modelActionType = ModelActionTypeEdit;
    [self preDoRequest];
    NSString *extendsUrl = @"";
    if(![customerId isEqualToString:@""]){
        extendsUrl = [NSString stringWithFormat:@"%@%@%@%@", @"/", customerId, @"/", @"addresses"];
    }
    NSLog(@"%@", [self valueForKey:@"_id"]);
    if([self valueForKey:@"_id"] != nil && ![[self valueForKey:@"_id"] isEqualToString:@""]){
        extendsUrl = [[extendsUrl stringByAppendingString:@"/"]stringByAppendingString:[self valueForKey:@"_id"]];
        [(SimiAddressAPI *)[self getAPI] saveAddress:self extendsUrl:extendsUrl target:self selector:@selector(didFinishRequest:responder:)];
    }else{
        [(SimiAddressAPI *)[self getAPI] addNewAddress:self extendsUrl:extendsUrl target:self selector:@selector(didFinishRequest:responder:)];
    }
}

- (void)saveToLocal{
    currentNotificationName = DidSaveAddress;
    modelActionType = ModelActionTypeEdit;
    [self preDoRequest];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryPath = [paths objectAtIndex:0];
    NSString *addressTempPath = [libraryPath stringByAppendingPathComponent:@"AddressTemp.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:addressTempPath]) {
        addressTempPath = [libraryPath stringByAppendingPathComponent:@"AddressTemp.plist"];
    }
    NSMutableArray *addressList = [[NSMutableArray alloc] initWithContentsOfFile:addressTempPath];
    if (addressList == nil) {
        addressList = [[NSMutableArray alloc] initWithObjects:self, nil];
    }else{
        [addressList addObject:self];
    }
    [addressList writeToFile:addressTempPath atomically:YES];
    SimiResponder *responder = [[SimiResponder alloc] init];
    responder.status = @"SUCCESS";
    responder.message = @"Saved address successfully !";
    [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
}

- (NSString *)formatAddress
{
    NSMutableArray *result = [NSMutableArray new];
    // Customer Name
    NSMutableArray *customerName = [NSMutableArray new];
    if ([self valueForKey:@"prefix"]) {
        [customerName addObject:[self valueForKey:@"prefix"]];
    }
    [customerName addObject:[self valueForKey:@"first_name"]];
    [customerName addObject:[self valueForKey:@"last_name"]];
    if ([self valueForKey:@"suffix"]) {
        [customerName addObject:[self valueForKey:@"suffix"]];
    }
    [result addObject:[customerName componentsJoinedByString:@" "]];
    // Street
    if ([self valueForKey:@"street"]) {
        [result addObject:[self valueForKey:@"street"]];
    }
    // State
    NSMutableArray *cityAndZip = [NSMutableArray new];
    if ([self valueForKey:@"city"] && ![[self valueForKey:@"city"] isEqual: [NSNull null]]) {
        [cityAndZip addObject:[self valueForKey:@"city"]];
    }
    if ([self valueForKey:@"state"] && ![[self valueForKey:@"state"] isEqual: [NSNull null]]) {
        if ([[self valueForKey:@"state"] valueForKey:@"name"] && ![[[self valueForKey:@"state"] valueForKey:@"name"] isEqual: [NSNull null]]) {
            [cityAndZip addObject:[[self valueForKey:@"state"] valueForKey:@"name" ]];
        }
    }
    if ([self valueForKey:@"zip"] && ![[self valueForKey:@"zip"] isEqual: [NSNull null]]) {
        [cityAndZip addObject:[self valueForKey:@"zip"]];
    }
    if ([cityAndZip count]) {
        [result addObject:[cityAndZip componentsJoinedByString:@", "]];
    }
    // Country
    if ([self valueForKey:@"country"] && ![[self valueForKey:@"country"] isEqual: [NSNull null]]) {
        if ([[self valueForKey:@"country"] valueForKey:@"name"] && ![[[self valueForKey:@"country"] valueForKey:@"name"] isEqual: [NSNull null]]) {
            [result addObject:[[self valueForKey:@"country"]valueForKey:@"name"]];
        }
    }
    // Phone
    if ([self valueForKey:@"phone"] && ![[self valueForKey:@"phone"] isEqual: [NSNull null]]) {
        [result addObject:[self valueForKey:@"phone"]];
    }
    // Email
    if ([self valueForKey:@"email"]) {
        [result addObject:[self valueForKey:@"email"]];
    }
    
    return [result componentsJoinedByString:@"\n"];
}

@end
