//
//  SCProductCollectionViewControllerPad.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/18/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCProductCollectionViewControllerPad.h"
#import "SCProductCollectionViewCellPad.h"
@interface SCProductCollectionViewControllerPad ()

@end

@implementation SCProductCollectionViewControllerPad

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SimiProductModel *product = [self.productCollection objectAtIndex:[indexPath row]];
    NSString *stringCell = [NSString stringWithFormat:@"CELL_ID%@",[product valueForKey:@"_id"]];
    [collectionView registerClass:[SCProductCollectionViewCellPad class] forCellWithReuseIdentifier:stringCell];
    SCProductCollectionViewCellPad *cell = [collectionView dequeueReusableCellWithReuseIdentifier:stringCell forIndexPath:indexPath];
    if (cell.isShowOnlyImage != self.isShowOnlyImage) {
        cell.isShowOnlyImage = self.isShowOnlyImage;
        cell.isChangeLayOut = YES;
    }else
    {
        cell.isChangeLayOut = NO;
    }
    [cell cusSetProductModel:product];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedCollectionViewCellAtIndexPath-After" object:cell userInfo:@{@"indexPath": indexPath}];
    return cell;
}

- (void)setLayout
{
    minimumImageSize = 161.33;
    maximumImageSize = 246;
    heightLabel = 20;
    padding = 8;
    paddingTop = 60;
    paddingBottom = 40;
    lineSpace = 20;
    if (self.isShowOnlyImage) {
        UICollectionViewFlowLayout *grid = [[UICollectionViewFlowLayout alloc]init];
        grid.itemSize = [SimiGlobalVar scaleSize:CGSizeMake(minimumImageSize, minimumImageSize)];
        grid.minimumInteritemSpacing = [SimiGlobalVar scaleValue:padding];
        grid.minimumLineSpacing = [SimiGlobalVar scaleValue:padding];
        // Hide all text
        [self.collectionView reloadData];
        [self.collectionView setCollectionViewLayout:grid animated:YES completion:^(BOOL finished) {
        }];
        [self.collectionView setContentInset:UIEdgeInsetsMake([SimiGlobalVar scaleValue:paddingTop], [SimiGlobalVar scaleValue:5], paddingBottom, [SimiGlobalVar scaleValue:padding])];
        self.collectionView.showsVerticalScrollIndicator = NO;
    }else
    {
        UICollectionViewFlowLayout *grid = [[UICollectionViewFlowLayout alloc]init];
        grid.itemSize = [SimiGlobalVar scaleSize:CGSizeMake(maximumImageSize, maximumImageSize + 2* heightLabel)];
        grid.minimumInteritemSpacing = [SimiGlobalVar scaleValue:padding];
        grid.minimumLineSpacing = [SimiGlobalVar scaleValue:lineSpace];
        __block __weak SCProductCollectionViewControllerPad *weakSelf =  self;
        [self.collectionView setCollectionViewLayout:grid animated:YES completion:^(BOOL finished) {
           [weakSelf.collectionView reloadData];
        }];
        [self.collectionView setContentInset:UIEdgeInsetsMake([SimiGlobalVar scaleValue:paddingTop], [SimiGlobalVar scaleValue:padding], paddingBottom, [SimiGlobalVar scaleValue:padding])];
        self.collectionView.showsVerticalScrollIndicator = NO;
    }
}

#pragma mark Scroll View Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isShowOnlyImage) {
        if (self.productCollection.count % 6 != 0) {
            numberRow = self.productCollection.count/6 + 1;
        }else
            numberRow = self.productCollection.count/6;
        maxScrollOffset = numberRow *(minimumImageSize + padding) - (SCREEN_HEIGHT - 64);
    }else
    {
        if (self.productCollection.count % 4 != 0) {
            numberRow = self.productCollection.count/4 +1;
        }else
            numberRow = self.productCollection.count/4;
        maxScrollOffset = numberRow *(maximumImageSize + 2 *heightLabel + lineSpace) - (SCREEN_HEIGHT - 64);
    }
    if (scrollView.contentOffset.y > - [SimiGlobalVar scaleValue:paddingTop] && scrollView.contentOffset.y < maxScrollOffset) {
        if (self.lastContentOffset > scrollView.contentOffset.y)
        {
            [self.delegate setHideViewToolBar:NO];
        }
        else if (self.lastContentOffset < scrollView.contentOffset.y)
        {
            [self.delegate setHideViewToolBar:YES];
        }
        self.lastContentOffset = scrollView.contentOffset.y;
    }
}
@end
