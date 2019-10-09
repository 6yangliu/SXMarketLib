//
//  UIColor+Y_StockChart.m
//  BTC-Kline
//
//  Created by yate1996 on 16/4/30.
//  Copyright © 2016年 yate1996. All rights reserved.
//

#import "UIColor+Y_StockChart.h"
@interface UIColor (Y_StockChart)

@property (nonatomic, strong) NSString *theme;

@end
@implementation UIColor (Y_StockChart)

+ (void)setTheme:(NSString *)theme {
    objc_setAssociatedObject(self, "_theme", theme, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
+ (NSString *)theme {
    return objc_getAssociatedObject(self, "_theme");
}


+ (UIColor *)colorWithRGBHex:(UInt32)hex {
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:1.0f];
}

#pragma mark 所有图表的背景颜色
+(UIColor *)backgroundColor
{
    if([[UIColor theme] isEqualToString:COLOR_SCHEME_BLACK]){
        return [UIColor colorWithRGBHex:0x222739];
    }
    return [UIColor colorWithRGBHex:0xFFFFFF];
}


#pragma mark 辅助背景色
+(UIColor *)assistBackgroundColor
{
    if([[UIColor theme] isEqualToString:COLOR_SCHEME_BLACK]){
        return [UIColor colorWithRGBHex:0x222739];
    }
    return [UIColor colorWithRGBHex:0xF4F5F9];
}

#pragma mark 菜单类背景色
+(UIColor *)segMenuBackgroundColor{
    if([[UIColor theme] isEqualToString:COLOR_SCHEME_BLACK]){
        return [UIColor colorWithRGBHex:0x222739];
    }
    return [UIColor colorWithRGBHex:0xF4F5F9];
}
#pragma mark 主菜单类文字颜色
+(UIColor *)segMainMenuTextColor{
    if([[UIColor theme] isEqualToString:COLOR_SCHEME_BLACK]){
        return [UIColor colorWithRGBHex:0x8F9DAA];
    }
    return [UIColor colorWithRGBHex:0x0F3652];
    
}
#pragma mark seg菜单类文字普通颜色
+(UIColor *)segTextNomalColor{
    if([[UIColor theme] isEqualToString:COLOR_SCHEME_BLACK]){
        return [UIColor colorWithRGBHex:0x8F9DAA];
    }
    return [UIColor colorWithRGBHex:0x0F3652];
    
}

#pragma mark 菜单类选中文字颜色
+(UIColor *)segTextSelectColor{
    if([[UIColor theme] isEqualToString:COLOR_SCHEME_BLACK]){
        return [UIColor colorWithRGBHex:0x3092FC];
    }
    return [UIColor colorWithRGBHex:0xF4B90E];
}

#pragma mark 涨的颜色
+(UIColor *)increaseColor
{
    return [UIColor colorWithRGBHex:0x07c087
];
}

#pragma mark 跌的颜色
+(UIColor *)decreaseColor
{
    return [UIColor colorWithRGBHex:0xee714a];
}

#pragma mark 主文字颜色
+(UIColor *)mainTextColor
{
    return [UIColor colorWithRGBHex:0x8F9DAA];
}

#pragma mark 辅助文字颜色
+(UIColor *)assistTextColor
{
    
    if([[UIColor theme] isEqualToString:COLOR_SCHEME_BLACK]){
        return [UIColor colorWithRGBHex:0x8F9DAA];
    }
    return [UIColor colorWithRGBHex:0x565a64];
}

#pragma mark 分时线下面的成交量线的颜色
+(UIColor *)timeLineVolumeLineColor
{
    return [UIColor colorWithRGBHex:0x2d333a];
}
#pragma mark 网格线颜色
+(UIColor *)sepLineColor{
    
    if([[UIColor theme] isEqualToString:COLOR_SCHEME_BLACK]){
        return [UIColor colorWithRGBHex:0x2B3147];
    }
    
    return [UIColor colorWithRGBHex:0xF0F0F0];
}
#pragma mark 分时线界面线的颜色
+(UIColor *)timeLineLineColor
{
    return [UIColor colorWithRGBHex:0x49a5ff];
}

#pragma mark 长按时线的颜色
+(UIColor *)longPressLineColor
{
    if([[UIColor theme] isEqualToString:COLOR_SCHEME_BLACK]){
        return [UIColor colorWithRGBHex:0x8194D3];
    }
    
    return [UIColor colorWithRGBHex:0x8194D3];
}

#pragma mark ma5的颜色
+(UIColor *)ma7Color
{
    return [UIColor colorWithRGBHex:0xff783c];
}

#pragma mark ma30颜色
+(UIColor *)ma30Color
{
    return [UIColor colorWithRGBHex:0x49a5ff];
}

#pragma mark BOLL_MB的颜色
+(UIColor *)BOLL_MBColor
{
    return [UIColor colorWithRGBHex:0x49a5ff];;
}

#pragma mark BOLL_UP的颜色
+(UIColor *)BOLL_UPColor
{
    return [UIColor purpleColor];
}

#pragma mark BOLL_DN的颜色
+(UIColor *)BOLL_DNColor
{
    return [UIColor greenColor];
}

@end
