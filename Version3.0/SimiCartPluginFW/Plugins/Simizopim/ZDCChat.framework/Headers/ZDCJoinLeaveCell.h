/*
 *
 *  ZDChatJoinLeaveCell.h
 *  ZDCChat
 *
 *  Created by Zendesk on 24/09/2014.
 *
 *  Copyright (c) 2016 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zopim Chat SDK, You agree to the Zendesk Terms
 *  of Service https://www.zendesk.com/company/terms and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/application-developer-and-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Chat SDK.
 *
 */


#import <UIKit/UIKit.h>
#import "ZDCChatCell.h"


/**
 * Cell for notifying that an agent has left the chat.
 */
@interface ZDCJoinLeaveCell : ZDCChatCell


/**
 * Label for the event message.
 */
@property (nonatomic, strong) UILabel *msg;


#pragma mark appearance


/**
 * Label text colour.
 */
@property (nonatomic, strong) UIColor *textColor UI_APPEARANCE_SELECTOR;

/**
 * Label font.
 */
@property (nonatomic, strong) UIFont *textFont UI_APPEARANCE_SELECTOR;

/**
 * Insets of the text cell.
 */
@property (nonatomic, strong) NSValue *textInsets UI_APPEARANCE_SELECTOR;


@end

