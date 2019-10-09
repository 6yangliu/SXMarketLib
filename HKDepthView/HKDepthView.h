//
//  HKDepthView.h
//
//
//  Created by ly on 2019/5/14.
//  Copyright © 2019年 liuy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HKDepthModel;
@interface HKDepthView : UIView

@property (nonatomic,strong)NSArray* depthData;

-(void)reloadData;

@end

