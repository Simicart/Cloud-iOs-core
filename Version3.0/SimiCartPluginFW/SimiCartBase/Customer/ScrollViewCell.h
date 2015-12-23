//
//  ScrollViewCell.h
//  SimiCart
//
//  Created by Thuy Dao on 2/20/14.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScrollViewCellDelegate <NSObject>

-(void)didSelectProduct:(NSString *)productID;

@end

@interface ScrollViewCell : UIView

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *imagePath;
@property (strong, nonatomic) NSString *productID;
@property (strong, nonatomic) NSString *price;

@property (strong, nonatomic) id<ScrollViewCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIButton *viewButton;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
- (IBAction)viewButtonClicked:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil;

- (void)fetchDataDictionary:(NSDictionary*)dict;
@end
