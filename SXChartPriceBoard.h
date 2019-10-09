//
//  SXChartPriceBoard.h
//  SXMarketViewDemo
//  面板
//  Created by liuy on 2018/5/8.
//  Copyright © 2018年 liuy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+Y_StockChart.h"
#ifndef KScreenWidthPrt
#define KScreenWidthPrt  [[UIScreen mainScreen]bounds].size.width/375 //各设备宽的比例 以375为参照
#define KScreenPrt(P) KScreenWidthPrt*P
#endif


#import <Masonry/Masonry.h>
@interface SXChartPriceBoard : UIView

@property(nonatomic,assign)UIInterfaceOrientation orientation;

@property(nonatomic,strong)UILabel *coinLabel;

@property(nonatomic,strong)UILabel *priceLabel;

@property(nonatomic,strong)UILabel *cnyValueLabel;

@property(nonatomic,strong)UILabel *zdfLabel;

@property(nonatomic,strong)UILabel *highLabel;

@property(nonatomic,strong)UILabel *lowLabel;

@property(nonatomic,strong)UILabel *volumLabel;

@property(nonatomic,copy)NSString *coin;

@property(nonatomic,copy)NSString *nowPrice;

@property(nonatomic,assign)double zdf;

@property(nonatomic,copy)NSString *highPrice;

@property(nonatomic,copy)NSString *rmbValue;

@property(nonatomic,copy)NSString *lowPrice;

@property(nonatomic,copy)NSString *volum;

@end
