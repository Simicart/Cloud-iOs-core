//
//  SimiCart
//
//  Created by Thuy Dao on 2/20/14.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import "SimiModel.h"
#import <UIKit/UIKit.h>

@interface SCHomeCategoryCollectionViewCell : UICollectionViewCell

/*
 The function setProduct:(Product *)product raise notification "DidDrawProductImageView" to customize product image view
 */

@property (strong, nonatomic) SimiModel *category;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *imagePath;
@property (strong, nonatomic) NSString *categoryID;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *nameLabel;


@end
