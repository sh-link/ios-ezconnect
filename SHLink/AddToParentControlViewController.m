//
//  AddToParentControlViewController.m
//  SHLink
//
//  Created by zhen yang on 15/5/21.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "AddToParentControlViewController.h"
#import "FaildView.h"
#import "EmptyView.h"
#import "ScreenUtil.h"
#import "AddDeviceCellTableViewCell.h"
#import "UIView+Extension.h"
#import "SHRouter.h"
#import "MJExtension.h"
#import "MessageUtil.h"
#import "MJRefresh.h"
#import "MBProgressHUD+MJ.h"
#import "SHRectangleButton.h"
#import "ParentControlDevListViewController.h"
#define padding 10
@interface AddToParentControlViewController ()<UITableViewDataSource, UITableViewDelegate>

@end
@implementation AddToParentControlViewController
{
    //是否全选
    BOOL isSelectAll;
    UIView *_container;
    UITableView *_tableView;
    EmptyView *_emptyView;
    FaildView *_failedView;
    CGFloat screenWidth;
    CGFloat screenHeight;
    UIButton *_add;
    
    //数据
    NSMutableArray *_clientDics;
    NSMutableArray *_clientModels;
    NSMutableArray *_clientFrames;
    
    UIBarButtonItem *rightButton;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat height = 44;
    isSelectAll = false;
    
    screenWidth = [ScreenUtil getWidth];
    screenHeight = [ScreenUtil getHeight];
    
    self.title = @"添加设备";
    rightButton = [[UIBarButtonItem alloc]initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAll)];
    
    _container = [[UIView alloc]init];
    _container.frame = CGRectMake(0, 0, screenWidth, screenHeight - 64);
    [self.view addSubview:_container];
    
    _tableView = [[UITableView alloc]init];
    [_container addSubview:_tableView];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.frame = CGRectMake(0, 0, screenWidth, _container.height - (height + 5) - padding);
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    _emptyView = [EmptyView getEmptyView:@"没有可添加的设备"];
    _emptyView.hidden = true;
    [self.view addSubview:_emptyView];
    
    _add = [[SHRectangleButton alloc]init];

    [_add setImage:[UIImage imageNamed:@"add_pc"] forState:UIControlStateNormal];
    [_add setTitle:@"添加" forState:UIControlStateNormal];
    UIEdgeInsets imgInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    UIEdgeInsets titleInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [_add setImageEdgeInsets:imgInsets];
    [_add setTitleEdgeInsets:titleInsets];

    [_add addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
    _add.hidden = true;
    [_container addSubview:_add];
    
    CGFloat y = _container.height - padding - (height + 5);
    CGFloat width = height * (160.0f / 70.0f);
    CGFloat x = (screenWidth - width) / 2.0f;
    _add.frame = CGRectMake(x, y, width, height);
    
    _failedView = [[FaildView alloc]init];
    [_failedView setMessage:@"查询设备列表失败"];
    _failedView.hidden = true;
    [self.view addSubview:_failedView];
    
    
    _clientDics = [NSMutableArray array];
    _clientFrames = [NSMutableArray array];
    _clientModels = [NSMutableArray array];
    
    __block AddToParentControlViewController *tmp = self;
    //添加刷新
    [_tableView addLegendHeaderWithRefreshingBlock:^{
        //
        [tmp getAllDevices];
    }];
    
    [_emptyView addLegendHeaderWithRefreshingBlock:^{
        //
        [tmp getAllDevices];
    }];
    
    [_failedView addLegendHeaderWithRefreshingBlock:^{
        //
        [tmp getAllDevices];
    }];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddDeviceCellTableViewCell *cell = [AddDeviceCellTableViewCell cellWithTableView:tableView];
    cell.cellFrame = _clientFrames[indexPath.row];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _clientModels.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddDeviceFrame *frame = _clientFrames[indexPath.row];
    
    return frame.cellHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    AddDeviceCellTableViewCell *cell = (AddDeviceCellTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell.checkBox sendActionsForControlEvents:UIControlEventTouchUpInside];
    DeviceInfo *device = _clientModels[indexPath.row];
    if(device.checked == 0)
    {
        device.checked = 1;
    }
    else
    {
        device.checked = 0;
    }
}
-(void)selectAll
{
    isSelectAll = !isSelectAll;
    if(isSelectAll)
    {
        rightButton.title = @"全不选";
    }
    else
    {
        rightButton.title = @"全选";
    }
    for(DeviceInfo *device in _clientModels)
    {
        if(isSelectAll)
        {
            device.checked = 1;
        }
        else
        {
            device.checked = 0;
        }
    }
    [_tableView reloadData];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_tableView.header beginRefreshing];
}
//获取所有设备
-(void)getAllDevices
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //
        NSError *error = nil;
        _clientDics = [[SHRouter currentRouter]getAllClient:&error];
        if(error)
        {
            //出错了
            [self performSelectorOnMainThread:@selector(showErrorView) withObject:nil waitUntilDone:true];
        }
        else
        {
            //成功响应
            DLog(@"%@", _clientDics);
            [_clientModels removeAllObjects];
            [_clientModels addObjectsFromArray:[DeviceInfo objectArrayWithKeyValuesArray:_clientDics]];
            //去除重复
            _clientModels = [self deleteRepeatEleFrom:_clientModels];
            
            //过滤掉已经处于父母控制列表中的
            DeviceInfo *device;
            
            for(int i = _clientModels.count - 1; i >= 0; i--)
            {
                device = _clientModels[i];
                
                //去除自己
                if([device.MAC isEqualToString:[SHRouter currentRouter].selfMac])
                {
                    [_clientModels removeObjectAtIndex:i];
                }
                
            }
            for(int i = _clientModels.count - 1; i >= 0; i--)
            {
                device = _clientModels[i];
                //去除已经在控制列表中的设备
               if(device.P_CONT == 1)
               {
                   
                   [_clientModels removeObjectAtIndex:i];
               }
            }
            _clientFrames = [self framesWithDeviceInfo:_clientModels];
            if(_clientModels.count == 0)
            {
                [self performSelectorOnMainThread:@selector(showEmptyView) withObject:nil waitUntilDone:true];
            }
            else
            {
                [self performSelectorOnMainThread:@selector(showTableView) withObject:nil waitUntilDone:true];
            }
        }
    });
}


-(NSMutableArray*)framesWithDeviceInfo:(NSMutableArray*)deviceInfos
{
    NSMutableArray *frames = [NSMutableArray array];
    for(DeviceInfo* info in deviceInfos)
    {
        AddDeviceFrame *frame = [[AddDeviceFrame alloc]init];
        frame.deviceInfo = info;
        [frames addObject:frame];
    }
    return  frames;
}

-(void)showTableView
{
    [_tableView.header endRefreshing];
    _container.hidden = false;
    _emptyView.hidden = true;
    _failedView.hidden = true;
    _add.hidden = false;
    [_tableView reloadData];
    self.navigationItem.rightBarButtonItem = rightButton;
    
}

-(void)showEmptyView
{
    [_emptyView.header endRefreshing];
    _container.hidden = true;
    _emptyView.hidden = false;
    _failedView.hidden = true;
    _add.hidden = true;
    self.navigationItem.rightBarButtonItem = nil;
}

-(void)showErrorView
{
    [_failedView.header endRefreshing];
    _container.hidden = true;
    _failedView.hidden = false;
    _emptyView.hidden = true;
    self.navigationItem.rightBarButtonItem = nil;
}

-(void)add
{
    //获取待添加的设备
    NSMutableArray *addClients = [NSMutableArray array];
    for(DeviceInfo *device in _clientModels)
    {
        if(device.checked == 1)
        {
            [addClients addObject:device];
        }
    }
    
    if(addClients.count == 0)
    {
        [MBProgressHUD showError:@"请至少选择一个要添加的设备"];
        return;
    }
    
    //添加到父母控制列表中
    [MBProgressHUD showMessage:@"正在请求添加设备"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error;
        BOOL result = [[SHRouter currentRouter]addCLients:addClients error:&error];
        if(result)
        {
            //添加成功
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUD];
                [MBProgressHUD showSuccess:@"添加成功"];
                [self.navigationController popViewControllerAnimated:true];
                ParentControlDevListViewController *controller = [self.navigationController.viewControllers lastObject];
                controller.isNeedRefresh = true;
            });
        }
        else
        {
            //添加失败
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:@"添加失败"];
            });
        }
    });
}

-(NSMutableArray*)deleteRepeatEleFrom:(NSMutableArray*)array
{
    NSMutableArray *newArray = [NSMutableArray array];
    for(DeviceInfo *device in array)
    {
        if(![newArray containsObject:device])
        {
            [newArray addObject:device];
        }
    }
    return newArray;
}
@end
