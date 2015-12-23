//
//  SimiTable.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 12/5/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiTable.h"

@implementation SimiTable

- (SimiSection *)addSectionWithIdentifier:(NSString *)identifier
{
    SimiSection *section = [[SimiSection alloc] initWithIdentifier:identifier];
    [self addObject:section];
    return section;
}

- (SimiSection *)addSectionWithIdentifier:(NSString *)identifier atIndex:(NSUInteger)index
{
    SimiSection *section = [[SimiSection alloc] initWithIdentifier:identifier];
    [self insertObject:section atIndex:index];
    return section;
}

- (SimiSection *)addSectionWithIdentifier:(NSString *)identifier headerTitle:(NSString *)headerTitle
{
    SimiSection *section = [[SimiSection alloc] initWithIdentifier:identifier];
    section.headerTitle = headerTitle;
    [self addObject:section];
    return section;
}

- (SimiSection *)addSectionWithIdentifier:(NSString *)identifier headerTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle
{
    SimiSection *section = [[SimiSection alloc] initWithHeaderTitle:headerTitle footerTitle:footerTitle];
    section.identifier = identifier;
    [self addObject:section];
    return section;
}

- (SimiSection *)getSectionByIdentifier:(NSString *)identifier
{
    for (SimiSection *section in self) {
        if ([section.identifier isEqualToString:identifier]) {
            return section;
        }
    }
    return nil;
}

- (NSUInteger)getSectionIndexByIdentifier:(NSString *)identifier
{
    for (NSUInteger index = 0; index < self.count; index++) {
        SimiSection *section = [self objectAtIndex:index];
        if ([section.identifier isEqualToString:identifier]) {
            return index;
        }
    }
    return NSNotFound;
}

- (void)removeSectionsByIdentifier:(NSString *)identifier
{
    for (NSUInteger index = self.count; index > 0; ) {
        SimiSection *section = [self objectAtIndex:--index];
        if ([section.identifier isEqualToString:identifier]) {
            [self removeObjectAtIndex:index];
        }
    }
}

@end
