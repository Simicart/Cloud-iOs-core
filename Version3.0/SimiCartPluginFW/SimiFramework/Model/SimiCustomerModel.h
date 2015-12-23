//
//  SimiCustomerModel.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/7/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiModel.h"

@interface SimiCustomerModel : SimiModel

/*
 Notification name: DidLogin
 */
- (void)loginWithUserMail:(NSString *)userEmail password:(NSString *)password;

/*
 Notification name: DidRegister
 */
- (void)doRegister;

/*
 Notification name: DidGetProfile
 */
- (void)getCustomerProfile;

/*
 Notification name: DidChangeUserInfo
 */
- (void)changeUserProfile;

/*
 Notification name: DidChangeUserPassword
 */
- (void)changeUserPassword;

/*
 Notification name: DidGetForgotPassword
 */
- (void)getForgotPasswordWithUserEmail:(NSString *)userEmail;

/*
 Notification name: DidGetAddressCollection
 */
- (void)getAddressCollection;

@end
