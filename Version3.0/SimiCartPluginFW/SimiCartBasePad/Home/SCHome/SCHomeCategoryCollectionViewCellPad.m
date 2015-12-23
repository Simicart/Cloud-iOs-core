//
//  SCHomeCategoryCollectionViewCellPad.m
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 8/20/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCHomeCategoryCollectionViewCellPad.h"

@implementation SCHomeCategoryCollectionViewCellPad


-(void)setFrame:(CGRect)frame
{
    //[super setFrame:frame];
    if (self) {
        CGFloat imageHeight = frame.size.width;
        if (self.imageView == nil) {
            self.imageView = [[UIImageView alloc]init];
            self.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [self addSubview:self.imageView];
        }
        [self.imageView setFrame:CGRectMake(0, 10, imageHeight, imageHeight)];
        
        if (self.nameLabel == nil) {
            self.nameLabel = [[UILabel alloc]init];
            [self.nameLabel setLineBreakMode:NSLineBreakByTruncatingTail];
            [self.nameLabel setTextAlignment:NSTextAlignmentCenter];
            [self.nameLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:22]];
            [self.nameLabel setTextColor:THEME_CONTENT_COLOR];
            [self addSubview:self.nameLabel];
            if ([[SimiGlobalVar sharedInstance] isReverseLanguage]) {
                [self.nameLabel setTextAlignment:NSTextAlignmentRight];
            }
        }
        [self.nameLabel setFrame:CGRectMake(0, imageHeight + 20, imageHeight, 22)];
    }
}
@end
