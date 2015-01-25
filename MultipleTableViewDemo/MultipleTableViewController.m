//
//  MultipleTableViewController.m
//  MultipleTableViewDemo
//
//  Created by YinWenjie on 15-1-18.
//  Copyright (c) 2015年 YinWenjie. All rights reserved.
//

#import "MultipleTableViewController.h"

@interface MultipleTableViewController ()

@end

@implementation MultipleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    int x = self.navigationController.navigationBar.frame.origin.x;
    int y = self.navigationController.navigationBar.frame.origin.y;
//    int width = self.navigationController.navigationBar.frame.size.width;
    int height = self.navigationController.navigationBar.frame.size.height;
    
    CGRect backgroundFrame = CGRectMake(0, 0, 320, 568);
    UIView *backgroundView = [[UIView alloc] initWithFrame:backgroundFrame];
    backgroundView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:backgroundView];
    
    CGRect frame = CGRectMake(0, y + height, 320, 568);
    MultipleTableView *MTV = [[MultipleTableView alloc] initWithFrame:frame];
    MTV.delegate = self;
    MTV.dataSource = self;
    [self.view addSubview:MTV];
    [MTV release];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - MultipleTableViewDelegate & Data Source
- (NSInteger) numberOfPagesDisplayedAtStart
{
    return 3;
}

- (NSInteger) numberOfPagesDisplayedOnceAtMost
{
    return 3;
}

- (CGFloat)   dataSheetView:(DataSheetView *)dataSheetView heightForLevel:(NSInteger)level andRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 55;
}

- (NSInteger)dataSheetView:(DataSheetView *)dataSheetView numberOfRowsForLevel:(NSInteger)level
{
    return 2 * dataSheetView.currentSheetLevel + 1;
}

- (UITableViewCell *)dataSheetView:(DataSheetView *)dataSheetView cellForLevel:(NSInteger)level andRowAtIndexPath:(NSIndexPath*)indexPath;
{
    DataSheetView *currentTableView = (DataSheetView *)dataSheetView;
    static NSString *identifier = @"TableViewIdentifier";
    UITableViewCell *cell = [currentTableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"第%ld列",currentTableView.currentSheetLevel + 1];
    return cell;
}

@end
