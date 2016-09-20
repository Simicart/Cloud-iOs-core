//
//  SCAppWishlistCoreWorker.h
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 8/25/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCSearchVoiceViewController.h"
#import "SCSearchVoicePadViewController.h"

@interface SCSearchVoiceCoreWorker : NSObject<SCSearchVoiceViewControllerDelegate>

@property (strong, nonatomic) SCSearchVoiceViewController *searchVoiceViewController;
@property (strong, nonatomic) SCSearchVoicePadViewController *searchVoicePadViewController;
@property (strong, nonatomic) UIButton *searchVoiceBtn;

@property (nonatomic) NSInteger heighButton;

@end
