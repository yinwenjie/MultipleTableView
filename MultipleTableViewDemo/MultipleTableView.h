//
//  MultipleTableView.h
//  MultipleTableViewDemo
//
//  Created by YinWenjie on 14-11-20.
//  Copyright (c) 2014年 YinWenjie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataSheetView.h"


@protocol MultipleTableViewDelegate;
@protocol MultipleTableViewDataSource;

@interface MultipleTableView : UIView<UITableViewDelegate,UITableViewDataSource>

//MultipleTableView的数据源和代理
@property (nonatomic, assign) id<MultipleTableViewDelegate> delegate;
@property (nonatomic, assign) id<MultipleTableViewDataSource> dataSource;

@end

@protocol MultipleTableViewDelegate <NSObject>

@optional
- (NSInteger) numberOfPagesDisplayedAtStart;
- (NSInteger) numberOfPagesDisplayedOnceAtMost;
- (CGFloat)   dataSheetView:(DataSheetView *)dataSheetView heightForLevel:(NSInteger)level andRowAtIndexPath:(NSIndexPath*)indexPath;
@end

@protocol MultipleTableViewDataSource<NSObject>

@required
- (UITableViewCell *)dataSheetView:(DataSheetView *)dataSheetView cellForLevel:(NSInteger)level andRowAtIndexPath:(NSIndexPath*)indexPath;

@optional

@end