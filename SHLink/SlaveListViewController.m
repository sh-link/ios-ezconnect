//
//  SlaveListViewController.m
//  SHLink
//
//  Created by zhen yang on 15/3/31.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "SlaveListViewController.h"
#import "SHRouter.h"
#import "SHProgressDialog.h"
#import "Utils.h"
#import "DeviceListTableViewController.h"
#import "AllDeviceHeader.h"
#import "SlaveListViewCellTableViewCell.h"
#import "FaildView.h"
#import "SearchView.h"
#import "MJRefresh.h"
#import "ScreenUtil.h"
#import "MBProgressHUD+MJ.h"
#import "MessageUtil.h"
#import "CellFrame.h"
#import "SlaveInfo.h"
#import "UIView+Extension.h"
@interface SlaveListViewController()  <UITableViewDataSource, UITableViewDelegate>

@end

@implementation SlaveListViewController
{
    //正常情况下显示table
    UITableView *table;
    //出错情况显示failedView;
    FaildView *faildView;

    NSMutableArray* routers;
    NSString* currentMac;
    CGFloat cellHeight;
    
    UIView *container;
    
    AllDeviceHeader *header;
    
    NSMutableArray *frameArray;
}

-(void)viewDidLoad
{
    self.title = @"路由器";
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]init];
    self.navigationItem.backBarButtonItem.title = @"返回";
    
    frameArray = [NSMutableArray new];
    
    [self initData];
    [self initView];
    
    [header addTarget:self action:@selector(getAllDevice) forControlEvents:UIControlEventTouchUpInside];
    
    //[MBProgressHUD showMessage:@"正在查询路由器列表"];
    [table.header beginRefreshing];

}



-(void)getAllDevice
{
    currentMac = @"FF-FF-FF-FF-FF-FF";
    [self performSegueWithIdentifier:@"slaveToClient"  sender:self];
}

-(void)refresh
{
    //清空
    [routers removeAllObjects];
    //获取slave列表
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error = nil;
        [[SHRouter currentRouter] getSlaveListWithError:&error];
        if(!error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                SlaveInfo *master = [[SlaveInfo alloc]init];
                master.mac = [SHRouter currentRouter].mac;
                NSMutableString *tmpMac = [NSMutableString stringWithString:master.mac];
                [tmpMac replaceOccurrencesOfString:@":" withString:@"-" options:NSLiteralSearch range:NSMakeRange(0, master.mac.length)];
                master.mac  = tmpMac;
                master.online = true;
                master.rx = -1;
                master.tx = -1;
                CellFrame *frame = [CellFrame new];
                frame.info = master;
                [frameArray addObject:frame];
                [routers addObject:master];
                if([SHRouter currentRouter].SlaveList == nil || [SHRouter currentRouter].SlaveList.count == 0)
                {
                    //隐藏头部
                    //[MessageUtil showLongToast:@"隐藏头部"];
                    table.frame = container.frame;
                    header.frame = CGRectZero;
                    header.hidden = true;
                }
                else
                {
                    //隐藏头部
                    table.frame = container.frame;
                    header.frame = CGRectZero;
                    header.hidden = true;

                    for(NSDictionary* macDic  in [SHRouter currentRouter].SlaveList)
                    {
                        SlaveInfo *slave = [[SlaveInfo alloc]init];
                        slave.mac = macDic[@"MAC"];
                        if(macDic[@"ONLINE"] != nil && ![macDic[@"ONLINE"] boolValue])
                        {
                            //不在线
                            slave.online = false;
                        }
                        else
                        {
                            //在线
                            slave.online = true;
                        }
                        NSNumber *rxNumber = macDic[@"RX"];
                        NSNumber *txNumber = macDic[@"TX"];
                        
                        if(rxNumber == nil)
                        {
                            slave.rx = -1;
                        }
                        else
                        {
                            slave.rx = [rxNumber intValue];
                        }
                        
                        if(txNumber == nil)
                        {
                            slave.tx = -1;
                        }
                        else
                        {
                            slave.tx = [txNumber intValue];
                        }
                        CellFrame *frame = [CellFrame new];
                        frame.info = slave;
                        [frameArray addObject:frame];
                        [routers addObject:slave];
                    }
                    
                    
                  
                    for(int i = 1; i < routers.count; i ++)
                    {
                        SlaveInfo *info = routers[i];
                        if(info.online)
                        {
                            //显示头部
                            //[MessageUtil showLongToast:@"显示头部"];
                            header.frame = CGRectMake(0, 0, [ScreenUtil getWidth], header.height);
                            header.hidden = false;
                            table.frame = CGRectMake(0, CGRectGetMaxY(header.frame), [ScreenUtil getWidth], [ScreenUtil getHeight] - CGRectGetMaxY(header.frame) - 64);
                   
                            DLog(@"container.frame = %@", NSStringFromCGRect(container.frame));
                            DLog(@"table.frame = %@", NSStringFromCGRect(table.frame));
                            DLog(@"header.frame = %@", NSStringFromCGRect(header.frame));
                          break;
                        }
                    }
                }
                
                [self performSelectorOnMainThread:@selector(showTable) withObject:nil waitUntilDone:YES];
            });
           
        }
        else
        {
            [self performSelectorOnMainThread:@selector(showFailedView) withObject:nil waitUntilDone:YES];
        }
        
        CGFloat time = 0.5;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
        });
        
    });
}



-(void)initView
{
    container = [[UIView alloc]init];
    container.frame = CGRectMake(0, 0, self.view.width, self.view.height);
    [self.view addSubview:container];
    table = [[UITableView alloc]init];
    table.separatorStyle = NO;
    table.frame = container.frame;
    header = [[AllDeviceHeader alloc]init];
   
    [container addSubview:header];
    [container addSubview:table];
    //container.hidden = true;
    
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = getColor(225, 225, 225, 225);
  
    //table.backgroundColor = [UIColor redColor];
    faildView = [[FaildView alloc]init];
    [faildView setMessage:@"网络故障，查询失败"];
    [self.view addSubview:faildView];

    table.hidden = false;
    faildView.hidden = true;

    
    __block SlaveListViewController *tmp = self;
    [table addLegendHeaderWithRefreshingBlock:^{
        [tmp refresh];
    }];
    
    [faildView addLegendHeaderWithRefreshingBlock:^{
        [tmp refresh];
    }];
}

-(void)initData
{
    routers = [[NSMutableArray alloc]init];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"cell for row ---------------------------");
    static NSString*  cellId = @"cellId";
    SlaveListViewCellTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if(cell == nil)
    {
        cell = [[SlaveListViewCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cellHeight = cell.height;
    }
    SlaveInfo *slaveInfo = routers[indexPath.row];
    [cell setContent:slaveInfo.mac];
    if(slaveInfo.online)
    {
        //在线
        [cell setImg:@"slave_router_icon_online"];
        cell.userInteractionEnabled = true;
        if((slaveInfo.rx != -1 &&slaveInfo.rx < 50) || (slaveInfo.tx != -1 && slaveInfo.tx < 50))
        {
            [cell setImg:@"slave_router_icon_red"];
        }
    }
    else
    {
        //不在线
        [cell setImg:@"slave_router_icon_offline"];
        cell.userInteractionEnabled = false;
    }
    [cell setCellFrame:frameArray[indexPath.row]];
    [cell setRX:slaveInfo.rx];
    [cell setTx:slaveInfo.tx];
    return  cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   
    return routers.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"height for row -----------------------------");
    CellFrame *frame = frameArray[indexPath.row];
    return frame.cellHeight;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    SlaveInfo *info = routers[indexPath.row];
    if(indexPath.row != 0)
    {
        currentMac = info.mac;
    }
    else{
        currentMac = nil;
    }
    [self performSegueWithIdentifier:@"slaveToClient"  sender:self];
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DeviceListTableViewController * target = segue.destinationViewController;
    [target setMac:currentMac];
}

-(void)showTable
{
    faildView.hidden = true;
    container.hidden= false;
    [table reloadData];
    [table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    [table.header endRefreshing];
}

-(void)showFailedView
{
    container.hidden = true;
    faildView.hidden = false;
    [faildView.header endRefreshing];
}



@end
