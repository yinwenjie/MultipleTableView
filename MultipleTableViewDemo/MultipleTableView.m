//
//  MultipleTableView.m
//  MultipleTableViewDemo
//
//  Created by YinWenjie on 14-11-20.
//  Copyright (c) 2014年 YinWenjie. All rights reserved.
//

#import "MultipleTableView.h"
#import "DataSheetView.h"

@interface MultipleTableView()

@property (nonatomic, assign) NSInteger startPagesToShow;
@property (nonatomic, assign) NSInteger maxPagesToShowAtOnce;

@property (nonatomic, assign) NSInteger targetLevel;                        //目标的level。
@property (nonatomic, retain) NSMutableArray *currentSheetsSet;           //当前显示的dataSheets实例的集合
@property (nonatomic, retain) NSMutableSet *backupSheetsSet;             //后备的dataSheets实例的集合

@end

@implementation MultipleTableView

- (id)initWithFrame:(CGRect)frame withDelegate:(id<MultipleTableViewDelegate>)delegate AndDataSource:(id<MultipleTableViewDataSource>)dataSource
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor yellowColor];
        
        self.delegate = delegate;
        self.dataSource = dataSource;
        
        //Initializer
        [self collectDelegateData];
        [self initializer];
        [self loadDataSheets];
    }
    return self;
}

- (void)collectDelegateData
{
    if ([_delegate respondsToSelector:@selector(numberOfPagesDisplayedAtStart)])
    {
        _startPagesToShow = [_delegate numberOfPagesDisplayedAtStart];
    }
    else
    {
        _startPagesToShow = 1;
    }
    
    if ([_delegate respondsToSelector:@selector(numberOfPagesDisplayedOnceAtMost)])
    {
        _maxPagesToShowAtOnce = [_delegate numberOfPagesDisplayedOnceAtMost];
    }
    else
    {
        _maxPagesToShowAtOnce = 2;
    }
    if (_startPagesToShow > _maxPagesToShowAtOnce)
    {
        _startPagesToShow = _maxPagesToShowAtOnce;
    }
    NSLog(@"%ld pages will be shown at start.", self.startPagesToShow);
    NSLog(@"%ld pages will be shown at most on screen.", self.maxPagesToShowAtOnce);
}

//类成员的初始化
- (void)initializer
{
    _targetLevel = 1;
    _currentSheetsSet = [[NSMutableArray alloc] init];
    _backupSheetsSet = [[NSMutableSet alloc] init];
}

//向背景视图上添加datasheets
- (void)loadDataSheets
{
    for (int nIdx = 0; nIdx < self.startPagesToShow; nIdx++)
    {
        CGRect dataSheetFrame = CGRectMake(130 * nIdx, 0, 320, 568);
        DataSheetView *sheetView = [[DataSheetView alloc] initWithFrame:dataSheetFrame style:UITableViewStylePlain];
        sheetView.tag = nIdx;
        sheetView.delegate = self;
        sheetView.dataSource = self;
        sheetView.currentSheetLevel = nIdx;
        [self addSubview:sheetView];
        [sheetView release];
        [_currentSheetsSet addObject:sheetView];
    }
    
    for (UIView *view in self.subviews)
    {
        if (view.tag == 0)
        {
            view.backgroundColor = [UIColor yellowColor];
        }
        else if (view.tag == 1)
        {
            view.backgroundColor = [UIColor greenColor];
        }
        else if (view.tag == 2)
        {
            view.backgroundColor = [UIColor purpleColor];
        }
    }
}

//从后备的dataSheets实例的集合中检索元素
- (DataSheetView *)dequeDataSheet
{
    DataSheetView *sheetView = [_backupSheetsSet anyObject];
    if (sheetView)
    {
        [_backupSheetsSet removeObject:sheetView];
    }
    return sheetView;
}

//回收某个dataSheets到后备集合
- (void)collectDataSheet:(DataSheetView *)dataSheet
{
    dataSheet.delegate = nil;
    dataSheet.dataSource = nil;
    dataSheet.tag = NSNotFound;
    dataSheet.frame = CGRectZero;
    dataSheet.currentSheetLevel = NSNotFound;
    [_currentSheetsSet removeObject:dataSheet];
    [_backupSheetsSet addObject:dataSheet];
}

//重新排列当前显示的各个TableView
- (void)resizeTableViews
{
    for (DataSheetView *sheetView in _currentSheetsSet)
    {
        NSInteger nIdx = sheetView.tag;
        CGRect dataSheetFrame = CGRectMake(220 * nIdx / _currentSheetsSet.count, 0, 320, 568);
        sheetView.frame = dataSheetFrame;
    }
}

#pragma mark - UITableView Delegate & DataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DataSheetView *currentTableView = (DataSheetView *)tableView;
    if (currentTableView.tag == _currentSheetsSet.count - 1)
    {
        //建立一个新的表并添加到屏幕上
       
        DataSheetView *newSheetView = [[DataSheetView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        newSheetView.tag = currentTableView.tag + 1;
        newSheetView.currentSheetLevel = currentTableView.currentSheetLevel + 1;
        newSheetView.delegate = self;
        newSheetView.dataSource = self;
        newSheetView.backgroundColor = [UIColor redColor];
        [self addSubview:newSheetView];
        [newSheetView release];
        [_currentSheetsSet addObject:newSheetView];
        
        if (_currentSheetsSet.count > _maxPagesToShowAtOnce)
        {
            DataSheetView *sheetToCollect = [_currentSheetsSet objectAtIndex:0];
            [sheetToCollect removeFromSuperview];
            [_currentSheetsSet removeObject:sheetToCollect];
            for (DataSheetView *sheetView in _currentSheetsSet)
            {
                sheetView.tag--;
            }
        }
    }


    [self resizeTableViews];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DataSheetView *currentTableView = (DataSheetView *)tableView;
    static NSString *identifier = @"TableViewIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"第%ld张表格",currentTableView.currentSheetLevel + 1];
    return cell;
}
@end
