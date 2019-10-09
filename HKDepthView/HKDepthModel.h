//
//  HKDepthModel.h
//
//
//  Created by ly on 2019/5/14.
//  Copyright © 2019年 liuy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HKDepthModel : NSObject


@property (nonatomic,assign) double price;
@property (nonatomic,assign) double volume;


+(CGFloat)depthCaculate:(NSArray *)data :(NSInteger)depthIndex :(NSInteger)type;

+(double)getMaxPrice:(NSMutableArray *)dataArrayM;
+(double)getMinPrice:(NSMutableArray *)dataArrayM;
+(double)getVolumeSum:(NSMutableArray *)dataArrayM;
+(NSMutableArray *)getDepthPoint:(NSMutableArray *)dataArrayM;
+(double)getMinVolumeSum:(NSMutableArray *)dataArrayM;
+(NSMutableArray *)getBuyDepthPoint:(NSMutableArray *)dataArrayM;
+(NSMutableArray *)getSellDepthPoint:(NSMutableArray *)dataArrayM;
+(NSUInteger)getDigitFromStr:(NSString *)str;
@end
