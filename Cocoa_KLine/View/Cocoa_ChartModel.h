//
//  Cocoa_ChartModel.h
//  Cocoa-KLine
//
//  Created by Yochi on 2018/8/1.
//  Copyright © 2018年 Yochi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Cocoa_ChartModel : NSObject

//-------------------------------
/** 外部必传参数 */
//-------------------------------

// 成交量
@property (nonatomic, assign) double volume;
// 开盘价
@property (nonatomic, assign) double open;
// 收盘价
@property (nonatomic, assign) double close;
// 最高价
@property (nonatomic, assign) double high;
// 最低价
@property (nonatomic, assign) double low;

/** 字符串显示 */
// 成交量
@property (nonatomic, strong) NSString *volumeStr;
// 开盘价
@property (nonatomic, strong) NSString *openStr;
// 收盘价
@property (nonatomic, strong) NSString *closeStr;
// 最高价
@property (nonatomic, strong) NSString *highStr;
// 最低价
@property (nonatomic, strong) NSString *lowStr;

// 小数位精度 主要用于数据展示 最长12位
@property (nonatomic, assign) NSInteger priceaccuracy;
@property (nonatomic, assign) NSInteger volumaccuracy;

// 日期时间
@property (nonatomic, copy) NSString *date;

@property (nonatomic, copy) NSString *timestampStr;

//-------------------------------
/** 内部计算参数 */
//-------------------------------

/********************坐标位置******************************/

/** 开盘点 */
@property (nonatomic, assign) CGPoint openPoint;

/** 收盘点 */
@property (nonatomic, assign) CGPoint closePoint;

/** 最高点 */
@property (nonatomic, assign) CGPoint highPoint;

/** 最低点 */
@property (nonatomic, assign) CGPoint lowPoint;

/** 当前k线位置 */
@property (assign, nonatomic) NSInteger localIndex;

/********************k线图均线******************************/
/** 5日均线 */
@property (nonatomic, assign) double ma5;
/** 10日均线 */
@property (nonatomic, assign) double ma10;
/** 20日均线 */
@property (nonatomic, assign) double ma20;

/********************k线图BOLL******************************/
@property (nonatomic, assign) double BOLL_MD;

@property (nonatomic, assign) double BOLL_UP;

@property (nonatomic, assign) double BOLL_DN;

/********************成交量均线******************************/
/** 5日成交量均线 */
@property (nonatomic, assign) double ma5Volume;

/** 10日成交量均线 */
@property (nonatomic, assign) double ma10Volume;

@property (nonatomic, assign) double priceChangeRatio;

/********************MACD值******************************/
@property(assign, nonatomic) double dea;
@property(assign, nonatomic) double diff;
@property(assign, nonatomic) double macd;

/********************KDJ值******************************/
@property(assign, nonatomic) double KValue;
@property(assign, nonatomic) double DValue;
@property(assign, nonatomic) double JValue;

/********************WR值******************************/
@property(assign, nonatomic) double WRValue;

/********************OBV值******************************/
@property(assign, nonatomic) double OBVValue;

@end
