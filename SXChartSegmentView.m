//
//  SXChartSegmentView.m
//  SXMarketViewDemo
//
//  Created by liuy on 2018/5/3.
//  Copyright © 2018年 liuy. All rights reserved.
//
#import "SXChartSegmentView.h"
#import "Masonry.h"
#import "UIColor+Y_StockChart.h"

static NSInteger const SXChartSegmentViewTag = 2000;

static NSInteger const SXChartSegmentViewSubTag = 3000;

static CGFloat const menuofSubmeuRatio = 1.25f;// menu/submenu

static CGFloat const padding = 4.0f;//间隔

@interface SXChartSegmentView()

@property (nonatomic, strong) UIButton *selectedMenuBtn;

@property (nonatomic, strong) UIButton *popBackView;
@property (nonatomic, strong) UIView *popView;

@end

@implementation SXChartSegmentView

- (instancetype)initWithItems:(NSArray<SXChartSegmentViewModel *> *)items
{
    self = [super initWithFrame:CGRectZero];
    if(self)
    {
        self.items = items;
       
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
//        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor segMenuBackgroundColor];
    }
    return self;
}


- (UIView *)popBackView{
    
    if(!_popBackView){
        
        _popBackView=[[UIButton alloc] init];
        UIWindow *win =[UIApplication sharedApplication].keyWindow;
        [win addSubview:_popBackView];
        _popBackView.hidden=YES;
        _popBackView.backgroundColor=[UIColor clearColor];
        
        [_popBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(win).insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        
        [_popBackView addTarget:self action:@selector(onPopBackViewClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _popBackView;
    
}

- (UIView *)popView{
    
    if(!_popView){
        
        _popView=[[UIView alloc] init];
        _popView.backgroundColor=[UIColor clearColor];
        _popView.hidden=YES;
        _popView.userInteractionEnabled=YES;
        [self.popBackView addSubview:_popView];
        [_popView mas_makeConstraints:^(MASConstraintMaker *make) {
            
        }];
    }
    return _popView;
}


- (void)setItems:(NSArray *)items
{
    _items = items;
    if(items.count == 0 || !items)
    {
        return;
    }
    NSInteger index = 0;
    NSInteger count = items.count;
    UIButton *preBtn = nil;
    
    for (SXChartSegmentViewModel *model in items)
    {
        
        NSString *title=model.title;
        if([title isEqualToString:@"分时"]){
            NSInteger localIndex=[[[NSUserDefaults standardUserDefaults] objectForKey:KCurrentLineType] integerValue];
            SXChartSegmentViewSubModel *subModel=model.subObjects[localIndex];
            if(![subModel.title isEqualToString:@"关闭"]){
                title=subModel.title;
            }
            model.defaultSltIndex=localIndex;
        }else if([title isEqualToString:@"主指标"]){
            
            NSInteger localIndex=[[[NSUserDefaults standardUserDefaults] objectForKey:KCurrentMainZbType] integerValue];
            SXChartSegmentViewSubModel *subModel=model.subObjects[localIndex];
            if(![subModel.title isEqualToString:@"关闭"]){
                title=subModel.title;
            }
            model.defaultSltIndex=localIndex;
        }
        
        else if([title isEqualToString:@"指标"]){
            
            NSInteger localIndex=[[[NSUserDefaults standardUserDefaults] objectForKey:KCurrentFuZbType] integerValue];
            SXChartSegmentViewSubModel *subModel=model.subObjects[localIndex];
            if(![subModel.title isEqualToString:@"关闭"]){
                title=subModel.title;
            }
            model.defaultSltIndex=localIndex;
        }
        
        UIButton *btn = [self private_createButtonWithTitle:ALS(title) tag:SXChartSegmentViewTag+index];
        [btn addTarget:self action:@selector(onMenuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitleColor:[UIColor segMainMenuTextColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor segTextSelectColor] forState:UIControlStateSelected];
        [self addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.width.equalTo(self).multipliedBy(1.0f/count);
            make.height.equalTo(self);
            make.top.equalTo(self);
            if(preBtn){
                 make.left.equalTo(preBtn.mas_right);
            }else{
                 make.left.equalTo(self);
                
            }
        }];
        preBtn = btn;
        index++;
    }
}
-(void)setSltMenuIndex:(NSInteger)sltMenuIndex{
    
    _sltMenuIndex=sltMenuIndex;
    
    
}

- (void)setSltSubIndex:(NSInteger)sltSubIndex{
    
    _sltSubIndex=sltSubIndex;
    
}
#pragma mark -本类方法
- (void)layoutSubviews{
    [super layoutSubviews];
}
#pragma mark - 私有方法
#pragma mark 创建segment按钮
- (UIButton *)private_createButtonWithTitle:(NSString *)title tag:(NSInteger)tag
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor=[UIColor segMenuBackgroundColor];
    [btn setTitleColor:[UIColor segTextNomalColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13];
    btn.tag = tag;
    [btn setTitle:title forState:UIControlStateNormal];
    return btn;
}

#pragma mark 事件区
/**
 主Menu点击
 **/
- (void)onMenuButtonClicked:(UIButton *)menubtn
{
    self.selectedMenuBtn = menubtn;
    
    NSInteger index=menubtn.tag-SXChartSegmentViewTag;
    self.sltMenuIndex=index;
    
    [self showPopMenu:index btn:(UIButton *)menubtn];
    
    [menubtn setSelected:YES];
}
/**
 子Menu点击
 **/
- (void)onMenuSubButtonClicked:(UIButton *)subMenubtn{
    
    NSInteger index=subMenubtn.tag-SXChartSegmentViewSubTag;
    self.sltSubIndex=index;
    
    SXChartSegmentViewModel *model=self.items[self.sltMenuIndex];
    model.defaultSltIndex=index;
    
    [self updataSegmentView:self.sltMenuIndex :self.sltSubIndex];
    [self onPopBackViewClick:nil];
    
    if(self.delegate&&[self.delegate respondsToSelector:@selector(chartSegmentView:clickSegmentMenuIndex:subIndex:)]){
        
        [self.delegate chartSegmentView:self clickSegmentMenuIndex:self.sltMenuIndex subIndex:self.sltSubIndex];
        
        
    }
    
    
}

- (void)onPopBackViewClick:(id)sender{
    
    [_popView removeFromSuperview];
    _popView=nil;
    [_popBackView removeFromSuperview];
    _popBackView=nil;
    [_selectedMenuBtn setSelected:NO];
}

-(void)showPopMenu:(NSInteger)index btn:(UIButton *)menubtn{
    
    //子菜单按钮高度
    CGFloat popBtnHeight=menubtn.frame.size.height*menuofSubmeuRatio;
    
    
    SXChartSegmentViewModel *segmentViewModel=_items[index];
    NSArray *array=segmentViewModel.subObjects;
    
    [self.popView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        self.popBackView.hidden=NO;
        self.popView.hidden=NO;
        
        
        if(!array||array.count==0){
            CGRect rct=[self convertRect:self.bounds toView:self.popBackView];
            make.top.mas_equalTo(rct.origin.y+rct.size.height+padding);
            make.left.mas_equalTo(rct.origin.x);
            make.width.equalTo(self.mas_width);
            make.height.mas_equalTo(popBtnHeight*3);
            
            return ;
        }
        if(array.count>self.items.count){//多数据列表(多行多列)
            __block UIButton *preBtn = nil;
            
            CGRect rct=[self convertRect:self.bounds toView:self.popBackView];
            make.top.mas_equalTo(rct.origin.y+rct.size.height+padding);
            make.left.mas_equalTo(rct.origin.x);
            make.width.equalTo(self.mas_width);
            if(array.count%self.items.count==0){
                make.height.mas_equalTo(popBtnHeight*(array.count/self.items.count));
                
            }else{
                make.height.mas_equalTo(popBtnHeight*(array.count/self.items.count+1));
            }
            
            NSInteger column=self.items.count;
            NSInteger row=array.count%self.items.count==0 ?array.count/self.items.count : array.count/self.items.count+1;
            //填充子列表数据
            for (int i=0 ;i<array.count;i++) {
                SXChartSegmentViewSubModel *subModel=array[i];
                UIButton *btn = [self private_createButtonWithTitle:ALS(subModel.title) tag:SXChartSegmentViewSubTag+i];
                btn.backgroundColor= UIColorFromRGB(0x202333);
                [btn addTarget:self action:@selector(onMenuSubButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                [self.popView addSubview:btn];
              
                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(self.popView.mas_width).multipliedBy(1.0f/column);
                    make.height.mas_equalTo(popBtnHeight);
                    if(i==0){
                        make.top.mas_equalTo(@0);
                        make.left.mas_equalTo(@0);
                    }else{
                        if(i%column==0){
                            make.left.mas_equalTo(@0);
                        }else{
                            make.left.equalTo(preBtn.mas_right);
                        }
                        
                        if(i%column==0){
                            make.top.equalTo(preBtn.mas_bottom);
                        }else{
                            make.top.equalTo((preBtn.mas_top));
                        }
                        
                    }
                }];
                
                preBtn=btn;
                
            }
        }else{//较少数据列表(单列多行)
            __block UIButton *preBtn = nil;
            
            CGRect rct=[menubtn convertRect:menubtn.bounds toView:self.popBackView];
            make.top.mas_equalTo(rct.origin.y+rct.size.height+padding);
            make.left.mas_equalTo(rct.origin.x);
            make.width.equalTo(menubtn.mas_width);
            make.height.mas_equalTo(popBtnHeight*array.count);
            //填充子列表数据
            for (int i=0 ;i<array.count;i++) {
                SXChartSegmentViewSubModel *subModel=array[i];
                UIButton *btn = [self private_createButtonWithTitle:ALS(subModel.title) tag:SXChartSegmentViewSubTag+i];
                btn.backgroundColor= UIColorFromRGB(0x202333);
                [btn addTarget:self action:@selector(onMenuSubButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                [self.popView addSubview:btn];
                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(menubtn.mas_width);
                    make.height.mas_equalTo(popBtnHeight);
                    make.left.mas_equalTo(@0);
                    if(i==0){
                        make.top.mas_equalTo(@0);
                    }else{
                        make.top.equalTo(preBtn.mas_bottom);
                    }
                }];
                preBtn=btn;
            }
        }
    }];
    
    //更新按钮状态
    for (int i=0;i<self.items.count;i++) {
        if(i==self.sltMenuIndex){
            SXChartSegmentViewModel *model=self.items[i];
            for(UIButton *btn in [_popView subviews]){
                NSInteger btnTag=btn.tag-SXChartSegmentViewSubTag;
                if(btnTag==model.defaultSltIndex){
                    [btn setTitleColor:[UIColor segTextSelectColor] forState:0];
                }else{
                    [btn setTitleColor:[UIColor segTextNomalColor] forState:0];
                }
            }
        }
    }
    
}
//更新SegmentView
-(void)updataSegmentView:(NSInteger)menuIndex :(NSInteger)subMenuIndex{
    
    if(self.sltMenuIndex<0){
        return;
    }
    if(self.sltSubIndex<0){
        return;
    }
    
    SXChartSegmentViewModel *model=self.items[menuIndex];
    SXChartSegmentViewSubModel *subModel=model.subObjects[subMenuIndex];
    
    if([subModel.type isEqualToString:@"0"]){
        [self.selectedMenuBtn setTitle:ALS(model.title) forState:0];
    }else{
        [self.selectedMenuBtn setTitle:ALS(subModel.title) forState:0];
    }
    
}


@end



@implementation SXChartSegmentViewSubModel


@end



@implementation SXChartSegmentViewModel


@end



