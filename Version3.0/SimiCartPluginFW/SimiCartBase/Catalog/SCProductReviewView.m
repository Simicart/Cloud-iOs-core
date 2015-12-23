



//
//  SCReviewView.m
//  SimiCart
//
//  Created by Tan on 7/4/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import "SCProductReviewView.h"
#import "SimiGlobalVar.h"

@implementation SCProductReviewView{
    float maginLeftX;
    float maginTopRow;
    float maginTop_Label_and_star;
    float sizeStar;
    float reviewTypeLabel_With;
    float reviewTypeLabel_Height;
    float originXlabelStar;
    float originXviewStar;
    float originXlableViewCollection;
    float originY_StarRate;
    float originY_StarRow;
    float originXStarRate;
    float maginTop_Label_and_labelreView;
}

@synthesize reviewType, reviewNumber, reviewTypeLabel, reviewNumberLabel, starReview,starLabelCollection,labelViewCollection;

- (id)initWithFrame:(CGRect)frame
{
    sizeStar = 12;
    maginTopRow = 28;
    reviewTypeLabel_Height = 40;
    reviewTypeLabel_With = 200;
    maginTop_Label_and_star = 40;
    maginTop_Label_and_labelreView = 35;
    originXlabelStar = 15;
    originXStarRate = 225;
    originXlableViewCollection = 150;
    originY_StarRate = 14;
    originY_StarRow = 4;
    //Gin edit
    float screenWidth = 320;
    float imageStarX = 0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        screenWidth = SCREEN_WIDTH *2/3;
        originXlableViewCollection = 400;
    }
    if ([[SimiGlobalVar sharedInstance] isReverseLanguage]) {
        originXlabelStar = screenWidth - reviewTypeLabel_With -15;
        originXStarRate = 35;
        imageStarX = screenWidth -sizeStar - 15;
    }
    //end
    self = [super initWithFrame:frame];
    if (self) {
        starReview = [[NSMutableArray alloc]init];
        labelViewCollection = [[NSMutableArray alloc] init];
        
        reviewTypeLabel = [[UILabel alloc]initWithFrame:[SimiGlobalVar scaleFrame:CGRectMake(originXlabelStar, 0, reviewTypeLabel_With, reviewTypeLabel_Height)]];
        reviewTypeLabel.text = SCLocalizedString(@"Customer Reviews");
        [reviewTypeLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:[SimiGlobalVar scaleValue:16]]];
        [reviewTypeLabel setTextAlignment:NSTextAlignmentLeft];
        //Gin edit
        if([[SimiGlobalVar sharedInstance] isReverseLanguage]){
            [reviewTypeLabel setTextAlignment:NSTextAlignmentRight];
        }
        //end
        [self addSubview:reviewTypeLabel];
        float originY;
        for(int i = 0;i< 5;i++){
            UIImageView *imgStar = [[UIImageView alloc] initWithFrame:[SimiGlobalVar scaleFrame:CGRectMake(0, originY_StarRate,sizeStar, sizeStar)]];
            [imgStar setImage:[UIImage imageNamed:@"rate0"]];
            CGRect frameStar = [imgStar frame];
            frameStar.origin.x = [SimiGlobalVar scaleValue:originXStarRate]+ i*[SimiGlobalVar scaleValue:sizeStar];
            [imgStar setFrame:frameStar];
            [self addSubview:imgStar];
            [starReview addObject:imgStar];
        }
        
        for(int k = 0;k< 5;k++){
            for (int j = 0; j<5; j++) {
                originY = maginTopRow*k +maginTop_Label_and_star;
                UIImageView *imgStar = [[UIImageView alloc] initWithFrame:[SimiGlobalVar scaleFrame:CGRectMake(imageStarX, originY_StarRow,sizeStar, sizeStar)]];
                if(k >= j){
                    [imgStar setImage:[UIImage imageNamed:@"ic_star"]];
                }else{
                    [imgStar setImage:[UIImage imageNamed:@"ic_star2"]];
                }
                CGRect frameStar = [imgStar frame];
                frameStar.origin.x = [SimiGlobalVar scaleValue:originXlabelStar+ j*sizeStar];
                //Gin edit
                if([[SimiGlobalVar sharedInstance] isReverseLanguage]){
                    frameStar.origin.x = [SimiGlobalVar scaleValue:imageStarX - j*sizeStar];
                }
                //end
                frameStar.origin.y = [SimiGlobalVar scaleValue: originY];
                [imgStar setFrame:frameStar];
                [self addSubview:imgStar];
            }
            
        }
        
        for (int f = 0; f< 5; f++) {
            UILabel *lbViewColection = [[UILabel alloc]initWithFrame:[SimiGlobalVar scaleFrame:CGRectMake(0, 0, 50, 20)]];
            lbViewColection.text = [NSString stringWithFormat:@"( %i )",(int)reviewNumber ];
            [lbViewColection setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE_REGULAR]];
            CGRect frameLbViewColection = [lbViewColection frame];
            frameLbViewColection.origin.x =[SimiGlobalVar scaleValue: originXlableViewCollection];
            frameLbViewColection.origin.y = [SimiGlobalVar scaleValue:(maginTop_Label_and_labelreView + f*maginTopRow)];
            [lbViewColection setFrame: frameLbViewColection];
            //Gin edit
            if([[SimiGlobalVar sharedInstance] isReverseLanguage]){
                [lbViewColection setTextAlignment:NSTextAlignmentCenter];
            }
            //end
            [self addSubview:lbViewColection];
            [labelViewCollection addObject:lbViewColection];
        }
    }
    
    
    return self;
}

- (void)setReviewType:(NSString *)rt{
    if (![reviewType isEqualToString:rt]) {
        reviewType = [rt copy];
        reviewTypeLabel.text = reviewType;
    }
}

- (void)setReviewNumber:(NSInteger)rn{
    reviewNumber = rn;
    reviewNumberLabel.text = [NSString stringWithFormat:@"(%ld)", (long) reviewNumber];
}

- (void)setRatePoint:(float)rp{
    if ((rp > 0) && (rp <= 5)){
        _ratePoint = rp;
    }else{
        _ratePoint = 0;
    }
    
    int temp = (int)_ratePoint;
    
    if (_ratePoint == 0) {
        for (int i = 0; i < [starReview count]; i++) {
            [[starReview objectAtIndex:i] setImage:[UIImage imageNamed:@"ic_star2"]];
        }
    }else{
        for (int i = 0; i < temp; i++) {
            [[starReview objectAtIndex:i] setImage:[UIImage imageNamed:@"ic_star"]];
        }
        if (_ratePoint - temp > 0) {
            [[starReview objectAtIndex:temp] setImage:[UIImage imageNamed:@"ic_star_50"]];
            for (int i = temp+1; i < [starReview count]; i++) {
                [[starReview objectAtIndex:i] setImage:[UIImage imageNamed:@"ic_star2"]];
            }
        }else{
            for (int i = temp; i < [starReview count]; i++) {
                [[starReview objectAtIndex:i] setImage:[UIImage imageNamed:@"ic_star2"]];
            }
        }
        
    }
}

- (void)resetColor{
    [UIView beginAnimations:nil context: nil];
    [UIView setAnimationDuration:0.3];
    self.backgroundColor = THEME_APP_BACKGROUND_COLOR;
    [UIView commitAnimations];
}

- (void)setStarCollectionWithFiveStar:(NSString *)fiveStar fourStar:(NSString *)fourStar threeStar:(NSString *)threeStar twoStar:(NSString *)twoStar oneStar:(NSString *)oneStar{
    if (fiveStar == nil) {
        fiveStar = [[NSString alloc]initWithFormat:@"0"];
    }
    if (fourStar == nil) {
        fourStar = [[NSString alloc]initWithFormat:@"0"];
    }
    if (threeStar == nil) {
        threeStar = [[NSString alloc]initWithFormat:@"0"];
    }
    if (twoStar == nil) {
        twoStar = [[NSString alloc]initWithFormat:@"0"];
    }
    if (oneStar == nil) {
        oneStar = [[NSString alloc]initWithFormat:@"0"];
    }
    
    NSArray *starArray = [[NSArray alloc]initWithObjects:oneStar, twoStar, threeStar, fourStar, fiveStar, nil];
    float rate = 0;
    for (int i = 0; i < starArray.count; i++) {
        [[labelViewCollection objectAtIndex:i] setText:[NSString stringWithFormat:@"(%@)", [starArray objectAtIndex:i]]];
        rate = [[starArray objectAtIndex:i] floatValue] / reviewNumber;
        if (isnan(rate)) {
            rate = 0;
        }
       
    }
}

@end
