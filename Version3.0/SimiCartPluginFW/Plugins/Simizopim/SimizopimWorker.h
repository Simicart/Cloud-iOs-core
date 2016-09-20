//
//  YoutubeWorker.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/20/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>
static NSString *LEFTMENU_ROW_CHAT = @"LEFTMENU_ROW_CHAT";
@interface SimizopimWorker : NSObject<UIPopoverControllerDelegate>
@property (nonatomic, strong) UIPopoverController *popController;
@property (nonatomic, strong) UIButton *messageButton;
@end
