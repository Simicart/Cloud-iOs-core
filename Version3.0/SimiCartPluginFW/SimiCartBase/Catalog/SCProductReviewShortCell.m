
//
//  ShortReviewCell.m
//  SimiCart
//
//  Created by Tan on 7/1/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//
#import "SCProductReviewShortCell.h"

@implementation SCProductReviewShortCell
{
    float maginLeftX;
    float maginTopStar;
    float maginTopTitle;
    float sizeStar;
    float labelTitle_With;
    float labelTitle_Height;
    float labelBody_With;
    float labelBody_Height;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    maginLeftX = 15;
    sizeStar = 12;
    labelBody_Height = 60;
    labelBody_With = 270;
    labelTitle_Height = 50;
    labelTitle_With = 200;
    maginTopStar = 10;
    maginTopTitle = 20;
    //Gin edit
    float imageStarX = 15;
    float screenWidth = self.frame.size.width;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        labelBody_With = SCREEN_WIDTH *2/3 - 50;
        labelTitle_With = labelBody_With;
        screenWidth = SCREEN_WIDTH*2/3;
    }
    if([[SimiGlobalVar sharedInstance] isReverseLanguage]){
        imageStarX = screenWidth - sizeStar - 15;
    }
    //end
    
    if (self) {
        _starCollection = [[NSMutableArray alloc] init];
        for(int i = 0;i< 5;i++){
            UIImageView *imgStar = [[UIImageView alloc] initWithFrame:[SimiGlobalVar scaleFrame:CGRectMake(0, maginTopStar, sizeStar, sizeStar)]];
            [imgStar setImage:[UIImage imageNamed:@"rate0"]];
            CGRect frameStar = [imgStar frame];
            frameStar.origin.x =[SimiGlobalVar scaleValue:maginLeftX] +i*imgStar.frame.size.width;
            if([[SimiGlobalVar sharedInstance] isReverseLanguage]){
                frameStar.origin.x =[SimiGlobalVar scaleValue:imageStarX] -i*imgStar.frame.size.width;
            }
            [imgStar setFrame:frameStar];
            [self addSubview:imgStar];
            [_starCollection addObject:imgStar];
        }
        
        _titleLabel = [[UILabel alloc]initWithFrame:[SimiGlobalVar scaleFrame:CGRectMake(maginLeftX, maginTopTitle, labelTitle_With, labelTitle_Height)]];
        [_titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:[SimiGlobalVar scaleValue:13]]];
        [self addSubview:_titleLabel];
        _bodyLabel = [[UILabel alloc]initWithFrame:[SimiGlobalVar scaleFrame:CGRectMake(maginLeftX, _titleLabel.frame.origin.y+_titleLabel.frame.size.height, labelBody_With, labelBody_Height)]];
        [_bodyLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:[SimiGlobalVar scaleValue:11]]];
        [self addSubview:_bodyLabel];
        _timeLabel = [[UILabel alloc]initWithFrame:[SimiGlobalVar scaleFrame:CGRectMake(maginLeftX,_bodyLabel.frame.origin.y+_bodyLabel.frame.size.height, labelBody_With, labelTitle_Height)]];
        [_timeLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:[SimiGlobalVar scaleValue:10]]];
        [self addSubview:_timeLabel];
        //Gin edit
        if([[SimiGlobalVar sharedInstance] isReverseLanguage]){
            [_titleLabel setFrame:[SimiGlobalVar scaleFrame:CGRectMake( screenWidth - labelTitle_With - 16, maginTopTitle, labelTitle_With, labelTitle_Height)]];
            [_bodyLabel setFrame:[SimiGlobalVar scaleFrame:CGRectMake(screenWidth - labelBody_With - 16, _titleLabel.frame.origin.y+_titleLabel.frame.size.height, labelBody_With, labelBody_Height)]];
            [_timeLabel setFrame:[SimiGlobalVar scaleFrame:CGRectMake(screenWidth - labelBody_With - 16,_bodyLabel.frame.origin.y+_bodyLabel.frame.size.height, labelBody_With, labelTitle_Height)]];
            
             [_titleLabel setTextAlignment:NSTextAlignmentRight];
             [_bodyLabel setTextAlignment:NSTextAlignmentRight];
             [_timeLabel setTextAlignment:NSTextAlignmentRight];
        }
        //end
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil{
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:nibNameOrNil owner:self options:nil];
    self = [nibObjects objectAtIndex:0];
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setRatePoint:(float)rp{
    if ((rp > 0) && (rp <= 5)){
        _ratePoint = rp;
    }else{
        _ratePoint = 0;
    }
    
    int temp = (int)_ratePoint;
    
    if (_ratePoint == 0) {
        for (int i = 0; i < [_starCollection count]; i++) {
            [[_starCollection objectAtIndex:i] setImage:[UIImage imageNamed:@"ic_star2"]];
        }
    }else{
        for (int i = 0; i < temp; i++) {
            [[_starCollection objectAtIndex:i] setImage:[UIImage imageNamed:@"ic_star"]];
        }
        if (_ratePoint - temp > 0) {
            [[_starCollection objectAtIndex:temp] setImage:[UIImage imageNamed:@"ic_star_50"]];
            for (int i = temp+1; i < [_starCollection count]; i++) {
                [[_starCollection objectAtIndex:i] setImage:[UIImage imageNamed:@"ic_star2"]];
            }
        }else{
            for (int i = temp; i < [_starCollection count]; i++) {
                [[_starCollection objectAtIndex:i] setImage:[UIImage imageNamed:@"ic_star2"]];
            }
        }
        
    }
}

- (void)setReviewTitle:(NSString *)reviewTitle{
    if (![_reviewTitle isEqualToString:reviewTitle]) {
        _reviewTitle = [reviewTitle copy];
        _titleLabel.text = _reviewTitle;
    }
}

- (void)setReviewBody:(NSString *)reviewBody{
    if (![_reviewBody isEqualToString:reviewBody]) {
        _reviewBody = [reviewBody copy];
        _bodyLabel.text = _reviewBody;
    }
}

- (void)setReviewTime:(NSString *)reviewTime{
    if (![_reviewTime isEqualToString:reviewTime]) {
        _reviewTime = [reviewTime copy];
        _timeLabel.text = _reviewTime;
    }
}

- (void)setCustomerName:(NSString *)customerName{
    if (![_customerName isEqualToString:customerName]){
        _customerName = [customerName copy];
        _timeLabel.text = [NSString stringWithFormat:@"%@ by %@", _reviewTime, _customerName];
        
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage])
        {
            
        }
     
    }
}

- (void)reArrangeLabelWithTitleLine:(int)titleLine BodyLine:(int)bodyLine{
    _titleLabel.numberOfLines = titleLine;
    _bodyLabel.numberOfLines = bodyLine;
    
    if (bodyLine == 0) {                    //Set order: star-title-time-body
        [_bodyLabel resizLabelToFit];
        CGRect frame = _bodyLabel.frame;
        _bodyLabel.frame = frame;
        
        CGRect frameTimeLabel = _timeLabel.frame;
        frameTimeLabel.origin.y = _bodyLabel.frame.origin.y + _bodyLabel.frame.size.height;
        _timeLabel.frame =frameTimeLabel;
    }else{                                  //Set order: star-title-body-time
        CGRect frame = _bodyLabel.frame;
        frame.origin.y = _titleLabel.frame.origin.y + [SimiGlobalVar scaleValue:20];
        _bodyLabel.frame =  frame;
        
        frame = _timeLabel.frame;
        
        frame.origin.y = _bodyLabel.frame.origin.y + [SimiGlobalVar scaleValue:30];
        _timeLabel.frame = frame;
    }
    
}

- (CGFloat)getActualCellHeight{
    return _bodyLabel.frame.size.height + _bodyLabel.frame.origin.y +100;
}

@end
