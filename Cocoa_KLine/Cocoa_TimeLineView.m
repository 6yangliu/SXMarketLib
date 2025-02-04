 //
//  Cocoa_CandleLineView.m
//  Cocoa-KLine
//
//  Created by Yochi on 2018/7/31.
//  Copyright © 2018年 Yochi. All rights reserved.
//

#import "Cocoa_TimeLineView.h"
#import "Cocoa_KLine.h"
#import "Cocoa_ChartStylesheet.h"
@interface Cocoa_TimeLineView ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIScrollView *parentsScrollView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat preContentOffset;
// 所要绘制的区域的宽度
@property (nonatomic, assign) CGFloat contentWidth;

@property (nonatomic,assign) CGFloat contentOffset;

// 手指长按触摸点
@property (nonatomic, assign) CGPoint touchPoint;

/** 当前屏幕范围内绘制起点位置 */


/** 涨跌幅k线 */
@property (nonatomic,strong) CAShapeLayer *advancesLayer;
@property (nonatomic,strong) CAShapeLayer *declinesLayer;

/** 均线 */
@property (nonatomic,strong) CAShapeLayer *ma1LineLayer;
@property (nonatomic,strong) CAShapeLayer *ma2LineLayer;
@property (nonatomic,strong) CAShapeLayer *ma3LineLayer;

@property (nonatomic,strong) UILabel *lowValueL;
@property (nonatomic,strong) UILabel *highValueL;

@property (nonatomic,strong) CAShapeLayer *timeLayer;
@property (nonatomic,assign) NSInteger totalCount;

// 啮合手势相关
@property (nonatomic, assign) CGFloat lastPinScale;
@property (nonatomic, assign) CGFloat lastPinCount;

@property (nonatomic, strong) Cocoa_ChartModel *zoomDisModel;
@property (nonatomic, assign) NSInteger zoomLocalIndex;
@property (nonatomic, assign) CGFloat oldContentOffsetX;
@property (nonatomic, assign) CGFloat oldContentWidth;

@property (nonatomic, assign) BOOL isLoadingMore;

@end

@implementation Cocoa_TimeLineView

#pragma mark 移除所有监听
- (void)removeAllObserver
{
    [_parentsScrollView removeObserver:self forKeyPath:@"contentOffset" context:observerContext];
}

static char *observerContext = NULL;
#pragma mark 添加所有事件监听的方法
- (void)private_addAllEventListener{

    [_parentsScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:observerContext];
}

#pragma mark - #pragma mark KVO监听实现
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    if (self.dataArray.count <=0 ) {
        return;
    }
    
    if([keyPath isEqualToString:@"contentOffset"]) {
        
        CGFloat difValue = fabs(self.parentsScrollView.contentOffset.x - self.oldContentOffsetX);
        
        if(difValue >= (self.candleWidth + self.candleSpace)) {
            
            /** 绘制k线 */
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            [self drawChartView];
            [CATransaction commit];
 
            self.oldContentOffsetX = self.parentsScrollView.contentOffset.x;
        }
    }
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
     
        [self initLayer];
    }
    
    return self;
}

- (void)initLayer
{
    [self.layer addSublayer:self.timeLayer];
    [self.layer addSublayer:self.advancesLayer];
    [self.layer addSublayer:self.declinesLayer];
    [self.layer addSublayer:self.ma1LineLayer];
    [self.layer addSublayer:self.ma2LineLayer];
    [self.layer addSublayer:self.ma3LineLayer];
    
    [self addSubview:self.lowValueL];
    [self addSubview:self.highValueL];
    [self addSubview:self.indicatorView];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    _parentsScrollView = (UIScrollView*)self.superview;
    _parentsScrollView.delegate = self;
    UIPanGestureRecognizer *panGestureRecognizer = _parentsScrollView.panGestureRecognizer;
    [panGestureRecognizer addTarget:self action:@selector(panGestureRecognizer:)];
    
    [self private_addAllEventListener];
}

#pragma mark - k线绘制逻辑
- (void)clearChartView
{
    self.parentsScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.parentsScrollView.frame)+0.3, 0);
    CGRect frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, CGRectGetWidth(self.parentsScrollView.frame), self.frame.size.height);
    self.frame = frame;
    self.indicatorView.center = CGPointMake(15, CGRectGetHeight(self.frame)/2.0);
    
    [self.indicatorView stopAnimating];
    self.isLoadingMore = NO;
    [self.advancesLayer removeFromSuperlayer];
    self.advancesLayer = nil;
    
    [self.declinesLayer removeFromSuperlayer];
    self.declinesLayer = nil;
    
    [self.ma1LineLayer removeFromSuperlayer];
    self.ma1LineLayer = nil;
    
    [self.ma2LineLayer removeFromSuperlayer];
    self.ma2LineLayer = nil;
    
    [self.ma3LineLayer removeFromSuperlayer];
    self.ma3LineLayer = nil;
    
    self.lowValueL.text = nil;
    self.highValueL.text = nil;
    
    [self.layer addSublayer:self.advancesLayer];
    [self.layer addSublayer:self.declinesLayer];
    [self.layer addSublayer:self.ma1LineLayer];
    [self.layer addSublayer:self.ma2LineLayer];
    [self.layer addSublayer:self.ma3LineLayer];
}

- (void)drawChartView
{
    [self initCurrentDisplayModels];
    
    [self calcuteMaxAndMinValue];
    
    /** 绘制k线 */
    [self drawCandleSublayers];
    
    /** 绘制均线 */
    [self drawMaSublayers];

    // 回到数据
    if (self.delegate && [self.delegate respondsToSelector: @selector(displayScreenleftPostion:startIndex:count:)]) {
        
        [_delegate displayScreenleftPostion:self.leftPostion startIndex:self.startIndex count:self.displayCount];
    }
}

/** 获取显示的k线个数 */
- (void)initCurrentDisplayModels
{
    NSInteger needDrawKLineCount = self.displayCount ;
    NSInteger currentStartIndex  = self.startIndex;
    NSInteger count = (currentStartIndex + needDrawKLineCount) >self.dataArray.count ? self.dataArray.count :currentStartIndex + needDrawKLineCount;
    
    [self.currentDisplayArray removeAllObjects];
    
    if (currentStartIndex < count) {
        
        for (NSInteger i = currentStartIndex; i <  count ; i++) {
            
            Cocoa_ChartModel *model = self.dataArray[i];
            
            model.localIndex = i;
            
            [self.currentDisplayArray addObject:model];
        }
        
        self.zoomDisModel = [self.currentDisplayArray firstObject];
    }
}

- (void)calcuteMaxAndMinValue
{
    CGFloat maxY  = CGFLOAT_MIN;
    CGFloat minY  = CGFLOAT_MAX;
    
    CGFloat minlowValue  = CGFLOAT_MAX;
    CGFloat maxHighValue = CGFLOAT_MIN;
    
    NSInteger idx = 0;
    for (NSInteger i = idx; i < self.currentDisplayArray
         .count; i++) {
        
        Cocoa_ChartModel * entity = [self.currentDisplayArray objectAtIndex:i];
        minY = minY < entity.low ? minY : entity.low;
        maxY = maxY > entity.high ? maxY : entity.high;
        
        minlowValue = minlowValue < entity.low ? minlowValue : entity.low;
        maxHighValue = maxHighValue > entity.high ? maxHighValue : entity.high;
      
//        maxY = MAX(maxY, MAX(entity.ma20, MAX(entity.ma10, entity.ma5)));
//        minY = MIN(minY, MIN(entity.ma20, MIN(entity.ma10, entity.ma5)));

        if (entity.ma20 !=0.0) {
            maxY = MAX(maxY, entity.ma20);
            minY = MIN(minY, entity.ma20);
        }

        // 10位精度
        if (maxY - minY < 0.00000000005) {
            
            maxY += 0.00000000005;
            minY -= 0.00000000005;
        }
    }
    
    self.minlowValue = minlowValue;
    self.maxHighValue = maxHighValue;
    
    self.maxValue = maxY;
    self.minValue = minY;
    
    // 单位价格高度 GRectGetHeight(self.frame)/self.scaleValue
    self.scaleValue = (CGRectGetHeight(self.frame)-self.padding.top - self.padding.bottom) / (maxY - minY);
    
    self.coordinateminValue = self.minValue - self.padding.bottom/self.scaleValue;
    
    self.coordinateMaxValue =  CGRectGetHeight(self.frame)/self.scaleValue + self.coordinateminValue;
}

- (void)drawCandleSublayers
{
    CGMutablePathRef advancesRef = CGPathCreateMutable();
    CGMutablePathRef declinesRef = CGPathCreateMutable();
    
    __weak typeof(self) weakself=self;
    [self.currentDisplayArray enumerateObjectsUsingBlock:^(Cocoa_ChartModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        __weak typeof(self) self=weakself;

        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat open  = ((self.maxValue - model.open) * self.scaleValue);
            CGFloat close = ((self.maxValue - model.close) * self.scaleValue);
            CGFloat high  = ((self.maxValue - model.high) * self.scaleValue);
            CGFloat low   = ((self.maxValue - model.low) * self.scaleValue);
            CGFloat left  = self.leftPostion + ((self.candleWidth + self.candleSpace) * idx) + self.padding.left;

            if (left >= self.parentsScrollView.contentSize.width) {
                left = self.parentsScrollView.contentSize.width - self.candleWidth/2.f;
            }

            /** 判断当前涨跌幅，画什么颜色线条  */
            CGMutablePathRef context = advancesRef;

            StockStyleState stockState = model.open <= model.close ? StockStateRise : StockStateFall;
            context = model.open <= model.close ? advancesRef : declinesRef;

            [self drawCandleWith:context openPoint:CGPointMake(left, open) closePoint:CGPointMake(left, close) highPoint:CGPointMake(left, high) lowPoint:CGPointMake(left,low) stockState:(stockState)];

            model.openPoint  = CGPointMake(left, open);
            model.closePoint = CGPointMake(left, close);
            model.highPoint  = CGPointMake(left, high);
            model.lowPoint   = CGPointMake(left, low);

            /** 绘制k线 */
            self.advancesLayer.path = advancesRef;

            /** 绘制k线 */
            self.declinesLayer.path = declinesRef;

            if (!((model.high >= self.maxHighValue) || (model.low <= self.minlowValue))) {
                return ;
            }

            if (model.high >= self.maxHighValue) {
                // 最大值
                CGFloat leftPointX = left + self.candleWidth/2.0 - 0.5;
                if (idx > self.displayCount/2 && left > self.parentsScrollView.frame.size.width/2.0) {

                    leftPointX = leftPointX-90;
                    self.highValueL.text = [NSString stringWithFormat:@"%@──", klineValue(model.high,model.priceaccuracy)];
                    self.highValueL.textAlignment = NSTextAlignmentRight;
                }else {

                    leftPointX = left + self.candleWidth/2.0 - 0.5;
                    self.highValueL.text = [NSString stringWithFormat:@"──%@", klineValue(model.high,model.priceaccuracy)];
                    self.highValueL.textAlignment = NSTextAlignmentLeft;
                }

                self.highValueL.frame = CGRectMake(leftPointX, high+10, 90, 16);

            }

            if (model.low <= self.minlowValue) {
                // 最小值
                CGFloat leftPointX = left + self.candleWidth/2.0 - 0.5;
                if (idx > self.displayCount/2 && left > self.parentsScrollView.frame.size.width/2.0) {

                    leftPointX = leftPointX-90;
                    self.lowValueL.text = [NSString stringWithFormat:@"%@──", klineValue(model.low,model.priceaccuracy)];
                    self.lowValueL.textAlignment = NSTextAlignmentRight;
                }else {

                    leftPointX = left + self.candleWidth/2.0 - 0.5;
                    self.lowValueL.text = [NSString stringWithFormat:@"──%@", klineValue(model.low,model.priceaccuracy)];
                    self.lowValueL.textAlignment = NSTextAlignmentLeft;
                }

                self.lowValueL.frame = CGRectMake(leftPointX, low + 14, 90, 16);
                
            }

            if (CGRectGetMidY(self.lowValueL.frame) - CGRectGetMidY(self.highValueL.frame) < 20) {
                self.lowValueL.text = @"";
                self.highValueL.text = @"";
            }
        });
    }];
}

/** 绘制均线 */
- (void)drawMaSublayers
{
    UIBezierPath *pathLine1 = [UIBezierPath bezierPath];
    UIBezierPath *pathLine2 = [UIBezierPath bezierPath];
    UIBezierPath *pathLine3 = [UIBezierPath bezierPath];
    
    for (NSInteger idx = 0; idx<self.currentDisplayArray.count; idx ++) {
        
        Cocoa_ChartModel *model = [self.currentDisplayArray objectAtIndex:idx];

        // 绘制五日均线
        CGPoint ma5Point = CGPointMake(self.padding.left+self.leftPostion + ((self.candleWidth  + self.candleSpace) * idx) + self.candleWidth/2, ((self.maxValue - model.ma5) *self.scaleValue) + self.padding.top);

        if (model.localIndex >= 4) {
         
            if (idx == 0) {
                
                [pathLine1 moveToPoint:CGPointMake(ma5Point.x,ma5Point.y)];
            }else {
                if (model.localIndex == 4) {
                    [pathLine1 moveToPoint:CGPointMake(ma5Point.x,ma5Point.y)];
                }
                [pathLine1 addLineToPoint:CGPointMake(ma5Point.x,ma5Point.y)];
            }
        }

        // 画十日均线
        CGPoint ma10Point = CGPointMake(self.padding.left+self.leftPostion + ((self.candleWidth  + self.candleSpace) * idx) + self.candleWidth/2, ((self.maxValue - model.ma10) *self.scaleValue) + self.padding.top);
        
        if (model.localIndex >= 9) {
         
            if (idx == 0) {
                
                [pathLine2 moveToPoint:CGPointMake(ma10Point.x,ma10Point.y)];
            }else {
                if (model.localIndex == 9) {
                    [pathLine2 moveToPoint:CGPointMake(ma10Point.x,ma10Point.y)];
                }
                [pathLine2 addLineToPoint:CGPointMake(ma10Point.x,ma10Point.y)];
            }
        }

        // 画三十日均线
        CGPoint ma20Point = CGPointMake(self.padding.left+self.leftPostion + ((self.candleWidth  + self.candleSpace) * idx) + self.candleWidth/2, ((self.maxValue - model.ma20) *self.scaleValue) + self.padding.top);
        if (model.localIndex >= 29) {
            
            if (idx == 0) {
                
                [pathLine3 moveToPoint:CGPointMake(ma20Point.x,ma20Point.y)];
            }else {
                
                if (model.localIndex == 29) {
                    [pathLine3 moveToPoint:CGPointMake(ma20Point.x,ma20Point.y)];
                }
                [pathLine3 addLineToPoint:CGPointMake(ma20Point.x,ma20Point.y)];
            }
        }

    }
    
    // 画五日均线
    self.ma1LineLayer.path = pathLine1.CGPath;
    self.ma3LineLayer.lineWidth = self.avgLineWidth;
    self.ma1LineLayer.strokeColor = self.ma1AvgLineColor.CGColor;
    self.ma1LineLayer.fillColor = [[UIColor clearColor] CGColor];
    self.ma1LineLayer.contentsScale = [UIScreen mainScreen].scale;
    
    // 画十日均线
    self.ma2LineLayer.path = pathLine2.CGPath;
    self.ma2LineLayer.strokeColor = self.ma2AvgLineColor.CGColor;
    self.ma2LineLayer.lineWidth = self.avgLineWidth;
    self.ma2LineLayer.fillColor = [[UIColor clearColor] CGColor];
    self.ma2LineLayer.contentsScale = [UIScreen mainScreen].scale;
    
    // 画二十日均线
    self.ma3LineLayer.path = pathLine3.CGPath;
    self.ma3LineLayer.strokeColor = self.ma3AvgLineColor.CGColor;
    self.ma3LineLayer.lineWidth = self.avgLineWidth;
    self.ma3LineLayer.fillColor = [[UIColor clearColor] CGColor];
    self.ma3LineLayer.contentsScale = [UIScreen mainScreen].scale;
}

/** 刷新数据 */
- (void) refreshChartView
{
    [self.indicatorView stopAnimating];
    
    if (self.dataArray.count == 0) {

        [self clearChartView];
        
        return;
    }
    
    CGFloat preContentOffset = self.parentsScrollView.contentSize.width;
    // (self.dataArray.count - 1) *self.candleSpace
    CGFloat klineWidth = (self.dataArray.count)*(self.candleWidth + self.candleSpace) + self.padding.left + self.padding.right;
    
    if(klineWidth < self.parentsScrollView.frame.size.width) {
        klineWidth = self.parentsScrollView.frame.size.width;
    }
    
    CGRect frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, klineWidth, self.frame.size.height);
    self.frame = frame;
    
    self.parentsScrollView.contentSize = CGSizeMake(klineWidth+0.3,0);
    preContentOffset = preContentOffset == 0 ? CGRectGetWidth(self.parentsScrollView.frame) : preContentOffset;
    
    CGFloat contentOffsetX = floor(klineWidth - preContentOffset);
    
    if (self.isLoadingMore) {
       
        self.parentsScrollView.contentOffset = CGPointMake(floor(klineWidth - preContentOffset),0);
    }else {
       
        contentOffsetX = klineWidth - self.parentsScrollView.frame.size.width;
        self.parentsScrollView.contentOffset = CGPointMake(contentOffsetX,0);
    }
    
    self.indicatorView.center = CGPointMake(15, CGRectGetHeight(self.frame)/2.0);
    self.isLoadingMore = NO;
    [self layoutIfNeeded];

    /** 绘制k线 */
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self drawChartView]; 
    [CATransaction commit];
}

#pragma mark - 绘制贝塞尔曲线
- (void)drawCandleWith:(CGMutablePathRef)context openPoint:(CGPoint)openPoint closePoint:(CGPoint)closePoint highPoint:(CGPoint)highPoint lowPoint:(CGPoint)lowPoint stockState:(StockStyleState)stockStat
{
    CGFloat openPrice  = openPoint.y + self.padding.top;
    CGFloat closePrice = closePoint.y + self.padding.top;
    CGFloat hightPrice = highPoint.y + self.padding.top;
    CGFloat lowPrice   = lowPoint.y + self.padding.top;
    CGFloat x = openPoint.x;
    CGFloat y = openPrice > closePrice ? (closePrice) : (openPrice);
    CGFloat height = MAX(fabs(closePrice-openPrice), 1);
    CGRect rect = CGRectMake(x, y, self.candleWidth, height);
    
    if (isEqualZero(fabs(closePrice-openPrice))) {
        
        rect = CGRectMake(x, closePrice - height, self.candleWidth, height);
    }
    
    CGPathAddRect(context, NULL, rect);
    
    CGFloat xPostion = x + self.candleWidth / 2;
    
    if (closePrice < openPrice) {
        
        if (!isEqualZero(closePrice - hightPrice)) {
            CGPathMoveToPoint(context, NULL, xPostion, closePrice);
            CGPathAddLineToPoint(context, NULL, xPostion, hightPrice);
        }
        
        if (!isEqualZero(lowPrice - closePrice)) {
            
            CGPathMoveToPoint(context, NULL, xPostion, lowPrice);
            CGPathAddLineToPoint(context, NULL, xPostion, closePrice);
        }
        
    }else {
        
        if (!isEqualZero(hightPrice - closePrice)) {
            
            CGPathMoveToPoint(context, NULL, xPostion, closePrice);
            CGPathAddLineToPoint(context, NULL, xPostion, hightPrice);
        }
        
        if (!isEqualZero(lowPrice - openPrice)) {
            
            CGPathMoveToPoint(context, NULL, xPostion, lowPrice);
            CGPathAddLineToPoint(context, NULL, xPostion, openPrice);
        }
    }
}

- (UIBezierPath*)drawAvgLineWithMovePoint:(CGPoint)movePoint stopPoint:(CGPoint)stopPoint lineColor:(UIColor *)lineColor
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(movePoint.x,movePoint.y)];
    [path addLineToPoint:CGPointMake(stopPoint.x,stopPoint.y)];
    return path;
}

- (void)pinGesture:(UIPinchGestureRecognizer *)pin
{
    CGFloat zoomBefore = (self.zoomDisModel.localIndex)*(self.candleSpace + self.candleWidth);
    
    pin.scale = pin.scale - self.lastPinScale + 1;
    pin.scale = (pin.scale > 1.2) ? 1.2 : pin.scale;
    
    CGFloat klineWidth = (self.dataArray.count)*(self.candleWidth) + (self.dataArray.count-1) *self.candleSpace + self.padding.left + self.padding.right;
    
    if (klineWidth<= self.parentsScrollView.frame.size.width && pin.scale <=1.0) {
        //缩放最小，屏宽
        return;
    }
    
    self.candleWidth  = pin.scale*self.candleWidth;
    
    self.lastPinScale = pin.scale;
    
    klineWidth = (self.dataArray.count)*(self.candleWidth) + (self.dataArray.count-1) *self.candleSpace + self.padding.left + self.padding.right;
    
    if(klineWidth < self.parentsScrollView.frame.size.width) {
        klineWidth = self.parentsScrollView.frame.size.width;
    }

    CGRect frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, klineWidth, self.frame.size.height);
    self.frame = frame;

    self.parentsScrollView.contentSize = CGSizeMake(klineWidth+0.3,0);

    Cocoa_ChartModel *lastModel = [self.currentDisplayArray lastObject];
    
    if (klineWidth != self.parentsScrollView.frame.size.width && lastModel.localIndex < self.dataArray.count - 2) {
        
        CGFloat zoomAfter = (self.zoomDisModel.localIndex)*(self.candleSpace + self.candleWidth);

        self.parentsScrollView.contentOffset = CGPointMake(self.contentOffset + (zoomAfter - zoomBefore), 0);
    }
    
    /** 绘制k线 */
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self drawChartView];
    [CATransaction commit];
}

#pragma mark - scrolle delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.contentOffset = scrollView.contentOffset.x;
    
    //NSLog(@"self.contentOffset : %f", self.contentOffset);
    
    if (self.contentOffset <=0.0) {
        return;
    }

    if (self.socketFlag && fabs(self.contentOffset + CGRectGetWidth(self.parentsScrollView.frame)-self.parentsScrollView.contentSize.width) <= self.candleWidth) {
        
        [self refreshChartView];
        self.socketFlag = NO;
    }
    if(self.isloadMoreEnable){
        //给定一个临界初始值(负数)
        if (self.parentsScrollView.contentOffset.x <= 30 && !self.isLoadingMore) {
            
            if (self.totalCount == self.dataArray.count) {
                return;
            }
            
            self.totalCount = self.dataArray.count;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(displayMoreData)]) {
                self.isLoadingMore = YES;
                //记录上一次的偏移量
                self.preContentOffset = self.parentsScrollView.contentSize.width  - _parentsScrollView.contentOffset.x;
                
                [self.indicatorView startAnimating];
                // 加载框移到最前面
                [self bringSubviewToFront:self.indicatorView];
                [_delegate displayMoreData];
            }
        }
    }
}

#pragma mark - panGestureRecognizerAction

- (void)panGestureRecognizer:(UIPanGestureRecognizer*)panGestureRecognizer
{
    /** 用于加载更多数据使用 */
    switch (panGestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            
        }break;
            
        case UIGestureRecognizerStateChanged:
        {
            
        }break;
            
        case UIGestureRecognizerStateEnded:
        {
            if(self.isloadMoreEnable){
                //给定一个临界初始值(负数) 手动加载更多取消
                [self loadMoreKlineData];
            }

        }break;
            
        default:
            
            break;
    }
}

- (void)loadMoreKlineData
{
    if (self.parentsScrollView.contentOffset.x <= -20&& !self.isLoadingMore) {
        
        if (self.totalCount != self.dataArray.count &&  self.contentOffset >0.0) {
            return;
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(displayMoreData)]) {
            self.isLoadingMore = YES;
            //记录上一次的偏移量
            self.preContentOffset = self.parentsScrollView.contentSize.width  - _parentsScrollView.contentOffset.x;
        
            
            [self.indicatorView startAnimating];
            [_delegate displayMoreData];
        }
    }
}

#pragma mark - layz

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        
        _dataArray = [NSMutableArray array];
    }
    
    return _dataArray;
}

- (NSMutableArray*)currentDisplayArray
{
    if (!_currentDisplayArray)
    {
        _currentDisplayArray = [NSMutableArray array];
    }
    return _currentDisplayArray;
}


- (NSInteger)displayCount
{
    _displayCount = ceil(self.contentWidth / (self.candleWidth + self.candleSpace));

    if (_displayCount > self.dataArray.count) {
        _displayCount = self.dataArray.count;
    }
    
    return _displayCount;
}

- (CGFloat)contentWidth
{
    return self.parentsScrollView.bounds.size.width - self.padding.left - self.padding.right;
}

- (CGFloat)candleSpace
{
    /** 编剧为线宽的1/3 */
    return (self.candleWidth / 3.0) < 1 ? 1 : self.candleWidth / 3.0;
}

/** 获取左侧开始的位置 */
- (NSInteger)startIndex
{
    CGFloat scrollViewOffsetX = self.leftPostion < 0 ? 0 : self.leftPostion;
    
    NSInteger leftArrCount = ceil(scrollViewOffsetX / (self.candleWidth+self.candleSpace));
    
    if (leftArrCount > self.dataArray.count) {
        
        _startIndex = self.dataArray.count - 1;
    } else if (leftArrCount == 0) {
        
        _startIndex = 0;
    }else {
        
        _startIndex =  leftArrCount ;
    }
    
    return _startIndex;
}

- (CGFloat)leftPostion
{
    // 左侧位置 0 开始
    CGFloat scrollViewOffsetX = _contentOffset <  0  ?  0 : _contentOffset;
   
    if (_contentOffset + self.parentsScrollView.frame.size.width >= self.parentsScrollView.contentSize.width) {
        
        scrollViewOffsetX = self.parentsScrollView.contentSize.width - self.parentsScrollView.frame.size.width;
    }
    return scrollViewOffsetX;
}

- (CGFloat)candleWidth
{
    if (!_candleWidth) _candleWidth = 8.0;
    if (_candleWidth < self.minCandleWidth) _candleWidth = self.minCandleWidth;
    if (_candleWidth > self.maxCandleWidth) _candleWidth = self.maxCandleWidth;
    return _candleWidth;
}

- (CGFloat)lineWidth
{
    return 1;
}

- (CGFloat)maxCandleWidth
{
    if (!_maxCandleWidth) _maxCandleWidth = 14;
    return _maxCandleWidth;
}

- (CGFloat)minCandleWidth
{
    if (!_minCandleWidth) _minCandleWidth = 1;
    return _minCandleWidth;
}

- (CGFloat)avgLineWidth
{
    if (!_avgLineWidth) _avgLineWidth = 1.0;
    return _avgLineWidth;
}

- (UIColor *)candleRiseColor
{
    if (!_candleRiseColor) _candleRiseColor = COLOR_RISECOLOR;
    return _candleRiseColor;
}

- (UIColor *)candleFallColor
{
    if (!_candleFallColor) _candleFallColor = COLOR_FALLCOLOR;
    return _candleFallColor;
}

- (CAShapeLayer *)timeLayer
{
    if (!_timeLayer) {
        
        _timeLayer = [CAShapeLayer layer];
        _timeLayer.contentsScale = [UIScreen mainScreen].scale;
        _timeLayer.strokeColor = [UIColor clearColor].CGColor;
        _timeLayer.fillColor = [UIColor clearColor].CGColor;
    }
    
    return _timeLayer;
}

- (CAShapeLayer *)advancesLayer
{
    if (!_advancesLayer) {
        
        _advancesLayer = [CAShapeLayer layer];
        _advancesLayer.lineWidth = (1 / [UIScreen mainScreen].scale) *1.5f;
        _advancesLayer.fillColor = self.candleRiseColor.CGColor;
        _advancesLayer.strokeColor = self.candleRiseColor.CGColor;
    }
    
    return _advancesLayer;
}

- (CAShapeLayer *)declinesLayer
{
    if (!_declinesLayer) {
        
        _declinesLayer = [CAShapeLayer layer];
        _declinesLayer.lineWidth = (1 / [UIScreen mainScreen].scale) *1.5f;
        _declinesLayer.fillColor = self.candleFallColor.CGColor;
        _declinesLayer.strokeColor = self.candleFallColor.CGColor;
    }
    return _declinesLayer;
}

- (CAShapeLayer *)ma1LineLayer
{
    if (!_ma1LineLayer) {
        
        _ma1LineLayer = [CAShapeLayer layer];
        _ma1LineLayer.lineWidth = 1.0;
        _ma1LineLayer.lineCap = kCALineCapRound;
        _ma1LineLayer.lineJoin = kCALineJoinRound;
    }
    
    return _ma1LineLayer;
}

- (CAShapeLayer *)ma2LineLayer
{
    if (!_ma2LineLayer) {
        
        _ma2LineLayer = [CAShapeLayer layer];
        _ma2LineLayer.lineWidth = 1.0;
        _ma2LineLayer.lineCap = kCALineCapRound;
        _ma2LineLayer.lineJoin = kCALineJoinRound;
    }
    
    return _ma2LineLayer;
}

- (CAShapeLayer *)ma3LineLayer
{
    if (!_ma3LineLayer) {
        
        _ma3LineLayer = [CAShapeLayer layer];
        _ma3LineLayer.lineWidth = 1.0;
        _ma3LineLayer.lineCap = kCALineCapRound;
        _ma3LineLayer.lineJoin = kCALineJoinRound;
    }
    
    return _ma3LineLayer;
}



- (UIColor *)ma1AvgLineColor
{
    if (!_ma1AvgLineColor) _ma1AvgLineColor = COLOR_MA5;
    return _ma1AvgLineColor;
}

- (UIColor *)ma2AvgLineColor
{
    if (!_ma2AvgLineColor) _ma2AvgLineColor = COLOR_MA10;
    return _ma2AvgLineColor;
}

- (UIColor *)ma3AvgLineColor
{
    if (!_ma3AvgLineColor) _ma3AvgLineColor = COLOR_MA30;
    return _ma3AvgLineColor;
}

- (UILabel *)lowValueL
{
    if (!_lowValueL) {
        
        _lowValueL = [[UILabel alloc] init];
        _lowValueL.font = [UIFont systemFontOfSize:10];
        _lowValueL.textColor = COLOR_TITLECOLOR;
        _lowValueL.adjustsFontSizeToFitWidth = YES;
    }
    
    return _lowValueL;
}

- (UILabel *)highValueL
{
    if (!_highValueL) {
        
        _highValueL = [[UILabel alloc] init];
        _highValueL.font = [UIFont systemFontOfSize:10];
        _highValueL.textColor = COLOR_TITLECOLOR;
        _highValueL.adjustsFontSizeToFitWidth = YES;
    }
    
    return _highValueL;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        
        _indicatorView = [[UIActivityIndicatorView alloc] init];
        _indicatorView.hidesWhenStopped = YES;
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    }
    
    return _indicatorView;
}

@synthesize coordinateMaxValue;
@synthesize coordinateminValue;
@synthesize minValue;
@synthesize maxValue;
@synthesize padding;
@synthesize scaleValue;
@synthesize leftPostion;
@synthesize candleSpace;

@end
