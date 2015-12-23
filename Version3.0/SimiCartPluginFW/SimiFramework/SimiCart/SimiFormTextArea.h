//
//  SimiFormTextArea.h
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiFormText.h"

@interface SimiFormTextArea : SimiFormText <UITextViewDelegate>

@property (strong, nonatomic) UITextView *textArea;

@end
