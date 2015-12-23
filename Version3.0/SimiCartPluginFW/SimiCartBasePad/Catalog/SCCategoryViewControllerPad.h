

#import <UIKit/UIKit.h>
#import "SCCategoryViewController.h"
#import "SimiSection.h"
#import "SimiRow.h"

@protocol SCCategoryViewControllerPad_Delegate <NSObject>
- (void)openCategoryProductsListWithCategoryId:(NSString *)categoryId;
@end



@interface SCCategoryViewControllerPad : SCCategoryViewController

@property (strong, nonatomic) id<SCCategoryViewControllerPad_Delegate> delegate;
@property (strong, nonatomic) NSString * categoryName;
@property (strong, nonatomic) NSString * parentName;
@property (strong, nonatomic) NSString * parentId;
@property (strong, nonatomic) NSMutableDictionary * categoriesSaved;
-(void)updateCategoryTitle: (NSString *)categoryTitle withParentTitle: (NSString *)parentTitle andParentId: (NSString *)parentId;
@end


@interface SCCategoryViewControllerPadCell : UITableViewCell
@property (nonatomic) BOOL isBackCell;
@property (nonatomic) BOOL isTitleCell;

@end
