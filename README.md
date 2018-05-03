# AnyCornerRadius
iOS中对任意视图切圆角 ，可以切任意一个角任意大小


最近要做一个新项目，产品需求刚过完，UI的效果图也就随之而出了，拿到效果图之后，看到首页就让我大吃一惊了，因为里面出现好多不同大小和个数的圆角，这让我着实头疼，大家可以看看UI效果图。
![首页.png](https://upload-images.jianshu.io/upload_images/2517741-eae4775b66c8b8e2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
可以看到页面确实很炫，但是实现也比较费劲。

###之前圆角方案
######1.使用layer的cornerRadius属性进行设置
```
self.view.layer.cornerRadius = 5.f; 
self.view.layer.masksToBounds = YES;
````

######缺点：
1).当图片数量比较多的时候,这种添加圆角方式特别消耗性能,比如在UITableViewCell
添加过多圆角的话,甚至会带来视觉可见的卡顿.
2).无法配置圆角数量(只能添加view的四个角全为圆角),无法配置某个圆角大小.
第一个问题实际上是由于数量太多的情况下,系统会频繁的调用GPU的离屏渲染(Offscreen Rendering)机制,导致内存损耗严重.
######解决：
第一个问题: 采取预先生成圆角图片，并缓存起来这个方法才是比较好的手段。预处理圆角图片可以在后台处理，处理完毕后缓存起来，再在主线程显示，这就避免了不必要的离屏渲染了,更多关于离屏渲染的详解,大家可以看[这里](https://link.jianshu.com?t=http://objccn.io/issue-3-1/),本文不多赘述.

```
self.view.layer.cornerRadius = 5.f;
self.view.layer.masksToBounds = YES; // 裁剪
self.view.layer.shouldRasterize = YES; // 缓存
self.view.layer.rasterizationScale = [UIScreen mainScreen].scale;
```
当shouldRasterize设成true时，layer被渲染成一个bitmap，并缓存起来，等下次使用时不会再重新去渲染了。实现圆角本 身就是在做颜色混合（blending），如果每次页面出来时都blending，消耗太大，这时shouldRasterize = yes，下次就只是简单的从渲染引擎的cache里读取那张bitmap，节约[系统](https://link.jianshu.com?t=http://www.2cto.com/os/)资源。
######2.使用UIBezierPath进行切圆角
这种方案可以完美的解决方案一中第二个问题不能实现配置任意圆角数量。
实现过程

```
UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 100, 50)];
view.backgroundColor = [UIColor redColor];
UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(25, 0)];
CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
maskLayer.frame = view.bounds;
maskLayer.path = maskPath.CGPath;
view.layer.mask = maskLayer;
[self.view addSubview:view];
```
其中想配置不同数量圆角可以设置UIRectCorner枚举属性进行配置。
```
UIRectCornerTopLeft     = 1 << 0,//顶左
UIRectCornerTopRight    = 1 << 1,//顶右
UIRectCornerBottomLeft  = 1 << 2,//底左
UIRectCornerBottomRight = 1 << 3,//底右
UIRectCornerAllCorners  = ~0UL//所有
```
######缺点：
1. 通过UIBezierPath虽然解决了配置不同数量圆角，但是还是没有能解决配置不同大小的圆角
######解决：
下面就到了主角亮相的时刻了。
######插曲
与第二种方案很类似的一个是在iOS11.0之后对于圆角出来了一个新特性
```
@property CACornerMask maskedCorners
  CA_AVAILABLE_STARTING (10.13, 11.0, 11.0, 4.0);
```
就是在layer新增了一个maskedCorners属性,其中CACornerMask是一个结构体
```
typedef NS_OPTIONS (NSUInteger, CACornerMask)
{
  kCALayerMinXMinYCorner = 1U << 0,
  kCALayerMaxXMinYCorner = 1U << 1,
  kCALayerMinXMaxYCorner = 1U << 2,
  kCALayerMaxXMaxYCorner = 1U << 3,
};
```
这个属性用于设置不同位置的圆角
```
UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 100, 50)];
view.backgroundColor = [UIColor redColor];
if (@available(iOS 11.0, *)) {
    view.layer.maskedCorners = kCALayerMaxXMaxYCorner |kCALayerMaxXMinYCorner;
} else {
     // Fallback on earlier versions
}
view.layer.cornerRadius = 25.f;
view.layer.masksToBounds = YES;
[self.view addSubview:view];
```
但是他跟方案二有相同的缺点
###问题解决思路
看到效果图之后，我首先想到了第二种方案，在模糊的记忆中首先想到它可以配置 不同数量的圆角，然后就是想看看它能不能同时实现配置不同大小的圆角，找了很久也看了layer的一些属性没有找到，相关属性，网上也找了很多文章（可能没有找对关键字）也没有找到，很多都是方案一方案二的方法，没有具体解决不同大小的圆角方案，后面我一度以为iOS中不能实现（可能我太菜了），在我陷入迷茫的时候，我的同事突然提醒了我，说reactnative 中可以实现配置任意数量圆角并同时配置不同大小的方式（到这块可能了解RN工作原理的人已经大概知道该怎么去做了，RN的项目其实最终展示的控件还是原生控件，他们内部通过js来实现原生交互，将RN代码创建的控件转化成原生的控件，在RN中的任何组件，在原生都可以找到对应的原生组件，既然RN可以实现，那代表着原生也能实现），我之前也用过RN，写代码很快（用熟了之后）很方便，像效果图中的那个效果，很快就能实现。
######1.于是我赶紧找RN的原生代码
![1.png](https://upload-images.jianshu.io/upload_images/2517741-edc7671c877713fc.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
这个主要是RN的在原生中的代码库，我们最主要的是看红框中的内容
![2.png](https://upload-images.jianshu.io/upload_images/2517741-dfdc094d60ab7c3b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
因为主要是view及它的子类有这种属性，所有我们只需要在view对应的那个文件中找就可以
```
- (void)updateClippingForLayer:(CALayer *)layer
{
  CALayer *mask = nil;
  CGFloat cornerRadius = 0;

  if (self.clipsToBounds) {

    const RCTCornerRadii cornerRadii = [self cornerRadii];
    if (RCTCornerRadiiAreEqual(cornerRadii)) {

      cornerRadius = cornerRadii.topLeft;

    } else {
      //切圆角的代码
      CAShapeLayer *shapeLayer = [CAShapeLayer layer];
      CGPathRef path = RCTPathCreateWithRoundedRect(self.bounds, RCTGetCornerInsets(cornerRadii, UIEdgeInsetsZero), NULL);
      shapeLayer.path = path;
      CGPathRelease(path);
      mask = shapeLayer;
    }
  }

  layer.cornerRadius = cornerRadius;
  layer.mask = mask;
}
```
这是它里面的一段代码，主要的切圆角方式再标注的地方，不难看出还是用了类似方案二中添加路径的方式去切圆角只是和UIBezierPath不一样，点击RCTPathCreateWithRoundedRect这个方法，我们就可以看到具体切圆角的过程了。
```
CGPathRef RCTPathCreateWithRoundedRect(CGRect bounds,
                                       RCTCornerInsets cornerInsets,
                                       const CGAffineTransform *transform)
{
  const CGFloat minX = CGRectGetMinX(bounds);
  const CGFloat minY = CGRectGetMinY(bounds);
  const CGFloat maxX = CGRectGetMaxX(bounds);
  const CGFloat maxY = CGRectGetMaxY(bounds);

  const CGSize topLeft = {
    MAX(0, MIN(cornerInsets.topLeft.width, bounds.size.width - cornerInsets.topRight.width)),
    MAX(0, MIN(cornerInsets.topLeft.height, bounds.size.height - cornerInsets.bottomLeft.height)),
  };
  const CGSize topRight = {
    MAX(0, MIN(cornerInsets.topRight.width, bounds.size.width - cornerInsets.topLeft.width)),
    MAX(0, MIN(cornerInsets.topRight.height, bounds.size.height - cornerInsets.bottomRight.height)),
  };
  const CGSize bottomLeft = {
    MAX(0, MIN(cornerInsets.bottomLeft.width, bounds.size.width - cornerInsets.bottomRight.width)),
    MAX(0, MIN(cornerInsets.bottomLeft.height, bounds.size.height - cornerInsets.topLeft.height)),
  };
  const CGSize bottomRight = {
    MAX(0, MIN(cornerInsets.bottomRight.width, bounds.size.width - cornerInsets.bottomLeft.width)),
    MAX(0, MIN(cornerInsets.bottomRight.height, bounds.size.height - cornerInsets.topRight.height)),
  };

  CGMutablePathRef path = CGPathCreateMutable();
  RCTPathAddEllipticArc(path, transform, (CGPoint){
    minX + topLeft.width, minY + topLeft.height
  }, topLeft, M_PI, 3 * M_PI_2, NO);
  RCTPathAddEllipticArc(path, transform, (CGPoint){
    maxX - topRight.width, minY + topRight.height
  }, topRight, 3 * M_PI_2, 0, NO);
  RCTPathAddEllipticArc(path, transform, (CGPoint){
    maxX - bottomRight.width, maxY - bottomRight.height
  }, bottomRight, 0, M_PI_2, NO);
  RCTPathAddEllipticArc(path, transform, (CGPoint){
    minX + bottomLeft.width, maxY - bottomLeft.height
  }, bottomLeft, M_PI_2, M_PI, NO);
  CGPathCloseSubpath(path);
  return path;
}
static void RCTPathAddEllipticArc(CGMutablePathRef path,
                                  const CGAffineTransform *m,
                                  CGPoint origin,
                                  CGSize size,
                                  CGFloat startAngle,
                                  CGFloat endAngle,
                                  BOOL clockwise)
{
  CGFloat xScale = 1, yScale = 1, radius = 0;
  if (size.width != 0) {
    xScale = 1;
    yScale = size.height / size.width;
    radius = size.width;
  } else if (size.height != 0) {
    xScale = size.width / size.height;
    yScale = 1;
    radius = size.height;
  }

  CGAffineTransform t = CGAffineTransformMakeTranslation(origin.x, origin.y);
  t = CGAffineTransformScale(t, xScale, yScale);
  if (m != NULL) {
    t = CGAffineTransformConcat(t, *m);
  }

  CGPathAddArc(path, &t, 0, 0, radius, startAngle, endAngle, clockwise);
}
```
上面就是RN中视图切圆角的具体代码，主要执行过程大家可以自己看源码
主要文件名和路径看下图：
![3.png](https://upload-images.jianshu.io/upload_images/2517741-392f6bfb39606132.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
主要是这两个文件，最主要的代码就是这句
```
/* Add an arc of a circle to `path', possibly preceded by a straight line
   segment. The arc is approximated by a sequence of Bézier curves. `(x, y)'
   is the center of the arc; `radius' is its radius; `startAngle' is the
   angle to the first endpoint of the arc; `endAngle' is the angle to the
   second endpoint of the arc; and `clockwise' is true if the arc is to be
   drawn clockwise, false otherwise. `startAngle' and `endAngle' are
   measured in radians. If `m' is non-NULL, then the constructed Bézier
   curves representing the arc will be transformed by `m' before they are
   added to `path'.

   Note that using values very near 2π can be problematic. For example,
   setting `startAngle' to 0, `endAngle' to 2π, and `clockwise' to true will
   draw nothing. (It's easy to see this by considering, instead of 0 and 2π,
   the values ε and 2π - ε, where ε is very small.) Due to round-off error,
   however, it's possible that passing the value `2 * M_PI' to approximate
   2π will numerically equal to 2π + δ, for some small δ; this will cause a
   full circle to be drawn.

   If you want a full circle to be drawn clockwise, you should set
   `startAngle' to 2π, `endAngle' to 0, and `clockwise' to true. This avoids
   the instability problems discussed above. */

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
CG_EXTERN void CGPathAddArc(CGMutablePathRef cg_nullable path,
    const CGAffineTransform * __nullable m,
    CGFloat x, CGFloat y, CGFloat radius, CGFloat startAngle, CGFloat endAngle,
    bool clockwise)
    CG_AVAILABLE_STARTING(__MAC_10_2, __IPHONE_2_0);
```
注：再API中写到clockwise默认是YES,即是顺时针，但是再iOS中的UIView中，这实际是逆时针，所有有时候看代码中写的感觉有问题，但运行出来确实正确的，不知道为什么。

######2.开始参考RN的代码写自己圆角代码
通过了解和熟悉整个RN的代码实现过程，我就开始写这块的代码，具体代码如下：
```
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
```
具体应用部分代码：
 ```
//切圆角
     CAShapeLayer *shapeLayer = [CAShapeLayer layer];
     self.cornerRadii = CornerRadiiMake(self.borderTopLeftRadius, self.borderTopRightRadius, self.borderBottomLeftRadius, self.borderBottomRightRadius);
     CGPathRef path = CYPathCreateWithRoundedRect(self.bounds,self.cornerRadii);
     shapeLayer.path = path;
     CGPathRelease(path);
     self.layer.mask = shapeLayer;
```
最中解决了这个问题可以实现配置不同数量不同大小的圆角，对于性能这块，它采用的也是路径去处理，跟方案二很类似，所以大体差不多，具体的性能对比还没有详细比较过，后面我也实现了效果图中的效果
![4.png](https://upload-images.jianshu.io/upload_images/2517741-b0f6a1b41f49289b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
其中的颜色渐变边框我才用的是路径绘制渐变线的方式实现的，这块的代码比较多，写的比较繁琐（还不知道有什么简单的处理方式），如果有比较好的解决思路可以评论留言交流交流。
具体代码[这里](https://github.com/MrGCY/AnyCornerRadius),可以具体看看实现过程。
###总结
通过这次切不同大小圆角的问题，发现了之前自己真的是只做业务层，做最简单的东西，对于稍微深入一点的东西，一点都不知道，可能有些知道，但也仅仅限于这是个什么，但要用它做什么东西就不知道，上层的东西很方便很快捷但是局限性太大，要想做一些很炫很酷的效果还是得深入底层了解每个属性每个方法是什么？有什么用？主要使用在哪些方面？，这些概念的了解是最基本的，最最重要的还是我们怎么能把一个具体的事物转换成我们代码需要实现的抽象的事物，并且运用我们所知道的所有东西，用最好的方式将它转化成代码，这整个过程是最值得我们深究的，我们需要有思路，需要哪个地方该用什么怎么实现等等，我觉得这可能是我（也可能是和我有同感的程序员）认为最最重要的东西了







