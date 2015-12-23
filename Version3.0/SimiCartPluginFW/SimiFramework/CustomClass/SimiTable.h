//
//  SimiTable.h
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 12/5/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiSection.h"

@interface SimiTable : SimiMutableArray

- (SimiSection *)addSectionWithIdentifier:(NSString *)identifier;
- (SimiSection *)addSectionWithIdentifier:(NSString *)identifier atIndex:(NSUInteger)index;
- (SimiSection *)addSectionWithIdentifier:(NSString *)identifier headerTitle:(NSString *)headerTitle;
- (SimiSection *)addSectionWithIdentifier:(NSString *)identifier headerTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle;

- (SimiSection *)getSectionByIdentifier:(NSString *)identifier;
- (NSUInteger)getSectionIndexByIdentifier:(NSString *)identifier;

- (void)removeSectionsByIdentifier:(NSString *)identifier;

@end
