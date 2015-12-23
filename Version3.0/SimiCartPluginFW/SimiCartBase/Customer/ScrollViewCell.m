//
//  ScrollViewCell.m
//  SimiCart
//
//  Created by Thuy Dao on 2/20/14.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import "ScrollViewCell.h"
#import "HomeViewController.h"
#import "UIImageView+AFNetworking.h"
#import "ConstantsConfigurePlugin.h"

@implementation ScrollViewCell

@synthesize name, nameLabel, imageView, imagePath, viewButton, productID, price, priceLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {        
        if (imageView == nil) {
            imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 0, frame.size.width-10, 130*frame.size.height/200)];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [self addSubview:imageView];
        }
        if (nameLabel == nil) {
            nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 130*frame.size.height/200 + 5, frame.size.width-10, 45*frame.size.height/200)];
            [nameLabel setNumberOfLines:3];
            [nameLabel setLineBreakMode:NSLineBreakByTruncatingTail];
            [nameLabel setTextAlignment:NSTextAlignmentCenter];
            [nameLabel setFont:[UIFont fontWithName:KFontName size:11]];
            [self addSubview:nameLabel];
        }
        if (priceLabel == nil) {
            priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 180*frame.size.height/200, frame.size.width-10, 25*frame.size.height/200)];
            [priceLabel setNumberOfLines:1];
            [priceLabel setTextAlignment:NSTextAlignmentCenter];
            [priceLabel setFont: [UIFont fontWithName:KFontName size:11]];
            [priceLabel setTextColor:[UIColor colorWithRed:170/255.0 green:10/255.0 blue:0/255.0 alpha:1.0]];
            [self addSubview:priceLabel];
        }
        if (viewButton == nil) {
            viewButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [viewButton setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
            [viewButton addTarget:self action:@selector(viewButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:viewButton];
        }
        
    }
    return self;
}

- (void)fetchDataDictionary:(NSDictionary*)dict
{
    [self setImagePath: [dict valueForKey:@"product_image"]];
    [self setName: [dict valueForKey:@"product_name"]];
    [self setProductID: [dict valueForKey:@"product_id"]];
    [self setPrice: [dict valueForKey:@"product_price"]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil {
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:nibNameOrNil owner:self options:nil];
    self = [nibObjects objectAtIndex:0];
    return self;
}

- (void)setName:(NSString *)n{
    if (![n isKindOfClass:[NSNull class]]) {
        if (![n isEqualToString:name]) {
            name = [n copy];
            nameLabel.text = name;
           nameLabel.textColor = KLabelColor;
        }
    }
}

-(void)setImagePath:(NSString *)ip{
    if (![imagePath isEqualToString:ip]) {
        imagePath = [ip copy];
        NSURL *url = [NSURL URLWithString:imagePath];
        [imageView setImageWithURL:url];
        [imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"logo.png"]];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
    }
}

- (void)setProductID:(NSString *)pid{
    if (![pid isEqualToString:productID]) {
        productID = [pid copy];
    }
}

-(void)setPrice:(NSString *)p{
    if (![price isEqualToString:p]) {
        price = [p copy];
        priceLabel.text = [NSString stringWithFormat:@"%@%.2f", CURRENCY_SYMBOL, [price floatValue]];
    }
}

- (IBAction)viewButtonClicked:(id)sender {
    [self.delegate didSelectProduct:productID];
}
@end
