//
//  SXChartPriceBoard.m
//  SXMarketViewDemo
//
//  Created by liuy on 2018/5/8.
//  Copyright © 2018年 liuy. All rights reserved.
//

#import "SXChartPriceBoard.h"

@interface SXChartPriceBoard ()




@end

@implementation SXChartPriceBoard
{
    UIView *sep1;
    UIView *sep2;
    UILabel *highHint;
    UILabel *lowHint;
    UILabel *volumHint;
   
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if(self){
        self.backgroundColor=[UIColor backgroundColor];
        
        [self initSubView];
    }
    return self;
}


-(void)initSubView{
    
    sep1=[[UIView alloc] init];
    sep1.backgroundColor=[SXColorScheme getColor:COLOR_SepLineColor];
    [self addSubview:sep1];
    
    sep2=[[UIView alloc] init];
    sep2.backgroundColor=[SXColorScheme getColor:COLOR_SepLineColor];
    [self addSubview:sep2];
    _coinLabel=self.coinLabel;
    _priceLabel=self.priceLabel;
    _zdfLabel=self.zdfLabel;
    _cnyValueLabel=self.cnyValueLabel;
    _highLabel=self.highLabel;
    _lowLabel=self.lowLabel;
    _volumLabel=self.volumLabel;
}

#pragma mark- 懒加载
- (UILabel *)coinLabel{
    if(!_coinLabel){
        _coinLabel=[[UILabel alloc] init];
        [self addSubview:_coinLabel];
        
        _coinLabel.font=[UIFont systemFontOfSize:KScreenPrt(17)];
        _coinLabel.textColor=UIColorFromRGB(0xFFFFFF);
        _coinLabel.text=@"--";
    }
    return _coinLabel;
}

- (UILabel *)priceLabel{
    
    if(!_priceLabel){
        _priceLabel=[[UILabel alloc] init];
        [self addSubview:_priceLabel];
        
        _priceLabel.font=[UIFont systemFontOfSize:KScreenPrt(16)];
        _priceLabel.textColor=UIColorFromRGB(0x0F3652);
        _priceLabel.text=@"--";
    }

    return _priceLabel;
    
}
- (UILabel *)cnyValueLabel{
    
    if(!_cnyValueLabel){
        _cnyValueLabel=[[UILabel alloc] init];
        [self addSubview:_cnyValueLabel];
       
        _cnyValueLabel.font=[UIFont systemFontOfSize:KScreenPrt(12)];
        _cnyValueLabel.textColor=UIColorFromRGB(0x8F9DAA);
        _cnyValueLabel.text=@"--";
    }
    
    return _cnyValueLabel;
}

- (UILabel *)zdfLabel{
    
    if(!_zdfLabel){
        _zdfLabel=[[UILabel alloc] init];
        [self addSubview:_zdfLabel];
       
        _zdfLabel.font=[UIFont systemFontOfSize:KScreenPrt(14)];
        _zdfLabel.textColor=UIColorFromRGB(0x0F3652);
        _zdfLabel.textAlignment=0;
        _zdfLabel.text=@"--";
    }
    
    return _zdfLabel;
    
}

-(UILabel *)highLabel{
    
    if(!_highLabel){
        
        _highLabel=[[UILabel alloc] init];
        [self addSubview:_highLabel];
       
        
        _highLabel.textAlignment=NSTextAlignmentRight;
        _highLabel.font=[UIFont systemFontOfSize:KScreenPrt(10)];
        _highLabel.textColor=UIColorFromRGB(0xAEBBC7);;
        _highLabel.text=@"--";
        
        
        highHint=[[UILabel alloc] init];
        [self addSubview:highHint];
        
        highHint.textAlignment=NSTextAlignmentLeft;
        highHint.font=[UIFont systemFontOfSize:KScreenPrt(10)];
        highHint.textColor=UIColorFromRGB(0xAEBBC7);;
        highHint.text=SXMarketLocalString(@"24h最高");
        
        
    }
    return _highLabel;
}

-(UILabel *)lowLabel{
    
    if(!_lowLabel){
        
        _lowLabel=[[UILabel alloc] init];
        [self addSubview:_lowLabel];
        
        _lowLabel.textAlignment=NSTextAlignmentRight;
        _lowLabel.font=[UIFont systemFontOfSize:KScreenPrt(10)];
        _lowLabel.textColor=UIColorFromRGB(0xAEBBC7);
        _lowLabel.text=@"--";
        
        
        lowHint=[[UILabel alloc] init];
        [self addSubview:lowHint];
        
        lowHint.textAlignment=NSTextAlignmentLeft;
        lowHint.font=[UIFont systemFontOfSize:KScreenPrt(10)];
        lowHint.textColor=UIColorFromRGB(0xAEBBC7);;;
        lowHint.text=SXMarketLocalString(@"24h最低");
        
    }
    return _lowLabel;
}

-(UILabel *)volumLabel{
    
    if(!_volumLabel){
        
        _volumLabel=[[UILabel alloc] init];
        [self addSubview:_volumLabel];
        
        _volumLabel.textAlignment=NSTextAlignmentRight;
        _volumLabel.font=[UIFont systemFontOfSize:KScreenPrt(10)];
        _volumLabel.textColor=UIColorFromRGB(0xAEBBC7);
        _volumLabel.text=@"--";
     
        volumHint=[[UILabel alloc] init];
        [self addSubview:volumHint];
       
        
        volumHint.textAlignment=NSTextAlignmentLeft;
        volumHint.font=[UIFont systemFontOfSize:KScreenPrt(10)];
        volumHint.textColor=UIColorFromRGB(0xAEBBC7);
        volumHint.text=SXMarketLocalString(@"24h成交量");
    }
    return _volumLabel;
}

#pragma mark- 设置数据
-(void)layoutSubviews{
    [super layoutSubviews];
    //横屏
    if (_orientation == UIInterfaceOrientationLandscapeRight || _orientation == UIInterfaceOrientationLandscapeLeft)
    {
        sep1.frame=CGRectMake(0, 0, self.width, 1);
        sep2.frame=CGRectMake(0, self.height-1, self.width, 1);
        
        sep1.hidden=YES;
        sep2.hidden=NO;
        self.coinLabel.hidden=NO;
        volumHint.hidden=YES;
        self.volumLabel.hidden=YES;
       
        [self.coinLabel sizeToFit];
        self.coinLabel.centerY=self.height/2;
        self.coinLabel.left=KScreenPrt(10);
        
        [self.priceLabel sizeToFit];
        self.priceLabel.centerY=self.coinLabel.centerY;
        self.priceLabel.left=self.coinLabel.right+KScreenPrt(10);
        
        [self.zdfLabel sizeToFit];
        self.zdfLabel.centerY=self.coinLabel.centerY;
        self.zdfLabel.left=self.priceLabel.right+KScreenPrt(6);
        
        [self.cnyValueLabel sizeToFit];
        self.cnyValueLabel.centerY=self.coinLabel.centerY;
        self.cnyValueLabel.left=self.zdfLabel.right+KScreenPrt(8);
      
        [highHint sizeToFit];
        highHint.centerY=self.coinLabel.centerY;
        highHint.left=self.cnyValueLabel.right+KScreenPrt(31);
        
        [self.highLabel sizeToFit];
        self.highLabel.centerY=self.coinLabel.centerY;
        self.highLabel.left=highHint.right+KScreenPrt(4);
        
        
        [lowHint sizeToFit];
        lowHint.centerY=self.coinLabel.centerY;
        lowHint.left=self.highLabel.right+KScreenPrt(10);
        
        [self.lowLabel sizeToFit];
        self.lowLabel.centerY=self.coinLabel.centerY;
        self.lowLabel.left=lowHint.right+KScreenPrt(4);
       
    }
    //竖屏/
    else
    {
        sep1.frame=CGRectMake(0, 0, self.width, 1);
        sep2.frame=CGRectMake(0, self.height-1, self.width, 1);
       
        sep1.hidden=NO;
        sep2.hidden=NO;
        self.coinLabel.hidden=YES;
        volumHint.hidden=NO;
        self.volumLabel.hidden=NO;
        
      
        self.priceLabel.frame=CGRectMake(KScreenPrt(15), KScreenPrt(25), self.frame.size.width/2+KScreenPrt(40), KScreenPrt(14));
        self.cnyValueLabel.frame=CGRectMake(KScreenPrt(15), self.priceLabel.bottom+KScreenPrt(19), KScreenPrt(104), KScreenPrt(14));
        self.zdfLabel.frame=CGRectMake(0, 0, self.priceLabel.width-self.cnyValueLabel.right, KScreenPrt(14));
        self.zdfLabel.right=self.priceLabel.right;
        self.zdfLabel.top=self.cnyValueLabel.top;
        highHint.frame=CGRectMake(self.width/2+KScreenPrt(50), KScreenPrt(24), KScreenPrt(50), KScreenPrt(14));
        self.highLabel.frame=CGRectMake(0, highHint.top, 0, KScreenPrt(14));
        self.highLabel.width=self.width-KScreenPrt(15)-highHint.right;
        self.highLabel.right=self.width-KScreenPrt(15);
        
        lowHint.frame=CGRectMake(highHint.left, highHint.bottom+KScreenPrt(4), highHint.width, highHint.height);
        self.lowLabel.frame=CGRectMake(0, lowHint.top, 0, KScreenPrt(14));
        self.lowLabel.width=self.width-KScreenPrt(15)-lowHint.right;
        self.lowLabel.right=self.width-KScreenPrt(15);
        
        volumHint.frame=CGRectMake(highHint.left, lowHint.bottom+KScreenPrt(4), highHint.width, highHint.height);
        self.volumLabel.frame=CGRectMake(0, volumHint.top, 0, KScreenPrt(14));
        self.volumLabel.width=self.width-KScreenPrt(15)-volumHint.right;
        self.volumLabel.right=self.width-KScreenPrt(15);
       
    }
    
}

- (void)setCoin:(NSString *)coin{
    
    if(coin){
        _coin=coin;
    }
    
    self.coinLabel.text=_coin;
    
}

- (void)setNowPrice:(NSString *)nowPrice{
    
    if(nowPrice){
         _nowPrice=nowPrice;
    }
    
    self.priceLabel.text=_nowPrice;
    
}

-(void)setRmbValue:(NSString *)rmbValue{
    if(rmbValue){
        _rmbValue=rmbValue;
    }
    self.cnyValueLabel.text=[NSString stringWithFormat:@"≈%@%@",[SXNumberUtils vluf:[_rmbValue doubleValue]],KCSName];
}

- (void)setZdf:(double)zdf{
    _zdf=zdf;
    if(_zdf<0){
        self.zdfLabel.textColor=[UIColor decreaseColor];
        self.zdfLabel.text=[NSString stringWithFormat:@"%.2f%%",_zdf*100];
        self.priceLabel.textColor=[UIColor decreaseColor];
    }else{
        self.zdfLabel.textColor=[UIColor increaseColor];
        self.zdfLabel.text=[NSString stringWithFormat:@"+%.2f%%",_zdf*100];
         self.priceLabel.textColor=[UIColor increaseColor];
    }
}

- (void)setHighPrice:(NSString *)highPrice{
   
    if(highPrice){
         _highPrice=highPrice;
    }
    
    self.highLabel.text=_highPrice;
}

- (void)setLowPrice:(NSString *)lowPrice{
   
    if(lowPrice){
        _lowPrice=lowPrice;
    }
    self.lowLabel.text=_lowPrice;
}

- (void)setVolum:(NSString *)volum{
    if(volum){
        _volum=volum;
    }
    self.volumLabel.text=[SXNumberUtils volFormat:_volum];
}


@end
