//
//  HKDepthView.h
//
//
//  Created by ly on 2019/5/14.
//  Copyright © 2019年 liuy. All rights reserved.
//

#import "HKDepthView.h"
#import "HKDepthModel.h"


#define DPW self.frame.size.width
#define DPH self.frame.size.height
#define BTM_P 22
@interface HKDepthView ()
{
    CATextLayer *sellRoundTextLayer;
    CAShapeLayer *sellRoundLayer;
    UIBezierPath *sellRoundPath ;
    UIBezierPath *buyRoundPath ;
    CAShapeLayer *buyRoundLayer;
    CATextLayer *buyRoundTextLayer;
    
    CATextLayer *textLayer_y1;
    CATextLayer *textLayer_y2;
    CATextLayer *textLayer_y3;
    CATextLayer *textLayer_y4;
    CATextLayer *textLayer_y5;
    
    CATextLayer *textLayer_x1;
    CATextLayer *textLayer_x2;
    CATextLayer *textLayer_x3;
    
}
@property (nonatomic, assign) NSInteger priceDigit;

@property (nonatomic, assign) NSInteger volumeDigit;

/**纵坐标最大值*/
@property (nonatomic, assign) double max;
/**纵坐标中间值*/
@property (nonatomic, assign) double mid;
/**纵坐标最小值*/
@property (nonatomic, assign) double min;

/**横坐标坐标最大值*/
@property (nonatomic, assign) double maxX;
/**横坐标坐标中间值*/
@property (nonatomic, assign) double midX;
/**横坐标纵坐标最小值*/
@property (nonatomic, assign) double minX;

@property (nonatomic, strong)NSMutableArray<HKDepthModel*> *dataArrA;
@property (nonatomic, strong)NSMutableArray<HKDepthModel*> *dataArrB;

/**最新点坐标*/
@property (nonatomic, assign) CGPoint currentPoint;
/**是否显示背景*/
@property (nonatomic, assign) BOOL isNeedBackGroundColor;
/**分时线路径*/
@property (nonatomic, strong) UIBezierPath *timeLinePathA;
@property (nonatomic, strong) UIBezierPath *timeLinePathB;
/**分时线*/
@property (nonatomic, strong) CAShapeLayer *timeLineLayerA;
/**分时线*/
@property (nonatomic, strong) CAShapeLayer *timeLineLayerB;
/**背景*/
@property (nonatomic, strong) CAShapeLayer *fillColorLayerA;
/**背景*/
@property (nonatomic, strong) CAShapeLayer *fillColorLayerB;
/**十字光标*/
@property (nonatomic, strong) CAShapeLayer *crossLayer;
/**十字光标时间轴文字*/
@property (nonatomic, strong) CATextLayer *crossTimeLayer;
/**十字光标价格轴文字*/
@property (nonatomic, strong) CATextLayer *crossPriceLayer;

@property (nonatomic, strong) UIColor *textColor;
@end

@implementation HKDepthView

//alloc方法调用
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.textColor=[UIColor colorWithRed:143/255.0 green:157/255.0 blue:170/255.0 alpha:1];
        
        self.backgroundColor = [UIColor colorWithRed:34/255.0 green:39/255.0 blue:57/255.0 alpha:1];
        [self setupGestureRecognize];
    }
    return self;
}
//load nib 调用
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupGestureRecognize];
    }
    return self;
}
#pragma mark - 懒加载
- (UIBezierPath *)timeLinePathA {
    if (!_timeLinePathA) {
        _timeLinePathA = [[UIBezierPath alloc]init];
    }
    return _timeLinePathA;
}
- (UIBezierPath *)timeLinePathB {
    if (!_timeLinePathB) {
        _timeLinePathB = [[UIBezierPath alloc]init];
    }
    return _timeLinePathB;
}
- (CAShapeLayer *)timeLineLayerA{
    if (!_timeLineLayerA) {
        _timeLineLayerA = [[CAShapeLayer alloc]init];
        _timeLineLayerA.strokeColor = [UIColor colorWithRed:7/255.0 green:192/255.0 blue:135/255.0 alpha:1].CGColor;
        _timeLineLayerA.lineWidth = 0.5f;
    }
    return _timeLineLayerA;
}
- (CAShapeLayer *)timeLineLayerB{
    if (!_timeLineLayerB) {
        _timeLineLayerB = [[CAShapeLayer alloc]init];
        _timeLineLayerB.strokeColor = [UIColor colorWithRed:238/255.0 green:113/255.0 blue:74/255.0 alpha:1].CGColor;
        _timeLineLayerB.lineWidth = 0.5f;
    }
    return _timeLineLayerB;
}
- (CAShapeLayer *)fillColorLayerA {
    if (!_fillColorLayerA) {
        _fillColorLayerA = [[CAShapeLayer alloc]init];
        self.fillColorLayerA.fillColor = [UIColor colorWithRed:7/255.0 green:192/255.0 blue:135/255.0 alpha:0.2].CGColor;
        self.fillColorLayerA.strokeColor = [UIColor clearColor].CGColor;
    }
    return _fillColorLayerA;
}
- (CAShapeLayer *)fillColorLayerB {
    if (!_fillColorLayerB) {
        _fillColorLayerB = [[CAShapeLayer alloc]init];
        self.fillColorLayerB.fillColor = [UIColor colorWithRed:238/255.0 green:113/255.0 blue:74/255.0 alpha:0.2].CGColor;
        self.fillColorLayerB.strokeColor = [UIColor clearColor].CGColor;
    }
    return _fillColorLayerB;
}

- (CAShapeLayer *)crossLayer {
    if (!_crossLayer) {
        _crossLayer =[[CAShapeLayer alloc]init];
        _crossLayer.lineDashPattern = @[@1, @2];//画虚线
    }
    return _crossLayer;
}
- (CATextLayer *)crossPriceLayer {
    if (!_crossPriceLayer) {
        _crossPriceLayer = [[CATextLayer alloc]init];
    }
    return _crossPriceLayer;
}
- (CATextLayer *)crossTimeLayer {
    if (!_crossTimeLayer) {
        _crossTimeLayer = [[CATextLayer alloc]init];
    }
    return _crossTimeLayer;
}
#pragma mark - GestureRecognize
/**添加手势*/
- (void)setupGestureRecognize {
    UILongPressGestureRecognizer  *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)];
    [self addGestureRecognizer:longPress];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:tap];
}
/**长按*/
- (void)longPressAction:(UILongPressGestureRecognizer*)gesture {
    CGPoint tempPoint = [gesture locationInView:self];
    //越界控制
    if (tempPoint.x >= DPW) {
        tempPoint = CGPointMake(DPW, tempPoint.y);
    }
    if (tempPoint.x <= 0.0) {
        tempPoint = CGPointMake(0, tempPoint.y);
    }
    if (tempPoint.y >= DPH - BTM_P) {
        tempPoint = CGPointMake(tempPoint.x, DPH-BTM_P);
    }
    if (tempPoint.y <= 0.0) {
        tempPoint = CGPointMake(tempPoint.x, 0);
    }
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self drawCrossLineWithPoint:tempPoint];
    }else if (gesture.state == UIGestureRecognizerStateChanged) {
        [self drawCrossLineWithPoint:tempPoint];
    }else if (gesture.state == UIGestureRecognizerStateEnded) {
        
    }
}
- (void)tap:(UITapGestureRecognizer*) gesture {
    self.crossLayer.path = nil;
    [self.crossPriceLayer removeFromSuperlayer];
    [self.crossTimeLayer removeFromSuperlayer];
}
#pragma mark - 数据入口

-(void)reloadData{
    [self removeLayer];
    
    [self initData];
    [self drawFramework];
    [self drawLine];
}

#pragma mark-处理数据
-(void)initData{
    
    double buyMin=[HKDepthModel getMinPrice:self.depthData[0]];
    double sellMax=[HKDepthModel getMaxPrice:self.depthData[1]];
    double buyVolumeSum=[HKDepthModel getVolumeSum:self.depthData[0]];
    double sellVolumeSum=[HKDepthModel getVolumeSum:self.depthData[1]];
    double maxVolume=buyVolumeSum>=sellVolumeSum ? buyVolumeSum :sellVolumeSum;
    
    double buyMinVolumeSum=[HKDepthModel getMinVolumeSum:self.depthData[0]];
    double sellMinVolumeSum=[HKDepthModel getMinVolumeSum:self.depthData[1]];
    double minVolume=buyMinVolumeSum>=sellMinVolumeSum ? sellMinVolumeSum :buyMinVolumeSum;
    self.max=maxVolume;
    self.min=minVolume;
    self.mid=self.min+(self.max-self.min)/2;
    
    self.maxX=sellMax;
    self.minX=buyMin;
    self.midX=self.minX+(self.maxX-self.minX)/2;
    
    
    self.dataArrA=[HKDepthModel getDepthPoint:self.depthData[0]];
    self.dataArrB=[HKDepthModel getDepthPoint:self.depthData[1]];

    
    NSInteger maxPriceDight=0;
    NSInteger maxVolumeDight=0;
    if(self.depthData.count>1){
        for (NSArray *array in self.depthData[0]) {
            if([HKDepthModel getDigitFromStr:array[0]]>=maxPriceDight){
                 maxPriceDight=[HKDepthModel getDigitFromStr:array[0]];
            }
            if([HKDepthModel getDigitFromStr:array[1]]>=maxVolumeDight){
                maxVolumeDight=[HKDepthModel getDigitFromStr:array[1]];
            }
        }
    }
    
    self.priceDigit=maxPriceDight;
    self.volumeDigit=maxVolumeDight;
    
}


#pragma mark - 画图方法
-(void)removeLayer{
    [self.timeLinePathA removeAllPoints];
    self.timeLinePathA=nil;
    [self.timeLineLayerA removeFromSuperlayer];
    self.timeLineLayerA=nil;
    
    [self.timeLinePathB removeAllPoints];
    self.timeLinePathB=nil;
    [self.timeLineLayerB removeFromSuperlayer];
    self.timeLineLayerB=nil;
    
    [self.fillColorLayerA removeFromSuperlayer];
    self.fillColorLayerA=nil;
    
    [self.fillColorLayerB removeFromSuperlayer];
    self.fillColorLayerB=nil;
    
    [self.crossLayer removeFromSuperlayer];
    self.crossLayer=nil;
    [self.crossTimeLayer removeFromSuperlayer];
    self.crossTimeLayer=nil;
    [self.crossPriceLayer removeFromSuperlayer];
    self.crossPriceLayer=nil;
    
    [buyRoundPath removeAllPoints];
    [buyRoundLayer removeFromSuperlayer];
    [buyRoundTextLayer removeFromSuperlayer];
    
    [sellRoundPath removeAllPoints];
    [sellRoundLayer removeFromSuperlayer];
    [sellRoundTextLayer removeFromSuperlayer];
    
    
    [textLayer_x1 removeFromSuperlayer];
    [textLayer_x2 removeFromSuperlayer];
    [textLayer_x3 removeFromSuperlayer];
    
    [textLayer_y1 removeFromSuperlayer];
    [textLayer_y2 removeFromSuperlayer];
    [textLayer_y3 removeFromSuperlayer];
    [textLayer_y4 removeFromSuperlayer];
    [textLayer_y5 removeFromSuperlayer];
}

- (void)drawLine{
    [self drawTimeLineLayerA];
    [self drawTimeLineLayerB];
}

-(void)drawTimeLineLayerA{
    CGPoint lastPoint=CGPointMake(0, 0);
    for (int i = 0; i< self.dataArrA.count; i ++ ) {
        HKDepthModel *item = self.dataArrA[i];
        CGPoint point=[self modelToPoint:item];
        if(i==0){
            [self.timeLinePathA moveToPoint:CGPointMake(point.x, point.y)];
        }else{
            [self.timeLinePathA addLineToPoint:CGPointMake(point.x,  point.y)];
        }
        if(i==self.dataArrA.count-1){
            lastPoint=point;
        }
    }
//    背景区域图层A
    CGPoint xStartPointA=CGPointMake(0, DPH-BTM_P);
    CGPoint xEndPointA=CGPointMake( lastPoint.x, DPH-BTM_P);
    //继续向路径中添加下面两个点 形成闭合区间
    [self.timeLinePathA addLineToPoint:xEndPointA];
    [self.timeLinePathA addLineToPoint:xStartPointA];
    self.fillColorLayerA.path = self.timeLinePathA.CGPath;
    self.fillColorLayerA.zPosition -= 1;
    [self.layer addSublayer:self.fillColorLayerA];
    
    self.timeLineLayerA.fillColor = [UIColor clearColor].CGColor;
    self.timeLineLayerA.path = self.timeLinePathA.CGPath;
    [self.layer addSublayer:self.timeLineLayerA];
}
-(void)drawTimeLineLayerB{
    CGPoint firstPoint=CGPointMake(0, 0);
    for (int i = 0; i< self.dataArrB.count; i ++ ) {
        HKDepthModel *item = self.dataArrB[i];
        CGPoint point=[self modelToPoint:item];
        if(i==0){
            [self.timeLinePathB moveToPoint:CGPointMake(point.x, point.y)];
        }else{
            [self.timeLinePathB addLineToPoint:CGPointMake(point.x,  point.y)];
        }
        if(i==0){
            firstPoint=point;
        }
    }
    
    //背景区域图层B
    CGPoint xStartPointB=CGPointMake(firstPoint.x,DPH-BTM_P);
    CGPoint xEndPointB=CGPointMake( DPW,DPH-BTM_P);
    //继续向路径中添加下面两个点 形成闭合区间
    [self.timeLinePathB addLineToPoint:xEndPointB];
    [self.timeLinePathB addLineToPoint:xStartPointB];
    
    self.fillColorLayerB.path = self.timeLinePathB.CGPath;
    self.fillColorLayerB.zPosition -= 1;
    [self.layer addSublayer:self.fillColorLayerB];
    
    
    self.timeLineLayerB.fillColor = [UIColor clearColor].CGColor;
    self.timeLineLayerB.path = self.timeLinePathB.CGPath;
    [self.layer addSublayer:self.timeLineLayerB];
}
/**画框架*/
- (void)drawFramework {
    //y轴文字
    CGFloat rowSpace = (DPH -BTM_P)/5;
    NSString *tempStr = @"";
    double avg=(self.max-self.min)/5;
    for (int i = 0; i < 5; i ++) {
        if (0 == i) {
            tempStr = [NSString stringWithFormat:@"%.*f",self.volumeDigit,avg*5];
            tempStr=[SXNumberUtils volFormat:tempStr];
            CATextLayer *textLayer= [self drawLabelAtRect:CGRectMake(DPW-100, 0, 100, 20) textStr:tempStr];
            textLayer.alignmentMode=kCAAlignmentRight;
            textLayer_y1=textLayer;
        }else if (1==i) {
            tempStr = [NSString stringWithFormat:@"%.*f",self.volumeDigit,avg*4];
            tempStr=[SXNumberUtils volFormat:tempStr];
            CATextLayer *textLayer= [self drawLabelAtRect:CGRectMake(DPW-100, rowSpace*i, 100, 20) textStr:tempStr];
            textLayer.alignmentMode=kCAAlignmentRight;
            textLayer_y2=textLayer;
        }else if (2 == i) {
            tempStr = [NSString stringWithFormat:@"%.*f",self.volumeDigit,avg*3];
            tempStr=[SXNumberUtils volFormat:tempStr];
            CATextLayer *textLayer= [self drawLabelAtRect:CGRectMake(DPW-100, rowSpace*i, 100, 20) textStr:tempStr];
            textLayer.alignmentMode=kCAAlignmentRight;
            textLayer_y3=textLayer;
        }
        else if (3 == i) {
            tempStr = [NSString stringWithFormat:@"%.*f",self.volumeDigit,avg*2];
            tempStr=[SXNumberUtils volFormat:tempStr];
            CATextLayer *textLayer= [self drawLabelAtRect:CGRectMake(DPW-100, rowSpace*i, 100, 20) textStr:tempStr];
            textLayer.alignmentMode=kCAAlignmentRight;
            textLayer_y4=textLayer;
        }
        else if (4 == i) {
            tempStr = [NSString stringWithFormat:@"%.*f",self.volumeDigit,avg*1];
            tempStr=[SXNumberUtils volFormat:tempStr];
            CATextLayer *textLayer= [self drawLabelAtRect:CGRectMake(DPW-100, rowSpace*i, 100, 20) textStr:tempStr];
            textLayer.alignmentMode=kCAAlignmentRight;
            textLayer_y5=textLayer;
        }
    }
    //x轴文字
    rowSpace = (DPW)/2.0;
    for (int i = 0; i < 3; i ++) {
        if (0 == i) {
            tempStr = [NSString stringWithFormat:@"%.*f",self.priceDigit,self.minX];
            CATextLayer *textLayer= [self drawLabelAtRect:CGRectMake(0,(DPH -BTM_P)+6 , 100, 22) textStr:tempStr];
            textLayer.alignmentMode=kCAAlignmentLeft;
            textLayer_x1=textLayer;
        }else if (1==i) {
            tempStr = [NSString stringWithFormat:@"%.*f",self.priceDigit,self.midX];
            CATextLayer *textLayer= [self drawLabelAtRect:CGRectMake((DPW-100)/2,(DPH -BTM_P)+6 , 100, 22) textStr:tempStr];
            textLayer.alignmentMode=kCAAlignmentCenter;
            textLayer_x2=textLayer;
        }else if (2 == i) {
            tempStr = [NSString stringWithFormat:@"%.*f",self.priceDigit,self.maxX];
            CATextLayer *textLayer= [self drawLabelAtRect:CGRectMake(DPW-100,(DPH -BTM_P)+6 , 100, 22) textStr:tempStr];
            textLayer.alignmentMode=kCAAlignmentRight;
            textLayer_x3=textLayer;
        }
    }
    
    //标识
    CGFloat topP=0;
    // 圆标识
    
    buyRoundPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(DPW/2-8-17-5, topP, 8, 8)];
    buyRoundLayer = [CAShapeLayer layer];
    buyRoundLayer.lineWidth = 0.1;
    buyRoundLayer.strokeColor = [UIColor greenColor].CGColor;
    buyRoundLayer.path = buyRoundPath.CGPath;
    buyRoundLayer.fillColor = [UIColor colorWithRed:7/255.0 green:192/255.0 blue:135/255.0 alpha:1].CGColor; //
    [self.layer addSublayer:buyRoundLayer];
    
    buyRoundTextLayer= [self drawLabelAtRect:CGRectMake(DPW/2-17,topP , 17, 22) textStr:ALS(@"买盘")];
    buyRoundTextLayer.alignmentMode=kCAAlignmentLeft;
    
    sellRoundPath= [UIBezierPath bezierPathWithOvalInRect:CGRectMake(DPW/2+15, topP, 8, 8)];
    sellRoundLayer= [CAShapeLayer layer];
    sellRoundLayer.lineWidth = 0.1;
    sellRoundLayer.strokeColor = [UIColor greenColor].CGColor;
    sellRoundLayer.path = sellRoundPath.CGPath;
    sellRoundLayer.fillColor = [UIColor colorWithRed:238/255.0 green:113/255.0 blue:74/255.0 alpha:1].CGColor; //
    [self.layer addSublayer:sellRoundLayer];
   
    sellRoundTextLayer= [self drawLabelAtRect:CGRectMake(DPW/2+15+8+2,topP , 17, 22) textStr:ALS(@"卖盘")];
    sellRoundTextLayer.alignmentMode=kCAAlignmentLeft;
    
}

/**画xy轴文字,直接创建一个CATextLayer*/
- (CATextLayer *)drawLabelAtRect:(CGRect)rect textStr:(NSString*)textStr {
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.frame = rect;
    [self.layer addSublayer:textLayer];
    textLayer.foregroundColor = self.textColor.CGColor;
    textLayer.alignmentMode = kCAAlignmentJustified;
    textLayer.wrapped = YES;
    UIFont *font = [UIFont systemFontOfSize:8];
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
    textLayer.font = fontRef;
    textLayer.fontSize = font.pointSize;
    CGFontRelease(fontRef);
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    textLayer.string = textStr;
    return textLayer;
}


/**画文字十字光标文字,指定CATextLayer*/
- (void)drawCrossLabelWithTextLayer:(CATextLayer*)textLayer AtRect:(CGRect)rect textStr:(NSString*)textStr {
    textLayer.frame = rect;
    [self.layer addSublayer:textLayer];
    textLayer.foregroundColor = [UIColor whiteColor].CGColor;
    textLayer.alignmentMode = kCAAlignmentJustified;
    textLayer.wrapped = YES;
    UIFont *font = [UIFont systemFontOfSize:10];
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
    textLayer.font = fontRef;
    textLayer.fontSize = font.pointSize;
    CGFontRelease(fontRef);
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    textLayer.string = textStr;
}

/**画十字光标线*/
- (void)drawCrossLineWithPoint:(CGPoint)point {
    UIBezierPath * path = [[UIBezierPath alloc]init];
    [path moveToPoint:CGPointMake(point.x, 0)];
    [path addLineToPoint:CGPointMake(point.x, DPH - BTM_P)];
    [path moveToPoint:CGPointMake(0, point.y)];
    [path addLineToPoint:CGPointMake(DPW, point.y)];
    self.crossLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.crossLayer.path = path.CGPath;
    [self.layer addSublayer: self.crossLayer];
    //画坐标点对应文字
    NSString *volume =  [self vloumeWithPoint:point];
    NSString *price = [self priceWithPoint:point];
    [self drawCrossLabelWithTextLayer:self.crossTimeLayer AtRect:CGRectMake(point.x, DPH-BTM_P, 100, 20) textStr:price];
    [self drawCrossLabelWithTextLayer:self.crossPriceLayer AtRect:CGRectMake(0, point.y, 100, 20) textStr:[SXNumberUtils volFormat:volume]];
    
}

#pragma mark 模型坐标转换
-(CGPoint)modelToPoint:(HKDepthModel *)model{
    CGPoint point=CGPointMake(0, 0);
    
    CGFloat height = DPH - BTM_P;
    CGFloat avrSpaceY = height/(self.max - self.min);
    point.y=height - ((model.volume - self.min)*avrSpaceY);
    
    CGFloat width=DPW;
    CGFloat avrSpaceX = width/(self.maxX - self.minX);
    point.x=(model.price - self.minX)*avrSpaceX;
    return point;
}

- (NSString*)vloumeWithPoint:(CGPoint)point {
    NSString *vloume = @"";
    //单位距离代表的价格
    CGFloat aveVloume = (self.max - self.min)/(DPH - BTM_P);
    //保留两位小数
    vloume = [NSString stringWithFormat:@"%.*f",self.volumeDigit,(self.max - point.y*aveVloume)];
    return vloume;
}
- (NSString*)priceWithPoint:(CGPoint)point {
    NSString *price = @"";
    //单位距离代表的价格
    CGFloat avePrice = (self.maxX - self.minX)/DPW;
    //保留两位小数
    price = [NSString stringWithFormat:@"%.*f",self.priceDigit,self.minX+point.x*avePrice];
    return price;
}

@end
