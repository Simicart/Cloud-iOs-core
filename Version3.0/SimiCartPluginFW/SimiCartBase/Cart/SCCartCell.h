//
//  SCCartCell.h
//  SimiCart
//
//  Created by Tan on 5/16/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "SCAppDelegate.h"
#import "NSString+HTML.h"

@protocol SCCartCellDelegate <NSObject>

- (void)removeProductFromCart:(NSString *)cartItemId;
- (void)qtyButtonClicked:(UIButton* )button cellIndexPath:(NSIndexPath*) indexPath;
- (void) productImageClicked:(NSIndexPath*)indexPath;

@end

@interface SCCartCell : UITableViewCell

@property (strong, nonatomic)  UILabel *nameLabel;
@property (strong, nonatomic)  UILabel *priceLabel;
@property (strong, nonatomic)  UIButton *qtyButton;
@property (strong, nonatomic)  UIImageView *productImageView;
@property (strong, nonatomic)  UIButton *deleteButton;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) NSString *imagePath;
@property (strong, nonatomic) NSString *qty;

@property (strong, nonatomic) id<SCCartCellDelegate> delegate;
@property (strong, nonatomic) SimiCartModel *item;
@property (strong, nonatomic) NSIndexPath *indexPath;

@property (nonatomic) NSString *cartItemId;
@property (nonatomic) float heightCell;


-(void) setInterfaceCell;
- (void)deleteButtonClicked:(id)sender;
- (void)setPriceWithCurrency:(NSString *)priceWithCurrency;

-(void) qtyButtonClicked: (id)sender;
-(void) productImageClick;

@end
