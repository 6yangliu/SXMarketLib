//
//  SXMarket.h
//  SXMarketViewDemo
//
//  Created by liuy on 2018/5/8.
//  Copyright © 2018年 liuy. All rights reserved.
//

#ifndef SXMarket_h
#define SXMarket_h

#import "SXChartView.h"
#import "SXMarketConfig.h"
#import <Masonry/Masonry.h>
#import "KEDIOS.h"
#import "JSONKit.h"
#import "NSDate+Utils.h"
#import "SXNumberUtils.h"
#import "FileManager.h"

#ifndef IS_IPHONE

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define SCREEN_MAX_LENGTH MAX(kScreenWidth,kScreenHeight)
#define IS_IPHONE_X (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)

#endif

#define SXMarketLocalString(x,...) ALS(x, ...)


#endif /* SXMarket_h */
