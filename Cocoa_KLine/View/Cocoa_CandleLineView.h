//
//  Cocoa_CandleLineView.h
//  Cocoa-KLine
//  k线
//  Created by Yochi on 2018/7/31.
//  Copyright © 2018年 Yochi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cocoa_ChartModel.h"
#import "Cocoa_ChartProtocol.h"

@interface Cocoa_CandleLineView : UIView<Cocoa_ChartProtocol>

@property (nonatomic, assign) Cocoa_MainChartType mainChartType;

/**主图指标*/
@property (nonatomic, assign) MainTecnnicalType mainTecnnicalType;

/** 当前屏幕范围内显示的k线模型数组 */
@property (nonatomic,strong) NSMutableArray *currentDisplayArray;
@property (nonatomic,assign) NSInteger displayCount;
@property (nonatomic, assign) BOOL socketFlag;
/** 分时线(默认:1.0) **/
@property (nonatomic, assign) CGFloat timeLineWidth;
/** 均线宽度(默认:1.0) **/
@property (nonatomic, assign) CGFloat avgLineWidth;
/** 均线宽度(默认:1.0) **/
@property (nonatomic, assign) CGFloat bollLineWidth;

/** K线宽度(蜡烛实体宽度)(默认:8.0) **/
@property (nonatomic, assign) CGFloat candleWidth;
@property (nonatomic, assign) NSInteger startIndex;

@property (nonatomic, strong) UIColor *candleRiseColor;
@property (nonatomic, strong) UIColor *candleFallColor;

/** 最大宽度(默认:10.0) **/
@property (nonatomic, assign) CGFloat maxCandleWidth;

@property (nonatomic, assign) CGFloat maxHighValue;
@property (nonatomic, assign) CGFloat minlowValue;

/** 最小K线宽度(默认:1.0) **/
@property (nonatomic, assign) CGFloat minCandleWidth;

/** 分时线颜色 **/
@property (nonatomic, strong) UIColor *timeLineColor;

/** 5日均线颜色(默认:白色)  由小到大排列 **/
@property (nonatomic, strong) UIColor *ma1AvgLineColor;

/** 10日均线颜色(默认:黄色) **/
@property (nonatomic, strong) UIColor *ma2AvgLineColor;

/** 20日均线颜色(默认:紫色) **/
@property (nonatomic, strong) UIColor *ma3AvgLineColor;

/** 数据模型 */
@property (nonatomic,strong) NSMutableArray<__kindof Cocoa_ChartModel*> *dataArray;

@property (nonatomic, assign) id<Cocoa_ChartProtocol> delegate;

@property (nonatomic, assign) BOOL isloadMoreEnable;



- (void)pinGesture:(UIPinchGestureRecognizer *)pin;

- (void)refreshChartView;

- (void)refreshDisplayArrayModel;

- (void)clearChartView;

- (void)refreshMainTecnnical;

- (void)removeAllObserver;

@end
