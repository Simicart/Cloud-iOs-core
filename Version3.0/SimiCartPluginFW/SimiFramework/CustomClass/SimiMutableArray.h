//
//  SimiMutableArray.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/8/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimiMutableArray : NSMutableArray{
    NSMutableArray *mutableArray;
}

- (id)init;
- (NSUInteger)count;
- (void)addObject:(id)anObject;
- (void)addObjectsFromArray:(NSArray *)otherArray;
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)removeObject:(id)anObject;
- (void)removeLastObject;
- (void)removeAllObjects;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
- (id)objectAtIndex:(NSUInteger)index;
- (NSMutableArray *)data;

@end
