//
//  Cocoa_ChartStylesheet.h
//  Cocoa-KLine
//
//  Created by Yochi on 2018/8/1.
//  Copyright © 2018年 Yochi. All rights reserved.
//

#ifndef Cocoa_ChartStylesheet_h
#define Cocoa_ChartStylesheet_h

/** 屏幕横竖屏尺寸  */
#define kSCREENWIDTH [UIScreen mainScreen].bounds.size.width

#define kSCREENHEIGHT [UIScreen mainScreen].bounds.size.height

#define kSTATUSHEIGHT [[UIApplication sharedApplication] statusBarFrame].size.height

#define kNAVIGATIONHEIGHT (kSTATUSHEIGHT + 44)

#define kTABBARHEIGHT (PCiPhoneX ? 83.0 : 49.0)

//涨
#define COLOR_RISECOLOR [UIColor colorWithRed:7/255.0 green:192/255.0 blue:135/255.0 alpha:1]

//跌
#define COLOR_FALLCOLOR [UIColor colorWithRed:238/255.0 green:113/255.0 blue:74/255.0 alpha:1]

//背景色
//#define COLOR_BACKGROUND [UIColor colorWithRed:30.0/255.0 green:33.0/255.0 blue:48.0/255.0 alpha:1.0]

#define COLOR_BACKGROUND [UIColor colorWithRed:34/255.0 green:39/255.0 blue:57/255.0 alpha:1]
#define COLOR_CROSSBACKGROUND [UIColor colorWithRed:38.0/255.0 green:42.0/255.0 blue:64.0/255.0 alpha:1.0]
#define COLOR_CROSSTEXT [UIColor colorWithRed:142.0/255.0 green:154.0/255.0 blue:183.0/255.0 alpha:1.0]

// 高亮色
#define COLOR_HIGHLIGHT [UIColor colorWithRed:36.0/255.0 green:133.0/255.0 blue:169.0/255.0 alpha:1.0]

// 文字警告色
#define COLOR_WARNINTEXT [UIColor colorWithRed:176.0/255.0 green:100.0/255.0 blue:75.0/255.0 alpha:1.0]

// 坐标线颜色
#define COLOR_COORDINATELINE [UIColor colorWithRed:43/255.0 green:49/255.0 blue:71/255.0 alpha:1]

// 坐标文字颜色
#define COLOR_COORDINATETEXT [UIColor colorWithRed:104.0/255.0 green:105.0/255.0 blue:112.0/255.0 alpha:1.0]

// 文字标题色
#define COLOR_TITLECOLOR [UIColor colorWithRed:179.0/255.0 green:179.0/255.0 blue:179.0/255.0 alpha:1.0]
//分时线颜色
#define COLOR_timeLine  [UIColor colorWithRed:71/255.0 green:127/255.0 blue:183/255.0 alpha:1]
// 5 10 30 日均线
#define COLOR_MA5  [UIColor colorWithRed:231/255.0 green:229/255.0 blue:199/255.0 alpha:1]
#define COLOR_MA10 [UIColor colorWithRed:153/255.0 green:197/255.0 blue:198/255.0 alpha:1]
#define COLOR_MA30 [UIColor colorWithRed:180/255.0 green:154/255.0 blue:223/255.0 alpha:1]

//BOLL 线颜色
#define COLOR_BOLL_MD  [UIColor colorWithRed:231/255.0 green:229/255.0 blue:199/255.0 alpha:1]
#define COLOR_BOLL_UP [UIColor colorWithRed:153/255.0 green:197/255.0 blue:198/255.0 alpha:1]
#define COLOR_BOLL_DN [UIColor colorWithRed:180/255.0 green:154/255.0 blue:223/255.0 alpha:1]

#endif /* Cocoa_ChartStylesheet_h */
