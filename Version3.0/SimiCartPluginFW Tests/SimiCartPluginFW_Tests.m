//
//  SimiCartPluginFW_Tests.m
//  SimiCartPluginFW Tests
//
//  Created by Nguyen Dac Doan on 11/13/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "SimiCart.h"

@interface SimiCartPluginFW_Tests : XCTestCase

@end

@implementation SimiCartPluginFW_Tests

- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    
    [super tearDown];
}

- (void)testUIViewClassMethods {
    XCTAssertEqual(1, [[UIView initMethods:@selector(addSubview:)] count]);
    XCTAssertEqual(1, [[UIButton initMethods:@selector(addSubview:)] count]);
    XCTAssertEqual(2, [[UIButton initMethods:@selector(addSubview:)] count]);
}

- (void)testTreeViewPrototype
{
    // Build Tree
    UIView *view = [UIView new];
    view.simiObjectName = @"root";
    UIImageView *child1 = [UIImageView new];
    child1.simiObjectIdentifier = @"image1";
    UIImageView *child2 = [UIImageView new];
    child2.simiObjectName = @"image";
    UIScrollView *scroll = [UIScrollView new];
    scroll.simiObjectName = @"image";
    [view addSubview:child1];
    [view addSubview:child2];
    [view addSubview:scroll];
    
    UIView *sc1 = [UIView new];
    UIView *sc2 = [UIView new];
    sc2.simiObjectIdentifier = @"scroll";
    [scroll addSubview:sc1];
    [scroll addSubview:sc2];
    
    // Test selector methods
    [self measureBlock:^{
        XCTAssertEqualObjects(view, [sc1 up:@".root"]);
        NSArray *images = [view allSubviews:@".image"];
        XCTAssertEqual(2, [images count]);
        XCTAssertEqualObjects(child1, [view down:@"UIImageView#image1"]);
        XCTAssertEqual(2, [[view allSubviews:@"UIImageView"] count]);
        XCTAssertEqual(2, [[view allSubviews:@"UIView"] count]);
        XCTAssertEqualObjects(sc2, [view down:@"UIScrollView #scroll"]);
        XCTAssertEqual(1, [[view allSubviews:@"UIScrollView #scroll"] count]);
    }];
}

- (void)testListView
{
    // Init List View Tree
    SimiListView *list = [SimiListView new];
    // Children
    UIView *c1 = [UIView new];
    UIView *c2 = [UIView new];
    UIView *c3 = [UIView new];
    
    [list addSubview:c1];
    [list addSubview:c3];
    [list insertSubview:c2 atIndex:1];
    
    XCTAssertEqualObjects(c1, [list.subviews objectAtIndex:0]);
    XCTAssertEqualObjects(c2, [list.subviews objectAtIndex:1]);
    XCTAssertEqualObjects(c3, [list.subviews objectAtIndex:2]);
}

- (void)testSortMenuTabs
{
    SimiCartMenuSection *sec = [SimiCartMenuSection new];
    SimiCartMenuItem *item1 = [SimiCartMenuItem new];
    item1.sortOrder = 1;
    SimiCartMenuItem *item2 = [SimiCartMenuItem new];
    item2.sortOrder = 2;
    [sec addItem:item2];
    [sec addItem:item1];
    
    XCTAssertEqual(2, [[sec.items objectAtIndex:0] sortOrder]);
    XCTAssertEqual(1, [[sec.items objectAtIndex:1] sortOrder]);
    [sec sortMenuItems];
    XCTAssertEqual(1, [[sec.items objectAtIndex:0] sortOrder]);
    XCTAssertEqual(2, [[sec.items objectAtIndex:1] sortOrder]);
    
    SimiCartTabsBlock *block = [SimiCartTabsBlock new];
    [block addTab:nil content:nil sortOrder:2];
    [block addTab:nil content:nil sortOrder:1];
    
    XCTAssertEqual(2, [[block.tabs objectAtIndex:0] sortOrder]);
    XCTAssertEqual(1, [[block.tabs objectAtIndex:1] sortOrder]);
    [block sortTabs];
    XCTAssertEqual(1, [[block.tabs objectAtIndex:0] sortOrder]);
    XCTAssertEqual(2, [[block.tabs objectAtIndex:1] sortOrder]);
}

- (void)testValidMethod
{
    SimiFormAbstract *field1 = [[SimiFormAbstract alloc] initWithConfig:@{@"required":@1}];
    SimiFormAbstract *field2 = [[SimiFormAbstract alloc] initWithConfig:nil];
    
    XCTAssertEqual(NO, [field1 isDataValid]);
    XCTAssertEqual(YES, [field2 isDataValid]);
}

@end
