//
//  WifiSpeedMeasureViewController.m
//  SHLink
//
//  Created by zhen yang on 15/3/25.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "WifiSpeedMeasureViewController.h"
#import "SHRectangleButton.h"
#import "CircleView.h"
#define margin 10
#define DURATION 0.5

#define DOWNLOAD_URL @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V4.0.1.dmg"

@interface WifiSpeedMeasureViewController () <NSURLConnectionDataDelegate>
@end

@implementation WifiSpeedMeasureViewController
{
    UIImageView *panel;
    UIImageView *pointer;
    UILabel *speedText;
    SHRectangleButton *measureSpeed;
    UILabel *message;
    CircleView *circleView;
    
    NSURLConnection* conn;
    
    
    //是否正在测速
    BOOL isSpeedMeasuring;
    //初始角度
    float initialAngle;
    //下载的总字节
    long totalBytes;
    //下载的总时间
    UInt64 totalMills;
    //测速开始时间
    UInt64 startTime;
    UInt64 currentTime;
    UInt64 lastTime;
    //记录临时下载的时间
    UInt64 totalMillsTemp;
    //实时速度
    int currentSpeed;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //导航标题
    self.title = @"宽带测速";
    [self initField];
    [self initView];
}

//当发生错误时，会触发该方法
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self didForMeasureOver];
}
//当服用器响应数据时激发该方法
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //正在测速
    isSpeedMeasuring = true;
    //显示正在测速，并移除action
    [measureSpeed setTitle:@"正在测速" forState:UIControlStateNormal];
    [measureSpeed removeTarget:self action:@selector(measureSpeed) forControlEvents:UIControlEventTouchUpInside];

   
}
//每次读取服务器响应的数据时，都会激发该方法，这个方法会被多次调用
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    totalBytes = totalBytes + data.length;
    //记录该方法调用时的时间
    currentTime = [[NSDate date] timeIntervalSince1970]*1000;
    //计算从开始下载到此已经下载的总时间
    totalMills = currentTime - startTime;
    //计算从上一次500ms的整数倍时间到现在的时间间隔
    totalMillsTemp = totalMillsTemp + (currentTime - lastTime);
    //如果已经超过500ms没有转动指针，转动指针
    if(totalMillsTemp > 500)
    {
        // 重新计算
        totalMillsTemp = totalMillsTemp % 500;
        //计算当前速度
        currentSpeed = totalBytes / 1024.0 / totalMills * 1000;
        //转动指针
        [self rotateWithAnimation:[self getRoatateAngle:currentSpeed]];
        
        speedText.text = [NSString stringWithFormat:@"%d", currentSpeed];
        //处理外面的圆环
        [circleView setAngle:[self getRoatateAngle:currentSpeed]];
    }
    if(totalMills > 15000)
    {
        //最多测10s
        [connection cancel];
        [self didForMeasureOver];
    }
    lastTime = currentTime;
}
//数据加载完后调用该方法
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    isSpeedMeasuring = false;
    [measureSpeed setTitle:@"点击测速" forState:UIControlStateNormal];
    [measureSpeed removeTarget:self action:@selector(measureSpeed) forControlEvents:UIControlEventTouchUpInside];
    [self didForMeasureOver];
}
 //初始化成员变量
-(void)initField
{
    //是否正在测速
    isSpeedMeasuring = false;
    //初始角度
    initialAngle = -144;
    //下载的总字节
    totalBytes = 0;
    //下载的总时间
    totalMills = 0;
    //测速开始时间
    startTime = 0;
    currentTime = 0;
    lastTime = 0;
    //记录临时下载的时间
    totalMillsTemp = 0;
    //实时速度
    currentSpeed = 0;
}

-(void)initView
{
    CGFloat padding = self.view.frame.size.width / 8.0;
    CGFloat panelWidth = self.view.frame.size.width - 2* padding;
    int panelX = padding;
    int panelY =  self.view.frame.size.height / 25.0;
    
    //边上的圆圈
    circleView = [[CircleView alloc]init];
    circleView.frame = CGRectMake(panelX - 6, panelY - 6, panelWidth + 12, panelWidth + 12);
    circleView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:circleView];
    //速度盘
    panel = [[UIImageView alloc]init];
    panel.frame = CGRectMake(panelX,  panelY, panelWidth  , panelWidth);
    [panel setImage:[UIImage imageNamed:@"panel"]];
    [self.view addSubview:panel];
    //指针
    pointer = [[UIImageView alloc]init];
    pointer.center = panel.center;
    pointer.bounds = CGRectMake(0, 0, 12, panel.frame.size.height);
    [pointer setImage:[UIImage imageNamed:@"pointer"]];
    [self.view addSubview:pointer];
    
    //显示速度
    speedText =[[UILabel alloc]init];
    speedText.textAlignment = NSTextAlignmentCenter;
    speedText.frame = CGRectMake(0, CGRectGetMaxY(panel.frame) - 15, self.view.frame.size.width, 15);
    speedText.text = @"0";
    [self.view addSubview:speedText];
    
    //kb/s
    UILabel *unit = [[UILabel alloc]init];
    unit.textAlignment = NSTextAlignmentCenter;
    unit.text = @"KB/s";
    unit.frame = CGRectMake(0, CGRectGetMaxY(speedText.frame) + margin,  self.view.frame.size.width, 15);
    [self.view addSubview:unit];
    
    //提示信息
    message = [[UILabel alloc]init];
    message.textAlignment = NSTextAlignmentCenter;
    message.text = @"";
    message.frame = CGRectMake(0, CGRectGetMaxY(unit.frame) + margin, self.view.frame.size.width, 15);
    message.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:message];
    
    measureSpeed = [[SHRectangleButton alloc]init];
    [measureSpeed setTitle:@"正在测速" forState:UIControlStateNormal];
    measureSpeed.frame = CGRectMake(self.view.frame.size.width / 8.0, CGRectGetMaxY(message.frame) + 3*margin, self.view.frame.size.width / 4.0 * 3, 40);
    [self.view addSubview:measureSpeed];
    //让指针转到指定角度
    pointer.transform = CGAffineTransformMakeRotation(-(144/180.0)*M_PI);
}


-(void)measureSpeed
{
    [self initField];
    message.text = @"";
    //正在测速
    isSpeedMeasuring = true;
    //显示正在测速，并移除action
    [measureSpeed setTitle:@"正在测速" forState:UIControlStateNormal];
    [measureSpeed removeTarget:self action:@selector(measureSpeed) forControlEvents:UIControlEventTouchUpInside];
    //以指定的NSString创建url对象
    NSURL *url = [NSURL URLWithString:DOWNLOAD_URL];
    //创建NSURLRequest对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    conn = [NSURLConnection connectionWithRequest:request delegate:self];
    
    if(conn == nil)
    {
        [self didForMeasureOver];
    }
    else
    {
        lastTime  = startTime = [[NSDate date]timeIntervalSince1970] * 1000;
    }
}


-(void)viewDidAppear:(BOOL)animated
{
    if(isSpeedMeasuring)
    {
        [measureSpeed setTitle:@"正在测速" forState:UIControlStateNormal];
        [measureSpeed removeTarget:self action:@selector(measureSpeed) forControlEvents:UIControlEventTouchUpInside];
    }
    else{
        [measureSpeed setTitle:@"点击测速" forState:UIControlStateNormal];
        [measureSpeed addTarget:self action:@selector(measureSpeed) forControlEvents:UIControlEventTouchUpInside];
    }
}

//转到指定角度处
-(void)rotateWithAnimation:(float)toAngle
{
    CABasicAnimation *baseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //开始值
    baseAnimation.fromValue = [NSNumber numberWithFloat: initialAngle/180*M_PI];
    baseAnimation.toValue = [NSNumber numberWithFloat:toAngle/180*M_PI];
    //根据转动的角度计算动画需要执行的时间
        float diffAngle = toAngle - initialAngle;
        double time = fabs(diffAngle)/288 * DURATION;
    baseAnimation.duration = time;
    baseAnimation.autoreverses = NO;
    //下面两句不可缺，保证动画可以维护在最终状态
    baseAnimation.fillMode = kCAFillModeForwards;
    baseAnimation.removedOnCompletion = NO;
    [pointer.layer addAnimation:baseAnimation forKey:@"point_rotate"];
    initialAngle = toAngle;
}

//根据速度计算指针所在角度
-(float)getRoatateAngle:(int) speed
{
    if(speed <= 128)
    {
        return speed/128.0*72 - 144;
    }
    if(speed <= 256)
    {
        return 72 + (speed - 128) / 128.0 * 36 - 144;
    }
    
    if (speed <= 512) {
        return 108 + (speed - 256) / 256.0 * 36 - 144;
    }
    
    if (speed <= 1024) {
        return 144 + (speed - 512) / 512.0 * 36 - 144;
    }
    
    if (speed <= 1024 * 5) {
        return 180 + (speed - 1024) / (1024 * 4.0) * 36 - 144;
    }
    if (speed <= 1024 * 10) {
        return 216 + (speed - 1024 * 5) / (1024 * 5.0) * 36 - 144;
    } else {
        return 252 + (speed - 1024 * 10) / (1024 * 100.0) * 36 - 144;
    }
}

//测速结束
-(void)didForMeasureOver
{
    isSpeedMeasuring = false;
    [measureSpeed setTitle:@"点击测速" forState:UIControlStateNormal];
    [measureSpeed addTarget:self action:@selector(measureSpeed) forControlEvents:UIControlEventTouchUpInside];
    NSString *speedStr = nil;
    if(currentSpeed == 0)
    {
        speedStr = @"无法上网，请检查网络";
    }
    else{
        speedStr = [NSString stringWithFormat:@"您当前的网速相当于%dM宽带%@", currentSpeed * 8 / 1000 + 1,[self changeSpeedToString:currentSpeed * 8 / 1000 + 1]];
    }
    message.text = speedStr;
}

-(void)stopMeasure
{
    if(conn != nil)
    {
        [conn cancel];
        [self didForMeasureOver];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self stopMeasure];
}

-(NSString*)changeSpeedToString:(int)speed
{
    if(speed == 1)
    {
        return  @",适全上网";
    }
    else if(speed < 4)
    {
        return @",可以流畅观看标清电影";
    }
    else if(speed == 4)
    {
        return @",可以流畅观看高清电影";
    }
    else if(speed > 4)
    {
        return @",可以流畅观看高清电影";
    }
    return @"";
}
@end
