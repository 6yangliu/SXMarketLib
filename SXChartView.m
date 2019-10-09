//
//  SXChartView.m
//  SXMarketViewDemo
//  K线分时图
//  Created by liuy on 2018/5/3.
//  Copyright © 2018年 liuy. All rights reserved.
//

#import "SXChartView.h"


@interface SXChartView() <SXChartSegmentViewDelegate>




@property (nonatomic, strong) NSArray *topSegmentMenuItems;

@end


@implementation SXChartView
{
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
        _isUpdateALL=YES;
        [self loadLocalKlineConfig];
        
    }
    return self;
}

- (NSArray *)topSegmentMenuItems{
    
    if(!_topSegmentMenuItems){
        //读取本地配置文件
        NSString *path=[[NSBundle mainBundle] pathForResource:@"SXChartTopMenuData" ofType:@"plist"];
        NSArray *array=[NSArray arrayWithContentsOfFile:path];
        //数据转换(字典转模型)
        NSMutableArray *menuArray=[NSMutableArray array];
        for (NSDictionary *dic in array) {
            
            SXChartSegmentViewModel *model=[SXChartSegmentViewModel new];
            model.title=dic[@"title"];
            model.type=dic[@"type"];

            
            NSMutableArray *childData=[[NSMutableArray alloc] init];
            for (NSDictionary *subDic in dic[@"childData"]) {
                SXChartSegmentViewSubModel *model=[SXChartSegmentViewSubModel new];
                model.title=subDic[@"title"];
                model.type=subDic[@"type"];
                [childData addObject:model];
            }
            model.subObjects=[NSArray arrayWithArray:childData];
            
            [menuArray addObject:model];
            
        }
        
        _topSegmentMenuItems=[NSArray arrayWithArray:menuArray];
    }
    
    return _topSegmentMenuItems;
    
}


- (SXChartSegmentView *)topSegmentView
{
    if(!_topSegmentView)
    {
        _topSegmentView = [[SXChartSegmentView alloc] initWithFrame:CGRectMake(0, 0, self.width-KScreenPrt(40), KScreenPrt(40))];
        _topSegmentView.delegate = self;
        
        [self addSubview:_topSegmentView];
        
        _topSegmentView.items=self.topSegmentMenuItems;
        
    }
    return _topSegmentView;
}

- (UIButton *)fullScreenBtn{
    
    if(!_fullScreenBtn){
        
        _fullScreenBtn=[[UIButton alloc] initWithFrame:CGRectMake(self.topSegmentView.right, self.topSegmentView.top, self.topSegmentView.height,self.topSegmentView.height)];
        _fullScreenBtn.backgroundColor=self.topSegmentView.backgroundColor;
        [_fullScreenBtn setImage:[UIImage imageNamed:@"screen_full"] forState:UIControlStateNormal];
        [_fullScreenBtn setImage:[UIImage imageNamed:@"screen_scale"] forState:UIControlStateSelected];
        [self addSubview:_fullScreenBtn];
    }
    return _fullScreenBtn;
}

- (Cocoa_ChartManager *)kLineView
{
    if(!_kLineView)
    {
        _kLineView = [[Cocoa_ChartManager alloc] initWithFrame:CGRectMake(0, self.topSegmentView.bottom+KScreenPrt(20), self.width, self.height-self.topSegmentView.bottom-KScreenPrt(20)) tecnnicalType:self.currentFuZbType];
        [self addSubview:_kLineView];
    }
    return _kLineView;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    self.topSegmentView.frame=CGRectMake(0, 0, self.width-KScreenPrt(40), KScreenPrt(40));
    self.fullScreenBtn.frame=CGRectMake(self.topSegmentView.right, self.topSegmentView.top, self.topSegmentView.height,self.topSegmentView.height);
    self.kLineView.frame=CGRectMake(0, self.topSegmentView.bottom+KScreenPrt(10), self.width, self.height-self.topSegmentView.bottom-KScreenPrt(10));
    [self.kLineView landscapeSwitch];
}

- (void)reloadData
{
    [self reloadKLineData];
}

-(void)reloadKLineData{
    self.kLineView.dataArray=[SXMarketDataManager klineModelData:[NSMutableArray arrayWithArray:self.kLindData]];
    self.kLineView.mainChartType=self.currentLineType;
    self.kLineView.mainTecnnicalType=self.currentMainZbType;
    if(self.isUpdateALL){
        [self.kLineView refreshChartView];
    }else{
      [self.kLineView appendingChartView];
    }
}



#pragma 本类方法
/**
 *加载本地配置
 **/
- (void)loadLocalKlineConfig{
    
    //K线本地配置
    NSNumber *currentLineTypeObj=[[NSUserDefaults standardUserDefaults] objectForKey:KCurrentLineType];
    if(!currentLineTypeObj){
       [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:KLineTypeTimeShare] forKey:KCurrentLineType];
       [[NSUserDefaults standardUserDefaults] synchronize];
    }
     self.currentLineType=[[[NSUserDefaults standardUserDefaults] objectForKey:KCurrentLineType] integerValue];
   
    //主指标本地配置
    NSNumber *currentMainZbTypeObj=[[NSUserDefaults standardUserDefaults] objectForKey:KCurrentMainZbType];
    if(!currentMainZbTypeObj){
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:MainTecnnicalType_Close] forKey:KCurrentMainZbType];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    self.currentMainZbType=[[[NSUserDefaults standardUserDefaults] objectForKey:KCurrentMainZbType] integerValue];
    
    //副图指标
    NSNumber *currentFuZbTypeObj=[[NSUserDefaults standardUserDefaults] objectForKey:KCurrentFuZbType];
    if(!currentFuZbTypeObj){
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:TecnnicalType_Close] forKey:KCurrentFuZbType];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    self.currentFuZbType=[[[NSUserDefaults standardUserDefaults] objectForKey:KCurrentFuZbType] integerValue];
}


#pragma mark - 代理
//分时K线图双击手势事件代理
-(void)onChartViewDoubleClick:(UIGestureRecognizer *)ges{
    
    if(self.delgate&&[self.delgate respondsToSelector:@selector(chartView:didChartViewDoubleClick:)]){
        [self.delgate chartView:self didChartViewDoubleClick:nil];
    }
    
}

#pragma mark- SXChartSegmentViewDelegate
/**
 *menuIndex 父菜单index
 *subIndex  子菜单index
 **/
- (void)chartSegmentView:(SXChartSegmentView *)segmentView clickSegmentMenuIndex:(NSInteger)menuIndex subIndex:(NSInteger)subIndex {
    
    if(menuIndex==0){//K线分时
        self.currentLineType=subIndex;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:self.currentLineType] forKey:KCurrentLineType];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        Cocoa_KLineDataType type=0;
        type=subIndex;// 注意tag和Y_KLineType enum对应关系 **重要**
        if(self.delgate&&[self.delgate respondsToSelector:@selector(onChangeKlineDataWithType:)]){
            [self.delgate onChangeKlineDataWithType:type];
        }
        
        
        
    }
    
    if(menuIndex ==1){//主图指标
        self.currentMainZbType=subIndex;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:self.currentMainZbType] forKey:KCurrentMainZbType];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.kLineView.mainTecnnicalType=self.currentMainZbType;
        [self.kLineView refreshMainTecnnical];
    }
    
    if(menuIndex ==2){//副图指标
        self.currentFuZbType=subIndex;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:self.currentFuZbType] forKey:KCurrentFuZbType];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.kLineView refreshTecnnical:self.currentFuZbType];
        
    }

}



@end
