//
//  CALayer+LayerColor.m
//  ipeixun
//
//  Created by Mac on 16/8/28.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import "CALayer+LayerColor.h"

@implementation CALayer (LayerColor)
- (void)setBorderColorFromUIColor:(UIColor *)color
{
    self.borderColor = color.CGColor;
}
@end
