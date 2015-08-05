//
//  TimeLineView.m
//  SHLink
//
//  Created by zhen yang on 15/3/26.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "TimeLineView.h"
#import "TimeViewPoint.h"
#define GET_ARRAY_LEN(array,len) {len = (sizeof(array) / sizeof(array[0]));}

@implementation TimeLineView
{
    //字体大小
    int _textSize;
    //亮线颜色
    UIColor *onColor;
    //暗线颜色
    UIColor *offColor;
    //时间点半径
    int radius;
    //最小的padding值
    int minPadding;
    //文字与线之间的间距
    int verticalSpace;
    //画笔宽度
    float onStrokeWidth;
    float offStrokeWidth;
    
    //文本宽高
    CGSize textRect;
    //文本size
    int textHeight;
    //记录时间点圆的横坐标，最多四个时间点
    int x1,x2,x3,x4;
    //文本的纵坐标
    int textY;
    //控件宽高
    int width;
    int height;
    
    
    //时间点数组
    NSMutableArray *points;
    //纵坐标
    int startY;
    
    //时间点
    NSArray *_times;
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setUp];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}
-(void)setUp
{
    _textSize = 12;
    points = [[NSMutableArray alloc]init];
    onColor = [self genColorWithRed:0x99 green:0xcc blue:0x4f alpha:255];
    offColor = [self genColorWithRed:0xcc green:0xcc blue:0xcc alpha:255];
    radius = 2;
    minPadding = 8;
    verticalSpace = 5;
    onStrokeWidth = 7;
    offStrokeWidth = 6;
    textHeight = [self sizeWithFont:@"00:00"].height;
    textRect = [self sizeWithFont:@"00:00"];
    
    self.backgroundColor = [UIColor clearColor];
    //测量文本高度
}

-(UIColor*)genColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}

-(void)drawRect:(CGRect)rect
{
    textY = minPadding;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    /*----------画暗线----start----------*/
    CGContextSetLineWidth(ctx, offStrokeWidth);
    CGContextSetRGBStrokeColor(ctx, 0xcc/255.0, 0xcc/255.0, 0xcc/255.0, 1);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    //确定起点x,y
    int startX = minPadding;
    startY = minPadding + textHeight+ minPadding;
    //确定终点x,y
    int endX = rect.size.width - minPadding;
    int endY = startY;
    const CGPoint offPoints[] = {CGPointMake(startX, startY), CGPointMake(endX, endY)};
    CGContextStrokeLineSegments(ctx, offPoints, 2);
    /*----------画暗线------end----------*/
    
    [self drawTimePoint:rect Context:ctx];
}

-(void)drawTimePoint:(CGRect)rect Context:(CGContextRef)ctx
{
  
    [self fillPoints:_times];
    for(TimeViewPoint *point in points)
    {
        //画亮点
        CGContextAddEllipseInRect(ctx, [point getRect]);
        [onColor set];
        CGContextDrawPath(ctx, kCGPathFillStroke);
        
        //画文本
        //重新计算起点，即横坐标
        int x = 0;
        if([point getAlign] == NSTextAlignmentCenter)
        {
            x = [point getPosition].x - textRect.width/2.0;
        }
        else if([point getAlign] == NSTextAlignmentLeft)
        {
            x = [point getPosition].x;
        }
        else{
            x = [point getPosition].x - textRect.width;
        }
        //设置文本颜色
        //CGContextSetRGBFillColor(ctx, 0.2, 0.2, 0.2, 1);
        //[onColor set];
        CGContextSetTextDrawingMode(ctx, kCGTextFill);
        [[self getTime:[point getTime]] drawAtPoint:CGPointMake(x, textY) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Arial Rounded MT Bold" size:_textSize], NSFontAttributeName, [UIColor grayColor], NSForegroundColorAttributeName,nil]];
        
     }
    
    
        //画时间线
        if(points.count == 2)
        {
            //将两个点连接起来
            CGContextSetLineWidth(ctx, onStrokeWidth);
            CGContextSetLineCap(ctx, kCGLineCapRound);
            //设置画笔颜色
            //CGContextSetRGBStrokeColor(ctx, 1, 0, 0, 1);
            [onColor set];
            CGPoint point1 = CGPointMake([points[0] getPosition].x, [points[0] getPosition].y);
            CGPoint point2 = CGPointMake([points[1] getPosition].x, [points[1] getPosition].y);
            
            const CGPoint _points[] = {point1, point2};
            CGContextStrokeLineSegments(ctx, _points, 2);
            
        }
        else
        {
            //将两个点连接起来
            CGContextSetLineWidth(ctx, onStrokeWidth);
            CGContextSetLineCap(ctx, kCGLineCapRound);
            //设置画笔颜色
            //CGContextSetRGBStrokeColor(ctx, 1, 0, 0, 1);
            [onColor set];
            CGPoint point1 = CGPointMake([points[0] getPosition].x, [points[0] getPosition].y);
            CGPoint point2 = CGPointMake([points[1] getPosition].x, [points[1] getPosition].y);
            CGPoint point3 = CGPointMake([points[2] getPosition].x, [points[2] getPosition].y);
            CGPoint point4 = CGPointMake([points[3] getPosition].x, [points[3] getPosition].y);
            
            const CGPoint _points[] = {point1, point2, point3, point4};
            CGContextStrokeLineSegments(ctx, _points, 4);
            
        }
}
-(void)fillPoints:(NSArray*)times
{
    NSNumber* time1;
    NSNumber* time2;
    NSNumber* time3;
    NSNumber* time4;
    [points removeAllObjects];
    if(times.count == 2)
    {
       
        time1 = _times[0];
        time2 = _times[1];
        TimeViewPoint *point1 = [[TimeViewPoint alloc]init];
        [point1 setTime:time1.intValue];
        
        if([point1 getTime] == 0)
        {
            [point1 setPosition:CGPointMake(minPadding, startY)];
        }
        else
        {
            [point1 setPosition:CGPointMake((self.frame.size.width - 2 * minPadding)/4.0 + minPadding, startY)];
        }
        
        TimeViewPoint *point2 = [[TimeViewPoint alloc]init];
        [point2 setTime:time2.intValue];
        if([point2 getTime] == 24*60)
        {
            [point2 setPosition:CGPointMake(self.frame.size.width - minPadding, startY)];
        }
        else{
            [point2 setPosition:CGPointMake((self.frame.size.width - 2 * minPadding)/4.0 * 3 + minPadding, startY)];
        }
       
        if([point1 getTime] == 0)
        {
            [point1 setAlign:NSTextAlignmentLeft];NSLog(@"it is here");
        }
        if([point2 getTime] == 24 * 60)
        {
            [point2 setAlign:NSTextAlignmentRight];
        }
        
        [point1 setPartner:point2];
        [point2 setPartner:point1];
        
        [points addObject:point1];
        [points addObject:point2];
        
    }
    
    else if(times.count == 3)
    {
        time1 = _times[0];
        time2 = _times[1];
        time3 = _times[2];
        TimeViewPoint *point1 = [[TimeViewPoint alloc]init];
        [point1 setTime:time1.intValue];
        if(time1.intValue == 0)
        {
            [point1 setPosition:CGPointMake(minPadding, startY)];
        }
        else
        {
            [point1 setPosition:CGPointMake((self.frame.size.width - 2*minPadding)/8.0 + minPadding, startY)];
        }
        
        
        TimeViewPoint *point2 = [[TimeViewPoint alloc]init];
        [point2 setTime:time2.intValue];
        [point2 setPosition:CGPointMake((self.frame.size.width - 2*minPadding)/8.0 *3 + minPadding, startY)];
        
        TimeViewPoint *point3 = [[TimeViewPoint alloc]init];
        [point3 setTime:time3.intValue];
        [point3 setPosition:CGPointMake((self.frame.size.width - 2*minPadding)/8.0 *5 + minPadding, startY)];
        
        TimeViewPoint *point4 = [[TimeViewPoint alloc]init];
        [point4 setTime:24 * 60];
        [point4 setPosition:CGPointMake((self.frame.size.width - 2*minPadding)/8.0 *8 + minPadding, startY)];
        
        [point1 setPartner:point2];
        [point2 setPartner:point1];
        
        [point3 setPartner:point4];
        [point4 setPartner:point3];
        
        if([point1 getTime] == 0)
        {
            [point1 setAlign:NSTextAlignmentLeft];
        }
        
        if ([point4 getTime] == 24 * 60) {
            [point4 setAlign:NSTextAlignmentRight];
        }
        
        [points addObject:point1];
        [points addObject:point2];
        [points addObject:point3];
        [points addObject:point4];
    }
    else if(times.count == 4)
    {
        time1 = _times[0];
        time2 = _times[1];
        time3 = _times[2];
        time4 = _times[3];
        TimeViewPoint *point1  = [[TimeViewPoint alloc]init];
        [point1 setTime:time1.intValue];
        if(time1.intValue != 0)
        {
            [point1 setPosition:CGPointMake((self.frame.size.width - 2*minPadding)/8.0 + minPadding, startY)];
        }
        else
        {
            [point1 setPosition:CGPointMake(minPadding, startY)];
        }
        TimeViewPoint *point2  = [[TimeViewPoint alloc]init];
        [point2 setTime:time2.intValue];
        [point2 setPosition:CGPointMake((self.frame.size.width - 2*minPadding)/8.0 * 3 + minPadding, startY)];
        
        TimeViewPoint *point3  = [[TimeViewPoint alloc]init];
        [point3 setTime:time3.intValue];
        [point3 setPosition:CGPointMake((self.frame.size.width - 2*minPadding)/8.0 * 5 + minPadding, startY)];
        
        TimeViewPoint *point4  = [[TimeViewPoint alloc]init];
        [point4 setTime:time4.intValue];
        [point4 setPosition:CGPointMake((self.frame.size.width - 2*minPadding)/8.0 * 7 + minPadding, startY)];
        
        [point1 setPartner:point2];
        [point2 setPartner:point1];
        
        [point3 setPartner:point4];
        [point4 setPartner:point3];
        
        if([point1 getTime] == 0)
        {
            [point1 setAlign:NSTextAlignmentLeft];
        }
        
        if ([point4 getTime] == 24 * 60) {
            [point4 setAlign:NSTextAlignmentRight];
        }
        
        [points addObject:point1];
        [points addObject:point2];
        [points addObject:point3];
        [points addObject:point4];
    }
    
    
    
}


-(CGSize)sizeWithFont:(NSString *)str
{
    NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:_textSize]};
    return [str boundingRectWithSize:self.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

-(void)setTimes:(NSArray *)times
{
    _times = times;
    
    [self setNeedsDisplay];
}

-(NSString*)getTime:(int)time
{
    int hour = time/60;
    int minutes = time%60;
    NSString* hourStr;
    NSString* minutesStr;
    if(hour < 10)
    {
        hourStr = [NSString stringWithFormat:@"0%d",hour];
    }
    else
    {
        hourStr = [NSString stringWithFormat:@"%d", hour];
    }
    
    if(minutes < 10)
    {
        minutesStr = [NSString stringWithFormat:@"0%d", minutes];
    }
    else
    {
        minutesStr = [NSString stringWithFormat:@"%d", minutes];
    }
    return [NSString stringWithFormat:@"%@:%@", hourStr, minutesStr];
   
}
-(int)getHeight
{
    return minPadding + textHeight + minPadding + onStrokeWidth + minPadding;
}
@end
