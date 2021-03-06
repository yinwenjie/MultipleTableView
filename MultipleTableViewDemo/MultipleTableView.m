//
//  MultipleTableView.m
//  MultipleTableViewDemo
//
//  Created by YinWenjie on 14-11-20.
//  Copyright (c) 2014年 YinWenjie. All rights reserved.
//

#import "MultipleTableView.h"

#define VIEW_ORIGIN_X   self.frame.origin.x
#define VIEW_ORIGIN_Y   self.frame.origin.y
#define VIEW_HEIGHT self.frame.size.height
#define VIEW_WIDTH  self.frame.size.width

#define TOPSHEETOFFSET  2 * VIEW_WIDTH / 3 //最顶层列表相对于左侧边界的距离

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

- (void)dealloc
{
    [super dealloc];
    _delegate = nil;
    _dataSource = nil;
    [_currentSheetsSet release];
    [_removedDataSheets release];
    [_backupSheetsSet release];
}

//向背景视图上添加datasheets
- (void)loadDataSheets
{
    for (int nIdx = 0; nIdx < self.startPagesToShow; nIdx++)
    {
        CGRect dataSheetFrame = CGRectMake(TOPSHEETOFFSET / _startPagesToShow * nIdx, 0, VIEW_WIDTH, VIEW_HEIGHT);
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
            CGRect dataSheetFrame = CGRectMake(TOPSHEETOFFSET * nIdx / _currentSheetsSet.count, 0, VIEW_WIDTH, VIEW_HEIGHT);
            sheetView.frame = dataSheetFrame;
        }];
    }
}

//移除废弃的sheets
- (void)removeAbandonedSheets
{
    for (DataSheetView *sheetView in _removedDataSheets)
    {
        if (sheetView.tag == 0)
        {
            [UIView animateWithDuration:0.8 animations:^{
                CGRect outOfRange = CGRectMake(-VIEW_WIDTH, 0, VIEW_WIDTH, VIEW_HEIGHT);
                sheetView.frame = outOfRange;
            } completion:^(BOOL finished){
                if (finished) {
                    sheetView.delegate = nil;
                    sheetView.dataSource = nil;
                    [sheetView removeFromSuperview];
                    [_removedDataSheets removeObject:sheetView];
                }
            }];
        }
        else
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self bringSubviewToFront:sheetView];
                CGRect outOfRange = CGRectMake(VIEW_WIDTH, 0, VIEW_WIDTH, VIEW_HEIGHT);
                sheetView.frame = outOfRange;
            } completion:^(BOOL finished){
                if (finished) {
                    sheetView.delegate = nil;
                    sheetView.dataSource = nil;
                    [sheetView removeFromSuperview];
                    [_removedDataSheets removeObject:sheetView];
                }
            }];
        }

    }
}

#pragma mark - UITableView Delegate & DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DataSheetView *sheetView = (DataSheetView *)tableView;
    if (_delegate && [_delegate respondsToSelector:@selector(dataSheetView:heightForLevel:andRowAtIndexPath:)])
    {
        return [_delegate dataSheetView:sheetView heightForLevel:sheetView.currentSheetLevel andRowAtIndexPath:indexPath];
    }
    return 45;
}

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
        newSheetView.frame = CGRectMake(VIEW_WIDTH, 0, VIEW_WIDTH, VIEW_HEIGHT);//初始frame在屏幕范围的外面，方便动画滑入
        [self addSubview:newSheetView];
        [newSheetView release];
        [_currentSheetsSet addObject:newSheetView];
        
        if (_currentSheetsSet.count > _maxPagesToShowAtOnce)
        {
            sheetToCollect = [_currentSheetsSet firstObject];
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
            [_currentSheetsSet removeObject:sheetToCollect];
            [_removedDataSheets addObject:sheetToCollect];
        }
        
        //在左侧新添加列表
        DataSheetView *newSheetView = [[DataSheetView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        DataSheetView *firstSheetView = [_currentSheetsSet firstObject];
        if (firstSheetView.currentSheetLevel != 0)
        {
            newSheetView.delegate = self;
            newSheetView.dataSource = self;
            newSheetView.frame = CGRectMake(-VIEW_WIDTH, 0, VIEW_WIDTH, VIEW_HEIGHT);//初始frame在屏幕范围的外面，方便动画滑入
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
            sheetView.tag = nIdx;
            [self bringSubviewToFront:sheetView];
        }
    }
    [self resizeTableViews];
    [self removeAbandonedSheets];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DataSheetView *sheetView = (DataSheetView *)tableView;
    if (_dataSource && [_dataSource respondsToSelector:@selector(dataSheetView:heightForLevel:andRowAtIndexPath:)])
    {
        return [_dataSource dataSheetView:sheetView numberOfRowsForLevel:sheetView.currentSheetLevel];
    }
    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DataSheetView *sheetView = (DataSheetView *)tableView;
    UITableViewCell *cell = [_dataSource dataSheetView:sheetView cellForLevel:sheetView.currentSheetLevel andRowAtIndexPath:indexPath];
    return cell;
}
@end
