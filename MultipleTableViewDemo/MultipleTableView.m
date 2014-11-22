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
@property (nonatomic, assign) NSInteger targetLevel;                        //目标的level。
@property (nonatomic, retain) NSMutableSet *currentSheetsSet;           //当前显示的dataSheets实例的集合
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
}

//类成员的初始化
- (void)initializer
{
    _targetLevel = 1;
    _currentSheetsSet = [[NSMutableSet alloc] init];
    _backupSheetsSet = [[NSMutableSet alloc] init];
}

//向背景视图上添加datasheets
- (void)loadDataSheets
{
    NSLog(@"%ld pages will be show at start.", self.startPagesToShow);
    for (int nIdx = 0; nIdx < self.startPagesToShow; nIdx++)
    {
        CGRect dataSheetFrame = CGRectMake(130 * nIdx, 0, 320, 568);
        DataSheetView *sheetView = [[DataSheetView alloc] initWithFrame:dataSheetFrame style:UITableViewStylePlain];
        sheetView.tag = nIdx;
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
@end
