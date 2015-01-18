//
//  ViewController.m
//  MultipleTableViewDemo
//
//  Created by YinWenjie on 14-11-20.
//  Copyright (c) 2014年 YinWenjie. All rights reserved.
//

#import "ViewController.h"
#import "MultipleTableViewController.h"

@interface ViewController ()
//@property (nonatomic, retain) UITableView *tableView1;
//@property (nonatomic, retain) UITableView *tableView2;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"START";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *pushBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(pushMultipleViewController)];
    self.navigationItem.rightBarButtonItem = pushBtn;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void)pushMultipleViewController
{
    MultipleTableViewController *mtVC = [[MultipleTableViewController alloc] init];
    [self.navigationController pushViewController:mtVC animated:YES];
}

@end
