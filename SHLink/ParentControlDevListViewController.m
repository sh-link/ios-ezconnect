//
//  ParentControlDevListViewController.m
//  SHLink
//
//  Created by zhen yang on 15/5/18.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "ParentControlDevListViewController.h"
#import "ScreenUtil.h"
#import "FaildView.h"
#import "SHRouter.h"
#import "MJExtension.h"
#import "DeviceInfo.h"
#import "ParentControlDevListCell.h"
#import "MessageUtil.h"
#import "EmptyView.h"
#import "MJRefresh.h"
#import "DeviceInfo.h"
#import "MBProgressHUD+MJ.h"
#import "SHRectangleButton.h"
#define padding 10
@interface ParentControlDevListViewController ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    UITableView *_tableView;
    FaildView *_errorView;
    NSMutableArray *_clientList;
    NSMutableArray *_clients_info;
    NSMutableArray *_cleintListFrame;
    NSInteger currentRow;
    UILongPressGestureRecognizer *longPressReger;
    BOOL isShowCheckBox;
    UIBarButtonItem *leftButtonItem;
    UIBarButtonItem *rightButtonItem;
    BOOL isSelectAll;
    UIView *_deleteView;
    UIButton *_deleteButton;
    EmptyView *_emptyView;
    UIView *_container;
    
    SHRectangleButton *query;
    SHRectangleButton *add;
    
    int deleteIndex;
}
@end

@implementation ParentControlDevListViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    _isNeedRefresh = true;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]init];
    self.navigationItem.backBarButtonItem.title = @"返回";
    isShowCheckBox = false;
    isSelectAll = false;
    self.title = @"家长控制列表";
    
    leftButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAll)];
    rightButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"多选" style:UIBarButtonItemStylePlain target:self action:@selector(multipleSelect)];
    //创建数组
    _clientList = [NSMutableArray array];
    _clients_info = [NSMutableArray array];
    _cleintListFrame = [NSMutableArray array];
    
    //创建view
    _container = [[UIView alloc]init];
    [self.view addSubview:_container];
    _container.frame = CGRectMake(0, 0, [ScreenUtil getWidth], [ScreenUtil getHeight] - 64);
    _tableView = [[UITableView alloc]init];
    _tableView.frame = CGRectMake(0, 0, [ScreenUtil getWidth], [ScreenUtil getHeight] - 64 - 44 - padding);
    [_container addSubview:_tableView];
    
    
    query = [[SHRectangleButton alloc]init];
    add = [[SHRectangleButton alloc]init];
    [_container addSubview:query];
    [_container addSubview:add];
    
    CGFloat height = 44;
    CGFloat width = ([ScreenUtil getWidth] - 3 *padding) / 2.0f;
    CGFloat x = padding;
    CGFloat y = [ScreenUtil getHeight] - 64 - height - padding;
    query.frame = CGRectMake(x, y, width, height);
    add.frame = CGRectMake(CGRectGetMaxX(query.frame) + padding, y, width, height);
    [add setTitle:@"添加设备" forState:UIControlStateNormal];
    [query setTitle:@"查看时间设置" forState:UIControlStateNormal];

    _emptyView = [EmptyView getEmptyView:@"没有被家长控制的设备"];
    _emptyView.frame = _tableView.frame;
    _emptyView.hidden = true;
    
    [_container addSubview:_emptyView];

    _deleteView = [[UIView alloc]init];
    [_container addSubview:_deleteView];
    
    _deleteView.frame = CGRectMake(0, [ScreenUtil getHeight] - 1*64, [ScreenUtil getWidth], 64);
    //_deleteView.backgroundColor = getColor(136, 216, 63, 255);
    _deleteView.backgroundColor = getColor(255, 255, 255, 255);
    _deleteButton = [[SHRectangleButton alloc]init];
    [_deleteView addSubview:_deleteButton];
    [_deleteButton setImage:[UIImage imageNamed:@"delete_pc"] forState:UIControlStateNormal];
    [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    UIEdgeInsets imgInsets = UIEdgeInsetsMake(0, 0, 0, 5);
    UIEdgeInsets titleInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    [_deleteButton setImageEdgeInsets:imgInsets];
    [_deleteButton setTitleEdgeInsets:titleInsets];
    [_deleteButton setBackgroundColor:[UIColor greenColor]];
    
    
    height = 64 - 20;
    width = height * (160.0f / 70.0f);
    x = ([ScreenUtil getWidth] - width)/ 2.0f;
    y = padding;
    _deleteButton.frame = CGRectMake(x, y, width, height);
    
    
    _errorView = [[FaildView alloc]init];
    [_errorView setMessage:@"网络故障，查询失败"];
    _errorView.hidden = true;
    [self.view addSubview:_errorView];
    
    //下拉刷新
    __block ParentControlDevListViewController *tmp = self;
    [_tableView addLegendHeaderWithRefreshingBlock:^{
        [tmp getDevicesInParentControl];
    }];
    
    [_errorView addLegendHeaderWithRefreshingBlock:^{
        [tmp getDevicesInParentControl];
    }];
    [_emptyView addLegendHeaderWithRefreshingBlock:^{
        [tmp getDevicesInParentControl];
    }];

    [_deleteButton addTarget:self action:@selector(delete) forControlEvents:UIControlEventTouchUpInside];
    [add addTarget:self action:@selector(addClicked) forControlEvents:UIControlEventTouchUpInside];
    [query addTarget:self action:@selector(queryClicked) forControlEvents:UIControlEventTouchUpInside];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    _isNeedRefresh = false;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(_isNeedRefresh)
    {
        [_tableView.header beginRefreshing];
    }
}
-(void)getDevicesInParentControl
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //
        NSError *error;
        _clientList = [[SHRouter currentRouter] getDevicesInParentControl:&error];
        [_clients_info removeAllObjects];
        [_clients_info addObjectsFromArray:[DeviceInfo objectArrayWithKeyValuesArray:_clientList]];
        _cleintListFrame = [self framesWithDeviceInfo:_clients_info];
        if(!error)
        {
            if(_clients_info.count == 0)
            {
                [self performSelectorOnMainThread:@selector(showEmptyView) withObject:nil waitUntilDone:YES];
            }
            else
            {
                [self performSelectorOnMainThread:@selector(showTableView) withObject:nil waitUntilDone:YES];
            }
        }
        else
        {
            [self performSelectorOnMainThread:@selector(showErrorView) withObject:nil waitUntilDone:YES];
        }
    });
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DLog(@"numberofRows");
    return _clients_info.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"cellForRow");
    ParentControlDevListCell *cell = [ParentControlDevListCell cellWithTableView:tableView showCheckBox:isShowCheckBox];
    cell.cellFrame = _cleintListFrame[indexPath.row];
    return cell;
}

-(NSMutableArray*)framesWithDeviceInfo:(NSMutableArray*)deviceInfos
{
    NSMutableArray *frames = [NSMutableArray array];
    for(DeviceInfo* info in deviceInfos)
    {
        ParentControlCellFrame *frame = [[ParentControlCellFrame alloc]init];
        frame.deviceInfo = info;
        [frames addObject:frame];
    }
    return  frames;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ParentControlCellFrame* frame =  _cleintListFrame[indexPath.row];
    return frame.cellHeight;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ParentControlDevListCell *cell = (ParentControlDevListCell *)[tableView cellForRowAtIndexPath:indexPath];
    [_tableView deselectRowAtIndexPath:indexPath animated:true];
    if(isShowCheckBox)
    {
        DeviceInfo *info = _clients_info[indexPath.row];
        if(info.checked == 0)
        {
            info.checked = 1;
        }
        else
        {
            info.checked = 0;
        }
        [cell.checkBox sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        //删除当前设备
        //显示对话框
        deleteIndex = indexPath.row;
        //[MessageUtil showShortToast:[NSString stringWithFormat:@"%d", deleteIndex]];
        DeviceInfo *device = _clients_info[indexPath.row];
        NSString* message = [NSString stringWithFormat:@"您确定将该设备(%@)从家长控制列表里删除里吗", device.MAC];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"解除家长控制" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}

-(void)multipleSelect
{
    leftButtonItem.title = @"全选";
    isSelectAll = false;
    isShowCheckBox = !isShowCheckBox;
    for(DeviceInfo *info in _clients_info)
    {
        info.checked = 0;
    }
    if(isShowCheckBox)
    {
        self.navigationItem.rightBarButtonItem.title = @"取消";
        self.title = @"选择设备";
        [self.navigationItem setHidesBackButton:true animated:true];
        [self.navigationItem setLeftBarButtonItem:leftButtonItem animated:true];
        [UIView beginAnimations:@"animation" context:nil];
        [UIView setAnimationDuration:0.3f];
        _deleteView.frame = CGRectMake(0, [ScreenUtil getHeight] - 2 * 64, [ScreenUtil getWidth], 64);
        [UIView commitAnimations];
    }
    else
    {
        self.navigationItem.rightBarButtonItem.title = @"多选";
        self.title = @"家长控制";
        [self.navigationItem setHidesBackButton:false animated:true];
        [self.navigationItem setLeftBarButtonItem:nil animated:true];
       
        [UIView beginAnimations:@"animation" context:nil];
        [UIView setAnimationDuration:0.3f];
        _deleteView.frame = CGRectMake(0, [ScreenUtil getHeight] - 1* 64, [ScreenUtil getWidth], 64);
        [UIView commitAnimations];
    }
    
    if(_clients_info.count == 0)
    {
        [self showEmptyView];
    }
    else
    {
        [self showTableView];
    }

}
-(void)selectAll
{
    isSelectAll = !isSelectAll;
    if(isSelectAll)
    {
        for(DeviceInfo *info in _clients_info)
        {
            info.checked = 1;
        }
        leftButtonItem.title = @"全不选";
    }
    else
    {
        for(DeviceInfo *info in _clients_info)
        {
            info.checked = 0;
        }
        leftButtonItem.title = @"全选";
    }
    [_tableView reloadData];
}

-(void)showTableView
{
    [_tableView.header endRefreshing];
    _container.hidden = false;
    [_tableView reloadData];
    _tableView.hidden = false;
    _errorView.hidden = true;
    _emptyView.hidden = true;
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

-(void)showErrorView
{
    [_errorView.header endRefreshing];
    _emptyView.hidden = true;
    _container.hidden = true;
    _errorView.hidden = false;
    self.navigationItem.rightBarButtonItem = nil;
}

-(void)showEmptyView
{
    [_emptyView.header endRefreshing];
    _container.hidden = false;
    _emptyView.hidden = false;
    _tableView.hidden = true;
    _errorView.hidden = true;
    self.navigationItem.rightBarButtonItem = nil;
}

-(void)delete
{
    //找出被选中，需要删除的设备
    __block NSMutableArray *deleteClients = [NSMutableArray array];
    for(DeviceInfo *info in _clients_info)
    {
        if(info.checked == 1)
        {
            [deleteClients addObject:info];
        }
    }
    if(deleteClients.count == 0)
    {
        [MessageUtil showShortToast:@"请至少选中一个需要删除的设备"];
        return;
    }
    
    [MBProgressHUD showMessage:@"正在请求解除家长控制"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error;
        BOOL result = [[SHRouter currentRouter]deleteClients:deleteClients error:&error];
        if(result)
        {
            //成功删除
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //隐藏对话框并提示
                [MBProgressHUD hideHUD];
                [MBProgressHUD showSuccess:@"成功解除家长控制"];
                
                for(DeviceInfo *info in deleteClients)
                {
                    [_clients_info removeObject:info];
                }
                _cleintListFrame = [self framesWithDeviceInfo:_clients_info];
                [self multipleSelect];
            });
        }
        else
        {
            //删除失败
            //隐藏对话框并提示
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:@"解除家长控制失败"];
            });        }
    });
}

-(void)queryClicked
{
    [self performSegueWithIdentifier:@"parentControl2parentControlDetail" sender:nil];
}

-(void)addClicked
{
    [self performSegueWithIdentifier:@"parentControl2addDevice" sender:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        [MBProgressHUD showMessage:@"正在请求解除家长控制"];
        //删除设备
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSError *error;
            DeviceInfo *device = _clients_info[deleteIndex];
            BOOL result = [[SHRouter currentRouter]deleteClientFromParentControl:device.MAC name:device.NAME error:&error];
            if(result)
            {
                //删除成功
                [_clients_info removeObjectAtIndex:deleteIndex];
                //更新frame
                _cleintListFrame = [self framesWithDeviceInfo:_clients_info];
                //隐藏对话框并提示
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUD];
                    [MBProgressHUD showSuccess:@"成功解除家长控制"];
                });
                if(_clients_info.count == 0)
                {
                    [self performSelectorOnMainThread:@selector(showEmptyView) withObject:nil waitUntilDone:true];
                }
                else
                {
                    [self performSelectorOnMainThread:@selector(showTableView) withObject:nil waitUntilDone:true];
                }
            }
            else
            {
                //删除失败
                //隐藏对话框并提示
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUD];
                    [MBProgressHUD showError:@"解除家长控制失败"];
                });
            }
        });
    }
}

@end
