//
//  SimiToolbar.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/26/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SimiToolbar;

@protocol SimiToolbarDelegate <NSObject, UIToolbarDelegate>
@optional
- (void)toolbarDidClickDoneButton:(SimiToolbar *)toolbar;
- (void)toolbarDidClickCancelButton:(SimiToolbar *)toolbar;
@end

@interface SimiToolbar : UIToolbar

@property (strong, nonatomic) UIBarButtonItem *doneButton;
@property (strong, nonatomic) UIBarButtonItem *cancelButton;
@property (strong, nonatomic) UIBarButtonItem *fixedSpace;
@property (weak, nonatomic) id<SimiToolbarDelegate> delegate;

@end
