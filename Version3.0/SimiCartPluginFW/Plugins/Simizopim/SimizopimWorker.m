//
//  YoutubeWorker.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/20/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimizopimWorker.h"
#import "ChatStyling.h"
#import <SimiCartBundle/SCThemeWorker.h>
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SimiRow.h>
#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SCLeftMenuViewController.h>
#import <SimiCartBundle/SCNavigationBarPhone.h>
#import <SimiCartBundle/SCNavigationBarPad.h>

@implementation SimizopimWorker
{
    NSMutableArray * cells;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didTapChatButton) name:@"tapToChatButton" object:nil];
        [SimiGlobalVar sharedInstance].isZopimChat = YES;
    }
    return self;
}

-(void)didTapChatButton
{
    NSString *accountKey = @"3WlAvERBApxnMZGdc40no5lmvt1mJCQ8";
    [ZDCChat initializeWithAccountKey:accountKey];
    [ZDCChat startChat:^(ZDCConfig *config) {
        config.preChatDataRequirements.name = ZDCPreChatDataOptionalEditable;
        config.preChatDataRequirements.email = ZDCPreChatDataRequiredEditable;
        config.preChatDataRequirements.phone = ZDCPreChatDataOptionalEditable;
        config.preChatDataRequirements.department = ZDCPreChatDataOptionalEditable;
        config.preChatDataRequirements.message = ZDCPreChatDataOptionalEditable;
    }];
    [self styleApp];
}

-(void)move:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateChanged) {
        self.messageButton.center = [sender locationInView:[[[UIApplication sharedApplication] delegate] window]];
    }
}

- (void) styleApp
{
    [[ZDCChatOverlay appearance] setOverlayTintColor:[UIColor colorWithRed:0.9 green:0.45 blue:0 alpha:1]];
    [[ZDCChatOverlay appearance] setMessageCountColor:THEME_BUTTON_TEXT_COLOR];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
