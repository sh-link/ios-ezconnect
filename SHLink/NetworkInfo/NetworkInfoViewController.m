//
//  NetworkInfoViewController.m
//  SHLink
//
//  Created by 钱凯 on 15/2/9.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "NetworkInfoViewController.h"
#import "PureLayout.h"
#import "SHSearchRoationLayer.h"
#import "SHRouter.h"
#import "MJRefresh.h"
#import "UIView+Extension.h"
typedef NS_ENUM(int, _STATE) {
    _stateLoding,
    _stateSuccess,
    _stateFaild,
};

#define searchLayerWidth 70.0

@interface NetworkInfoViewController ()
{
    UILabel *_wlanFailedLB;
    UILabel *_wanFailedLB;
    UILabel *_wanNotConnectedLB;
    
    UIView *_wlanSearchView;
    UIView *_wanSearchView;
    
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeightConstraint;

@property (weak, nonatomic) IBOutlet UILabel *ssidLB;
@property (weak, nonatomic) IBOutlet UILabel *wifiKeyLB;
@property (weak, nonatomic) IBOutlet UILabel *channelLB;

@property (weak, nonatomic) IBOutlet UILabel *ipLB;
@property (weak, nonatomic) IBOutlet UILabel *maskLB;
@property (weak, nonatomic) IBOutlet UILabel *gatewayLB;
@property (weak, nonatomic) IBOutlet UILabel *dns1LB;
@property (weak, nonatomic) IBOutlet UILabel *dns2LB;
@property (weak, nonatomic) IBOutlet UILabel *txCountLB;
@property (weak, nonatomic) IBOutlet UILabel *rxCountLB;

@property (weak, nonatomic) IBOutlet UIView *wlanConfigView;
@property (weak, nonatomic) IBOutlet UIView *wanConfigView;
@property (weak, nonatomic) IBOutlet UILabel *onlinestate;

@property (nonatomic) _STATE state;

@end

@implementation NetworkInfoViewController

#pragma mark - Life cycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"网络信息";
    [self setup];
    //监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:UIApplicationDidBecomeActiveNotification object:nil];
    [_scrollView addLegendHeaderWithRefreshingBlock:^{
        //
        [self refresh];
    }];
    
    _onlinestate.textColor = [UIColor redColor];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self refresh];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setup {
    SHSearchRoationLayer *wlanSearchLayer = [SHSearchRoationLayer layer];
    SHSearchRoationLayer *wanSearchLayer = [SHSearchRoationLayer layer];
    
    _wlanSearchView = [[UIView alloc] initWithFrame:CGRectZero];
    _wlanSearchView.backgroundColor = [UIColor clearColor];
    
    [_wlanConfigView addSubview:_wlanSearchView];
    
    [_wlanSearchView autoSetDimension:ALDimensionWidth toSize:searchLayerWidth];
    [_wlanSearchView autoSetDimension:ALDimensionHeight toSize:searchLayerWidth];
    [_wlanSearchView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [_wlanSearchView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    
    wlanSearchLayer.frame = CGRectMake(0, 0, searchLayerWidth, searchLayerWidth);
    [_wlanSearchView.layer addSublayer:wlanSearchLayer];
    
    _wanSearchView = [[UIView alloc] initWithFrame:CGRectZero];
    _wanSearchView.backgroundColor = [UIColor clearColor];
    
    [_wanConfigView addSubview:_wanSearchView];
    
    [_wanSearchView autoSetDimension:ALDimensionWidth toSize:searchLayerWidth];
    [_wanSearchView autoSetDimension:ALDimensionHeight toSize:searchLayerWidth];
    [_wanSearchView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [_wanSearchView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    
    wanSearchLayer.frame = CGRectMake(0, 0, searchLayerWidth, searchLayerWidth);
    [_wanSearchView.layer addSublayer:wanSearchLayer];
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
    
    rotationAnimation.duration = 1.0;
    rotationAnimation.repeatCount = HUGE_VALF;
    
    [wlanSearchLayer addAnimation:rotationAnimation forKey:nil];
    [wanSearchLayer addAnimation:rotationAnimation forKey:nil];
    
    [wlanSearchLayer setNeedsDisplay];
    [wanSearchLayer setNeedsDisplay];
    
    _wanFailedLB = [[UILabel alloc] initWithFrame:CGRectZero];
    _wlanFailedLB = [[UILabel alloc] initWithFrame:CGRectZero];
    
    _wanFailedLB.text = @"无法连接到路由器";
    _wanFailedLB.textColor = [UIColor redColor];
    _wanFailedLB.textAlignment = NSTextAlignmentCenter;
    
    _wlanFailedLB.text = @"无法连接到路由器";
    _wlanFailedLB.textColor = [UIColor redColor];
    _wlanFailedLB.textAlignment = NSTextAlignmentCenter;
    
    _wanNotConnectedLB = [[UILabel alloc] initWithFrame:CGRectZero];
    
    [_wanConfigView addSubview:_wanFailedLB];
    [_wanConfigView addSubview:_wanNotConnectedLB];
    [_wlanConfigView addSubview:_wlanFailedLB];
    
//    _wlanConfigView.layer.shadowRadius = 5;
//    _wlanConfigView.layer.shadowOffset = CGSizeMake(3, 3);
//    _wlanConfigView.layer.shadowOpacity = 0.3;
//    
//    _wanConfigView.layer.shadowRadius = 5;
//    _wanConfigView.layer.shadowOffset = CGSizeMake(3, 3);
//    _wanConfigView.layer.shadowOpacity = 0.3;
    
}

#pragma mark - Actrion
#pragma mark -

- (void)refresh {
    [self setState:_stateLoding];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1.5);
        NSError *error = nil;
        SHRouter *router = [SHRouter currentRouter];
        [router getNetworkSettingInfoWithError:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                
                [self setState:_stateFaild];
                
            } else {
                
                _ssidLB.text = [NSString stringWithFormat:@"网络名称: %@",router.ssid];
                _wifiKeyLB.text = [NSString stringWithFormat:@"连接密码: %@",router.wifiKey];
                _channelLB.text = [NSString stringWithFormat:@"通信信道: %d",router.channel];
                
                if (router.wanIsConnected) {
                    
                    _ipLB.text = [NSString stringWithFormat:@"IP地址: %@",router.wanIp];
                    _maskLB.text = [NSString stringWithFormat:@"子网掩码: %@",router.wanMask];
                    
                    _gatewayLB.textColor = _ipLB.textColor;
                    _gatewayLB.text = [NSString stringWithFormat:@"网关地址: %@",router.wanGateway];
                    
                    _dns1LB.text = [NSString stringWithFormat:@"DNS1: %@",router.dns1];
                    _dns2LB.text = [NSString stringWithFormat:@"DNS2: %@",router.dns2];
                    _txCountLB.text = [NSString stringWithFormat:@"已发送数据包: %lld",router.txPktNum];
                    _rxCountLB.text = [NSString stringWithFormat:@"已接收数据包: %lld",router.rxPktNum];
                    if(router.WAN_INET_STAT == 0)
                    {
                        _onlinestate.hidden = TRUE;
                        
                    }
                    else
                    {
                        _onlinestate.hidden = FALSE;
                        
                        if(router.WAN_INET_STAT == 1)
                        {
                            _onlinestate.text = @"pppoe用户名密码错误";
                        }
                        else if(router.WAN_INET_STAT == 2)
                        {
                            _onlinestate.text = @"pppoe服务器无响应";
                        }
                        else if(router.WAN_INET_STAT == 3)
                        {
                            _onlinestate.text = @"pppoe服务器未知错务";
                        }
                        else if(router.WAN_INET_STAT == 4)
                        {
                            _onlinestate.text = @"您可能选择了错误的上网方式";
                        }
                    }
                    
                } else {
                    
                    _ipLB.text = nil;
                    _maskLB.text = nil;
                    
                    _gatewayLB.textColor = [UIColor redColor];
                    _gatewayLB.text = @"wan口未连接！";
                    
                    _dns1LB.text = nil;
                    _dns2LB.text = nil;
                    _txCountLB.text = nil;
                    _rxCountLB.text = nil;
                    _onlinestate.text = nil;
                }
                
                [self setState:_stateSuccess];
            }
            [_scrollView.header endRefreshing];
        });
    });
}

#pragma mark - Layout
#pragma mark -

- (void)updateViewConstraints {
    
    [_contentHeightConstraint autoRemove];
    
    CGFloat contentHeight = MAX(CGRectGetHeight(self.view.bounds), (CGRectGetMaxY(_wanConfigView.frame) + 35));
    
    _contentHeightConstraint = [_contentView autoSetDimension:ALDimensionHeight toSize:contentHeight];
    
    _wlanFailedLB.frame = _wlanConfigView.bounds;
    _wanFailedLB.frame = _wanConfigView.bounds;
    
    [super updateViewConstraints];
    
}

#pragma mark - Properties
#pragma mark -

- (void)setState:(_STATE)state {
    _state = state;
    if (state == _stateSuccess) {
        
        _ssidLB.hidden = NO;
        _wifiKeyLB.hidden = NO;
        _channelLB.hidden = NO;
        
        _ipLB.hidden = NO;
        _maskLB.hidden = NO;
        _gatewayLB.hidden = NO;
        _dns1LB.hidden = NO;
        _dns2LB.hidden = NO;
        _txCountLB.hidden = NO;
        _rxCountLB.hidden = NO;
        _onlinestate.hidden = NO;
        
        _wlanSearchView.hidden = YES;
        _wanSearchView.hidden = YES;
        
        _wlanFailedLB.hidden = YES;
        _wanFailedLB.hidden = YES;
        
        
    } else if (state == _stateLoding) {
        
        _ssidLB.hidden = YES;
        _wifiKeyLB.hidden = YES;
        _channelLB.hidden = YES;
        
        _ipLB.hidden = YES;
        _maskLB.hidden = YES;
        _gatewayLB.hidden = YES;
        _dns1LB.hidden = YES;
        _dns2LB.hidden = YES;
        _txCountLB.hidden = YES;
        _rxCountLB.hidden = YES;
        _onlinestate.hidden = YES;
        
        _wlanFailedLB.hidden = YES;
        _wanFailedLB.hidden = YES;
        
        _wlanSearchView.hidden = NO;
        _wanSearchView.hidden = NO;
        
    } else if (state == _stateFaild) {
        
        _ssidLB.hidden = YES;
        _wifiKeyLB.hidden = YES;
        _channelLB.hidden = YES;
        
        _ipLB.hidden = YES;
        _maskLB.hidden = YES;
        _gatewayLB.hidden = YES;
        _dns1LB.hidden = YES;
        _dns2LB.hidden = YES;
        _txCountLB.hidden = YES;
        _rxCountLB.hidden = YES;
        _onlinestate.hidden = YES;
        
        _wlanSearchView.hidden = YES;
        _wanSearchView.hidden = YES;
        
        _wlanFailedLB.hidden = NO;
        _wanFailedLB.hidden = NO;
    }
    
}

@end
