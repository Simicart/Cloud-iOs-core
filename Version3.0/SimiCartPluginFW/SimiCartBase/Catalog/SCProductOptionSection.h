//
//  ZThemeSection.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 4/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimiSection.h"
#import "SimiCartBundle.h"

@interface SCProductOptionSection : SimiSection
@property (nonatomic) BOOL hasChild;
@property (nonatomic) BOOL isSelected;
@property (nonatomic, strong) NSString *bannerCategoryURL;
@property (nonatomic, strong) NSMutableDictionary *sectionContent;
@property (nonatomic, strong) NSMutableArray *sectionContentTypeArray;
@end
