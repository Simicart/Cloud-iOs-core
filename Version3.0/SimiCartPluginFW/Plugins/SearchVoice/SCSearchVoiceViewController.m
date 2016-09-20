//
//  SCSearchVoiceViewController.m
//  SimiCartPluginFW
//
//  Created by Lionel on 4/4/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//
// lionel added
#import <AVFoundation/AVFoundation.h>
#import "SCSearchVoiceViewController.h"

@interface SCSearchVoiceViewController () {
    // lionel added
    AVAudioRecorder *recorder;
    SpeechToTextModule *module;
}

@end

@implementation SCSearchVoiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
         //Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   @"MyAudioMemo.m4a",
                                   nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:nil];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
    self.recordStatusLb.text = @"Say something to looking for...";
    self.recordingButton.enabled = YES;
    [self.recordingButton setImage:[UIImage imageNamed:@"recording"] forState:(UIControlStateNormal)];
    self.recordingButton.hidden = NO;
    self.tryRecordBtn.hidden = YES;
    self.tryRecordLb.hidden = YES;
    self.searchTextBtn.hidden = YES;
    self.searchTextLb.hidden = YES;
    
    // end
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (module == nil) {
        module = [[SpeechToTextModule alloc] init];
        module.delegate = self;
    }
    module.langCode = LOCALE_IDENTIFIER;
    [module beginRecording];
    [self setUpSearchVoiceView];
}

// lionel added for voice search

- (void)setUpSearchVoiceView {
    // recording view
    // add backgroundView
    UIView *backGroundView = [[UIView alloc] initWithFrame:[SimiGlobalVar scaleFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)]];
    NSLog(@"screen width : %f, screen height : %f", SCREEN_WIDTH, SCREEN_HEIGHT);
    backGroundView.backgroundColor = [UIColor blackColor];
    backGroundView.alpha = 0.9;
    [self.view addSubview:backGroundView];
    // recording image
    self.recordingButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 100)/2, (SCREEN_HEIGHT - 100) / 2, 100, 100)];
    [self.recordingButton addTarget:self action:@selector(stopRecord) forControlEvents:(UIControlEventTouchUpInside)];
    [self.recordingButton setImage:[UIImage imageNamed:@"recording"] forState:(UIControlStateNormal)];
    self.recordingButton.clipsToBounds = YES;
    self.recordingButton.layer.cornerRadius = self.recordingButton.frame.size.width / 2;
    // status label
    self.recordStatusLb = [[UILabel alloc] initWithFrame:CGRectMake(8, self.recordingButton.frame.origin.y - 8 - 50, SCREEN_WIDTH - 16, 50)];
    self.recordStatusLb.text = @"Say something to looking for...";
    self.recordStatusLb.textColor = [UIColor whiteColor];
    [self.recordStatusLb setTextAlignment:(NSTextAlignmentCenter)];
    // close button
    self.recordCloseBtn = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 30)/2, SCREEN_HEIGHT - 30 - 8, 30, 30)];
    // try record btn
    self.tryRecordBtn = [[UIButton alloc] initWithFrame:CGRectMake(((SCREEN_WIDTH / 2) - 50)/2, (SCREEN_HEIGHT - 50) / 2, 50, 50)];
    [self.tryRecordBtn setImage:[UIImage imageNamed:@"ic_micro_inactive"] forState:(UIControlStateNormal)];
    self.tryRecordBtn.clipsToBounds = YES;
    self.tryRecordBtn.layer.cornerRadius = self.tryRecordBtn.frame.size.width / 2;
    [self.tryRecordBtn addTarget:self action:@selector(tryRecordBtnHandle) forControlEvents:(UIControlEventTouchUpInside)];
    self.tryRecordBtn.hidden = YES;
    
    self.tryRecordLb = [[UILabel alloc] initWithFrame:CGRectMake(8, self.tryRecordBtn.frame.origin.y + 50, (SCREEN_WIDTH / 2) - 16, 20)];
    self.tryRecordLb.text = @"tap to try again";
    [self.tryRecordLb setFont:[UIFont systemFontOfSize:12]];
    self.tryRecordLb.textColor = [UIColor whiteColor];
    [self.tryRecordLb setTextAlignment:(NSTextAlignmentCenter)];
    self.tryRecordLb.hidden = YES;
    // search text btn
    self.searchTextBtn = [[UIButton alloc] initWithFrame:CGRectMake(((SCREEN_WIDTH / 2) - 50)/2 + (SCREEN_WIDTH/2), (SCREEN_HEIGHT - 50) / 2, 50, 50)];
    [self.searchTextBtn setImage:[UIImage imageNamed:@"ic_search_inactive"] forState:(UIControlStateNormal)];
    self.searchTextBtn.clipsToBounds = YES;
    self.searchTextBtn.layer.cornerRadius = self.searchTextBtn.frame.size.width / 2;
    [self.searchTextBtn addTarget:self action:@selector(searchTextBtnHandle) forControlEvents:(UIControlEventTouchUpInside)];
    self.searchTextBtn.hidden = YES;
    
    self.searchTextLb = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH /2) + 8, self.tryRecordBtn.frame.origin.y + 50, (SCREEN_WIDTH / 2) - 16, 20)];
    self.searchTextLb.text = @"type your search";
    [self.searchTextLb setFont:[UIFont systemFontOfSize:12]];
    self.searchTextLb.textColor = [UIColor whiteColor];
    [self.searchTextLb setTextAlignment:(NSTextAlignmentCenter)];
    self.searchTextLb.hidden = YES;
    
    [self.recordCloseBtn setImage:[UIImage imageNamed:@"ic_close"] forState:(UIControlStateNormal)];
    self.recordCloseBtn.imageView.clipsToBounds = YES;
    [self.recordCloseBtn setContentMode:(UIViewContentModeScaleAspectFit)];
    [self.recordCloseBtn addTarget:self action:@selector(closeBtnHandle) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:self.recordingButton];
    [self.view addSubview:self.recordStatusLb];
    [self.view addSubview:self.recordCloseBtn];
    [self.view addSubview:self.tryRecordBtn];
    [self.view addSubview:self.tryRecordLb];
    [self.view addSubview:self.searchTextLb];
    [self.view addSubview:self.searchTextBtn];
}

- (void)stopRecord
{
    self.recordingButton.enabled = NO;
    [self.recordingButton setImage:[UIImage imageNamed:@"inrecording"] forState:(UIControlStateNormal)];
    [module stopRecording:YES];
}

- (void)closeBtnHandle {
    [self.delegate cancelAction];
}

- (void)tryRecordBtnHandle {
    self.recordStatusLb.text = @"Say something to looking for...";
    self.recordingButton.enabled = YES;
    [self.recordingButton setImage:[UIImage imageNamed:@"recording"] forState:(UIControlStateNormal)];
    self.recordingButton.hidden = NO;
    self.tryRecordBtn.hidden = YES;
    self.tryRecordLb.hidden = YES;
    self.searchTextBtn.hidden = YES;
    self.searchTextLb.hidden = YES;
    if (module == nil) {
        module = [[SpeechToTextModule alloc] init];
        module.delegate = self;
    }
    module.langCode = LOCALE_IDENTIFIER;
    [module beginRecording];
}

- (void)searchTextBtnHandle {
    [self closeBtnHandle];
    [self.delegate searchTextAction];
}

#pragma mark - AVAudioPlayerDelegate®

-(BOOL)didReceiveVoiceResponse:(NSData *)data {
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSRange needleRange = NSMakeRange(14,
                                      string.length - 14);
    NSString *needle = [string substringWithRange:needleRange];
    if (needle != nil && ![needle isEqualToString:@""]) {
        NSData* newData = [needle dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableData *lookServerResponseData = [[NSMutableData alloc] init];
        [lookServerResponseData appendData:newData];
        NSError *errorJson=nil;
        NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:lookServerResponseData options:kNilOptions error:&errorJson];
        NSArray *result = [responseDict objectForKey:@"result"];
        NSDictionary *resultDic = [result objectAtIndex:0];
        NSArray *resultArray = [resultDic objectForKey:@"alternative"];
        NSNumber *resultIndex = [responseDict valueForKey:@"result_index"];
        NSString *stringResult = [[resultArray objectAtIndex:[resultIndex integerValue]] valueForKey:@"transcript"];
        NSLog(@"result string : %@", stringResult);
        [self.delegate finishAction:stringResult];
    } else {
        self.recordStatusLb.text = @"We didn't quite get that";
        self.recordingButton.hidden = YES;
        self.tryRecordBtn.hidden = NO;
        self.tryRecordLb.hidden = NO;
        self.searchTextBtn.hidden = NO;
        self.searchTextLb.hidden = NO;
    }
    return YES;
}
// end

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
