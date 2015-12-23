//
//  UILabel+DynamicSizeMe.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/7/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "UILabelDynamicSize.h"

@implementation UILabel (DynamicSizeMe)
-(float)resizLabelToFit{
    float height = [self labelHeight];
    CGRect newFrame = [self frame];
    newFrame.size.height = height + 3 ;
    [self setFrame:newFrame];
    return newFrame.origin.y + newFrame.size.height;
}

-(float)labelHeight{
    [self setNumberOfLines:0];
    self.lineBreakMode = NSLineBreakByWordWrapping;
    
    CGSize maximumLabelSize = CGSizeMake(self.frame.size.width,9999);
    CGRect maxFrame = [self.text boundingRectWithSize:maximumLabelSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.font} context:nil];
    return maxFrame.size.height;
}

@end
