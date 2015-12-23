//
//  ZThemeSection.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 4/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//
#import "SimiCartBundle.h"
#import "SimiSection.h"

@interface ZaraSection: SimiSection
@property (nonatomic) BOOL hasChild;
@property (nonatomic) BOOL isSelected;
@property (nonatomic, strong) NSString *bannerCategoryURL;
@property (nonatomic, strong) NSDictionary *zThemeSectionContent;
@property (nonatomic, strong) NSMutableArray *zThemeSectionContentTypeArray;
@end
