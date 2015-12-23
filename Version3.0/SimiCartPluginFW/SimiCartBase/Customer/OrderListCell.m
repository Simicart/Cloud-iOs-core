//
//  OrderListCell.m
//  SimiCart
//
//  Created by Tan on 7/30/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import "OrderListCell.h"

@implementation OrderListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        float fontSize = 15;
        float originalTitleX = [SimiGlobalVar scaleValue:20];
        float originalValueX = [SimiGlobalVar scaleValue:140];
        float widthTitle = [SimiGlobalVar scaleValue:100];
        float widthItem = [SimiGlobalVar scaleValue:280];
        float widthValue = [SimiGlobalVar scaleValue:160];
        float heightLabel = [SimiGlobalVar scaleValue:20];
        float heightLabelWithSpace = 20;
        float heightCell = 5;
        //  Gin Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            originalValueX = [SimiGlobalVar scaleValue:20];
            originalTitleX = [SimiGlobalVar scaleValue:190];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                widthItem = 620;
                widthValue = 500;
                originalTitleX = 540;
            }
        }
        //  End RTL
        //Gin edit 030815
        _statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(originalTitleX, heightCell, widthTitle, heightLabel)];
        [_statusLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME_REGULAR] size:fontSize]];
        [_statusLabel setText: SCLocalizedString(@"Order Status")];
        [_statusLabel setTextColor:THEME_CONTENT_COLOR];
        [self addSubview:_statusLabel];
        
        _statusValueLabel = [[UILabel alloc]initWithFrame:CGRectMake(originalValueX, heightCell, widthValue, heightLabel)];
        [_statusValueLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:fontSize]];
        [_statusValueLabel setTextColor:THEME_CONTENT_COLOR];
        [self addSubview:_statusValueLabel];
        heightCell += heightLabelWithSpace;
        
        _datelabel = [[UILabel alloc]initWithFrame:CGRectMake(originalTitleX, heightCell, widthTitle, heightLabel)];
        [_datelabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME_REGULAR] size:fontSize]];
        [_datelabel setText: SCLocalizedString(@"Order Date")];
        [_datelabel setTextColor:THEME_CONTENT_COLOR];
        [self addSubview:_datelabel];
        
        _dateValueLabel = [[UILabel alloc]initWithFrame:CGRectMake(originalValueX, heightCell, widthValue, heightLabel)];
        [_dateValueLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:fontSize]];
        [_dateValueLabel setTextColor:THEME_CONTENT_COLOR];
        [self addSubview:_dateValueLabel];
        heightCell += heightLabelWithSpace;
        
        _recipientLabel = [[UILabel alloc]initWithFrame:CGRectMake(originalTitleX, heightCell, widthTitle, heightLabel)];
        [_recipientLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME_REGULAR] size:fontSize]];
        [_recipientLabel setTextColor:THEME_CONTENT_COLOR];
        [_recipientLabel setText: SCLocalizedString(@"Recipient")];
        [self addSubview:_recipientLabel];
        
        _recipientValueLabel = [[UILabel alloc]initWithFrame:CGRectMake(originalValueX, heightCell, widthValue, heightLabel)];
        [_recipientValueLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:fontSize]];
        [_recipientValueLabel setTextColor:THEME_CONTENT_COLOR];
        [self addSubview:_recipientValueLabel];
        heightCell += heightLabelWithSpace;
        
        _itemLabel = [[UILabel alloc]initWithFrame:CGRectMake(originalTitleX, heightCell, widthTitle, heightLabel)];
        [_itemLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME_REGULAR] size:fontSize]];
        [_itemLabel setText: SCLocalizedString(@"Items")];
        [_itemLabel setTextColor:THEME_CONTENT_COLOR];
        [self addSubview:_itemLabel];
        heightCell += heightLabelWithSpace;
        
        _itemValueLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, heightCell, widthItem, heightLabel*2)];
        _itemValueLabel.numberOfLines = 2;
        [_itemValueLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:fontSize]];
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [_itemValueLabel setFrame:CGRectMake(10, heightCell, widthItem, heightLabel*2)];
        }
        [_itemValueLabel setTextColor:THEME_CONTENT_COLOR];
        [self addSubview:_itemValueLabel];
        //end
        //  Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [_statusLabel setTextAlignment:NSTextAlignmentRight];
            [_statusValueLabel setTextAlignment:NSTextAlignmentRight];
            [_datelabel setTextAlignment:NSTextAlignmentRight];
            [_dateValueLabel setTextAlignment:NSTextAlignmentRight];
            [_recipientValueLabel setTextAlignment:NSTextAlignmentRight];
            [_recipientLabel setTextAlignment:NSTextAlignmentRight];
            [_itemLabel setTextAlignment:NSTextAlignmentRight];
            [_itemValueLabel setTextAlignment:NSTextAlignmentRight];
        }
        //  End RTL
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil {
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:nibNameOrNil owner:self options:nil];
    self = [nibObjects objectAtIndex:0];
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setOrderModel:(SimiOrderModel *)orderModel
{
    if (orderModel) {
        _orderModel = orderModel;
        [_statusValueLabel setText:[_orderModel valueForKey:@"status"]];
        [_dateValueLabel setText:[_orderModel valueForKey:@"created_at"]];
        [_recipientValueLabel setText:[_orderModel valueForKey:@"bill_name"]];
        NSLog(@"%@,%@,%@",_statusValueLabel.text,_dateValueLabel.text,_recipientValueLabel.text);
        NSArray *objects = [_orderModel valueForKey:@"items"];
        NSString *string = [NSString stringWithFormat:@"● %@", [[objects objectAtIndex:0] valueForKey:@"name"]];
        for (int i = 1; i < objects.count; i++) {
            string = [NSString stringWithFormat:@"%@\n● %@", string, [[objects objectAtIndex:i] valueForKey:@"name"]];
        }
        //  Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            string = [NSString stringWithFormat:@"%@ ●", [[objects objectAtIndex:0] valueForKey:@"name"]];
            for (int i = 1; i < objects.count; i++) {
                string = [NSString stringWithFormat:@"%@\n%@ ●", string, [[objects objectAtIndex:i] valueForKey:@"name"]];
            }
        }
        //  End RTL
        [_itemValueLabel setText:string];
        NSLog(@"%@",_itemValueLabel.text);
    }
}

@end
