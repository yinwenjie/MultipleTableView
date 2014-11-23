//
//  MultipleTableView.h
//  MultipleTableViewDemo
//
//  Created by YinWenjie on 14-11-20.
//  Copyright (c) 2014年 YinWenjie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MultipleTableViewDelegate;
@protocol MultipleTableViewDataSource;

@interface MultipleTableView : UIView<UITableViewDelegate,UITableViewDataSource>

//MultipleTableView的数据源和代理
@property (nonatomic, assign) id<MultipleTableViewDelegate> delegate;
@property (nonatomic, assign) id<MultipleTableViewDataSource> dataSource;

- (id)initWithFrame:(CGRect)frame withDelegate:(id<MultipleTableViewDelegate>)delegate AndDataSource:(id<MultipleTableViewDataSource>)dataSource;

@end

@protocol MultipleTableViewDelegate <NSObject>

@optional
- (NSInteger) numberOfPagesDisplayedAtStart;
- (NSInteger) numberOfPagesDisplayedOnceAtMost;
@end

@protocol MultipleTableViewDataSource<NSObject>

@optional

@end