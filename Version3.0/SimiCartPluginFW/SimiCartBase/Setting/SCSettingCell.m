//
//  SCSettingCell.m
//  SimiCartPluginFW
//
//  Created by Axe on 8/8/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCSettingCell.h"

@implementation SCSettingCell
-(id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){

    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withRow:(SimiRow*)row{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    float widthCell = SCREEN_WIDTH;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        widthCell = SCREEN_WIDTH*2/3;
    }
    float cellHeight = row.height;
    float imagePaddingLeft = 20;
    float iconSize = 25;
    float spaceImageName = 20;
    float rightTextWidth = 100;
    float nameWith = widthCell - imagePaddingLeft -iconSize -spaceImageName - rightTextWidth;
    //Gin edit RTL
    float orilbTextX = imagePaddingLeft + iconSize + spaceImageName;
    if([[SimiGlobalVar sharedInstance] isReverseLanguage]){
        imagePaddingLeft = widthCell - iconSize - 30;
        orilbTextX = imagePaddingLeft - spaceImageName - nameWith;
    }
    //end
    if(self){
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(imagePaddingLeft, (cellHeight - iconSize)/2,iconSize, iconSize)];
        [_iconView setImage:row.image];
        _lblText = [[UILabel alloc] initWithFrame:CGRectMake(orilbTextX, 0, nameWith, cellHeight)];
        _lblText.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
        _lblText.text = row.title;
        [_lblText setTextColor:THEME_CONTENT_COLOR];
        //Gin edit RTL
        if([[SimiGlobalVar sharedInstance] isReverseLanguage]){
            [_lblText setTextAlignment:NSTextAlignmentRight];
        }
        //end
        [self addSubview:_iconView];
        [self addSubview:_lblText];
        
        if ([row.identifier isEqualToString:LANGUAGE_CELL]) {
            _rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(widthCell - rightTextWidth, 0, 70, cellHeight)];
            //Gin edit RTL
            if([[SimiGlobalVar sharedInstance] isReverseLanguage]){
                [_rightLabel setFrame:CGRectMake(rightTextWidth - 70, 0, 70, cellHeight)];
                [_rightLabel setTextAlignment:NSTextAlignmentRight];
            }
            //end
            [_rightLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2]];
            [_rightLabel setTextColor:THEME_CONTENT_COLOR];
            [_rightLabel setText:[[[[SimiGlobalVar sharedInstance] store] valueForKeyPath:@"store_config"] valueForKeyPath:@"store_name"]];
            [self addSubview:_rightLabel];
        }
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return  self;
}
@end
