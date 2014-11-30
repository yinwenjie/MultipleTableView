//
//  DataSheetView.h
//  MultipleTableViewDemo
//
//  Created by YinWenjie on 14-11-20.
//  Copyright (c) 2014年 YinWenjie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataSheetView : UITableView

@property (nonatomic, assign) NSInteger currentSheetLevel;      //该sheet所处在的level，负责与数据进行交互

@end
