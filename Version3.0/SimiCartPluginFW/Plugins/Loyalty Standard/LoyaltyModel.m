//
//  LoyaltyModel.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 1/16/15.
//  Copyright (c) 2015 Magestore. All rights reserved.
//

#import "LoyaltyModel.h"
#import "LoyaltyAPI.h"

@implementation LoyaltyModel

- (void)loadProgramOverview
{
    currentNotificationName = @"LoadedProgramOverview";
    modelActionType = ModelActionTypeGet;
    [self preDoRequest];
    [(LoyaltyAPI *)[self getAPI] loadProgramOverviewWithTarget:self selector:@selector(didFinishRequest:responder:)];
}

- (void)saveSettings
{
    currentNotificationName = @"SavedLoyaltySettings";
    modelActionType = ModelActionTypeEdit;
    [self preDoRequest];
    [(LoyaltyAPI *)[self getAPI] saveSettings:self selector:@selector(didFinishRequest:responder:)];
}

@end
