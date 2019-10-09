//
//  Cocoa_ChartProtocol.h
//  Cocoa-KLine
//
//  Created by Yochi on 2018/7/31.
//  Copyright © 2018年 Yochi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cocoa_ChartModel.h"

//kline Type
typedef enum
{
    MainChartType_TimeLine=0,
    MainChartType_TypeKline,
    MainChartType_Other,
    
}Cocoa_MainChartType;

//种类
typedef NS_ENUM(NSInteger, Cocoa_KLineDataType) {
    KLineTypeTimeShare=0,
    KLineType1Min,
    KLineType5Min,
    KLineType15Min,
    KLineType30Min,
    KLineType1Hour,
    KLineType4Hour,
    KLineType1Day,
    KLineType1Week
};

//主图指标Type
typedef enum {
    MainTecnnicalType_MA=0,
    MainTecnnicalType_BOLL,
    MainTecnnicalType_Close,  //MA关闭线
}MainTecnnicalType;

//副图指标Type
typedef enum
{
    TecnnicalType_MACD = 0,
    TecnnicalType_KDJ,
    TecnnicalType_OBV,
    TecnnicalType_WR,
    TecnnicalType_Close,
}TecnnicalType;

typedef NS_ENUM(NSInteger, StockStyleState){
    StockStateRise = 1,
    StockStateFall
};
//最新精度用于计算 按最大算
#define minAccuracyValue 0.0000000000001

static inline bool isEqualZero(float value) {
    
    return fabsf(value) <= minAccuracyValue;
}

// 数据精度控制 值 参考值
static inline NSString* klineValue(double value, NSInteger accuracy) {
    
    NSString *string = [NSString stringWithFormat:@"%%.%ldf",accuracy];
    NSString *accuracystr = [NSString stringWithFormat:string, value];
    return accuracystr;
}

/** 所有指标，遵循次协议 */
@protocol Cocoa_ChartProtocol <NSObject>

/** 数据模型 */
@property (nonatomic,strong) NSMutableArray<__kindof Cocoa_ChartModel*> *dataArray;
/** 数据模型最大值 */
@property (nonatomic, assign) double maxValue;
/** 数据模型最小值 */
@property (nonatomic, assign) double minValue;
/** 坐标最大值 */
@property (nonatomic, assign) double coordinateMaxValue;
/** 坐标最小值 */
@property (nonatomic, assign) double coordinateminValue;
/** 坐标比例 */
@property (nonatomic, assign) CGFloat scaleValue;
/** 边距 */
@property (nonatomic, assign) UIEdgeInsets padding;

// @synthesize xxx 将@property中定义的属性自动生成get/set的实现方法而且默认访问成员变量xxx

@optional

@property (nonatomic,assign) CGFloat    leftPostion;
@property (nonatomic,assign) NSInteger  startIndex;
@property (nonatomic,assign) NSInteger  displayCount;
@property (nonatomic,assign) CGFloat    candleWidth;
@property (nonatomic,assign) CGFloat    candleSpace;

// 清空k线界面数据
- (void)clearChartView;

// 刷新k线界面
- (void)refreshChartView;

// 计算最大最小值
- (void)calcuteMaxAndMinValue;

// 绘制k线
- (void)drawChartView;

// 加载更多数据
- (void)displayMoreData;

// 蜡烛柱，位置，index，带动底部指标
- (void)displayScreenleftPostion:(CGFloat)leftPostion startIndex:(NSInteger)index count:(NSInteger)count;

@end
