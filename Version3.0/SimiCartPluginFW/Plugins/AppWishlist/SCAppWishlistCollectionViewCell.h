//
//  SCAppWishlistCollectionViewCell.h
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 8/26/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCAppWishlistCollectionViewCell_Delegate <NSObject>
- (void)shareWithText:(NSString *)sharingText andURL:(NSString *)url andButton:(UIButton *)button;
- (void)removeProductWithWishlistId: (NSString *)idOnWishlist;
- (void)addProductToCartWithWishlistId: (NSString *)idOnWishlist;
- (void)openProductViewWithId: (NSString *)productId;
@end


@interface SCAppWishlistCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView * productImage;
@property (strong, nonatomic) UILabel * nameLabel;
@property (strong, nonatomic) UILabel * priceLabel;
@property (strong, nonatomic) UILabel * specialPriceLabel;
@property (strong, nonatomic) UIView * straightLine; //for Special Price

@property (strong, nonatomic) UIButton * btnAddToCart;
@property (strong, nonatomic) UIButton * btnShare;
@property (strong, nonatomic) UIButton * btnDelete;

@property (strong, nonatomic) SimiModel * product;

@property (strong, nonatomic) id<SCAppWishlistCollectionViewCell_Delegate> delegate;

@end
