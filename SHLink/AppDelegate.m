//
//  AppDelegate.m
//  SHLink
//
//  Created by 钱凯 on 15/1/20.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"
#import "DialogUtil.h"
#import "SHRouter.h"
#import "UpdateOSViewController.h"
#import "SHSetupTabBarController.h"
#import "MessageUtil.h"
@interface AppDelegate ()

@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [UINavigationBar appearance].translucent = NO;
    //设置导航栏背景
    [[UINavigationBar appearance] setBackgroundImage:[self genBarBackgroundImage] forBarMetrics:UIBarMetricsDefault];
    //[[UINavigationBar appearance]setBackgroundImage:[UIImage imageNamed:@"navigator_bar"] forBarMetrics:UIBarMetricsDefault];
    //设置状态栏样式，颜色为白色，需要在info.plist文件中添加一个键值对View controller-based status bar appearance = NO,意思是禁止控制器控制状态栏，交给application管理
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //设置导航栏标题文字属性
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:20.0]}];
    //设置导航栏上返回项的文字颜色
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    DLog(@"程序将要失去焦点");
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    DLog(@"程序将要进入后台");
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    DLog(@"程序将要进入前台");
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    DLog(@"程序已经获取焦点");
}
- (void)applicationWillTerminate:(UIApplication *)application {
    DLog(@"程序将要终止");
}
//创建导航条背景
- (UIImage *)genBarBackgroundImage {
    static dispatch_once_t onceToken;
    static UIImage *image;
    //单例
    dispatch_once(&onceToken,^{
        CGFloat imageWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat imageHeight = 1;
        size_t bytesPerRow = 4 * imageWidth;
        CGContextRef ctx = NULL;
        // 创建色彩空间对象
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        //创建一个位图上下文
        ctx = CGBitmapContextCreate(NULL, imageWidth, imageHeight, 8, bytesPerRow, colorSpace, (CGBitmapInfo) kCGImageAlphaPremultipliedLast);
        CGFloat gradLocations[2] = {0.0f, 1.0f};
        CGFloat gradColors[8] = {
            136.0/255.0f,216.0/255.0f,63.0/255.0f,1.0f,100.0/255.0f,180.0/255.0f,70.0/255.0f,1.0f};
        //创建渐变
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradColors, gradLocations,  kCGImageAlphaPremultipliedLast);
        CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, imageHeight/2.0), CGPointMake(imageWidth, imageHeight/2.0), kCGGradientDrawsAfterEndLocation);
        //创建一个位图
        CGImageRef cgImage = CGBitmapContextCreateImage(ctx);
        image = [UIImage imageWithCGImage:cgImage];
        //释放资源
        CGColorSpaceRelease(colorSpace);
        CGContextRelease(ctx);
        CGImageRelease(cgImage);
    });
    return image;
}


@end
