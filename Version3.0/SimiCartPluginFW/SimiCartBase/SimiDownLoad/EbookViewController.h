//
//  ViewController.h
//  testPubb
//
//  Created by Shrutesh on 07/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EpubContent.h"
#import "XMLHandler.h"
#import <QuartzCore/QuartzCore.h>

@interface EbookViewController : UIViewController<XMLHandlerDelegate,UIGestureRecognizerDelegate,UIWebViewDelegate,UISearchBarDelegate>{
    UILabel *_pageNumberLbl;
    XMLHandler *_xmlHandler;
	EpubContent *_ePubContent;
	NSString *_pagesPath;
	NSString *_rootPath;
	NSString *_strFileName;
	int _pageNumber;
    NSUInteger textFontSize;
    BOOL isInverted;
    NSString *textColor;
    NSString *backgroundColor;
}
@property (nonatomic, strong)EpubContent *_ePubContent;
@property (nonatomic, strong)NSString *_rootPath;
@property (nonatomic, strong)NSString *_strFileName;
@property (nonatomic, strong)NSString *filePath;
@property (nonatomic, strong)UIWebView *_webview;
@property (nonatomic, strong)UIButton *btnDone;
@property (nonatomic, strong)UIButton *btnPlusA;
@property (nonatomic, strong)UIButton *btnMinusA;
@property (nonatomic, strong)UIButton *btnDay;
@property (nonatomic, strong)UIButton *btnNight;
@property (nonatomic, strong)UIButton *btnNext;
@property (nonatomic, strong)UIButton *btnPreview;

- (void)unzipAndSaveFile;
- (NSString *)applicationDocumentsDirectory; 
- (void)loadPage;
- (NSString*)getRootFilePath;

- (NSInteger)stringHighlight:(NSString*)str;
- (void)removeHighlightsB;


-(void)plusA:(id)sender;
-(void)minusA:(id)sender;
-(void)day:(id)sender;
-(void)night:(id)sender;

- (void)next:(id)ignored;
- (void)prev:(id)ignored;


@end
