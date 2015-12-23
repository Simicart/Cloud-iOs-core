//
//  SCSpotProductCell_Theme01.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/18/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "UIImage+SimiCustom.h"
#import "MatrixSpotProductCell.h"

@implementation MatrixSpotProductCell


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setViewSpot];
    }
    return self;
}

- (void)setViewSpot
{
    _slideShow = [[MatrixSlideShow alloc]initWithFrame:self.bounds];
    [_slideShow setImagesContentMode:UIViewContentModeScaleAspectFit];
    [_slideShow setDelay:3];
    [_slideShow setTransitionDuration:0.5];
    [_slideShow setTransitionType:SCTheme01SlideShowTransitionSlideUpDown];
    [self addSubview:_slideShow];
    
    imgViewBackGround = [[UIImageView alloc]initWithFrame:self.bounds];
    [imgViewBackGround setImage:[UIImage imageNamed:@"images_transpa_view_now"]];
    imgViewBackGround.alpha = 0.5;
    [self addSubview:imgViewBackGround];
    
    lblSpotName = [[UILabel alloc] initWithFrame:[SimiGlobalVar scaleFrame:CGRectMake(10, 15, self.frame.size.width -20, 55)]];
    lblSpotName.numberOfLines = 2;
    [lblSpotName setTextColor:[UIColor whiteColor]];
    lblSpotName.textAlignment = NSTextAlignmentLeft;
    [lblSpotName setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:22]];
    [self addSubview:lblSpotName];
    
    lblViewMore = [[UILabel alloc] initWithFrame:[SimiGlobalVar scaleFrame:CGRectMake(10, 70, self.frame.size.width, 15)]];
    [lblViewMore setTextColor:[UIColor whiteColor]];
    lblViewMore.textAlignment = NSTextAlignmentLeft;
    [lblViewMore setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:12]];
    lblViewMore.text = SCLocalizedString(@"View more");
    [self addSubview:lblViewMore];
    CGRect viewMoreFrame = [SimiGlobalVar scaleFrame:CGRectMake(67, 75.5, 7, 5)];
    viewMoreFrame.origin.x =[lblViewMore.text sizeWithAttributes:@{NSFontAttributeName:[lblViewMore font]}].width + lblViewMore.frame.origin.x + 5;
    imgViewMore = [[UIImageView alloc]initWithFrame:viewMoreFrame];
    
    [imgViewMore setImage:[[UIImage imageNamed:@"ic_view_all"] imageWithColor:[UIColor whiteColor]]];
    [self addSubview:imgViewMore];
    
    btnSpot = [[UIButton alloc]initWithFrame:self.bounds];
    [btnSpot addTarget:self action:@selector(didSelectSpotProduct) forControlEvents:UIControlEventTouchUpInside];
    //Axe updated
    //UITapGestureRecognizer* tapSpotBtn = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectSpotProduct)];
    //[btnSpot addGestureRecognizer:tapSpotBtn];
    [self addSubview:btnSpot];}

- (void)cusSetSpotModel:(SimiModel *)spotModel
{
    self.spotModel = spotModel;
    [lblSpotName setText:[self.spotModel valueForKey:@"name"]];
    if ([lblSpotName.text sizeWithAttributes:@{NSFontAttributeName:[lblSpotName font]}].width <= lblSpotName.frame.size.width)
        [lblSpotName setFrame:[SimiGlobalVar scaleFrame:CGRectMake(10, 43, self.frame.size.width -20, 24)]];
    if ([[self.spotModel valueForKey:@"isFake"]boolValue]) {
        self.slideShow.useImages = YES;
        [self.slideShow addImage:[UIImage imageNamed:[self.spotModel valueForKey:@"image"]]];
    }else
    {
        NSMutableArray * array = [self.spotModel valueForKey:@"phone_images"];
        if (array.count > 0) {
            for (int i = 0; i < array.count; i++) {
                [self.slideShow addImagePath:[[array objectAtIndex:i] valueForKey:@"url" ]];
            }
        }
    }
}

- (void)didSelectSpotProduct
{
    if (![[_spotModel valueForKey:@"isFake"]boolValue]) {
        [self.delegate didSelectedSpotProductWithSpotProductModel:_spotModel];
    }
}


@end
