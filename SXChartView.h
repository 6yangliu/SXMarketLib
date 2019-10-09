//
//  SXChartView.h
//  SXMarketViewDemo
//  K线分时图
//  Created by liuy on 2018/5/3.
//  Copyright © 2018年 liuy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+Y_StockChart.h"
#import "SXChartPriceBoard.h"
#import "SXChartSegmentView.h"
#import "Cocoa_KLine.h"

#import <Masonry/Masonry.h>
#import "SXMarketDataManager.h"
#ifndef KScreenWidthPrt
#define KScreenWidthPrt  [[UIScreen mainScreen]bounds].size.width/375 //各设备宽的比例 以375为参照
#define KScreenPrt(P) KScreenWidthPrt*P
#endif

#define KChartViewHeightOfset 100.0f

/**
 *  SXChartView delegate
 */
@class SXChartView;

@protocol SXChartViewDelegate <NSObject>


-(void)onChangeKlineDataWithType:(Cocoa_KLineDataType)klineType;

-(void)chartView:(SXChartView *)chartView didChartViewDoubleClick:(id)userinfo;


@end


@interface SXChartView : UIView

@property (nonatomic, strong) SXChartSegmentView *topSegmentView;//顶部部选择View

@property (nonatomic, strong) UIButton *fullScreenBtn;//全屏按钮



@property (nonatomic, strong) NSArray *itemModels;

@property (nonatomic, weak) id<SXChartViewDelegate> delgate;

@property (nonatomic, strong) Cocoa_ChartManager *kLineView;//K线图View

@property (nonatomic, assign) Cocoa_MainChartType currentLineType;//k线type

@property (nonatomic, assign) MainTecnnicalType currentMainZbType;//主指标type

@property (nonatomic, assign) TecnnicalType currentFuZbType;//副指标type

@property (nonatomic,strong)NSArray *kLindData;//K线数据
/**
 *YES 全量 NO 增量
 */
@property (nonatomic, assign) BOOL isUpdateALL;
-(void) reloadData;
/**
 外部调用刷新K线数据
 **/
-(void)reloadKLineData;

@end
