//
//  Cocoa_ChartManager.m
//  Cocoa-KLine
//
//  Created by Yochi on 2018/7/31.
//  Copyright © 2018年 Yochi. All rights reserved.
//
#import "Cocoa_ChartManager.h"
#import "Cocoa_TecnnicalView.h"
#import "Cocoa_ChartProtocol.h"
#import "Cocoa_TradingVolumeView.h"
#import "Cocoa_CrossCurveView.h"
#import "Cocoa_CalculateCoordinate.h"
#import "Cocoa_MACDView.h"
#import "Cocoa_KDJView.h"
#import "Cocoa_OBVView.h"
#import "Cocoa_WRView.h"
#import "Cocoa_FullScreenController.h"
#define kTecnnicalChartScale 0.25

#define kVolumeViewChartScale 0.25

@interface Cocoa_ChartManager ()<Cocoa_ChartProtocol>

// 四层基础界面(主图，成交量图，指标，时间轴)
@property (nonatomic, strong) Cocoa_CandleLineView *candleView;
@property (nonatomic, strong) Cocoa_TecnnicalView *volumeView;
@property (nonatomic, strong) Cocoa_TecnnicalView *tecnnicalView;
@property (nonatomic, strong) UIView *xAxisView;
// 界面高度
@property (nonatomic, assign) CGFloat topKViewHeight;
@property (nonatomic, assign) CGFloat VolumeTecnnicaHeight;
@property (nonatomic, assign) CGFloat tecnnicalHeight;
@property (nonatomic, assign) CGFloat xAxisViewHeight;
//成交量图(添加到volumeView上)
@property (nonatomic, strong) Cocoa_TradingVolumeView *tradingVolumeView;
// 指标界面
@property (nonatomic, strong) Cocoa_MACDView *tradingMacdView;
@property (nonatomic, strong) Cocoa_KDJView  *tecnnicalKDJView;
@property (nonatomic, strong) Cocoa_OBVView  *tecnnicalOBVView;
@property (nonatomic, strong) Cocoa_WRView   *tecnnicalWRView;
//当前指标图
@property (nonatomic, assign) id<Cocoa_ChartProtocol>temptecnnicalStateView;

@property (nonatomic, strong) NSMutableArray *tecnnicalNameArray;
@property (nonatomic, strong) NSMutableArray *tecnnicalArray;

// 长按十字线界面
@property (nonatomic, strong) Cocoa_CrossCurveView *crossView;
@property (nonatomic, strong) Cocoa_ChartModel *lastModel;

// 手势
@property (nonatomic,strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic,strong) UIPinchGestureRecognizer *pinchPressGesture;
@property (nonatomic, assign) CGFloat currentZoom;

// 坐标线
@property (nonatomic, strong) CAShapeLayer *verificalLayer;

// 纵坐标值文字
@property (nonatomic, strong) CATextLayer *topTextLayer;
@property (nonatomic, strong) CATextLayer *topSecTextLayer;
@property (nonatomic, strong) CATextLayer *centerTextLayer;
@property (nonatomic, strong) CATextLayer *bottomTextLayer;
@property (nonatomic, strong) CATextLayer *bottomSecTextLayer;

// 横坐标值文字
@property (nonatomic, strong) CATextLayer *firstDateTextLayer;
@property (nonatomic, strong) CATextLayer *secondeDateTextLayer;
@property (nonatomic, strong) CATextLayer *thirdDateTextLayer;
@property (nonatomic, strong) CATextLayer *fourthDateTextLayer;

// 成交量文字
@property (nonatomic, strong) CATextLayer *volumeTextLayer;
// 底部指标文字
@property (nonatomic, strong) CATextLayer *tecnnicalTextLayer;

// 均值文字
@property (nonatomic, strong) CATextLayer *ma1DataLayer;
@property (nonatomic, strong) CATextLayer *ma2DataLayer;
@property (nonatomic, strong) CATextLayer *ma3DataLayer;

@end

@implementation Cocoa_ChartManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    // 移除观察者
    [_candleView removeAllObserver];
}

// 系统调用 界面显示发生变化是，移除长十字线
- (void)didMoveToWindow {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mainScrollerView.scrollEnabled = YES;
        [self.crossView removeFromSuperview];
        if (self.lastModel) {
            [self maassignment:self.lastModel];
            [self updataTecnnicalTextLayer:self.lastModel :self.tecnnicalType];
        }
    });
}

- (instancetype)initWithFrame:(CGRect)frame tecnnicalType:(TecnnicalType)tecnnicalType{
     self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = COLOR_BACKGROUND;
        self.tecnnicalType=tecnnicalType;
       
        [self.layer addSublayer:self.verificalLayer];
        
        __weak typeof(self) weakSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(self) self = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.mainScrollerView.scrollEnabled = YES;
                [self.crossView removeFromSuperview];
                if (self.lastModel) {
                    [self maassignment:self.lastModel];
                    [self updataTecnnicalTextLayer:self.lastModel :self.tecnnicalType];
                }
            });
        }];
        //计算高度
        [self calculateHeight];
        
        /** 绘制坐标系 */
        [self drawVerificalLine];
        
        /** k线的展示 */
        [self addSubview:self.mainScrollerView];
        /** k线图 */
        [self.mainScrollerView addSubview:self.candleView];
        /** 成交量图 根据k线图联动*/
        [self.mainScrollerView addSubview:self.volumeView];
        /** 指标图  根据k线图联动*/
        [self.mainScrollerView addSubview:self.tecnnicalView];
        /** 时间轴*/
        [self addSubview:self.xAxisView];
        /******************************************/
        /** 加入指标视图 */
        self.tecnnicalNameArray=[NSMutableArray arrayWithArray:@[@"MACD", @"KDJ", @"OBV", @"WR"]];
        [self.tecnnicalArray addObject:self.tradingMacdView];
        [self.tecnnicalArray addObject:self.tecnnicalKDJView];
        [self.tecnnicalArray addObject:self.tecnnicalOBVView];
        [self.tecnnicalArray addObject:self.tecnnicalWRView];
        /** 初始化成交量图和指标图*/
        [self initVolumView];
        [self initTecnnicalView];
        /*******************坐标上显示的文本***********************/
        
        [self.layer addSublayer:self.topTextLayer];
        [self.layer addSublayer:self.topSecTextLayer];
        [self.layer addSublayer:self.centerTextLayer];
        [self.layer addSublayer:self.bottomTextLayer];
        [self.layer addSublayer:self.bottomSecTextLayer];
        [self.layer addSublayer:self.volumeTextLayer];
        [self.layer addSublayer:self.tecnnicalTextLayer];
        
        [self.xAxisView.layer addSublayer:self.firstDateTextLayer];
        [self.xAxisView.layer addSublayer:self.secondeDateTextLayer];
        [self.xAxisView.layer addSublayer:self.thirdDateTextLayer];
        [self.xAxisView.layer addSublayer:self.fourthDateTextLayer];
        
        [self.layer addSublayer:self.ma1DataLayer];
        [self.layer addSublayer:self.ma2DataLayer];
        [self.layer addSublayer:self.ma3DataLayer];
        /******************************************/
        /** 布局 */
        [self main_layoutsubview];
        /** 添加手势 */
        [self addGestureToCandleView];
    }
    return self;
}

/** socket追加数据 */
- (void)appendingChartView
{
    
    // 逻辑 最右侧，重新绘制，否则只追加数据
    if (fabs(self.mainScrollerView.contentOffset.x + CGRectGetWidth(self.mainScrollerView.frame)-self.mainScrollerView.contentSize.width) <= self.candleView.candleSpace) {
        [self refreshChartView];
        
    }else {
        /** 刷新k线 保证其他指标赋值完成，再刷新界面 */
        [self.candleView.dataArray removeAllObjects];
        [self.candleView.dataArray addObjectsFromArray:self.dataArray];
        
        
        [self.tradingVolumeView.dataArray removeAllObjects];
        [self.tradingVolumeView.dataArray addObjectsFromArray:self.dataArray];
        
        for (id<Cocoa_ChartProtocol> tecnnical in self.tecnnicalArray) {
            [tecnnical.dataArray removeAllObjects];
            [tecnnical.dataArray addObjectsFromArray:self.dataArray];
        }
        
        self.candleView.socketFlag = YES;
        [self calculationindicators];
    }
    
}

/** 刷新k线 */
- (void)refreshChartView
{
    if (self.dataArray.count <=0 ) {
        // 界面数据清空
        [self.candleView.dataArray removeAllObjects];
        [self.tradingVolumeView.dataArray removeAllObjects];
        [self.temptecnnicalStateView.dataArray removeAllObjects];
        [self.candleView clearChartView];
        [self.tradingVolumeView clearChartView];
        [self clearChartView];
        return;
    }
    
    /** 刷新k线 保证其他指标赋值完成，再刷新界面 */
    [self.candleView.dataArray removeAllObjects];
    [self.candleView.dataArray addObjectsFromArray:self.dataArray];
    
    // 计算指标值
    [self calculationindicators];
    
    [self.tradingVolumeView.dataArray removeAllObjects];
    [self.tradingVolumeView.dataArray addObjectsFromArray:self.dataArray];
    
    // 指标视图重新赋值
    for (id<Cocoa_ChartProtocol> tecnnical in self.tecnnicalArray) {
        [tecnnical.dataArray removeAllObjects];
        [tecnnical.dataArray addObjectsFromArray:self.dataArray];
    }
    
    // 刷新k线界面 核心界面，带动其它界面
    self.candleView.mainChartType=self.mainChartType;
    self.candleView.mainTecnnicalType=self.mainTecnnicalType;
    [self.candleView refreshChartView];
}
/** 刷新主图指标 */
- (void)refreshMainTecnnical{
    
    if(self.mainTecnnicalType==MainTecnnicalType_Close){
        _ma1DataLayer.hidden=YES;
        _ma2DataLayer.hidden=YES;
        _ma3DataLayer.hidden=YES;
    }else{
        _ma1DataLayer.hidden=NO;
        _ma2DataLayer.hidden=NO;
        _ma3DataLayer.hidden=NO;
    }
    
    self.candleView.mainTecnnicalType=self.mainTecnnicalType;
    [self.candleView refreshMainTecnnical];
}

/** 刷新附图指标 */
- (void)refreshTecnnical:(TecnnicalType)tecnnicalType{
    __weak typeof(self)weakSelf=self;
    dispatch_async(dispatch_get_main_queue(), ^{
        CGPoint mainOffset=self.mainScrollerView.contentOffset;
        self.tecnnicalType=tecnnicalType;
        [self calculateHeight];
        [self drawVerificalLine];
        [self initTecnnicalView];
        [self main_layoutsubview];
        [weakSelf displayScreenleftPostion:weakSelf.leftPostion startIndex:weakSelf.startIndex count:weakSelf.displayCount];
        [self refreshChartView];
        self.mainScrollerView.contentOffset=mainOffset;
    });
}
-(void)initVolumView{
    UIView *tempView = self.tradingVolumeView;
    [[self.volumeView.subviews firstObject] removeFromSuperview];
    [self.volumeView addSubview:tempView];
    tempView.frame = self.volumeView.bounds;
    tempView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}
-(void)initTecnnicalView{
    if(self.tecnnicalType>=self.tecnnicalArray.count){
        self.tecnnicalType=TecnnicalType_Close;
    }
    if (self.tecnnicalType<self.tecnnicalArray.count) {
        id<Cocoa_ChartProtocol> chartProtocol = self.tecnnicalArray[self.tecnnicalType];
        UIView *tempView = (UIView *)chartProtocol;
        [[self.tecnnicalView.subviews firstObject] removeFromSuperview];
        [self.tecnnicalView addSubview:tempView];
        self.temptecnnicalStateView = chartProtocol;
        tempView.frame = self.tecnnicalView.bounds;
        tempView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
}
- (void)calculationindicators
{
    computeMAData(self.dataArray, 5);
    computeMAData(self.dataArray, 10);
    computeMAData(self.dataArray, 30);
    computeMACDData(self.dataArray);
    computeKDJData(self.dataArray);
    computeWRData(self.dataArray, 14);
    computeOBVData(self.dataArray);
    computeBOLLData(self.dataArray);
}

- (void)clearChartView
{
    self.firstDateTextLayer.string   = @"";
    self.secondeDateTextLayer.string = @"";
    self.thirdDateTextLayer.string       = @"";
    self.fourthDateTextLayer.string      = @"";
    
    _topTextLayer.string       = @"";
    _topSecTextLayer.string    = @"";
    _centerTextLayer.string    = @"";
    _bottomTextLayer.string    = @"";
    _bottomSecTextLayer.string = @"";
    _volumeTextLayer.string = @"";
    _tecnnicalTextLayer.string = @"";
    
    _ma1DataLayer.string = @"";
    _ma2DataLayer.string = @"";
    _ma3DataLayer.string = @"";
}

- (void)maassignment:(Cocoa_ChartModel *)model
{
    if(self.mainTecnnicalType==MainTecnnicalType_MA){
        self.ma1DataLayer.string = [NSString stringWithFormat:@"MA5:%@",klineValue(model.ma5, model.priceaccuracy)];
        self.ma2DataLayer.string = [NSString stringWithFormat:@"MA10:%@",klineValue(model.ma10, model.priceaccuracy)];
        self.ma3DataLayer.string = [NSString stringWithFormat:@"MA30:%@",klineValue(model.ma20, model.priceaccuracy)];
    }
    if(self.mainTecnnicalType==MainTecnnicalType_BOLL){
        self.ma1DataLayer.string = [NSString stringWithFormat:@"MID:%@",klineValue(model.BOLL_MD, model.priceaccuracy)];
        self.ma2DataLayer.string = [NSString stringWithFormat:@"UP:%@",klineValue(model.BOLL_UP, model.priceaccuracy)];
        self.ma3DataLayer.string = [NSString stringWithFormat:@"LB:%@",klineValue(model.BOLL_DN, model.priceaccuracy)];
    }
    
}

- (void)updatecoordinateValue:(Cocoa_ChartModel *)model
{
    // k线坐标值更新 model精度isLoadingMore
    self.topTextLayer.string = [NSString stringWithFormat:@"%@",klineValue(self.candleView.coordinateMaxValue, model.priceaccuracy)];
    
    self.centerTextLayer.string = [NSString stringWithFormat:@"%@",klineValue((self.candleView.coordinateMaxValue - self.candleView.coordinateminValue)/2.0 + self.candleView.coordinateminValue, model.priceaccuracy)];
    
    self.topSecTextLayer.string = [NSString stringWithFormat:@"%@",klineValue((self.candleView.coordinateMaxValue - self.candleView.coordinateminValue)*3/4.0 + self.candleView.coordinateminValue, model.priceaccuracy)];
    
    self.bottomSecTextLayer.string = [NSString stringWithFormat:@"%@",klineValue((self.candleView.coordinateMaxValue - self.candleView.coordinateminValue)/4.0 + self.candleView.coordinateminValue, model.priceaccuracy)];
    
    self.bottomTextLayer.string = [NSString stringWithFormat:@"%@",klineValue(self.candleView.coordinateminValue, model.priceaccuracy)];
}

#pragma mark - 界面绘制

/** 绘制坐标轴 */
- (void)drawVerificalLine
{
    /** 绘制横坐标五根线 */
    
    if (_verificalLayer) {
        [_verificalLayer removeFromSuperlayer];
        _verificalLayer = nil;
        [self.layer insertSublayer:self.verificalLayer atIndex:0];
    }
    //========================横线部分========================
    /*******时间轴上方的线********/
    [self drawAbscissalineDashPattern:nil lineWidth:0.5 moveToPoint:CGPointMake(0.0,CGRectGetHeight(self.frame)-self.xAxisViewHeight) addLineToPoint:CGPointMake(CGRectGetWidth(self.frame),CGRectGetHeight(self.frame)-self.xAxisViewHeight)];
    
    /*******k线图第一条坐标线********/
    [self drawAbscissalineDashPattern:nil lineWidth:0.5 moveToPoint:CGPointMake(0.0,0.0) addLineToPoint:CGPointMake(CGRectGetWidth(self.frame),0.0)];
    /*******k线图中间坐标线*******@[@3, @2]*/
    [self drawAbscissalineDashPattern:nil lineWidth:0.5 moveToPoint:CGPointMake(0,self.topKViewHeight/2.0f) addLineToPoint:CGPointMake(CGRectGetWidth(self.frame),self.topKViewHeight/2.0)];
    
    /*******k线图第二根坐标线********/
    [self drawAbscissalineDashPattern:nil lineWidth:0.5 moveToPoint:CGPointMake(0,self.topKViewHeight/4.0f) addLineToPoint:CGPointMake(CGRectGetWidth(self.frame),self.topKViewHeight/4.0)];
    
    /*******k线图第四条坐标线********/
    [self drawAbscissalineDashPattern:nil lineWidth:0.5 moveToPoint:CGPointMake(0,self.topKViewHeight*3/4.0f) addLineToPoint:CGPointMake(CGRectGetWidth(self.frame),self.topKViewHeight*3/4.0)];
    
    /*******k线图最下面坐标线********/
    [self drawAbscissalineDashPattern:nil lineWidth:0.5 moveToPoint:CGPointMake(0, self.topKViewHeight) addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), self.topKViewHeight)];
    
    /********指标图最下面坐标线*******/
    [self drawAbscissalineDashPattern:nil lineWidth:0.5 moveToPoint:CGPointMake(0, self.topKViewHeight+self.VolumeTecnnicaHeight) addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), self.topKViewHeight+self.VolumeTecnnicaHeight)];
//
//    /*******指标图最上面坐标线********/
//    [self drawAbscissalineDashPattern:nil lineWidth:0.5 moveToPoint:CGPointMake(0, self.topKViewHeight) addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), self.topKViewHeight )];
    
    /*******指标图中间坐标线********/
//    [self drawAbscissalineDashPattern:nil lineWidth:0.5 moveToPoint:CGPointMake(0, self.topKViewHeight + self.VolumeTecnnicaHeight/2.0) addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), self.topKViewHeight+ self.VolumeTecnnicaHeight/2.0)];
    
    //========================竖线部分========================
    /**
     绘制纵坐标 5根线
     */
    CGFloat coordinateHeight = CGRectGetHeight(self.frame)-_xAxisViewHeight;
    /**中间******@[@3, @2]*******/
    [self drawAbscissalineDashPattern:nil lineWidth:0.5 moveToPoint:CGPointMake(CGRectGetWidth(self.frame)/3, 0) addLineToPoint:CGPointMake(CGRectGetWidth(self.mainScrollerView.frame)/3, coordinateHeight)];
    
    /**左一*******@[@3, @2]******/
    [self drawAbscissalineDashPattern:nil lineWidth:0.5 moveToPoint:CGPointMake(CGRectGetWidth(self.frame)*2/3, 0) addLineToPoint:CGPointMake(CGRectGetWidth(self.mainScrollerView.frame)*2/3, coordinateHeight)];
}

/** 绘制横坐标 */
- (void)drawAbscissalineDashPattern:(NSArray *)lineDashPattern
                          lineWidth:(CGFloat)lineWidth
                        moveToPoint:(CGPoint)moveToPoint
                     addLineToPoint:(CGPoint)addLineToPoint
{
    CAShapeLayer *XLayer = [CAShapeLayer layer];
    XLayer.strokeColor = COLOR_COORDINATELINE.CGColor;
    XLayer.fillColor = [[UIColor clearColor] CGColor];
    XLayer.contentsScale = [UIScreen mainScreen].scale;
    XLayer.lineWidth = lineWidth;
    XLayer.lineDashPattern = lineDashPattern;
    
    UIBezierPath *xpath = [UIBezierPath bezierPath];
    [xpath moveToPoint:moveToPoint];
    [xpath addLineToPoint:addLineToPoint];
    XLayer.path = xpath.CGPath;
    [self.verificalLayer addSublayer:XLayer];
}

#pragma mark 添加手势

- (void)addGestureToCandleView
{
    _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesture:)];
    [self.mainScrollerView addGestureRecognizer:_longPressGesture];
    
    _pinchPressGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchesView:)];
    [self.mainScrollerView addGestureRecognizer:_pinchPressGesture];
    
}

- (void)longGesture:(UILongPressGestureRecognizer*)longPress
{
    if (self.dataArray.count == 0) {
        [self.crossView removeFromSuperview];
        return;
    }
    
    if (UIGestureRecognizerStateBegan == longPress.state) {
        
        [self addSubview:self.crossView];
    }
    
    CGPoint originlocation = [longPress locationInView:self];
    CGPoint location = [longPress locationInView:self.crossView];
    CGFloat y = location.y;
    static CGFloat oldPositionX = 0;
    
    NSInteger temp_x = ((location.x - self.candleView.padding.left) / (self.candleView.candleWidth + self.candleView.candleSpace));
    NSLog(@"%li",temp_x);
    temp_x = temp_x < 0 ? 0 : temp_x;
    
    temp_x = temp_x >= self.candleView.displayCount ? self.candleView.displayCount - 1 : temp_x;
    
    //    Cocoa_ChartModel *model = (self.candleView.startIndex + temp_x < self.dataArray.count) ? [self.dataArray objectAtIndex:self.candleView.startIndex + temp_x] : self.dataArray.lastObject;
    //解决更新数据十字光标不显示问题(原因数据源dataArray更新坐标被清，这里取当前currentDisplayArray中的model)
    Cocoa_ChartModel *model = (temp_x< self.candleView.currentDisplayArray.count) ? [self.candleView.currentDisplayArray objectAtIndex:temp_x] : self.candleView.currentDisplayArray.lastObject;
    Cocoa_ChartModel *lastModel = [self.candleView.currentDisplayArray lastObject];
    
    self.lastModel = lastModel;
    
    CGFloat x = ((self.candleView.candleWidth) / 2) + model.highPoint.x - self.mainScrollerView.contentOffset.x;
    
    model.priceChangeRatio = (model.close-model.open)/model.open;
//    if (model.localIndex > 1) {
//        Cocoa_ChartModel *previousModel = self.dataArray[model.localIndex-1];
//        model.priceChangeRatio = (model.close - previousModel.close)/previousModel.close;
//    }
    
    // y轴坐标让用户控制
    if (UIGestureRecognizerStateChanged == longPress.state ||
        UIGestureRecognizerStateBegan   == longPress.state) {
        
        /*********/
        [self maassignment:model];
        [self updataTecnnicalTextLayer:model :self.tecnnicalType];
        /*********/
        
        self.crossView.touchPoint = location;
        CGFloat suspendDateLWidth = self.crossView.suspendDateL.frame.size.width;
        CGFloat centerPointX = x;
        
        if (x < suspendDateLWidth/2.0) {
            
            self.crossView.suspendDateL.center = CGPointMake(suspendDateLWidth/2.0, CGRectGetMaxY(self.crossView.frame)-8);
        }else if (x > CGRectGetWidth(self.frame) - suspendDateLWidth/2.0) {
            
            self.crossView.suspendDateL.center = CGPointMake(CGRectGetWidth(self.frame)-suspendDateLWidth/2.0, CGRectGetMaxY(self.crossView.frame)-8);
        }else {
            
            self.crossView.suspendDateL.center = CGPointMake(centerPointX, CGRectGetMaxY(self.crossView.frame)-8);
        }
        
        NSString *crossValueStr = nil;
        
//        CGFloat tecnnicalValueY = originlocation.y - (self.topKViewHeight);
//
//        if (originlocation.y >= self.topKViewHeight) {
//
//            crossValueStr = [NSString stringWithFormat:@"%@", klineValue((self.VolumeTecnnicaHeight - tecnnicalValueY)/self.temptecnnicalStateView.scaleValue + self.temptecnnicalStateView.coordinateminValue, model.volumaccuracy)];
//        }
//        else {
//
//            crossValueStr = [NSString stringWithFormat:@"%@", klineValue((self.topKViewHeight-y)/self.candleView.scaleValue + self.candleView.coordinateminValue, model.priceaccuracy)];
//        }
        //y值核心代码
        CGFloat volumeValueY = originlocation.y - (self.topKViewHeight);
        CGFloat tecnnicalValueY = originlocation.y - (self.topKViewHeight+self.VolumeTecnnicaHeight);
        if(originlocation.y<self.topKViewHeight){
            crossValueStr = [NSString stringWithFormat:@"%@", klineValue((self.topKViewHeight-y)/self.candleView.scaleValue + self.candleView.coordinateminValue, model.priceaccuracy)];
        }
        if (originlocation.y>=self.topKViewHeight&&originlocation.y<self.topKViewHeight+self.VolumeTecnnicaHeight ) {
            crossValueStr = [NSString stringWithFormat:@"%@", klineValue((self.VolumeTecnnicaHeight - volumeValueY)/self.tradingVolumeView.scaleValue + self.tradingVolumeView.coordinateminValue, model.volumaccuracy)];
            crossValueStr=[SXNumberUtils volFormat:crossValueStr];
        }
        if(originlocation.y >=self.topKViewHeight+self.VolumeTecnnicaHeight){
             crossValueStr = [NSString stringWithFormat:@"%@", klineValue((self.tecnnicalHeight - tecnnicalValueY)/self.temptecnnicalStateView.scaleValue + self.temptecnnicalStateView.coordinateminValue, model.priceaccuracy)];
        }
        [self.crossView drawCrossLineWithPoint:CGPointMake(x, y) inofStr:crossValueStr chartModel:model];
        
        self.mainScrollerView.scrollEnabled = NO;
        
        oldPositionX = location.x;
    }
    
    if(longPress.state == UIGestureRecognizerStateEnded) {
        self.mainScrollerView.scrollEnabled = YES;
        self.crossView.touchPoint = location;
        [self.crossView removeFromSuperview];
        [self maassignment:self.lastModel];
        [self updataTecnnicalTextLayer:self.lastModel :self.tecnnicalType];
    }
}

/** 横竖屏切换 */
- (void)landscapeSwitch
{
    [self calculateHeight];
    [self drawVerificalLine];
    [self main_layoutsubview];
    [self refreshChartView];
    [self refreshTecnnical:self.tecnnicalType];
}
- (void)pinchesView:(UIPinchGestureRecognizer *)pinchTap
{
    
    if (pinchTap.state == UIGestureRecognizerStateEnded) {
        
        self.mainScrollerView.scrollEnabled = YES;
        
    }else if (pinchTap.state == UIGestureRecognizerStateBegan && _currentZoom != 0.0f) {
        
        self.mainScrollerView.scrollEnabled = NO;
        pinchTap.scale = _currentZoom;
        
    }else if (pinchTap.state == UIGestureRecognizerStateChanged) {
        
        self.mainScrollerView.scrollEnabled = NO;
        
        if (isnan(_currentZoom)) {
            return;
        }
        
        [self.candleView pinGesture:pinchTap];
    }
}

#pragma mark - Cocoa_ChartProtocol delegate
- (void)displayMoreData
{
    if (self.loadmoredataBlock) {
        
        self.loadmoredataBlock(nil);
    }
}

- (void)displayScreenleftPostion:(CGFloat)leftPostion startIndex:(NSInteger)index count:(NSInteger)count
{
    [self showIndexLineView:leftPostion startIndex:index count:count];
    
    CGFloat showContentWidth = self.candleView.displayCount * (self.candleView.candleSpace + self.candleView.candleWidth);
    
    // 获取纵坐标做 中 右 三个数据 // 底部日期更新
    if (self.candleView.currentDisplayArray.count > 0) {
        
        Cocoa_ChartModel *firstModel = [self.candleView.currentDisplayArray firstObject];
        self.firstDateTextLayer.string = firstModel.date;
        CGFloat kcontentWidth = CGRectGetWidth(self.frame) - self.candleView.padding.left - self.candleView.padding.right;
        CGFloat ksingleWidth = self.candleView.candleSpace + self.candleView.candleWidth;
        if (self.candleView.displayCount/3 < self.candleView.currentDisplayArray.count && showContentWidth > CGRectGetWidth(self.frame)/3.0) {
            NSInteger kmodelCount = kcontentWidth/(3*ksingleWidth);
            Cocoa_ChartModel *secondModel = self.candleView.currentDisplayArray[kmodelCount];
            self.secondeDateTextLayer.string = secondModel.date;
        }else {
            self.secondeDateTextLayer.string = nil;
        }
        
        if (self.candleView.displayCount*2/3 < self.candleView.currentDisplayArray.count && showContentWidth > CGRectGetWidth(self.frame)*2.0/3.0) {
            
            NSInteger kmodelCount = (kcontentWidth*2)/(3*ksingleWidth);
            Cocoa_ChartModel *thirdModel = self.candleView.currentDisplayArray[kmodelCount];
            self.thirdDateTextLayer.string = thirdModel.date;
        }else {
            self.thirdDateTextLayer.string = nil;
        }
        
        if (showContentWidth >= CGRectGetWidth(self.frame) - self.candleView.padding.left - self.candleView.padding.right) {
            
            Cocoa_ChartModel *fourthModel = [self.candleView.currentDisplayArray lastObject];
            self.fourthDateTextLayer.string = fourthModel.date;
        }else {
            self.fourthDateTextLayer.string = nil;
        }
    }
    
    // 均值数据更新
    Cocoa_ChartModel *lastModel = [self.candleView.currentDisplayArray lastObject];
    [self maassignment:lastModel];
    
 
    self.volumeTextLayer.string = [NSString stringWithFormat:@"%@:%@",@"VOL",[SXNumberUtils volFormat:klineValue(self.tradingVolumeView.maxValue, lastModel.volumaccuracy)]];
    
    //更新指标文字
    [self updataTecnnicalTextLayer:lastModel :self.tecnnicalType];
    
    // 坐标更新
    [self updatecoordinateValue:[self.dataArray firstObject]];
    
    if (CGRectGetWidth(self.tecnnicalView.frame) == CGRectGetWidth(self.candleView.frame)) {
        return;
    }
    self.volumeView.frame = CGRectMake(0,  self.topKViewHeight, CGRectGetWidth(_candleView.frame), self.VolumeTecnnicaHeight);
    self.tecnnicalView.frame = CGRectMake(0,  self.topKViewHeight+self.VolumeTecnnicaHeight, CGRectGetWidth(_candleView.frame), self.tecnnicalHeight);
}
//更新指标文字
-(void)updataTecnnicalTextLayer:(Cocoa_ChartModel *)chartModel :(TecnnicalType)tecnnicalType{
    NSString *techName=@"";
    if(self.tecnnicalType<self.tecnnicalNameArray.count){
        techName=self.tecnnicalNameArray[tecnnicalType];
    }else{
        
    }
    self.tecnnicalTextLayer.string = [NSString stringWithFormat:@"%@:%@",techName,klineValue(self.temptecnnicalStateView.maxValue, chartModel.priceaccuracy)];
    
    
    if(tecnnicalType==TecnnicalType_MACD){
        NSString *macd=[NSString stringWithFormat:@"MACD:%@",klineValue(chartModel.macd, chartModel.priceaccuracy)];
        NSString *dif=[NSString stringWithFormat:@"DIF:%@",klineValue(chartModel.diff, chartModel.priceaccuracy)];
        NSString *dea=[NSString stringWithFormat:@"DEA:%@",klineValue(chartModel.dea, chartModel.priceaccuracy)];
        self.tecnnicalTextLayer.string = [NSString stringWithFormat:@"MACD(12,26,9)    %@ %@ %@",macd,dif,dea];
        
        NSRange macdRange=[self.tecnnicalTextLayer.string rangeOfString:macd];
        NSRange difRange=[self.tecnnicalTextLayer.string rangeOfString:dif];
        NSRange deaRange=[self.tecnnicalTextLayer.string rangeOfString:dea];
        
        NSDictionary *attributedDict = @{
                                         NSFontAttributeName:[UIFont systemFontOfSize:10.0],
                                         NSForegroundColorAttributeName:COLOR_COORDINATETEXT
                                         };
        NSMutableAttributedString *attrStr=[[NSMutableAttributedString alloc] initWithString:self.tecnnicalTextLayer.string];
        [attrStr setAttributes:attributedDict range:NSMakeRange(0, attrStr.length)];
        
        if(macdRange.location!=NSNotFound){
            [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor magentaColor] range:macdRange];
        }
        if(difRange.location!=NSNotFound){
            [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:difRange];
        }
        if(deaRange.location!=NSNotFound){
            [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:deaRange];
        }
        self.tecnnicalTextLayer.string=attrStr;
    }
    if(tecnnicalType==TecnnicalType_KDJ){
        NSString *KValue=[NSString stringWithFormat:@"K:%@",klineValue(chartModel.KValue, chartModel.priceaccuracy)];
        NSString *DValue=[NSString stringWithFormat:@"D:%@",klineValue(chartModel.DValue, chartModel.priceaccuracy)];
        NSString *JValue=[NSString stringWithFormat:@"J:%@",klineValue(chartModel.JValue, chartModel.priceaccuracy)];
        self.tecnnicalTextLayer.string = [NSString stringWithFormat:@"KDJ(14,1,3)    %@ %@ %@",KValue,DValue,JValue];
        
        NSRange KRange=[self.tecnnicalTextLayer.string rangeOfString:KValue];
        NSRange DRange=[self.tecnnicalTextLayer.string rangeOfString:DValue];
        NSRange JRange=[self.tecnnicalTextLayer.string rangeOfString:JValue];
        
        NSDictionary *attributedDict = @{
                                         NSFontAttributeName:[UIFont systemFontOfSize:10.0],
                                         NSForegroundColorAttributeName:COLOR_COORDINATETEXT
                                         };
        NSMutableAttributedString *attrStr=[[NSMutableAttributedString alloc] initWithString:self.tecnnicalTextLayer.string];
        [attrStr setAttributes:attributedDict range:NSMakeRange(0, attrStr.length)];
        
        if(KRange.location!=NSNotFound){
            [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:KRange];
        }
        if(DRange.location!=NSNotFound){
            [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:DRange];
        }
        if(JRange.location!=NSNotFound){
            [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor purpleColor] range:JRange];
        }
        self.tecnnicalTextLayer.string=attrStr;
    }
    
    
}
- (void)showIndexLineView:(CGFloat)leftPostion startIndex:(NSInteger)index count:(NSInteger)count
{
    self.leftPostion = leftPostion;
    self.startIndex = index;
    self.displayCount = count;
    
    //成交量图
    self.tradingVolumeView.candleSpace = self.candleView.candleSpace;
    self.tradingVolumeView.candleWidth = self.candleView.candleWidth;
    self.tradingVolumeView.leftPostion = leftPostion;
    self.tradingVolumeView.startIndex  = index;
    self.tradingVolumeView.displayCount = count;
    self.tradingVolumeView.padding = self.candleView.padding;
    
    if ([self.tradingVolumeView respondsToSelector:@selector(refreshChartView)]) {
        [self.tradingVolumeView refreshChartView];
    }
    //指标图
    self.temptecnnicalStateView.candleSpace = self.candleView.candleSpace;
    self.temptecnnicalStateView.candleWidth = self.candleView.candleWidth;
    self.temptecnnicalStateView.leftPostion = leftPostion;
    self.temptecnnicalStateView.startIndex  = index;
    self.temptecnnicalStateView.displayCount = count;
    self.temptecnnicalStateView.padding = self.candleView.padding;
   
    if ([self.temptecnnicalStateView respondsToSelector:@selector(refreshChartView)]) {
        
        [self.temptecnnicalStateView refreshChartView];
    }
}

#pragma mark - 布局
- (void)calculateHeight
{
    CGFloat totalHeight = CGRectGetHeight(self.mainScrollerView.frame);
    self.xAxisViewHeight=16;
    if(self.tecnnicalType==TecnnicalType_Close){
        self.tecnnicalHeight=0;
        self.tecnnicalTextLayer.hidden=YES;
        self.tecnnicalView.hidden=YES;
    }else{
        self.tecnnicalHeight=totalHeight*kTecnnicalChartScale;
        self.tecnnicalTextLayer.hidden=NO;
        self.tecnnicalView.hidden=NO;
    }
    self.VolumeTecnnicaHeight = totalHeight*kVolumeViewChartScale;
    self.topKViewHeight       = totalHeight-self.VolumeTecnnicaHeight-self.tecnnicalHeight;
}

- (void)main_layoutsubview
{
    _mainScrollerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-_xAxisViewHeight);
    _crossView.frame = self.bounds;
    _candleView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), self.topKViewHeight);
    _volumeView.frame = CGRectMake(0,  self.topKViewHeight, CGRectGetWidth(_candleView.frame), self.VolumeTecnnicaHeight);
    _tecnnicalView.frame = CGRectMake(0,  self.topKViewHeight+self.VolumeTecnnicaHeight, CGRectGetWidth(_candleView.frame), self.tecnnicalHeight);
    self.xAxisView.frame=CGRectMake(0, CGRectGetHeight(self.frame)-self.xAxisViewHeight, CGRectGetWidth(self.mainScrollerView.frame),self.xAxisViewHeight);
    [self layoutcoordinate];
}

- (void)layoutcoordinate
{
    self.topTextLayer.frame = CGRectMake(CGRectGetWidth(self.frame)-100, 0, 100, 15);
    self.topSecTextLayer.frame = CGRectMake(CGRectGetWidth(self.frame)-100, _topKViewHeight/4.0f - 15, 100, 15);
    
    self.bottomTextLayer.frame = CGRectMake(CGRectGetWidth(self.frame)-100, _topKViewHeight-15, 100, 15);
    self.bottomSecTextLayer.frame = CGRectMake(CGRectGetWidth(self.frame)-100, _topKViewHeight*3/4.0f - 15, 100, 15);
    self.centerTextLayer.frame = CGRectMake(CGRectGetWidth(self.frame)-100, _topKViewHeight/2.0f - 15, 100, 15);
    
    self.volumeTextLayer.frame=CGRectMake(10, _topKViewHeight+5, 100, 15);
    self.tecnnicalTextLayer.frame = CGRectMake(10, _topKViewHeight+_VolumeTecnnicaHeight+5, CGRectGetWidth(self.candleView.frame)-20, 15);
    
    self.firstDateTextLayer.frame = CGRectMake(0, 0, 100, 16);
    self.secondeDateTextLayer.frame = CGRectMake(CGRectGetWidth(self.frame)/3-50, 0, 100, 16);
    self.thirdDateTextLayer.frame = CGRectMake(CGRectGetWidth(self.frame)*2/3 - 50, 0, 100, 16);
    self.fourthDateTextLayer.frame = CGRectMake(CGRectGetWidth(self.frame)-100, 0, 100, 16);
    
    /** 均值布局 */
    self.ma1DataLayer.frame = CGRectMake(10, 2, 85, 16);
    self.ma2DataLayer.frame = CGRectMake(95, 2, 85, 16);
    self.ma3DataLayer.frame = CGRectMake(190, 2, 85, 16);
}

#pragma mark - lazy View
- (Cocoa_MACDView *)tradingMacdView
{
    if (!_tradingMacdView) {
        _tradingMacdView = [[Cocoa_MACDView alloc] init];
        _tradingMacdView.clipsToBounds = YES;
    }
    
    return _tradingMacdView;
}

- (Cocoa_TradingVolumeView *)tradingVolumeView
{
    if (!_tradingVolumeView) {
        
        _tradingVolumeView = [[Cocoa_TradingVolumeView alloc] init];
        _tradingVolumeView.clipsToBounds = YES;
        
        _tradingVolumeView.frame = self.tecnnicalView.bounds;
        _tradingVolumeView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    
    return _tradingVolumeView;
}

- (Cocoa_KDJView *)tecnnicalKDJView
{
    if (!_tecnnicalKDJView) {
        _tecnnicalKDJView = [[Cocoa_KDJView alloc] init];
        _tecnnicalKDJView.clipsToBounds = YES;
    }
    
    return _tecnnicalKDJView;
}

- (Cocoa_OBVView *)tecnnicalOBVView
{
    if (!_tecnnicalOBVView) {
        _tecnnicalOBVView = [[Cocoa_OBVView alloc] init];
        _tecnnicalOBVView.clipsToBounds = YES;
        
    }
    
    return _tecnnicalOBVView;
}

- (Cocoa_WRView *)tecnnicalWRView
{
    if (!_tecnnicalWRView) {
        _tecnnicalWRView = [[Cocoa_WRView alloc] init];
        _tecnnicalWRView.clipsToBounds = YES;
        
    }
    
    return _tecnnicalWRView;
}

- (UIScrollView *)mainScrollerView
{
    if (!_mainScrollerView) {
        _mainScrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height-self.xAxisViewHeight)];
        _mainScrollerView.userInteractionEnabled = YES;
        _mainScrollerView.showsVerticalScrollIndicator = NO;
        _mainScrollerView.showsHorizontalScrollIndicator = NO;
    }
    return _mainScrollerView;
}

- (Cocoa_CandleLineView *)candleView
{
    if (!_candleView) {
        _candleView = [[Cocoa_CandleLineView alloc] init];
        _candleView.delegate = self;
        _candleView.userInteractionEnabled = NO;
        _candleView.isloadMoreEnable=self.loadMoreEnable;
        _candleView.clipsToBounds = YES;
        _candleView.padding = UIEdgeInsetsMake(20, 5, 12, 20);
    }
    
    return _candleView;
}
- (Cocoa_TecnnicalView *)volumeView
{
    if (!_volumeView) {
        _volumeView = [[Cocoa_TecnnicalView alloc] init];
        _volumeView.userInteractionEnabled = NO;
        _volumeView.clipsToBounds = YES;
    }
    return _volumeView;
}

- (Cocoa_TecnnicalView *)tecnnicalView
{
    if (!_tecnnicalView) {
        _tecnnicalView = [[Cocoa_TecnnicalView alloc] init];
        _tecnnicalView.userInteractionEnabled = NO;
        _tecnnicalView.clipsToBounds = YES;
    }
    return _tecnnicalView;
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    
    return _dataArray;
}

- (NSMutableArray *)tecnnicalArray
{
    if (!_tecnnicalArray) {
        _tecnnicalArray = [NSMutableArray array];
    }
    
    return _tecnnicalArray;
}
- (NSMutableArray *)tecnnicalNameArray{
    if (!_tecnnicalNameArray) {
        _tecnnicalNameArray = [NSMutableArray array];
    }
    return _tecnnicalNameArray;
}

- (Cocoa_CrossCurveView *)crossView
{
    if (!_crossView) {
        _crossView = [[Cocoa_CrossCurveView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), _topKViewHeight+_VolumeTecnnicaHeight+_tecnnicalHeight+_xAxisViewHeight)];
        _crossView.clipsToBounds = YES;
        _crossView.userInteractionEnabled = NO;
    }
    
    return _crossView;
}

- (CAShapeLayer*)verificalLayer
{
    if (!_verificalLayer) {
        
        _verificalLayer = [CAShapeLayer layer];
    }
    return _verificalLayer;
}

- (CATextLayer *)topTextLayer
{
    if (!_topTextLayer) {
        
        _topTextLayer = [CATextLayer layer];
        _topTextLayer.contentsScale = [UIScreen mainScreen].scale;
        _topTextLayer.fontSize = 10.f;
        _topTextLayer.alignmentMode = kCAAlignmentRight;
        _topTextLayer.foregroundColor =
        COLOR_COORDINATETEXT.CGColor;
        _topTextLayer.string = @"";
    }
    
    return _topTextLayer;
}

- (CATextLayer *)topSecTextLayer
{
    if (!_topSecTextLayer) {
        
        _topSecTextLayer = [CATextLayer layer];
        _topSecTextLayer.contentsScale = [UIScreen mainScreen].scale;
        _topSecTextLayer.fontSize = 10.f;
        _topSecTextLayer.alignmentMode = kCAAlignmentRight;
        _topSecTextLayer.foregroundColor =
        COLOR_COORDINATETEXT.CGColor;
        _topSecTextLayer.string = @"";
    }
    
    return _topSecTextLayer;
}

- (CATextLayer *)bottomTextLayer
{
    if (!_bottomTextLayer) {
        
        _bottomTextLayer = [CATextLayer layer];
        _bottomTextLayer.contentsScale = [UIScreen mainScreen].scale;
        _bottomTextLayer.fontSize = 10.f;
        _bottomTextLayer.alignmentMode = kCAAlignmentRight;
        _bottomTextLayer.foregroundColor =
        COLOR_COORDINATETEXT.CGColor;
        _bottomTextLayer.string = @"";
        
    }
    
    return _bottomTextLayer;
}

- (CATextLayer *)bottomSecTextLayer
{
    if (!_bottomSecTextLayer) {
        
        _bottomSecTextLayer = [CATextLayer layer];
        _bottomSecTextLayer.contentsScale = [UIScreen mainScreen].scale;
        _bottomSecTextLayer.fontSize = 10.f;
        _bottomSecTextLayer.alignmentMode = kCAAlignmentRight;
        _bottomSecTextLayer.foregroundColor =
        COLOR_COORDINATETEXT.CGColor;
        _bottomSecTextLayer.string = @"";
        
    }
    
    return _bottomSecTextLayer;
}

- (CATextLayer *)centerTextLayer
{
    if (!_centerTextLayer) {
        
        _centerTextLayer = [CATextLayer layer];
        _centerTextLayer.contentsScale = [UIScreen mainScreen].scale;
        _centerTextLayer.fontSize = 10.f;
        _centerTextLayer.alignmentMode = kCAAlignmentRight;
        _centerTextLayer.foregroundColor =
        COLOR_COORDINATETEXT.CGColor;
        _centerTextLayer.string = @"";
    }
    
    return _centerTextLayer;
}
- (UIView *)xAxisView{
    if(!_xAxisView){
        _xAxisView=[[UIView alloc] init];
//        _xAxisView.backgroundColor=[UIColor redColor];
    }
    return _xAxisView;
}
- (CATextLayer *)firstDateTextLayer
{
    if (!_firstDateTextLayer) {
        
        _firstDateTextLayer = [CATextLayer layer];
        _firstDateTextLayer.contentsScale = [UIScreen mainScreen].scale;
        _firstDateTextLayer.fontSize = 10.f;
        _firstDateTextLayer.alignmentMode = kCAAlignmentNatural;
        _firstDateTextLayer.foregroundColor =
        COLOR_COORDINATETEXT.CGColor;
        _firstDateTextLayer.string = @"";
    }
    
    return _firstDateTextLayer;
}

- (CATextLayer *)secondeDateTextLayer
{
    if (!_secondeDateTextLayer) {
        
        _secondeDateTextLayer = [CATextLayer layer];
        _secondeDateTextLayer.contentsScale = [UIScreen mainScreen].scale;
        _secondeDateTextLayer.fontSize = 10.f;
        _secondeDateTextLayer.alignmentMode = kCAAlignmentCenter;
        _secondeDateTextLayer.foregroundColor =
        COLOR_COORDINATETEXT.CGColor;
        _secondeDateTextLayer.string = @"";
    }
    
    return _secondeDateTextLayer;
}

- (CATextLayer *)thirdDateTextLayer
{
    if (!_thirdDateTextLayer) {
        
        _thirdDateTextLayer = [CATextLayer layer];
        _thirdDateTextLayer.contentsScale = [UIScreen mainScreen].scale;
        _thirdDateTextLayer.fontSize = 10.f;
        _thirdDateTextLayer.alignmentMode = kCAAlignmentCenter;
        _thirdDateTextLayer.foregroundColor =
        COLOR_COORDINATETEXT.CGColor;
        _thirdDateTextLayer.string = @"";
    }
    
    return _thirdDateTextLayer;
}

- (CATextLayer *)fourthDateTextLayer
{
    if (!_fourthDateTextLayer) {
        
        _fourthDateTextLayer = [CATextLayer layer];
        _fourthDateTextLayer.contentsScale = [UIScreen mainScreen].scale;
        _fourthDateTextLayer.fontSize = 10.f;
        _fourthDateTextLayer.alignmentMode = kCAAlignmentRight;
        _fourthDateTextLayer.foregroundColor =
        COLOR_COORDINATETEXT.CGColor;
        _fourthDateTextLayer.string = @"";
    }
    
    return _fourthDateTextLayer;
}
- (CATextLayer *)volumeTextLayer
{
    if (!_volumeTextLayer) {
        
        _volumeTextLayer = [CATextLayer layer];
        _volumeTextLayer.contentsScale = [UIScreen mainScreen].scale;
        _volumeTextLayer.fontSize = 10.f;
        _volumeTextLayer.alignmentMode = kCAGravityLeft;
        _volumeTextLayer.foregroundColor =
        COLOR_COORDINATETEXT.CGColor;
        _volumeTextLayer.string = @"";
    }
    
    return _volumeTextLayer;
}

- (CATextLayer *)tecnnicalTextLayer
{
    if (!_tecnnicalTextLayer) {
        
        _tecnnicalTextLayer = [CATextLayer layer];
        _tecnnicalTextLayer.contentsScale = [UIScreen mainScreen].scale;
        _tecnnicalTextLayer.fontSize = 10.f;
        _tecnnicalTextLayer.alignmentMode = kCAGravityLeft;
        _tecnnicalTextLayer.foregroundColor =
        COLOR_COORDINATETEXT.CGColor;
        _tecnnicalTextLayer.string = @"";
    }
    
    return _tecnnicalTextLayer;
}

- (CATextLayer *)ma1DataLayer
{
    if (!_ma1DataLayer) {
        
        _ma1DataLayer = [CATextLayer layer];
        _ma1DataLayer.contentsScale = [UIScreen mainScreen].scale;
        _ma1DataLayer.fontSize = 10.f;
        _ma1DataLayer.alignmentMode = kCAGravityLeft;
        _ma1DataLayer.foregroundColor =
        _candleView.ma1AvgLineColor.CGColor;
        _ma1DataLayer.string = @"";
    }
    
    return _ma1DataLayer;
}

- (CATextLayer *)ma2DataLayer
{
    if (!_ma2DataLayer) {
        
        _ma2DataLayer = [CATextLayer layer];
        _ma2DataLayer.contentsScale = [UIScreen mainScreen].scale;
        _ma2DataLayer.fontSize = 10.f;
        _ma2DataLayer.alignmentMode = kCAGravityLeft;
        _ma2DataLayer.foregroundColor =
        _candleView.ma2AvgLineColor.CGColor;
        _ma2DataLayer.string = @"";
    }
    
    return _ma2DataLayer;
}

- (CATextLayer *)ma3DataLayer
{
    if (!_ma3DataLayer) {
        
        _ma3DataLayer = [CATextLayer layer];
        _ma3DataLayer.contentsScale = [UIScreen mainScreen].scale;
        _ma3DataLayer.fontSize = 10.f;
        _ma3DataLayer.alignmentMode = kCAGravityLeft;
        _ma3DataLayer.foregroundColor =
        _candleView.ma3AvgLineColor.CGColor;
        _ma3DataLayer.string = @"";
    }
    
    return _ma3DataLayer;
}

@synthesize coordinateMaxValue;

@synthesize coordinateminValue;

@synthesize maxValue;

@synthesize minValue;

@synthesize padding;

@synthesize scaleValue;

@synthesize leftPostion;

@synthesize startIndex;

@synthesize displayCount;

@end
