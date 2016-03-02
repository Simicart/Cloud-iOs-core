//
//  SCOrderFeeCell.m
//  SimiCart
//
//  Created by Cody Nguyen on 8/17/15.
//  Copyright (c) 2015 Cody Nguyen. All rights reserved.
//

#import "SCOrderMethodCell.h"


#pragma mark UITable Method Cell
@implementation SCOrderMethodCell
- (void)setTitle: (NSString *)title andContent:(NSString *)content andIsSelected:(BOOL)isSelected
{
    //gin edit
    float lblMethodTitleWidth = [SimiGlobalVar scaleValue:215];
    //end
    if (self.lblMethodTitle == nil) {
        self.lblMethodTitle = [[UILabel alloc]initWithFrame:CGRectMake(45, 5, lblMethodTitleWidth, 30)];
        self.lblMethodTitle.font = [UIFont fontWithName:THEME_FONT_NAME size:16.0];
        self.lblMethodTitle.textColor = THEME_CONTENT_COLOR;
        [self addSubview:self.lblMethodTitle];
    }
    self.lblMethodTitle.text = title;
    
    if (self.lblMethodContent == nil) {
        self.lblMethodContent = [[UILabel alloc]init];
        [self.lblMethodContent setFont:[UIFont fontWithName:THEME_FONT_NAME size:12]];
        self.lblMethodContent.textColor = [UIColor blackColor];
        [self addSubview:self.lblMethodContent];
    }
    self.lblMethodContent.text = content;
    CGRect contentFrame = CGRectMake(45, 30, 260, 20);
    if ([content sizeWithAttributes:@{NSFontAttributeName:[self.lblMethodContent font]}].width >= contentFrame.size.width){
        contentFrame.size.height += 50;
        self.lblMethodContent.numberOfLines += 3;
    }
    [self.lblMethodContent setFrame:contentFrame];
    
    NSString *optionImageName = @"";
    if (isSelected) {
        optionImageName = @"ic_selected";
    }
    else{
        optionImageName = @"ic_unselected";
    }
    UIImage *optionImage = [UIImage imageNamed:optionImageName];
    self.optionImageView = [[UIImageView alloc]initWithFrame:CGRectMake(16, 12, 15, 15)];
    self.optionImageView.image = optionImage;
    //Gin edit
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        [self.optionImageView setFrame:CGRectMake(SCREEN_WIDTH -[SimiGlobalVar scaleValue:30], 12, 15, 15)];
        
        [self.lblMethodContent setTextAlignment:NSTextAlignmentRight];
        contentFrame.origin.x = self.optionImageView.frame.origin.x -[SimiGlobalVar scaleValue:10] - contentFrame.size.width;
        [self.lblMethodContent setFrame:contentFrame];
        
        [self.lblMethodTitle setTextAlignment:NSTextAlignmentRight];
        [self.lblMethodTitle setFrame:CGRectMake(self.optionImageView.frame.origin.x -[SimiGlobalVar scaleValue:10]  - lblMethodTitleWidth, 5, lblMethodTitleWidth, 30)];
    
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self.optionImageView setFrame:CGRectMake([SimiGlobalVar scaleValue:512] -[SimiGlobalVar scaleValue:30], 12, 15, 15)];
            
            [self.lblMethodContent setTextAlignment:NSTextAlignmentRight];
            contentFrame.origin.x = self.optionImageView.frame.origin.x -[SimiGlobalVar scaleValue:10] - contentFrame.size.width;
            [self.lblMethodContent setFrame:contentFrame];
            
            [self.lblMethodTitle setTextAlignment:NSTextAlignmentRight];
            [self.lblMethodTitle setFrame:CGRectMake(self.optionImageView.frame.origin.x-[SimiGlobalVar scaleValue:10]  - lblMethodTitleWidth, 5, lblMethodTitleWidth, 30)];
        }
    }
    //End
    [self addSubview:self.optionImageView];
    self.accessoryType = UITableViewCellAccessoryNone;
    if (self.isCreditCard) {
        CGFloat xOrigin = SCREEN_WIDTH;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            xOrigin = SCREEN_WIDTH / 2;
        }
        _btnEditCard = [[UIButton alloc]initWithFrame:CGRectMake(xOrigin - 100, 0, 100, 40)];
        [_btnEditCard setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_btnEditCard setImage:[UIImage imageNamed:@"ic_address_edit"] forState:UIControlStateNormal];
        [_btnEditCard setImageEdgeInsets:UIEdgeInsetsMake(10, 60, 10, 20)];
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [_btnEditCard setFrame:CGRectMake(0, 0, 100, 40)];
            [_btnEditCard setImageEdgeInsets:UIEdgeInsetsMake(10, 20, 10, 60)];
        }
        [_btnEditCard addTarget:self action:@selector(editCreditCard:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_btnEditCard];
    }
}

- (void)editCreditCard:(id)sender
{
    [self.delegate editCreditCard:self.paymentIndex];
}
@end