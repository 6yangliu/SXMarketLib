//
//  SXChartSegmentView.h
//  SXMarketViewDemo
//  K线分时图顶部菜单栏
//  Created by liuy on 2018/5/3.
//  Copyright © 2018年 liuy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SXChartSegmentViewSubModel : NSObject

@property (nonatomic,copy)NSString *title;

@property (nonatomic,copy)NSString *type;


@end


@interface SXChartSegmentViewModel : NSObject

@property (nonatomic,copy)NSString *title;

@property (nonatomic,copy)NSString *type;

@property (nonatomic,assign)NSInteger defaultSltIndex;

@property (nonatomic,strong)NSArray *subObjects;

@end



@class SXChartSegmentView;

@protocol SXChartSegmentViewDelegate <NSObject>

/**
 *menuIndex 父菜单index
 *subIndex  子菜单index
 **/
- (void)chartSegmentView:(SXChartSegmentView *)segmentView clickSegmentMenuIndex:(NSInteger)menuIndex subIndex:(NSInteger)subIndex ;


@end


@interface SXChartSegmentView : UIView

- (instancetype)initWithItems:(NSArray *)items;

@property (nonatomic, strong) NSArray *items;

@property (nonatomic, weak) id <SXChartSegmentViewDelegate> delegate;

@property (nonatomic, assign) NSInteger sltMenuIndex;
@property (nonatomic, assign) NSInteger sltSubIndex;

@end


