//
//  SimiTheme.h
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 6/24/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SimiThemeMethods <NSObject>

@optional
// Theme name
- (NSString *)getThemeName;

// Theme fonts
- (NSString *)getFontName;
- (CGFloat)getFontSize;
- (CGFloat)getFontSizeRegular;

// Theme colors
- (UIColor *)navigationIconColor;
- (UIColor *)themeColor;
- (UIColor *)menuTextColor;
- (UIColor *)menuBackgroundColor;
- (UIColor *)menuLineColor;
- (UIColor *)menuIconColor;
- (UIColor *)buttonBackgroundColor;
- (UIColor *)buttonTextColor;
- (UIColor *)appBackgroundColor;
- (UIColor *)contentColor;
- (UIColor *)lineColor;
- (UIColor *)imageBorderColor;
- (UIColor *)iconColor;
- (UIColor *)priceColor;
- (UIColor *)specialPriceColor;
- (UIColor *)sectionColor;
- (UIColor *)searchBoxBackgroundColor;
- (UIColor *)searchTextColor;
- (UIColor *)searchIconColor;
- (UIColor *)outStockBackgroundColor;
- (UIColor *)outStockTextColor;
- (UIColor *)textColor;
- (UIColor *)lightTextColor;

// Theme configurations
- (BOOL)isColorOverlay;

// Format title
- (NSString *)formatTitleString:(NSString *)title;

@end

@interface SimiTheme : NSObject <SimiThemeMethods>

@end
