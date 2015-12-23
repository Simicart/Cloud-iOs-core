//
//  SimiCustomerModel.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/7/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiCustomerModel.h"
#import "SimiCustomerAPI.h"

@implementation SimiCustomerModel

- (void)loginWithUserMail:(NSString *)userEmail password:(NSString *)password{
    currentNotificationName = DidLogin;
    modelActionType = ModelActionTypeEdit;
    [self setValue:userEmail forKey:@"email"];
    [self setValue:password forKey:@"password"];
    [self preDoRequest];
    [(SimiCustomerAPI *)[self getAPI] loginWithParams:self target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)doRegister{
    currentNotificationName = DidRegister;
    modelActionType = ModelActionTypeEdit;
    [self preDoRequest];
    [(SimiCustomerAPI *)[self getAPI]  registerWithParams:self target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)getCustomerProfile{
    currentNotificationName = DidGetProfile;
    modelActionType = ModelActionTypeEdit;
    NSString *extendsUrl = @"";
    if(![[self valueForKey:@"_id"] isEqualToString:@""]){
        extendsUrl = [@"/" stringByAppendingString:[self valueForKey:@"_id"]];
    }
    [self preDoRequest];
    [(SimiCustomerAPI *)[self getAPI] getCustomerProfileWithUrl:extendsUrl target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)changeUserProfile
{
    currentNotificationName = DidChangeUserInfo;
    modelActionType = ModelActionTypeEdit;
    NSString *extendsUrl = @"";
    if(![[self valueForKey:@"_id"] isEqualToString:@""]){
        extendsUrl = [@"/" stringByAppendingString:[self valueForKey:@"_id"]];
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:[self valueForKey:@"first_name"] forKey:@"first_name"];
    [params setValue:[self valueForKey:@"last_name"] forKey:@"last_name"];
    [params setValue:[self valueForKey:@"dob"] forKey:@"dob"];
    [params setValue:[self valueForKey:@"gender"] forKey:@"gender"];
    [self preDoRequest];
    [(SimiCustomerAPI *)[self getAPI] changeUserInfoWithParams:params extendsUrl:extendsUrl target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)getAddressCollection{
    currentNotificationName = DidGetAddressCollection;
    modelActionType = ModelActionTypeEdit;
    [self preDoRequest];
    if ([[SimiGlobalVar sharedInstance] isLogin]) {
        //Get data from server
        NSString *extendsUrl = @"";
        if(![[self valueForKey:@"_id"] isEqualToString:@""]){
            extendsUrl = [@"/" stringByAppendingString:[self valueForKey:@"_id"]];
        }
        [(SimiCustomerAPI *)[self getAPI] getAddressCollectionWithUrl:extendsUrl target:self selector:@selector(didFinishRequest:responder:)];
    }else{
        //Get data from local
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *libraryPath = [paths objectAtIndex:0];
        NSString *addressTempPath = [libraryPath stringByAppendingPathComponent:@"AddressTemp.plist"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        SimiResponder *responder = [[SimiResponder alloc] init];
        if ([fileManager fileExistsAtPath:addressTempPath]) {
            responder.status = @"SUCCESS";
            responder.message = @"Found Addresses !";
        }else{
            responder.status = @"FAIL";
            responder.message = @"Addresses Not Found!";
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
    }
}

- (void)changeUserPassword
{
    currentNotificationName = DidChangeUserPassword;
    modelActionType = ModelActionTypeEdit;
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:[self valueForKey:@"email"] forKey:@"email"];
    [params setValue:[self valueForKey:@"password"] forKey:@"password"];
    [params setValue:[self valueForKey:@"newpassword"] forKey:@"newpassword"];
    [self preDoRequest];
    [(SimiCustomerAPI *)[self getAPI] changeUserPasswordWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)getForgotPasswordWithUserEmail:(NSString *)userEmail{
    currentNotificationName = DidGetForgotPassword;
    [self preDoRequest];
    [(SimiCustomerAPI *)[self getAPI] getForgotPasswordWithParams:@{@"email": userEmail} target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder
{
    if ([currentNotificationName isEqualToString:DidLogin] || [currentNotificationName isEqualToString:DidGetProfile] ||[currentNotificationName isEqualToString:DidGetAddressCollection]) {
        if (responder.simiObjectName) {
            currentNotificationName = responder.simiObjectName;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
            switch (modelActionType) {
                case ModelActionTypeInsert:{
                    [self addData:[responseObjectData valueForKey:@"customer"]];
                }
                    break;
                default:{
                    [self setData:[responseObjectData valueForKey:@"customer"]];
                }
                    break;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }else if (responseObject == nil){
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }
    }else
    {
        [super didFinishRequest:responseObject responder:responder];
    }
}


@end
