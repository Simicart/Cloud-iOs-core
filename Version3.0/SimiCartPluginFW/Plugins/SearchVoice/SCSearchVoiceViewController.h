//
//  SCSearchVoiceViewController.h
//  SimiCartPluginFW
//
//  Created by Lionel on 4/4/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SpeechToTextModule.h"

@protocol SCSearchVoiceViewControllerDelegate <NSObject>

- (void)finishAction:(NSString *)result;
- (void)cancelAction;
- (void)tryAgainAction;
- (void)searchTextAction;

@end

@interface SCSearchVoiceViewController : UIViewController <SpeechToTextModuleDelegate, AVAudioRecorderDelegate>
@property (assign) id<SCSearchVoiceViewControllerDelegate> delegate;
@property (strong, nonatomic) UIButton *searchVoiceBtn;
@property (strong, nonatomic) UILabel *recordStatusLb;
@property (strong, nonatomic) UIButton *recordingButton;
@property (strong, nonatomic) UIButton *recordCloseBtn;
@property (strong, nonatomic) UIButton *tryRecordBtn;
@property (strong, nonatomic) UIButton *searchTextBtn;
@property (strong, nonatomic) UILabel *tryRecordLb;
@property (strong, nonatomic) UILabel *searchTextLb;
@end
