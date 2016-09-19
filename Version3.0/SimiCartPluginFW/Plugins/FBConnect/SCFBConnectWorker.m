//
//  SCFBConnectWorker.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 11/18/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCFBConnectWorker.h"
#import "FacebookConnect.h"
#import "SimiCustomerModel+Facebook.h"
#import <SimiCartBundle/KeychainItemWrapper.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>



@implementation SCFBConnectWorker{
    NSMutableArray *cells;
    SimiCustomerModel *customer;
    SimiViewController *viewController;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCProductViewMoreController-ViewDidLoadBefore" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCLoginViewController_InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationOpenURL" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidLogout" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCLoginViewController_InitCellAfter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationWillTerminate" object:nil];
        
    }
    return self;
}

- (void)didReceiveNotification:(NSNotification*)noti
{
    
    if ([noti.name isEqualToString:@"SCProductViewMoreController-ViewDidLoadBefore"]) {
        FacebookConnect *facebookConnect = [[FacebookConnect alloc]initWithObject:noti.object];
        facebookConnect.productMoreVC = noti.object;
        if (self.arrayFacebookConnect == nil) {
            self.arrayFacebookConnect = [[NSMutableArray array]init];
        }
        [self.arrayFacebookConnect addObject:facebookConnect];
    }else if ([noti.name isEqualToString:@"SCLoginViewController_InitCellsAfter"]) {
        cells = noti.object;
        viewController = (SimiViewController*)[noti.userInfo valueForKey:@"controller"];
        SimiSection *section = [cells objectAtIndex:0];
        SimiRow *row = [[SimiRow alloc] initWithIdentifier:@"FacebookLoginCell" height:60];
        [section addRow:row];
    }else if ([noti.name isEqualToString:@"SCLoginViewController_InitCellAfter"]){
        NSIndexPath *indexPath = [noti.userInfo valueForKey:@"indexPath"];
        SimiSection *section = [cells objectAtIndex:indexPath.section];
        SimiRow *row = [section objectAtIndex:indexPath.row];
        
        if ([row.identifier isEqualToString:@"FacebookLoginCell"]) {
            UITableViewCell *cell = noti.object;
            FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
            loginButton.readPermissions = @[@"public_profile", @"email"];
            loginButton.publishPermissions = @[@"publish_actions"];
            float widthCell = 7 *SCREEN_WIDTH/8;
            float heightCell = SCREEN_HEIGHT/16.2142857143f;
            float paddingY = SCREEN_HEIGHT/37.8333333333f/2;
            float paddingX = SCREEN_WIDTH/16;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                float widthTable = (SCREEN_WIDTH*2/3);
                widthCell = 7 *widthTable/8;
                heightCell = widthTable/16.2142857143f;
                paddingY = widthTable/37.8333333333f/2;
                paddingX = widthTable/16;
            }
            
            loginButton.delegate = self;
            loginButton.frame = CGRectMake(paddingX, paddingY , widthCell, heightCell);
//            FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
//            [loginManager logInWithReadPermissions:@[@"email"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
//                //TODO: process error or result
//            }];
            cell.backgroundColor = [UIColor clearColor];
            [cell addSubview:loginButton];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
    }
  
    else if ([noti.name isEqualToString:@"ApplicationOpenURL"]){
       
        BOOL numberBool = [[noti object] boolValue];
        numberBool  = [[FBSDKApplicationDelegate sharedInstance] application:[[noti userInfo] valueForKey:@"application"] openURL:[[noti userInfo] valueForKey:@"url"] sourceApplication:[[noti userInfo] valueForKey:@"source_application"] annotation:[[noti userInfo] valueForKey:@"annotation"]];
   
        
    }
    else if ([noti.name isEqualToString:@"DidLogout"] || [noti.name isEqualToString:@"ApplicationWillTerminate"]){
        [[[FBSDKLoginManager alloc] init] logOut];
    }
    else if([noti.name isEqualToString:@"DidLogin"]){
        
    }
}



#pragma mark FBSDKLoginButtonDelegate
-(void) loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
    
    if([[FBSDKAccessToken currentAccessToken] hasGranted:@"email"]){
        [self loginWithFacebookInfo];
    }else{
        [[FBSDKLoginManager alloc] logInWithReadPermissions:@[@"email"] fromViewController:viewController handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if([[FBSDKAccessToken currentAccessToken] hasGranted:@"email"]){
                [self loginWithFacebookInfo];
            }else{
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Opps") message:SCLocalizedString(@"Something went wrong") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles:nil, nil];
                [alertView show];
                [[FBSDKLoginManager alloc] logOut];
                [viewController.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}

-(void) loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{

}

-(void) loginWithFacebookInfo{
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"/me?fields=email,name" parameters:nil]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             if([result isKindOfClass:[NSDictionary class]]){
                 NSString *email = [result objectForKey:@"email"];
                 NSString *name = [result objectForKey:@"name"];
                 if(customer == nil)
                     customer = [[SimiCustomerModel alloc] init];
                 if(email && name){
                     [customer loginWithFacebookEmail:email name:name];
                     NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
                     NSString *bundleIdentifier = [NSString stringWithFormat:@"%@", [info objectForKey:@"CFBundleIdentifier"]];
                     KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:bundleIdentifier accessGroup:nil];
                     [wrapper setObject:@"" forKey:(__bridge id)(kSecAttrDescription)];
                     [wrapper setObject:email forKey:(__bridge id)(kSecAttrAccount)];
                     
                     [[NSNotificationCenter defaultCenter] postNotificationName:@"SimiFaceBookWorker_StartLoginWithFaceBook" object:nil];
                     [viewController startLoadingData];
                 }
             }
         }
     }];
}

#pragma mark Dead Log
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
