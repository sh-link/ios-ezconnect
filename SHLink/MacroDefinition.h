//
//  MacroDefinition.h
//  SHLink
//
//  Created by zhen yang on 15/7/10.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#ifndef SHLink_MacroDefinition_h
#define SHLink_MacroDefinition_h

//-------------获取设备大小---------------
//navBar高度
#define NavigationBar_HEIGHT 44
//获取屏幕宽度
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)


//-------------打印日志------------------
//DEBUG  模式下打印日志,当前行
#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DLog(...)
#endif


//------------系统---------------------
//获取系统版本
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define CurrentSystemVersion [[UIDevice currentDevice] systemVersion]

//获取当前语言
#define CurrentLanguage ([NSLocale preferredLanguages] objectAtIndex:0])

//检查系统版本
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


//-----------图片---------------------
#define LOADIMAGE(file, ext) [UIImage imageNamedWithContentsOfFile:[NSBundle mainBundle] pathForResource:file ofType:ext]
#define IMAGE(A) [UIImage imageWithContentOfFile:[[NSBundle mainBundle] pathForResource:A ofType:nil]


