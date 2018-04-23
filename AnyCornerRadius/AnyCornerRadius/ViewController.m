//
//  ViewController.m
//  AnyCornerRadius
//
//  Created by Mr.GCY on 2018/4/23.
//  Copyright © 2018年 Mr.GCY. All rights reserved.
//

#import "ViewController.h"
#import "CYCustomArcImageView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
     [super viewDidLoad];
     CYCustomArcImageView * imageView = [[CYCustomArcImageView alloc] initWithFrame:CGRectMake(0, 0, 250, 400)];
     imageView.center = self.view.center;
     imageView.borderTopLeftRadius = 50;
     imageView.borderTopRightRadius = 20;
     imageView.borderBottomLeftRadius = 20;
     imageView.borderBottomRightRadius = 35;
     imageView.borderWidth = 3;
     imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"timg" ofType:@"jpeg"]];
     
     [self.view addSubview:imageView];
}
@end
