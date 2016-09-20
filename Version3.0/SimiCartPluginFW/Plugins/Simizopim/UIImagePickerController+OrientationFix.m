//
//  UIImagePickerController+OrientationFix.m
//  SimiCartPluginFW
//
//  Created by Lionel on 4/11/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "UIImagePickerController+OrientationFix.h"

@implementation UIImagePickerController (OrientationFix)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (BOOL)shouldAutorotate {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return NO;
    }
}

- (NSUInteger)supportedInterfaceOrientations {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskLandscape;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

@end
