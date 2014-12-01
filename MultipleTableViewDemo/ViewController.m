//
//  ViewController.m
//  MultipleTableViewDemo
//
//  Created by YinWenjie on 14-11-20.
//  Copyright (c) 2014年 YinWenjie. All rights reserved.
//

#import "ViewController.h"
#import "MultipleTableView.h"

@interface ViewController ()
//@property (nonatomic, retain) UITableView *tableView1;
//@property (nonatomic, retain) UITableView *tableView2;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    MultipleTableView *MTV = [[MultipleTableView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    CGRect frame = CGRectMake(0, 0, 320, 568);
    MultipleTableView *MTV = [[MultipleTableView alloc] initWithFrame:frame];
    MTV.delegate = self;
    MTV.dataSource = self;
    [self.view addSubview:MTV];
    [MTV release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) numberOfPagesDisplayedAtStart
{
    return 3;
}

- (NSInteger) numberOfPagesDisplayedOnceAtMost
{
    return 3;
}

@end
