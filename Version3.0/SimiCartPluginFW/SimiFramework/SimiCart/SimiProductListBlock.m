//
//  SimiProductListBlock.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiProductListBlock.h"
#import "SCProductListCell.h"

@implementation SimiProductListBlock

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Init cell
    static NSString *productListIdentifier = @"ProductListIdentifier";
    SCProductListCell *cell = [tableView dequeueReusableCellWithIdentifier:productListIdentifier];
    cell = [[[NSBundle mainBundle]loadNibNamed:@"SCProductListCell" owner:self options:nil]objectAtIndex:0];
    NSInteger row = indexPath.row;
    //Set cell data
    SimiProductModel *product = [self.collection objectAtIndex:row];
    [product setValue:[NSString stringWithFormat:@"%ld. %@", (long)row+1, [product valueForKey:@"product_name"]] forKey:@"cell_product_name"];
    cell.product = product;
    [cell setInterfaceCell];
    //Set cell style
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedProductListCell-After" object:cell userInfo:@{@"indexPath": indexPath}];
    return cell;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UINib *nib = [UINib nibWithNibName:@"SCCollectionViewCell" bundle:nil];
    [collectionView registerNib:nib forCellWithReuseIdentifier:@"Cell_Table"];
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell_Table" forIndexPath:indexPath];
    SimiProductModel *product = [self.collection objectAtIndex:[indexPath row]];
    [product setValue:[NSString stringWithFormat:@"%ld. %@", (long)[indexPath row]+1, [product valueForKey:@"product_name"]] forKey:@"cell_product_name"];
    [(SCProductListCell *)cell setProduct:product];
    [(SimiProductListBlock *)cell reArrangingFrame:2];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedCollectionViewCellAtIndexPath-After" object:cell userInfo:@{@"indexPath": indexPath}];
    return cell;
}

- (void)reArrangingFrame:(int)CollectionViewType
{
    
}

@end
