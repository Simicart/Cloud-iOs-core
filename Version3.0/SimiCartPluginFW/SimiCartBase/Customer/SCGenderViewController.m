//
//  SCGenderViewController.m
//  SimiCartPluginFW
//
//  Created by KingRetina on 8/11/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCGenderViewController.h"

@interface SCGenderViewController ()

@end

@implementation SCGenderViewController

@synthesize genderList, tableViewGender, selectedGender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoadAfter
{
    [super viewDidLoadAfter];
    // Do any additional setup after loading the view.
    genderList = [NSArray arrayWithObjects:SCLocalizedString(@"Male"), SCLocalizedString(@"Female"), nil];
    CGRect frame = self.view.frame;
    tableViewGender = [[SimiTableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    tableViewGender.delegate = self;
    tableViewGender.dataSource = self;
    tableViewGender.separatorColor = tableViewGender.backgroundColor;
    tableViewGender.scrollEnabled = NO;
    [self.view addSubview:tableViewGender];
    [tableViewGender reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
    return [genderList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 40;
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;;
    cell = [tableView dequeueReusableCellWithIdentifier:@"Gender"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Gender"];
        UITextField *tf = [[UITextField alloc]init];
        tf.text = [genderList objectAtIndex:indexPath.row];
        CGRect frame = cell.frame;
        frame.origin.x = 15;
        frame.size.width -= 15;
        tf.frame = frame;
        [cell addSubview:tf];

        if([tf.text isEqualToString:selectedGender]){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        tf.textColor = THEME_CONTENT_COLOR;
        tf.userInteractionEnabled = NO;
    }
    
    return cell;
}

#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger selectedId = indexPath.row;
    [self.delegate didSelectGender:selectedId];
    selectedGender = [genderList objectAtIndex:selectedId];
    [self.navigationController popViewControllerAnimated:YES];
}



@end
