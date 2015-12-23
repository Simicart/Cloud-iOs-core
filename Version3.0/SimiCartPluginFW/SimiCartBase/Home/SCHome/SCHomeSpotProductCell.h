//
//  ScrollViewCell.h
//  SimiCart
//
//  Created by Thuy Dao on 2/20/14.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimiProductModel.h"

@interface SCHomeSpotProductCell : UICollectionViewCell

/*
 The function setProduct:(Product *)product raise notification "DidDrawProductImageView" to customize product image view
 */

@property (strong, nonatomic) SimiProductModel *product;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *imagePath;
@property (strong, nonatomic) NSString *productID;
@property (strong, nonatomic) NSString *price;

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *priceLabel;


@end
