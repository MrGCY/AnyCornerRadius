//
//  CYAnyCornerRadiusUtil.m
//  ProjectComponentDemo
//
//  Created by Mr.GCY on 2018/4/23.
//  Copyright © 2018年 Mr.GCY. All rights reserved.
//

#import "CYAnyCornerRadiusUtil.h"

@implementation CYAnyCornerRadiusUtil
CornerRadii CornerRadiiMake(CGFloat topLeft,CGFloat topRight,CGFloat bottomLeft,CGFloat bottomRight){
     return (CornerRadii){
          topLeft,
          topRight,
          bottomLeft,
          bottomRight,
     };
}
//切圆角函数
CGPathRef CYPathCreateWithRoundedRect(CGRect bounds,
                                      CornerRadii cornerRadii)
{
     const CGFloat minX = CGRectGetMinX(bounds);
     const CGFloat minY = CGRectGetMinY(bounds);
     const CGFloat maxX = CGRectGetMaxX(bounds);
     const CGFloat maxY = CGRectGetMaxY(bounds);
     
     const CGFloat topLeftCenterX = minX +  cornerRadii.topLeft;
     const CGFloat topLeftCenterY = minY + cornerRadii.topLeft;
     
     const CGFloat topRightCenterX = maxX - cornerRadii.topRight;
     const CGFloat topRightCenterY = minY + cornerRadii.topRight;
     
     const CGFloat bottomLeftCenterX = minX +  cornerRadii.bottomLeft;
     const CGFloat bottomLeftCenterY = maxY - cornerRadii.bottomLeft;
     
     const CGFloat bottomRightCenterX = maxX -  cornerRadii.bottomRight;
     const CGFloat bottomRightCenterY = maxY - cornerRadii.bottomRight;
     /*
      path : 路径
      m : 变换
      x  y : 画圆的圆心点
      radius : 圆的半径
      startAngle : 起始角度
      endAngle ： 结束角度
      clockwise : 是否是顺时针
      void CGPathAddArc(CGMutablePathRef cg_nullable path,
      const CGAffineTransform * __nullable m,
      CGFloat x, CGFloat y, CGFloat radius, CGFloat startAngle, CGFloat endAngle,
      bool clockwise)
      */
     //虽然顺时针参数是YES，在iOS中的UIView中，这里实际是逆时针
     
     CGMutablePathRef path = CGPathCreateMutable();
     //顶 左
     CGPathAddArc(path, NULL, topLeftCenterX, topLeftCenterY,cornerRadii.topLeft, M_PI, 3 * M_PI_2, NO);
     //顶 右
     CGPathAddArc(path, NULL, topRightCenterX , topRightCenterY, cornerRadii.topRight, 3 * M_PI_2, 0, NO);
     //底 右
     CGPathAddArc(path, NULL, bottomRightCenterX, bottomRightCenterY, cornerRadii.bottomRight,0, M_PI_2, NO);
     //底 左
     CGPathAddArc(path, NULL, bottomLeftCenterX, bottomLeftCenterY, cornerRadii.bottomLeft, M_PI_2,M_PI, NO);
     CGPathCloseSubpath(path);
     return path;
}
//画渐变线
void drawLinearGradient(CGContextRef cg_nullable context,const CGFloat * cg_nullable components,int componentCount,CGFloat width,CGPoint startPoint,CGPoint endPoint,CGGradientDrawingOptions options){
     CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
     CGFloat colors[componentCount];
     for (int i = 0; i < componentCount; i++) {
          colors[i] = components[i];
     }
     CGGradientRef gradient = CGGradientCreateWithColorComponents
     (rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));//形成梯形，渐变的效果
     CGColorSpaceRelease(rgb);
     CGContextSaveGState(context);
     
     CGContextMoveToPoint(context, startPoint.x, startPoint.y);
     CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
     CGContextSetLineWidth(context, width);
     CGContextReplacePathWithStrokedPath(context);
     CGContextClip(context);
     
     //gradient渐变颜色,startPoint开始渐变的起始位置,endPoint结束坐标,options开始坐标之前or开始之后开始渐变
     CGContextDrawLinearGradient(context, gradient,startPoint ,endPoint,options);
     CGContextRestoreGState(context);// 恢复到之前的context
     
     CGGradientRelease(gradient);
}
//画线
void drawLine(CGContextRef cg_nullable context,CGColorRef color,CGFloat width,CGPoint startPoint,CGPoint endPoint){
     CGContextMoveToPoint(context, startPoint.x , startPoint.y);
     CGContextAddLineToPoint(context, endPoint.x,endPoint.y);
     CGContextSetLineWidth(context, width);
     CGContextSetStrokeColorWithColor(context, color);
     CGContextDrawPath(context, kCGPathStroke);
}
//画弧线
void drawLineArc(CGContextRef cg_nullable context,CGColorRef color,CGFloat width,CGPoint centerPoint,CGFloat radius, CGFloat startAngle, CGFloat endAngle, int clockwise){
     CGContextAddArc(context, centerPoint.x, centerPoint.y, radius, startAngle, endAngle, clockwise);
     //划线宽度
     CGContextSetLineWidth(context, width);
     //划线颜色
     CGContextSetStrokeColorWithColor(context, color);
     CGContextDrawPath(context, kCGPathStroke);
}
@end
