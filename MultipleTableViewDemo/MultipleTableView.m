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
@property (nonatomic, retain) NSMutableArray *removedDataSheets;

@end

@implementation MultipleTableView


//类成员的初始化
- (void)initializer
{
    _targetLevel = 1;
    _currentSheetsSet = [[NSMutableArray alloc] init];
    _removedDataSheets = [[NSMutableArray alloc] init];
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
}

//从后备的dataSheets实例的集合中检索元素
/*- (DataSheetView *)dequeDataSheet
{
    DataSheetView *sheetView = [_backupSheetsSet anyObject];
    if (sheetView)
    {
        [_backupSheetsSet removeObject:sheetView];
    }
    return sheetView;
}*/

- (void)setDelegate:(id<MultipleTableViewDelegate>)delegate
{
    _delegate = delegate;
    
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

    [self initializer];
    [self loadDataSheets];
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
    NSTimeInterval timeIntvl = 0.3;
    for (DataSheetView *sheetView in _currentSheetsSet)
    {
        [UIView animateWithDuration:timeIntvl animations:^{
            NSInteger nIdx = sheetView.tag;
            CGRect dataSheetFrame = CGRectMake(220 * nIdx / _currentSheetsSet.count, 0, 320, 568);
            sheetView.frame = dataSheetFrame;
        }];
    }
}

//移除废弃的sheets
- (void)removeAbandonedSheets
{
    NSTimeInterval timeIntvl = 0.8;
    for (DataSheetView *sheetView in _removedDataSheets)
    {
        [UIView animateWithDuration:timeIntvl animations:^{
            CGRect outOfRange = CGRectMake(-320, 0, 320, 568);
            sheetView.frame = outOfRange;
        } completion:^(BOOL finished){
            [sheetView removeFromSuperview];
            [_removedDataSheets removeObject:sheetView];
        }];
    }
}

#pragma mark - UITableView Delegate & DataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DataSheetView *currentSheetView = (DataSheetView *)tableView;
    if (currentSheetView.tag == _currentSheetsSet.count - 1)
    {
        //选择了最高级列表中的元素,建立一个新的表并添加到屏幕上
        DataSheetView *newSheetView = [[DataSheetView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        DataSheetView *sheetToCollect = nil;
        newSheetView.tag = currentSheetView.tag + 1;
        newSheetView.currentSheetLevel = currentSheetView.currentSheetLevel + 1;
        newSheetView.delegate = self;
        newSheetView.dataSource = self;
        newSheetView.frame = CGRectMake(320, 0, 320, 568);//初始frame在屏幕范围的外面，方便动画滑入
        [self addSubview:newSheetView];
        [newSheetView release];
        [_currentSheetsSet addObject:newSheetView];
        
        if (_currentSheetsSet.count > _maxPagesToShowAtOnce)
        {
            sheetToCollect = [_currentSheetsSet firstObject];
//            [sheetToCollect removeFromSuperview];
            sheetToCollect.bShouldRemove = YES;
            [_currentSheetsSet removeObject:sheetToCollect];
            [_removedDataSheets addObject:sheetToCollect];
            for (DataSheetView *sheetView in _currentSheetsSet)
            {
                sheetView.tag--;
            }
        }
    }
    else
    {
        //选择了低级别列表中的元素，列表向右方移动并重现更低级的列表
        NSInteger nCurrentLvl = currentSheetView.currentSheetLevel;
        DataSheetView *lastSheetView = [_currentSheetsSet lastObject];
        NSInteger nHighestLvl = lastSheetView.currentSheetLevel;
        NSInteger numSheetsToRemove = nHighestLvl - nCurrentLvl;
        for (NSInteger nIdx = 0; nIdx < numSheetsToRemove; nIdx++)
        {
            DataSheetView *sheetToCollect = [_currentSheetsSet lastObject];
            [sheetToCollect removeFromSuperview];
            [_currentSheetsSet removeObject:sheetToCollect];
            sheetToCollect.bShouldRemove = YES;
        }
        
        //在左侧新添加列表
        DataSheetView *newSheetView = [[DataSheetView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        DataSheetView *firstSheetView = [_currentSheetsSet firstObject];
        if (firstSheetView.currentSheetLevel != 0)
        {
            newSheetView.delegate = self;
            newSheetView.dataSource = self;
            newSheetView.frame = CGRectMake(-320, 0, 320, 568);//初始frame在屏幕范围的外面，方便动画滑入
            newSheetView.currentSheetLevel = firstSheetView.currentSheetLevel - 1;
            [self addSubview:newSheetView];
            [newSheetView release];
            [_currentSheetsSet insertObject:newSheetView atIndex:0];
        }
        else
        {
            [newSheetView release];
        }
        
        
        //更新各个列表的tag，排列顺序
        for (NSInteger nIdx = 0; nIdx < _currentSheetsSet.count; nIdx++)
        {
            DataSheetView *sheetView = [_currentSheetsSet objectAtIndex:nIdx];
            if (sheetView.bShouldRemove == NO)
            {
                sheetView.tag = nIdx;
                [self bringSubviewToFront:sheetView];
            }
        }
    }
    [self resizeTableViews];
    [self removeAbandonedSheets];
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
