//
//  SCCategoryProductCell_Theme01.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/18/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "MatrixCategoryProductCell.h"

@implementation MatrixCategoryProductCell
@synthesize cateModel;

- (id)initWithFrame:(CGRect)frame isAllCate:(BOOL)isAllCate
{
    self = [super initWithFrame:frame];
    self.isAllCate = isAllCate;
    if (self) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            _slideShow = [[MatrixSlideShow alloc]initWithFrame:self.bounds];
            [_slideShow setImagesContentMode:UIViewContentModeScaleToFill];
            [_slideShow setDelay:3];
            [_slideShow setTransitionDuration:0.5];
            [_slideShow setTransitionType:SCTheme01SlideShowTransitionSlideUpDown];
            [self addSubview:_slideShow];
            if (!_isAllCate) {
                imgCateBackGround = [[UIImageView alloc]initWithFrame:CGRectMake(0, [SimiGlobalVar scaleValue:35], self.frame.size.width, [SimiGlobalVar scaleValue:40])];
                imgCateBackGround.alpha = 0.5;
                imgCateBackGround.backgroundColor = [UIColor whiteColor];
                [self addSubview:imgCateBackGround];
                
                lblCateName = [[UILabel alloc]initWithFrame:CGRectMake(0, [SimiGlobalVar scaleValue:40], self.frame.size.width, [SimiGlobalVar scaleValue:20])];
                [lblCateName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
                lblCateName.textAlignment = NSTextAlignmentCenter;
                [self addSubview:lblCateName];
                
                lblViewMore = [[UILabel alloc]initWithFrame:CGRectMake(0, [SimiGlobalVar scaleValue:56], self.frame.size.width, [SimiGlobalVar scaleValue:15])];
                [lblViewMore setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:12]];
                lblViewMore.textAlignment = NSTextAlignmentCenter;
                [lblViewMore setText:SCLocalizedString(@"View more")];
                [self addSubview:lblViewMore];
                
                
                CGRect viewMoreFrame = [SimiGlobalVar scaleFrame:CGRectMake(67, 61.5, 7, 5)];
                viewMoreFrame.origin.x =([lblViewMore.text sizeWithAttributes:@{NSFontAttributeName:[lblViewMore font]}].width + lblViewMore.frame.size.width)/2 + 5;
                imgChoice = [[UIImageView alloc]initWithFrame:viewMoreFrame];
                [imgChoice setImage:[UIImage imageNamed:@"ic_view_all"]];
                
                [self addSubview:imgChoice];
            }else
            {
                imgCateBackGround = [[UIImageView alloc]initWithFrame:self.bounds];
                imgCateBackGround.alpha = 1;
                [imgCateBackGround setImage:[UIImage imageNamed:@"images_transpa_view_now"]];
                [self addSubview:imgCateBackGround];
                
                lblCateName = [[UILabel alloc]initWithFrame:CGRectMake(0, [SimiGlobalVar scaleValue:40], self.frame.size.width, [SimiGlobalVar scaleValue:20])];
                [lblCateName setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:10]];
                [lblCateName setTextColor:[UIColor whiteColor]];
                lblCateName.textAlignment = NSTextAlignmentCenter;
                [self addSubview:lblCateName];
                
                lblChoice = [[UILabel alloc]initWithFrame:[SimiGlobalVar scaleFrame:CGRectMake(22, 60, 60, 17)]];
                [lblChoice setBackgroundColor:[UIColor whiteColor]];
                [lblChoice.layer setCornerRadius:4];
                [lblChoice.layer setMasksToBounds:YES];
                [lblChoice setTextAlignment:NSTextAlignmentCenter];
                [lblChoice setFont:[UIFont fontWithName:THEME_FONT_NAME size:12]];
                [lblChoice setText:SCLocalizedString(@"View now")];
                [self addSubview:lblChoice];
                
                // End
            }
            btnCate = [[UIButton alloc]initWithFrame:self.bounds];
            [btnCate addTarget:self action:@selector(didSelectCategory) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btnCate];
        }else
        {
            _slideShow = [[MatrixSlideShow alloc]initWithFrame:self.bounds];
            _slideShow.layer.borderWidth = 1.0;
            _slideShow.layer.borderColor = [UIColor colorWithRed:213.0/255.0 green:213.0/255.0 blue:215.0/255.0 alpha:1.0].CGColor;
            [_slideShow setImagesContentMode:UIViewContentModeScaleAspectFit];
            [_slideShow setDelay:3];
            [_slideShow setTransitionDuration:0.5];
            [_slideShow setTransitionType:SCTheme01SlideShowTransitionSlideUpDown];
            [self addSubview:_slideShow];
            if (!_isAllCate) {
                imgCateBackGround = [[UIImageView alloc]initWithFrame:CGRectMake(0, 50, self.frame.size.width, 60)];
                imgCateBackGround.alpha = 0.5;
                imgCateBackGround.backgroundColor = [UIColor whiteColor];
                [self addSubview:imgCateBackGround];
                
                lblCateName = [[UILabel alloc]initWithFrame:CGRectMake(0, 55, self.frame.size.width, 30)];
                [lblCateName setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:22]];
                lblCateName.textAlignment = NSTextAlignmentCenter;
                [self addSubview:lblCateName];
                
                lblViewMore = [[UILabel alloc]initWithFrame:CGRectMake(0, 81, self.frame.size.width, 15)];
                [lblViewMore setFont:[UIFont fontWithName:THEME_FONT_NAME size:16]];
                lblViewMore.textAlignment = NSTextAlignmentCenter;
                [lblViewMore setText:SCLocalizedString(@"View more")];
                [self addSubview:lblViewMore];
                if (self.frame.size.width == 332) {
                    imgChoice = [[UIImageView alloc]initWithFrame:CGRectMake(202, 89, 7, 5)];
                }else
                {
                    imgChoice = [[UIImageView alloc]initWithFrame:CGRectMake(120, 89, 7, 5)];
                }
                [imgChoice setImage:[UIImage imageNamed:@"ic_view_all"]];
                [self addSubview:imgChoice];
            }else
            {
                imgCateBackGround = [[UIImageView alloc]initWithFrame:self.bounds];
                imgCateBackGround.alpha = 1;
                [imgCateBackGround setImage:[UIImage imageNamed:@"images_transpa_view_now"]];
                [self addSubview:imgCateBackGround];
                
                lblCateName = [[UILabel alloc]initWithFrame:CGRectMake(0, 60, self.frame.size.width, 20)];
                [lblCateName setFont:[UIFont fontWithName:THEME_FONT_NAME size:16]];
                [lblCateName setTextColor:[UIColor whiteColor]];
                lblCateName.textAlignment = NSTextAlignmentCenter;
                [self addSubview:lblCateName];
                
                lblChoice = [[UILabel alloc]initWithFrame:CGRectMake(33, 85, 100, 28)];
                [lblChoice setBackgroundColor:[UIColor whiteColor]];
                [lblChoice.layer setCornerRadius:4];
                [lblChoice.layer setMasksToBounds:YES];
                [lblChoice setTextAlignment:NSTextAlignmentCenter];
                [lblChoice setFont:[UIFont fontWithName:THEME_FONT_NAME size:16]];
                [lblChoice setText:SCLocalizedString(@"View now")];
                [self addSubview:lblChoice];
            }
            btnCate = [[UIButton alloc]initWithFrame:self.bounds];

            //Axe updated
            [btnCate addTarget:self action:@selector(didSelectCategory) forControlEvents:UIControlEventTouchUpInside];
//            UITapGestureRecognizer* tapCateButton = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectCategory)];
//            [btnCate addGestureRecognizer:tapCateButton];
//            [self addSubview:btnCate];
            [self addSubview:btnCate];
        }
    }
    return self;
}

- (void)cusSetCateModel:(SimiCategoryModel *)cateModel_
{
    self.cateModel = cateModel_;
    [lblCateName setText:SCLocalizedString([[self.cateModel valueForKey:@"name"]uppercaseString])];
    if ([[self.cateModel valueForKey:@"isFake"]boolValue]) {
        self.slideShow.useImages = YES;
        [self.slideShow addImage:[UIImage imageNamed:[self.cateModel valueForKey:@"image"]]];
    }else
    {
        NSMutableArray * array = [self.cateModel valueForKey:@"images"];
        if (array.count > 0) {
            for (int i = 0; i < array.count; i++) {
                [self.slideShow addImagePath:[[array objectAtIndex:i] valueForKey:@"url" ]];
            }
        }
    }
}

- (void)didSelectCategory
{
    if (![[cateModel valueForKey:@"isFake"]boolValue]) {
        [self.delegate didSelectCateGoryWithCateModel:cateModel];
    }
}



@end
