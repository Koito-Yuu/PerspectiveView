//
//  PerspectiveView.m
//  PerspectiveView
//
//  Created by S.C. on 16/9/11.
//  Copyright © 2016年 Kabylake. All rights reserved.
//

#import "PerspectiveView.h"

@implementation PerspectiveView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        _background           = [[UIImageView alloc] init];
        //默认放大倍率1.1
        _multiple             = 1.1;
        //默认全方向移动
        _perspectiveDirection = PerspectiveDirectionAll;
        [self addSubview:_background];
    }
    return self;
}

- (void)settingImage:(UIImage *)image {
    
    _background.image  = image;
    _background.bounds = CGRectMake(0, 0, self.frame.size.width * _multiple, self.frame.size.height * _multiple);
    _background.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
}

- (void)settingMultple:(CGFloat)multiple {
    
    //检查放大倍率
    _multiple = multiple >= 1 && multiple <=3 ? multiple : 1;
    _background.bounds = CGRectMake(0, 0, self.frame.size.width * _multiple, self.frame.size.height * _multiple);
}

- (void)settingPerspectiveDirection:(PerspectiveDirection)mode {
    
    _perspectiveDirection = mode;
}

- (void)enablePerspective {
    
    if (!_processor.manager.deviceMotionActive) {
        _processor = [[MotionProcessor alloc] init];
        [_processor startDeviceMotionWithBlock:^(CGFloat x, CGFloat y, CGFloat z) {
            
            [UIView animateKeyframesWithDuration:0.1
                                           delay:0
                                         options:UIViewKeyframeAnimationOptionCalculationModeDiscrete
                                      animations:^{
                                          switch (_perspectiveDirection) {
                                              case PerspectiveDirectionHorizontalOnly:
                                                  [self horizontalShift:y];
                                                  break;
                                              case PerspectiveDirectionVerticalOnly:
                                                  [self verticalShift:x];
                                                  break;
                                              case PerspectiveDirectionAll:
                                                  [self horizontalShift:y];
                                                  [self verticalShift:x];
                                                  break;
                                          }
                                      }
                                      completion:nil];
        }];
    }
}

/**
 *  图片水平移动的相关计算
 *
 *  @param y DeviceMotion传入的相关Y轴数据
 */
- (void)horizontalShift:(CGFloat)y {
    
    CGFloat horizontalShiftSpeed = (_background.frame.size.width - self.frame.size.width) / 100;
    
    //图片左右有位置
    if (_background.frame.origin.x <= 0 && _background.frame.origin.x + _background.frame.size.width >= self.frame.size.width) {
        //反转Y轴
        CGFloat xOffset = _background.frame.origin.x + -y * (_background.frame.size.width / [UIScreen mainScreen].bounds.size.width) * horizontalShiftSpeed + _background.frame.size.width / 2;
        _background.center = CGPointMake(xOffset, _background.center.y);
    }
    
    //图片左侧没位置
    if (_background.frame.origin.x > 0) {
        _background.frame = CGRectMake(0, _background.frame.origin.y, _background.frame.size.width, _background.frame.size.height);
    }
    
    //图片右侧没位置
    if (_background.frame.origin.x + _background.frame.size.width < self.frame.size.width) {
        _background.frame = CGRectMake(self.frame.size.width - _background.frame.size.width, _background.frame.origin.y, _background.frame.size.width, _background.frame.size.height);
    }
}

/**
 *  图片垂直移动的相关计算
 *
 *  @param x DeviceMotion传入的相关X轴数据
 */
- (void)verticalShift:(CGFloat)x {
    
    CGFloat verticalShiftSpeed = (_background.frame.size.height - self.frame.size.height) / 100;
    
    //图片上下有位置
    if (_background.frame.origin.y <= 0 && _background.frame.origin.y + _background.frame.size.height >= self.frame.size.height) {
        //反转X轴
        CGFloat yOffset = _background.frame.origin.y + -x * (_background.frame.size.height / [UIScreen mainScreen].bounds.size.height) * verticalShiftSpeed + _background.frame.size.height / 2;
        _background.center = CGPointMake(_background.center.x, yOffset);
    }
    
    //图片上侧没位置
    if (_background.frame.origin.y > 0) {
        _background.frame = CGRectMake(_background.frame.origin.x, 0, _background.frame.size.width, _background.frame.size.height);
    }
    
    //图片下侧没位置
    if (_background.frame.origin.y + _background.frame.size.height < self.frame.size.height) {
        _background.frame = CGRectMake(_background.frame.origin.x, self.frame.size.height - _background.frame.size.height, _background.frame.size.width, _background.frame.size.height);
    }
}

- (void)disablePerspective {
    
    [_processor stopDeviceMotion];
}

@end
