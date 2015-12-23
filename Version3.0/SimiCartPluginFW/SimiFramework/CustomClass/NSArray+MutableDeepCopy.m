//
//  NSArray+MutableDeepCopy.m
//  simicart
//
//  Created by Tan Hoang on 10/14/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import "NSArray+MutableDeepCopy.h"

@implementation NSArray (MutableDeepCopy)
- (NSArray *)mutableDeepCopy{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (id obj in self) {
        id temp = nil;
        if ([obj respondsToSelector:@selector(mutableDeepCopy)]) {
            temp = [obj mutableDeepCopy];
        }else if ([obj respondsToSelector:@selector(mutableCopy)]){
            temp = [obj mutableCopy];
        }
        if (temp == nil) {
            temp = [obj copy];
        }
        [array addObject:temp];
    }
    return array;
}
@end
