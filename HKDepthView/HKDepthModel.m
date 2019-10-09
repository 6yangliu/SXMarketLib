//
//  HKDepthModel.h
//
//
//  Created by ly on 2019/5/14.
//  Copyright © 2019年 liuy. All rights reserved.
//

#import "HKDepthModel.h"

@implementation HKDepthModel


+(CGFloat)depthCaculate:(NSArray *)data :(NSInteger)depthIndex :(NSInteger)type{
    NSArray *buyOrder=[NSArray array];
    if(data.count){
        buyOrder=data[0];
    }
    NSArray *sellOrder=[NSArray array];
    if(data.count>=1){
        sellOrder=data[1];
    }
    //计算买卖盘总和最大值
    double buyQtySum=0;
    for (NSArray *array in buyOrder) {
        if(array.count>=1){
            buyQtySum+=[array[1] doubleValue];
        }
    }
    double sellQtySum=0;
    for (NSArray *array in sellOrder) {
        if(array.count>=1){
            sellQtySum+=[array[1] doubleValue];
        }
    }
    double maxQty=buyQtySum>=sellQtySum ? buyQtySum : sellQtySum;
    //计算深度百分比
    NSArray *targetArray=[NSMutableArray array];
    if(type==0){//buy
        targetArray=buyOrder;
    }
    if(type==1){//buy
        targetArray=sellOrder;
    }
    double depthQty=0;
    for (int i=0 ;i<targetArray.count;i++) {
        if(i>depthIndex){
            break;
        }
        depthQty+=[targetArray[i][1] doubleValue];
        
    }
    if(maxQty==0){
        return 0;
    }
    return depthQty/maxQty;
}

+(double)getMaxPrice:(NSMutableArray *)dataArrayM{
    NSMutableArray *priceArray=[NSMutableArray array];
    for (NSArray *array in dataArrayM) {
        if(array.count>1){
            [priceArray addObject:array[0]];
        }else{
            [priceArray addObject:@"0"];
        }
        
    }
    double maxValue=[[priceArray valueForKeyPath:@"@max.doubleValue"] doubleValue];
    return maxValue;
}
+(double)getMinPrice:(NSMutableArray *)dataArrayM{
    NSMutableArray *priceArray=[NSMutableArray array];
    for (NSArray *array in dataArrayM) {
        if(array.count>1){
            [priceArray addObject:array[0]];
        }else{
            [priceArray addObject:@"0"];
        }
        
    }
    double minValue=[[priceArray valueForKeyPath:@"@min.doubleValue"] doubleValue];
    return minValue;
}

+(double)getVolumeSum:(NSMutableArray *)dataArrayM{
    NSMutableArray *volumeArray=[NSMutableArray array];
    for (NSArray *array in dataArrayM) {
        if(array.count>=1){
            [volumeArray addObject:array[1]];
        }else{
            [volumeArray addObject:@"0"];
        }
        
    }
    double sellQtySum=0;
    for (NSString *vol in volumeArray) {
        sellQtySum+=[vol doubleValue];
    }
    return sellQtySum;
}

+(double)getMinVolumeSum:(NSMutableArray *)dataArrayM{
    NSMutableArray *priceArray=[NSMutableArray array];
    for (NSArray *array in dataArrayM) {
        if(array.count>1){
            [priceArray addObject:array[1]];
        }else{
            [priceArray addObject:@"0"];
        }
        
    }
    double minValue=[[priceArray valueForKeyPath:@"@min.doubleValue"] doubleValue];
    return minValue;
}

+(NSMutableArray *)getDepthPoint:(NSMutableArray *)dataArrayM{
    NSArray *buyArray=[NSMutableArray array];
    if(dataArrayM){
        buyArray=dataArrayM;
    }
    
    NSMutableArray *depthPointD=[NSMutableArray array];
    NSMutableArray *buyPointM=[NSMutableArray array];
    double buyQtySum=0;
    for (NSArray *array in buyArray) {
        if(array.count>=1){
            HKDepthModel *buymodel=[[HKDepthModel alloc] init];
            buymodel.price=[array[0] doubleValue];
            buyQtySum+=[array[1] doubleValue];
            buymodel.volume=buyQtySum;
            [buyPointM addObject:buymodel];
        }
    }
    NSArray *resultBuy = [buyPointM sortedArrayUsingComparator:^NSComparisonResult(HKDepthModel* obj1,  HKDepthModel*  obj2) {
        
        return [@(obj1.price) compare:@(obj2.price)];
        
    }];
 
    [depthPointD addObjectsFromArray:resultBuy];
    return depthPointD;
}
+(NSMutableArray *)getSellDepthPoint:(NSMutableArray *)dataArrayM{
   
    NSArray *sellArray=[NSMutableArray array];
    if(dataArrayM){
        sellArray=dataArrayM;
    }
    
    NSMutableArray *depthPointD=[NSMutableArray array];
    
    double sellQtySum=0;
    NSMutableArray *sellPointM=[NSMutableArray array];
    for (NSArray *array in sellArray) {
        HKDepthModel *sellModel=[[HKDepthModel alloc] init];
        if(array.count>=1){
            sellModel.price=[array[0] doubleValue];
            sellQtySum+=[array[1] doubleValue];
            sellModel.volume=sellQtySum;
            [sellPointM addObject:sellModel];
        }
    }
    
    NSArray *resultSell = [sellPointM sortedArrayUsingComparator:^NSComparisonResult(HKDepthModel* obj1,  HKDepthModel*  obj2) {
        
        return [@(obj1.price) compare:@(obj2.price)];
        
    }];
    [depthPointD addObjectsFromArray:resultSell];
    return depthPointD;
}

+(NSUInteger)getDigitFromStr:(NSString *)str{
    NSRange range =  [str rangeOfString:@"." options:NSBackwardsSearch];//从最后面查找
    
    if(range.location==NSNotFound){
        return 0;
    }
    
    return str.length-range.location-1;
}


@end
