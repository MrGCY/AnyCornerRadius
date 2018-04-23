//
//  CYCustomArcImageView.m
//  ProjectComponentDemo
//
//  Created by Mr.GCY on 2018/4/20.
//  Copyright © 2018年 Mr.GCY. All rights reserved.
//

#import "CYCustomArcImageView.h"
#import "CYAnyCornerRadiusUtil.h"
@interface CYCustomArcImageView()
@property (nonatomic, assign) CornerRadii cornerRadii;
@end
@implementation CYCustomArcImageView
-(instancetype)init{
     if (self = [super init]) {
          [self setupUI];
     }
     return self;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
     if (self = [super initWithCoder:aDecoder]) {
          [self setupUI];
     }
     return self;
}
-(instancetype)initWithFrame:(CGRect)frame{
     if (self = [super initWithFrame:frame]) {
          [self setupUI];
     }
     return self;
}
-(void)layoutSubviews{

}
-(CGSize)sizeThatFits:(CGSize)size{
     if (self.image) {
          return self.image.size;
     }
     return size;
}
#pragma mark- 初始化视图
-(void)setupUI{

}
#pragma mark- setter getter
/**
 * Border radii.
 */
-(void)setBorderRadius:(CGFloat)borderRadius{
     _borderRadius = borderRadius;
     self.borderBottomRightRadius = borderRadius;
     self.borderBottomLeftRadius = borderRadius;
     self.borderTopRightRadius = borderRadius;
     self.borderTopLeftRadius = borderRadius;
}
/**
 * Border colors (actually retained).
 */
-(void)setBorderColor:(CGColorRef)borderColor{
     _borderColor = borderColor;
     self.borderTopColor = borderColor;
     self.borderRightColor = borderColor;
     self.borderBottomColor = borderColor;
     self.borderLeftColor = borderColor;
}
/**
 * Border widths.
 */
-(void)setBorderWidth:(CGFloat)borderWidth{
     _borderWidth = borderWidth;
     self.borderTopWidth = borderWidth;
     self.borderRightWidth = borderWidth;
     self.borderBottomWidth = borderWidth;
     self.borderLeftWidth = borderWidth;
}
#pragma mark- 绘制方法
- (void)drawRect:(CGRect)rect {
     //切圆角
     CAShapeLayer *shapeLayer = [CAShapeLayer layer];
     self.cornerRadii = CornerRadiiMake(self.borderTopLeftRadius, self.borderTopRightRadius, self.borderBottomLeftRadius, self.borderBottomRightRadius);
     CGPathRef path = CYPathCreateWithRoundedRect(self.bounds,self.cornerRadii);
     shapeLayer.path = path;
     CGPathRelease(path);
     self.layer.mask = shapeLayer;

     // 绘制图片
     if (self.image) {
          [self.image drawInRect:self.bounds];//在坐标中画出图片
          //          CGContextDrawImage(context, self.bounds, self.image.CGImage); 会出现图片上下颠倒
     }
     
     //An opaque type that represents a Quartz 2D drawing environment.
     //一个不透明类型的Quartz 2D绘画环境,相当于一个画布,你可以在上面任意绘画
     CGContextRef context = UIGraphicsGetCurrentContext();
     //画线
     [self drawGradientLineWithContent:context];
     //内侧线
     [self drawLineWithContent:context];
     
     CGContextRelease(context);
}
-(void)drawLineWithContent:(CGContextRef)context{
     //画线
     const CGFloat minX = CGRectGetMinX(self.bounds);
     const CGFloat minY = CGRectGetMinY(self.bounds);
     const CGFloat maxX = CGRectGetMaxX(self.bounds);
     const CGFloat maxY = CGRectGetMaxY(self.bounds);
     
     
     
     const CGFloat topLeftCenterX = minX +  self.borderTopLeftRadius;
     const CGFloat topLeftCenterY = minY + self.borderTopLeftRadius;
     
     const CGFloat topRightCenterX = maxX - self.borderTopRightRadius;
     const CGFloat topRightCenterY = minY + self.borderTopRightRadius;
     
     const CGFloat bottomLeftCenterX = minX +  self.borderBottomLeftRadius;
     const CGFloat bottomLeftCenterY = maxY - self.borderBottomLeftRadius;
     
     const CGFloat bottomRightCenterX = maxX -  self.borderBottomRightRadius;
     const CGFloat bottomRightCenterY = maxY - self.borderBottomRightRadius;
     
     CGFloat lineW = 5;
     CGFloat topSpaceY = (self.borderTopWidth + lineW)/2;
     CGFloat rightSpaceX = (self.borderRightWidth + lineW)/2;
     CGFloat bottomSpaceY = (self.borderBottomWidth + lineW)/2;
     CGFloat leftSpaceX = (self.borderLeftWidth + lineW)/2;
     
     self.borderTopLeftRadius -=  topSpaceY;
     self.borderTopRightRadius -=  rightSpaceX;
     self.borderBottomLeftRadius -=  bottomSpaceY;
     self.borderBottomRightRadius -=  leftSpaceX;
     
     
     //黄色
     UIColor *  color = [UIColor colorWithRed:234/255.0 green:254/255.0 blue:254/255.0 alpha:1.0];
     //1.0 顶左 画圆弧
     drawLineArc(context, color.CGColor, lineW, CGPointMake(topLeftCenterX, topLeftCenterY), self.borderTopLeftRadius, M_PI, 3 * M_PI_2, NO);
     //2.0 顶部划线
     drawLine(context, color.CGColor, lineW, CGPointMake(topLeftCenterX, topSpaceY), CGPointMake(topRightCenterX, topSpaceY));
     //3.0 顶右 画圆弧
     drawLineArc(context, color.CGColor, lineW, CGPointMake(topRightCenterX, topRightCenterY), self.borderTopRightRadius, 3 * M_PI_2, 0, NO);
     //4.0 右部划线
     drawLine(context, color.CGColor, lineW, CGPointMake(maxX - rightSpaceX, topRightCenterY), CGPointMake(maxX - rightSpaceX, bottomRightCenterY));
     //5.0 底右 画圆弧
     drawLineArc(context, color.CGColor, lineW, CGPointMake(bottomRightCenterX, bottomRightCenterY), self.borderBottomRightRadius, 0, M_PI_2, NO);
     //6.0 底部划线
     drawLine(context, color.CGColor, lineW, CGPointMake(bottomRightCenterX, maxY - bottomSpaceY), CGPointMake(bottomLeftCenterX, maxY - bottomSpaceY));

     //7.0 底左 画圆弧
     drawLineArc(context, color.CGColor, lineW, CGPointMake(bottomLeftCenterX, bottomLeftCenterY), self.borderBottomLeftRadius, M_PI_2, M_PI, NO);

     //8.0 左边划线
     drawLine(context, color.CGColor, lineW, CGPointMake(minX + leftSpaceX, bottomLeftCenterY), CGPointMake(minX + leftSpaceX, topLeftCenterY));
     
}

//画渐变线
-(void)drawGradientLineWithContent:(CGContextRef)context{
     
     
     //画线
     const CGFloat minX = CGRectGetMinX(self.bounds);
     const CGFloat minY = CGRectGetMinY(self.bounds);
     const CGFloat maxX = CGRectGetMaxX(self.bounds);
     const CGFloat maxY = CGRectGetMaxY(self.bounds);
     
     const CGFloat topLeftCenterX = minX +  self.borderTopLeftRadius;
     const CGFloat topLeftCenterY = minY + self.borderTopLeftRadius;
     
     const CGFloat topRightCenterX = maxX - self.borderTopRightRadius;
     const CGFloat topRightCenterY = minY + self.borderTopRightRadius;
     
     const CGFloat bottomLeftCenterX = minX +  self.borderBottomLeftRadius;
     const CGFloat bottomLeftCenterY = maxY - self.borderBottomLeftRadius;
     
     const CGFloat bottomRightCenterX = maxX -  self.borderBottomRightRadius;
     const CGFloat bottomRightCenterY = maxY - self.borderBottomRightRadius;
     
     //渐变色数组
     CGFloat colors[] =
     {
          245/255.0,213/255.0,79/255.0, 1.00,
          231/255.0,108/255.0,0, 1.00,
     };
     //黄色
     UIColor *  color = [UIColor colorWithRed:245/255.0 green:213/255.0 blue:79/255.0 alpha:1.0];
     //1.0 顶左 画圆弧
     drawLineArc(context, color.CGColor, self.borderTopWidth, CGPointMake(topLeftCenterX, topLeftCenterY), self.borderTopLeftRadius, M_PI, 3 * M_PI_2, NO);
     //2.0 顶部划线
     drawLine(context, color.CGColor, self.borderTopWidth, CGPointMake(topLeftCenterX, 0), CGPointMake(topRightCenterX, 0));
     //3.0 顶右 画圆弧
     drawLineArc(context, color.CGColor, self.borderRightWidth, CGPointMake(topRightCenterX, topRightCenterY), self.borderTopRightRadius, 3 * M_PI_2, 0, NO);
     //4.0 右部划线
     drawLinearGradient(context, colors,sizeof(colors)/(sizeof(colors[0])), self.borderRightWidth ,CGPointMake(maxX, topRightCenterY), CGPointMake(maxX, bottomRightCenterY),kCGGradientDrawsAfterEndLocation);
     
     color = [UIColor colorWithRed:231/255.0 green:108/255.0 blue:0 alpha:1.0];
     //5.0 底右 画圆弧
     drawLineArc(context, color.CGColor, self.borderBottomWidth, CGPointMake(bottomRightCenterX, bottomRightCenterY), self.borderBottomRightRadius, 0, M_PI_2, NO);
     //6.0 底部划线
     drawLine(context, color.CGColor, self.borderBottomWidth, CGPointMake(bottomRightCenterX, maxY), CGPointMake(bottomLeftCenterX, maxY));
     
     //7.0 底左 画圆弧
     drawLineArc(context, color.CGColor, self.borderLeftWidth, CGPointMake(bottomLeftCenterX, bottomLeftCenterY), self.borderBottomLeftRadius, M_PI_2, M_PI, NO);
     
     //8.0 左边划线
     CGFloat colors1[] = {
          231/255.0,108/255.0,0, 1.00,
          245/255.0,213/255.0,79/255.0, 1.00,
     };
     drawLinearGradient(context, colors1,sizeof(colors1)/(sizeof(colors1[0])),self.borderLeftWidth,CGPointMake(minX, bottomLeftCenterY), CGPointMake(minX, topLeftCenterY),kCGGradientDrawsAfterEndLocation);
     
}
@end
