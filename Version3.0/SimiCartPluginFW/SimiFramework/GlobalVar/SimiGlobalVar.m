//
//  SimiGlobalVar.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/19/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiGlobalVar.h"

@implementation SimiGlobalVar

@synthesize isLogin, customer, store;

+ (id)sharedInstance{
    static SimiGlobalVar *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SimiGlobalVar alloc] init];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            if (SCREEN_WIDTH == 320) {
                _sharedInstance.phoneUsing = CurrentVersionPhoneUsingiPhone5andBefore;
            }else if(SCREEN_WIDTH == 375)
            {
                _sharedInstance.phoneUsing = CurrentVersionPhoneUsingiPhone6;
            }else if(SCREEN_WIDTH == 414)
            {
                _sharedInstance.phoneUsing = CurrentVersionPhoneUsingiPhone6Plus;
            }
        }
    });
    return _sharedInstance;
}

- (UIColor *)colorWithHexString:(NSString *)str {
    const char *cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
    long x = strtol(cStr+1, NULL, 16);
    return [self colorWithHex:(UInt32)x];
}

- (UIColor *)colorWithHexString:(NSString *)str alpha:(CGFloat)alpha
{
    const char *cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
    long x = strtol(cStr+1, NULL, 16);
    return [self colorWithHex:(UInt32)x alpha:alpha];
}

- (UIColor *)colorWithHex:(UInt32)col alpha:(CGFloat)alpha {
    unsigned char r, g, b;
    b = col & 0xFF;
    g = (col >> 8) & 0xFF;
    r = (col >> 16) & 0xFF;
    return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:alpha];
}

- (UIColor *)colorWithHex:(UInt32)col {
    unsigned char r, g, b;
    b = col & 0xFF;
    g = (col >> 8) & 0xFF;
    r = (col >> 16) & 0xFF;
    return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:1];
}

- (UIColor *)darkerColorForColor:(UIColor *)c
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - 0.3, 0.0)
                               green:MAX(g - 0.3, 0.0)
                                blue:MAX(b - 0.3, 0.0)
                               alpha:a];
    return nil;
}

- (UIImage *)imageFromColor:(UIColor *)color{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)resetQuote
{
    [[SimiGlobalVar sharedInstance] setQuoteId:nil];
    [SimiGlobalVar sharedInstance].cart = nil;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults valueForKey:@"quoteId"]) {
        [userDefaults setValue:@"" forKey:@"quoteId"];
        [userDefaults synchronize];
    }
}

#pragma mark - Theme method
- (UIColor *)themeColor{
    UIColor *color = [self colorWithHexString: kThemeColorHex];
    NSString *keyColor = [[self.appConfigure valueForKey:@"theme"]valueForKey:@"key_color"];
    if (keyColor != nil) {
        color = [self colorWithHexString:keyColor];
    }
    return color;
}

+ (UIColor *)getThemeColor:(SEL)themeSelector
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:themeSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return (UIColor *)[theme performSelector:themeSelector];
#pragma clang diagnostic pop
    }
    return nil;
}

+ (BOOL)getThemeConfig:(SEL)themeSelector
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:themeSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return (BOOL)[theme performSelector:themeSelector];
#pragma clang diagnostic pop
    }
    return YES;
}

+ (NSString *)getThemeName
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:@selector(getThemeName)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return (NSString *)[theme performSelector:@selector(getThemeName)];
#pragma clang diagnostic pop
    }
    return nil;
}

+ (NSString *)getFontName
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:@selector(getFontName)]) {
        return [theme getFontName];
    }
    return @"ProximaNova-Light";
}

+ (NSString *)getFontNameRegular
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:@selector(getFontName)]) {
        return [theme getFontName];
    }
    return @"ProximaNova-Regular";
}

+ (CGFloat)getFontSize
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:@selector(getFontSize)]) {
        return [theme getFontSize];
    }
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 16 : 18;
}

+ (CGFloat)getFontSizeRegular
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:@selector(getFontSizeRegular)]) {
        return [theme getFontSizeRegular];
    }
    return 14;
}

//end King update 151004

- (UIColor *)navigationIconColor
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:@selector(menuTextColor)]) {
        return [theme navigationIconColor];
    }
    if([[self.appConfigure valueForKey:@"theme"] valueForKey:@"top_menu_icon_color"]){
        NSString *color = [[self.appConfigure valueForKey:@"theme"] valueForKey:@"top_menu_icon_color"];
        return [self colorWithHexString:color];
    }
    return [UIColor whiteColor];
}
- (UIColor *)menuTextColor
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:@selector(menuTextColor)]) {
        return [theme menuTextColor];
    }
    if([[self.appConfigure valueForKey:@"theme"] valueForKey:@"menu_text_color"]){
        NSString *color = [[self.appConfigure valueForKey:@"theme"] valueForKey:@"menu_text_color"];
        return [self colorWithHexString:color];
    }
    return [UIColor whiteColor];
}

- (UIColor *)menuBackgroundColor
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:@selector(menuBackgroundColor)]) {
        return [theme menuBackgroundColor];
    }
    if([[self.appConfigure valueForKey:@"theme"] valueForKey:@"menu_background"]){
        NSString *color = [[self.appConfigure valueForKey:@"theme"] valueForKey:@"menu_background"];
        return [self colorWithHexString:color];
    }
    return [self colorWithHexString:@"#1b1b1b" alpha:0.5];
}


- (UIColor *)menuLineColor
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:@selector(menuLineColor)]) {
        return [theme menuLineColor];
    }
    if([[self.appConfigure valueForKey:@"theme"] valueForKey:@"menu_line_color"]){
        NSString *color = [[self.appConfigure valueForKey:@"theme"] valueForKey:@"menu_line_color"];
        return [self colorWithHexString:color alpha:0.5];
    }
    return [UIColor colorWithWhite:1.0 alpha:0.1];
}

- (UIColor *)menuIconColor
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:@selector(menuIconColor)]) {
        return [theme menuIconColor];
    }
    if([[self.appConfigure valueForKey:@"theme"] valueForKey:@"menu_icon_color"]){
        NSString *color = [[self.appConfigure valueForKey:@"theme"] valueForKey:@"menu_icon_color"];
        return [self colorWithHexString:color];
    }
    return [UIColor whiteColor];
}

- (UIColor *)buttonBackgroundColor
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:@selector(buttonBackgroundColor)]) {
        return [theme buttonBackgroundColor];
    }
    if([[self.appConfigure valueForKey:@"theme"] valueForKey:@"button_background"]){
        NSString *color = [[self.appConfigure valueForKey:@"theme"] valueForKey:@"button_background"];
        return [self colorWithHexString:color];
    }
    return THEME_COLOR;
}

- (UIColor *)buttonTextColor
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:@selector(buttonTextColor)]) {
        return [theme buttonTextColor];
    }
    if([[self.appConfigure valueForKey:@"theme"] valueForKey:@"button_text_color"]){
        NSString *color = [[self.appConfigure valueForKey:@"theme"] valueForKey:@"button_text_color"];
        return [self colorWithHexString:color];
    }
    return [UIColor whiteColor];
}

- (UIColor *)appBackgroundColor
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:@selector(appBackgroundColor)]) {
        return [theme appBackgroundColor];
    }
    if([[self.appConfigure valueForKey:@"theme"] valueForKey:@"app_background"]){
        NSString *color = [[self.appConfigure valueForKey:@"theme"] valueForKey:@"app_background"];
        return [self colorWithHexString:color];
    }
    return [UIColor whiteColor];
}

- (UIColor *)contentColor
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:@selector(contentColor)]) {
        return [theme menuIconColor];
    }
    if([[self.appConfigure valueForKey:@"theme"] valueForKey:@"content_color"]){
        NSString *color = [[self.appConfigure valueForKey:@"theme"] valueForKey:@"content_color"];
        return [self colorWithHexString:color];
    }
    return [UIColor blackColor];
}

- (UIColor *)placeHolderColor
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:@selector(contentColor)]) {
        return [theme menuIconColor];
    }
    if([[self.appConfigure valueForKey:@"theme"] valueForKey:@"content_color"]){
        NSString *color = [[self.appConfigure valueForKey:@"theme"] valueForKey:@"content_color"];
        return [self colorWithHexString:color alpha:0.5];
    }
    return [UIColor lightGrayColor];
}

- (UIColor *)lineColor
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:@selector(lineColor)]) {
        return [theme lineColor];
    }
    if([[self.appConfigure valueForKey:@"theme"] valueForKey:@"line_color"]){
        NSString *color = [[self.appConfigure valueForKey:@"theme"] valueForKey:@"line_color"];
        return [self colorWithHexString:color];
    }
    return [self colorWithHexString:@"#e8e8e8"];
}

- (UIColor *)imageBorderColor
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:@selector(imageBorderColor)]) {
        return [theme imageBorderColor];
    }
    if([[self.appConfigure valueForKey:@"theme"] valueForKey:@"image_border_color"]){
        NSString *color = [[self.appConfigure valueForKey:@"theme"] valueForKey:@"image_border_color"];
        return [self colorWithHexString:color];
    }
    return [self colorWithHexString:@"#f5f5f5"];
}

- (UIColor *)iconColor
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:@selector(iconColor)]) {
        return [theme iconColor];
    }
    if([[self.appConfigure valueForKey:@"theme"] valueForKey:@"icon_color"]){
        NSString *color = [[self.appConfigure valueForKey:@"theme"] valueForKey:@"icon_color"];
        return [self colorWithHexString:color];
    }
    return [self colorWithHexString:@"#717171"];
}

- (UIColor *)priceColor
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:@selector(priceColor)]) {
        return [theme priceColor];
    }
    if([[self.appConfigure valueForKey:@"theme"] valueForKey:@"price_color"]){
        NSString *color = [[self.appConfigure valueForKey:@"theme"] valueForKey:@"price_color"];
        return [self colorWithHexString:color];
    }
    return [UIColor redColor];
}

- (UIColor *)specialPriceColor
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:@selector(specialPriceColor)]) {
        return [theme specialPriceColor];
    }
    if([[self.appConfigure valueForKey:@"theme"] valueForKey:@"special_price_color"]){
        NSString *color = [[self.appConfigure valueForKey:@"theme"] valueForKey:@"special_price_color"];
        return [self colorWithHexString:color];
    }
    return [UIColor redColor];
}

- (UIColor *)sectionColor
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:@selector(sectionColor)]) {
        return [theme sectionColor];
    }
    if([[self.appConfigure valueForKey:@"theme"] valueForKey:@"section_color"]){
        NSString *color = [[self.appConfigure valueForKey:@"theme"] valueForKey:@"section_color"];
        return [self colorWithHexString:color];
    }
    return [self colorWithHexString:@"#f8f8f9"];
}

- (UIColor *)searchBoxBackgroundColor
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:@selector(searchBoxBackgroundColor)]) {
        return [theme searchBoxBackgroundColor];
    }
    if([[self.appConfigure valueForKey:@"theme"] valueForKey:@"search_box_background"]){
        NSString *color = [[self.appConfigure valueForKey:@"theme"] valueForKey:@"search_box_background"];
        return [self colorWithHexString:color];
    }
    return [self colorWithHexString:@"#f3f3f3"];
}

- (UIColor *)searchTextColor
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:@selector(searchTextColor)]) {
        return [theme searchTextColor];
    }
    if([[self.appConfigure valueForKey:@"theme"] valueForKey:@"search_text_color"]){
        NSString *color = [[self.appConfigure valueForKey:@"theme"] valueForKey:@"search_text_color"];
        return [self colorWithHexString:color];
    }
    return [UIColor grayColor];
}

- (UIColor *)searchIconColor
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:@selector(searchIconColor)]) {
        return [theme searchIconColor];
    }
    if([[self.appConfigure valueForKey:@"theme"] valueForKey:@"search_icon_color"]){
        NSString *color = [[self.appConfigure valueForKey:@"theme"] valueForKey:@"search_icon_color"];
        return [self colorWithHexString:color];
    }
    return [UIColor grayColor];
}

- (UIColor *)outStockBackgroundColor
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:@selector(outStockBackgroundColor)]) {
        return [theme outStockBackgroundColor];
    }
    if([[self.appConfigure valueForKey:@"theme"] valueForKey:@"out_stock_background"]){
        NSString *color = [[self.appConfigure valueForKey:@"theme"] valueForKey:@"out_stock_background"];
        return [self colorWithHexString:color];
    }
    return [UIColor whiteColor];
}

- (UIColor *)outStockTextColor
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:@selector(outStockBackgroundColor)]) {
        return [theme outStockBackgroundColor];
    }
    if([[self.appConfigure valueForKey:@"theme"] valueForKey:@"out_stock_text_color"]){
        NSString *color = [[self.appConfigure valueForKey:@"theme"] valueForKey:@"out_stock_text_color"];
        return [self colorWithHexString:color];
    }
    return [UIColor whiteColor];
}


- (UIColor *)textColor
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:@selector(textColor)]) {
        return [theme textColor];
    }
    if([[self.appConfigure valueForKey:@"theme"] valueForKey:@"content_color"]){
        NSString *color = [[self.appConfigure valueForKey:@"theme"] valueForKey:@"content_color"];
        return [self colorWithHexString:color];
    }
    return [UIColor darkGrayColor];
}

- (UIColor *)lightTextColor
{
    SimiTheme *theme = [SimiTheme singleton];
    if ([theme respondsToSelector:@selector(lightTextColor)]) {
        return [theme lightTextColor];
    }
    return [UIColor lightGrayColor];
}

//end King update 151004

+ (CGFloat)scaleValue: (CGFloat)inputValue
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return inputValue *SCREEN_WIDTH/1024;
    }
    return inputValue * SCREEN_WIDTH/320;
}

+ (CGSize)scaleSize:(CGSize)inputSize
{
    return CGSizeMake([self scaleValue:inputSize.width], [self scaleValue:inputSize.height]);
}

+ (CGRect)scaleFrame: (CGRect)inputFrame
{
    return CGRectMake([self scaleValue:inputFrame.origin.x], [self scaleValue:inputFrame.origin.y], [self scaleValue:inputFrame.size.width], [self scaleValue:inputFrame.size.height]);
}


#pragma mark - Store methods
- (NSString *)currencySymbol{
    return [[[[self.store valueForKey:@"format_options"] valueForKey:@"currency"] valueForKey:@"base_currency"] valueForKey:@"symbol"] ? [[[[self.store valueForKey:@"format_options"] valueForKey:@"currency"] valueForKey:@"base_currency"] valueForKey:@"symbol"] : @"";
}

- (NSString *)currencyCode{
    return [[[[self.store valueForKey:@"format_options"] valueForKey:@"currency"] valueForKey:@"base_currency"] valueForKey:@"code"] ? [[[[self.store valueForKey:@"format_options"] valueForKey:@"currency"] valueForKey:@"base_currency"] valueForKey:@"code"] : @"";
}

- (NSString *)localeIdentifier{
    return [self.currentLocale valueForKey:@"code"] ? [self.currentLocale valueForKey:@"code"] : @"";
}

- (NSString *)countryCode{
    return [[[self.store valueForKey:@"general"] valueForKey:@"country"]valueForKey:@"code"] ? [[[self.store valueForKey:@"general"] valueForKey:@"country"]valueForKey:@"code"] : @"";
}

//Axe edited
- (NSString *)currencyPosition{
    NSString* currency_position = [[[self.store valueForKey:@"format_options"] valueForKey:@"currency"]valueForKey:@"currency_position"];
    return currency_position? currency_position : @"";
}

-(NSString *) thousandSeparator{
    return [[[self.store valueForKey:@"format_options"] valueForKey:@"currency"]valueForKey:@"thousand_separator"];
}

-(NSString *) decimalSeparator{
   return [[[self.store valueForKey:@"format_options"] valueForKey:@"currency"]valueForKey:@"decimal_separator"];
    
}

-(NSString* )numberOfDecimals{
    return [[[self.store valueForKey:@"format_options"] valueForKey:@"currency"]valueForKey:@"number_of_decimals"];
    
}

- (BOOL)isShowZeroPrice{
    if([[[self.store valueForKey:@"store_config"] valueForKey:@"is_show_zero_price"] isEqualToString:@"1"]){
        return YES;
    }
    return NO;
}

- (NSString *)countryName{
    return [[self.store valueForKey:@"store_config"] valueForKey:@"country_name"] ? [[self.store valueForKey:@"store_config"] valueForKey:@"country_name"] : @"";
}

- (NSString *)localizedStringForKey:(NSString *)key{
    NSString *localeKey = [NSString stringWithFormat:@"%@_%@", LOCALE_IDENTIFIER, key];
    NSString *temp = NSLocalizedString(localeKey, nil);
    if ([temp rangeOfString:LOCALE_IDENTIFIER].location != NSNotFound) {
        localeKey = [NSString stringWithFormat:@"%@_%@", LOCALE_IDENTIFIER, [key lowercaseString]];
        temp = NSLocalizedString(localeKey, nil);
    }
    if ([temp rangeOfString:LOCALE_IDENTIFIER].location != NSNotFound || LOCALE_IDENTIFIER.length == 0) {
        temp = NSLocalizedString(key, nil);
    }
    return temp;
}

- (NSString *)countryCollectionStorePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryPath = [paths objectAtIndex:0];
    NSString *addressTempPath = [libraryPath stringByAppendingPathComponent:@"Countries.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:addressTempPath]) {
        addressTempPath = [libraryPath stringByAppendingPathComponent:@"Countries.plist"];
    }
    return addressTempPath;
}

- (CGFloat)getLightDegreeOfColor:(UIColor *)color{
    const CGFloat *rgbValues = CGColorGetComponents(color.CGColor);
    CGFloat r = rgbValues[0];
    CGFloat g = rgbValues[1];
    CGFloat b = rgbValues[2];
    CGFloat lightDegree = ((r * 299) + (g * 587) + (b * 114)) / 1000;
    return lightDegree;
}

- (SimiCartModelCollection *)cart{
    if (_cart == nil) {
        _cart = [[SimiCartModelCollection alloc] init];
    }
    return _cart;
}

#pragma mark - Customer address methods

- (NSString *)getGenderLabel: (int) value{
    if(value == 123){
        return [NSString stringWithFormat:@"Male"];
    }else{
        return [NSString stringWithFormat:@"Female"];
    }
}

- (BOOL) displayPricesInShop
{
    if ([[[[[SimiGlobalVar sharedInstance]store] valueForKey:@"tax"] valueForKey:@"display_prices_in_shop"] isEqualToString:@"Including Tax"]) {
        return YES;
    }
    return NO;
}

@end
