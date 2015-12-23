//
//  SCOptionGroupViewCell.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/26/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiCartBundle.h"
#import "SimiView.h"

@interface SCOptionGroupViewCell : SimiView
- (void)setPriceOption:(NSDictionary*)optionDictionary;

// Update for Europe - properties
@property (nonatomic, strong) UILabel *lblOptionName;
@property (nonatomic, strong) UILabel *lblRegularPrice;
@property (nonatomic, strong) UILabel *lblSpecialPrice;

@property (nonatomic, strong) NSString *stringRegularPrice;
@property (nonatomic, strong) NSString *stringSpecialPrice;
@property (nonatomic, strong) NSDictionary *optionDict;
@end
