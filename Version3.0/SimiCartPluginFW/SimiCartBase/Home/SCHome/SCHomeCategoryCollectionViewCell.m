
//  SimiCart
//
//  Created by Thuy Dao on 2/20/14.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import "SCHomeCategoryCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "SimiFormatter.h"

@implementation SCHomeCategoryCollectionViewCell

@synthesize name, nameLabel, imageView, imagePath, categoryID, category;

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (self) {
        CGFloat imageHeight = frame.size.width;
        if (imageView == nil) {
            imageView = [[UIImageView alloc]init];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [self addSubview:imageView];
        }
        [imageView setFrame:CGRectMake(0, 0, imageHeight, imageHeight)];
        
        if (nameLabel == nil) {
            nameLabel = [[UILabel alloc]init];
            [nameLabel setLineBreakMode:NSLineBreakByTruncatingTail];
            [nameLabel setTextAlignment:NSTextAlignmentLeft];
            [nameLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE-4]];
            [nameLabel setTextColor:THEME_CONTENT_COLOR];
            [self addSubview:nameLabel];
        }
        //Gin edit
        if ([[SimiGlobalVar sharedInstance] isReverseLanguage]){
            [nameLabel setTextAlignment:NSTextAlignmentRight];
        }
        //end
        [nameLabel setFrame:CGRectMake(0, imageHeight + [SimiGlobalVar scaleValue:6], imageHeight, [SimiGlobalVar scaleValue:11])];
    }
}


- (void)setCategory:(SimiModel *)ct{
    if (![category isEqual:ct]) {
        category = ct;
        self.imagePath = [[category valueForKey:@"image"]valueForKey:@"url"];;
        self.name = [category valueForKey:@"name"];
        self.categoryID = [category valueForKey:@"category_id"];
    }
}

- (void)setName:(NSString *)n{
    if (![n isKindOfClass:[NSNull class]]) {
        if (![n isEqualToString:name]) {
            name = [n copy];
            nameLabel.text = name;
        }
    }
}

-(void)setImagePath:(NSString *)ip{
    if (![imagePath isEqualToString:ip]) {
        imagePath = [ip copy];
        if (![imagePath isEqualToString:@""]) {
            NSURL *url = [NSURL URLWithString:imagePath];
            [imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"logo"] options:SDWebImageRetryFailed];
            
        }else
            [imageView setImage:[UIImage imageNamed:@"default_category"]];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
    }
}

- (void)setCategoryID:(NSString *)cid{
    if (![cid isEqualToString:categoryID]) {
        categoryID = [cid copy];
    }
}

@end
