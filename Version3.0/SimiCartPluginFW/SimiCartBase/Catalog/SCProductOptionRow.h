//
//  ZThemeRow.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 4/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimiCartBundle.h"
#import "SimiRow.h"
@class ProductOptionModel;
@interface SCProductOptionRow : SimiRow
@property (nonatomic) BOOL hasChild;
@property (nonatomic, strong) ProductOptionModel *contentRow;
@end

@interface ProductOptionModel : SimiModel
@property (nonatomic) BOOL hightLight;
@property (nonatomic) BOOL isSelected;
@property (nonatomic, strong) NSString *variantAttributeKey;
@property (nonatomic, strong) NSString *variantAttributeTitle;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSMutableArray *dependIds;
@end