//
//  DeviceListTableViewController.m
//  SHLink
//
//  Created by zhen yang on 15/5/6.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "DeviceListTableViewController.h"
#import "DeviceListCell.h"
#import "FaildView.h"
#import "SearchView.h"
#import "SHRouter.h"
#import "MessageUtil.h"
#import "MJRefresh.h"
#import "NSMutableArray+SWUtilityButtons.h"
#import "EmptyView.h"
#import "ErrorUtil.h"
#import "MBProgressHUD+MJ.h"
@interface DeviceListTableViewController ()<UITableViewDataSource, UITableViewDelegate,SWTableViewCellDelegate>

@end

@implementation DeviceListTableViewController
{
    CGFloat cellHeight;
    FaildView *_errorView;
    NSMutableArray *_clientList;
    NSString* _mac;
    DeviceListCell *currentCell;
    NSInteger currentRow;
    UITableView* _tableView;
    EmptyView *_emptyView;
}

-(void)viewDidAppear:(BOOL)animated
{
    [_tableView.header beginRefreshing];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"终端列表";
    _tableView = [[UITableView alloc]init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64);
    [self.view addSubview:_tableView];
    _tableView.separatorStyle = NO;
    _tableView.backgroundColor = getColor(225, 225, 225, 225);
    _errorView = [[FaildView alloc]init];
    [self.view addSubview:_errorView];
    _errorView.hidden = true;
    
    __block DeviceListTableViewController *tmp = self;
    [_tableView addLegendHeaderWithRefreshingBlock:^{
        [tmp pullToRefresh];
    }];
    
    [_errorView addLegendHeaderWithRefreshingBlock:^{
        [tmp pullToRefresh];
    }];
    
     _clientList = [NSMutableArray array];
    
    _emptyView = [EmptyView getEmptyView:@"该路由器没有连接终端"];
    [self.view addSubview:_emptyView];
    _emptyView.hidden = true;
    
    [_emptyView addLegendHeaderWithRefreshingBlock:^{
        [tmp pullToRefresh];
    }];
}

-(void)pullToRefresh
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error = nil;
        if(_mac != nil && _mac != [SHRouter currentRouter].mac)
        {
            _clientList = [[SHRouter currentRouter] getTerminalWithMac:_mac error:&error];
         
        }
        else
        {
            _clientList = [[SHRouter currentRouter]getClientListWithError:&error];
        }
        
        if(!error)
        {
            if(_clientList.count == 0)
            {
                [self performSelectorOnMainThread:@selector(showEmptyView) withObject:nil waitUntilDone:YES];            }
            else
            {
                [self performSelectorOnMainThread:@selector(showTableView) withObject:nil waitUntilDone:YES];
            }
        }
        else
        {
            NSString *errorMsg = [ErrorUtil doForError:error];
            [self performSelectorOnMainThread:@selector(showErrorView:) withObject:errorMsg waitUntilDone:YES];
        }
    });
}



-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString*  cellId1 = @"cellId1";
    static NSString* cellId2 = @"cellId2";
    static NSString* cellId3 = @"cellID3";
    
    int flag = 1;
    DeviceListCell *cell;
    //查看是否旧版本
    if(_clientList[indexPath.row][@"P_CONT"] == nil)
    {
        
        //cell.rightUtilityButtons = [self getButtons];
        //修改名称
        flag = 1;
    }
    else
    {
        if([_clientList[indexPath.row][@"P_CONT"] intValue] == 1)
        {
           
            //cell.rightUtilityButtons = [self getButtonsDelete];
            //修改名称，删除
            flag = 3;
        }
        else if([_clientList[indexPath.row][@"P_CONT"] intValue] == 0)
        {
           
            if([[SHRouter currentRouter].selfMac isEqualToString:_clientList[indexPath.row][@"MAC"]])
            {
                // cell.rightUtilityButtons = [self getButtons];
                //修改名称
                flag = 1;
            }
            else
            {
                //cell.rightUtilityButtons = [self getButtonsAdd];
                //修改名称，添加
                flag = 2;
                
            }
        }
    }

    
    if(flag == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:cellId1];
    }
    else if(flag == 2)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:cellId2];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:cellId3];
    }
    
    if(cell == nil)
    {
        if(flag == 1)
        {
            cell = [[DeviceListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId1];
            cell.rightUtilityButtons = [self getButtons];
        }
        else if(flag == 2)
        {
            cell = [[DeviceListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId2];
            cell.rightUtilityButtons = [self getButtonsAdd];
        }
        else
        {
            cell = [[DeviceListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId3];
            cell.rightUtilityButtons = [self getButtonsDelete];
        }
        
        cellHeight = cell.totalHeight;
        cell.delegate = self;
    }
    
    [cell setName:_clientList[indexPath.row][@"NAME"]];
    [cell setMac:_clientList[indexPath.row][@"MAC"]];
    [cell setSend:[_clientList[indexPath.row][@"TX_PKTs"] intValue]];
    [cell setRecv:[_clientList[indexPath.row][@"RX_PKTs"] intValue]];
 
    
     //查看是否旧版本
    if(_clientList[indexPath.row][@"P_CONT"] == nil)
    {
        [cell setImgWithImgName:@"device_item_icon_normal"];
        //cell.rightUtilityButtons = [self getButtons];
        //修改名称
    }
    else
    {
        if([_clientList[indexPath.row][@"P_CONT"] intValue] == 1)
        {
            [cell setImgWithImgName:@"device_item_icon_parent_control"];
            //cell.rightUtilityButtons = [self getButtonsDelete];
             //修改名称，删除
        }
        else if([_clientList[indexPath.row][@"P_CONT"] intValue] == 0)
        {
            [cell setImgWithImgName:@"device_item_icon_normal"];
            if([[SHRouter currentRouter].selfMac isEqualToString:_clientList[indexPath.row][@"MAC"]])
            {
               // cell.rightUtilityButtons = [self getButtons];
                //修改名称
            }
            else
            {
                //cell.rightUtilityButtons = [self getButtonsAdd];
                //修改名称，添加
            }
        }
    }
    return  cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  _clientList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
}




-(void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    [cell hideUtilityButtonsAnimated:false];
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    if(index == 0)
    {
        NSString* title = [NSString stringWithFormat:@"修改名称(%@)",_clientList[indexPath.row][@"NAME"]];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        currentRow = indexPath.row;
        currentCell = (DeviceListCell*)cell;
        [alert show];
    }
    else if(index == 1)
    {
        
        NSString* mac = _clientList[indexPath.row][@"MAC"];
        NSString* name = _clientList[indexPath.row][@"NAME"];
        int pcont = [_clientList[indexPath.row][@"P_CONT"] intValue];
       
        if(pcont == 1)
        {
            //发送请求
            [MBProgressHUD showMessage:@"正在请求解除父母控制"];
           dispatch_async(dispatch_get_global_queue(0, 0), ^{
               NSError *error;
               [[SHRouter currentRouter] deleteClientFromParentControl:mac name:name error:&error];
               dispatch_async(dispatch_get_main_queue(), ^{
                   [MBProgressHUD hideHUD];
                   if(!error)
                   {
                       if(!error)
                       {
                           [MBProgressHUD showSuccess:@"删除成功"];
                           [_clientList[indexPath.row] setObject:@0 forKey:@"P_CONT"];
                           [self performSelectorOnMainThread:@selector(showTableView) withObject:nil waitUntilDone:YES];
                       }
                       else
                       {
                           [MBProgressHUD showError:@"删除失败"];
                           NSString *errorMsg = [ErrorUtil doForError:error];
                           [self performSelectorOnMainThread:@selector(showErrorView:) withObject:errorMsg waitUntilDone:YES];
                       }
                   }

               });
            });
        }
        else
        {
            //发送请求
            [MBProgressHUD showMessage:@"正在请求添加到父母控制"];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSError * error;
                [[SHRouter currentRouter]addClientToParentControl:mac name:name error:&error];
                dispatch_async(dispatch_get_main_queue(), ^{
                   [MBProgressHUD hideHUD];
                    if(!error)
                    {
                        [MBProgressHUD showSuccess:@"添加成功"];
                        [_clientList[indexPath.row] setObject:@1 forKey:@"P_CONT"];
                        [self performSelectorOnMainThread:@selector(showTableView) withObject:nil waitUntilDone:YES];
                    }
                    else
                    {
                        [MBProgressHUD showError:@"添加失败"];
                        NSString *errorMsg = [ErrorUtil doForError:error];
                        [self performSelectorOnMainThread:@selector(showErrorView:) withObject:errorMsg waitUntilDone:YES];
                    }

                });
            });
        }
       
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    SWTableViewCell *cell = (SWTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell showRightUtilityButtonsAnimated:true];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        //确定修改
        NSString *newName = [alertView textFieldAtIndex:0].text;
        //发送修改命令
        [MBProgressHUD showMessage:@"正在发送修改请求"];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSError *error = nil;
            BOOL ret = [[SHRouter currentRouter]setClientName:newName mac:_clientList[currentRow][@"MAC"] error:&error];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUD];
                
                if(ret)
                {
                    //成功
                    [currentCell setName:newName];
                    [_clientList[currentRow] setObject:newName forKey:@"NAME"];
                    [MBProgressHUD showSuccess:@"修改成功"];
                }
                else
                {
                    //失败
                    [MBProgressHUD showError:@"出错了,修改失败"];
                }
            });
    });
    }
}

-(NSArray *)getButtonsAdd
{
    NSMutableArray* buttons = [NSMutableArray new];
    [buttons sw_addUtilityButtonWithColor:
     getColor(0xf9, 0x3f, 0x25, 255) title:@"修改名称"];
    [buttons sw_addUtilityButtonWithColor:
    [UIColor colorWithRed:48/255.0f green:177/255.0f blue:245/255.0f alpha:1.0f]
                                   title:@"添加"];
    return buttons;
}

-(NSArray *)getButtonsDelete
{
    NSMutableArray* buttons = [NSMutableArray new];
    [buttons sw_addUtilityButtonWithColor:
     getColor(0xf9, 0x3f, 0x25, 255) title:@"修改名称"];
    [buttons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:48/255.0f green:177/255.0f blue:245/255.0f alpha:1.0f]
                                    title:@"删除"];
    return buttons;
}

-(NSArray *)getButtons
{
    NSMutableArray* buttons = [NSMutableArray new];
    [buttons sw_addUtilityButtonWithColor:
     getColor(0xf9, 0x3f, 0x25, 255) title:@"修改名称"];
    return buttons;
}

-(BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

-(void)showTableView
{
     [_tableView.header endRefreshing];
    [_tableView reloadData];
    _tableView.hidden = false;
    _errorView.hidden = true;
    _emptyView.hidden = true;
   
}

-(void)showErrorView:(NSString*)errorMsg
{
    [_errorView.header endRefreshing];
    _tableView.hidden = true;
    _emptyView.hidden = true;
    _errorView.hidden = false;
    [_errorView setMessage:errorMsg];
}

-(void)showEmptyView
{
    [_emptyView.header endRefreshing];
    _tableView.hidden = true;
    _emptyView.hidden = false;
    _errorView.hidden = true;
    
}

-(void)setMac:(NSString *)mac
{
    _mac = mac;
}

@end
