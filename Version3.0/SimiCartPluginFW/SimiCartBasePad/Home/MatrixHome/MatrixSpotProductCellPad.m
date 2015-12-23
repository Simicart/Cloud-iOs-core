//
//  SCSpotProductCellPad_Theme01.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/18/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "UIImage+SimiCustom.h"
#import "MatrixSpotProductCellPad.h"

@implementation MatrixSpotProductCellPad

@synthesize spotModel = _spotModel, slideShow = _slideShow;
- (void)setViewSpot
{
    _slideShow = [[MatrixSlideShow alloc]initWithFrame:self.bounds];
    _slideShow.layer.borderWidth = 1.0;
    _slideShow.layer.borderColor = [UIColor colorWithRed:213.0/255.0 green:213.0/255.0 blue:215.0/255.0 alpha:0.5].CGColor;
    [_slideShow setImagesContentMode:UIViewContentModeScaleAspectFit];
    [_slideShow setDelay:3];
    [_slideShow setTransitionDuration:0.5];
    [_slideShow setTransitionType:SCTheme01SlideShowTransitionSlideUpDown];
    [self addSubview:_slideShow];
    
    imgViewBackGround = [[UIImageView alloc]initWithFrame:CGRectMake(65, 67, 200, 34)];
    [imgViewBackGround setBackgroundColor:[UIColor blackColor]];
    imgViewBackGround.alpha = 0.5;
    [self addSubview:imgViewBackGround];
    
    lblSpotName = [[UILabel alloc]initWithFrame:CGRectMake(65, 67, 200, 34)];
    lblSpotName.numberOfLines = 1;
    [lblSpotName setTextColor:[UIColor whiteColor]];
    lblSpotName.textAlignment = NSTextAlignmentCenter;
    [lblSpotName setFont:[UIFont fontWithName:THEME_FONT_NAME size:20]];
    [self addSubview:lblSpotName];
    
    btnSpot = [[UIButton alloc]initWithFrame:self.bounds];
    [btnSpot addTarget:self action:@selector(didSelectSpotProduct) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnSpot];
}


- (void)cusSetSpotModel:(SimiModel *)spotModel
{
    self.spotModel = spotModel;
    [lblSpotName setText:[self.spotModel valueForKey:@"name"]];
    if (![[self.spotModel valueForKey:@"isFake"]boolValue]) {
        NSMutableArray * array = [self.spotModel valueForKey:@"tablet_images"];
        if (array.count > 0) {
            for (int i = 0; i < array.count; i++) {
                [self.slideShow addImagePath:[[array objectAtIndex:i] valueForKey:@"url"]];
            }
        }
    }else
    {
        self.slideShow.useImages = YES;
        [self.slideShow addImage:[UIImage imageNamed:[self.spotModel valueForKey:@"image"]]];
    }
}


- (void)didSelectSpotProduct
{
    if (![_spotModel valueForKey:@"isFake"]) {
        [self.delegate didSelectedSpotProductWithSpotProductModel:_spotModel];
    }
}

@end
