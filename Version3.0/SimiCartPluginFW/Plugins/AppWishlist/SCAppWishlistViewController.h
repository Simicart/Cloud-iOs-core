//
//  SCAppWishlistViewController.h
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 8/26/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import "SCAppWishlistModelCollection.h"
#import "SCAppWishlistCollectionViewCell.h"

@interface SCAppWishlistViewController : SimiViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SCAppWishlistCollectionViewCell_Delegate>

@property (strong, nonatomic) UICollectionView * wishlistCollectionView;
@property (strong, nonatomic) SCAppWishlistModelCollection * wishlistModelCollection;
@property (strong, nonatomic) UIView * header;
@property (strong, nonatomic) UILabel * emptyLabel;

@property (strong, nonatomic) NSString * sharingMessage;
@property (strong, nonatomic) NSString * sharingUrl;


@end
