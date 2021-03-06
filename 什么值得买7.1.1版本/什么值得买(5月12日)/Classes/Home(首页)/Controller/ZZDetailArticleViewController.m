//
//  ZZDetailViewController.m
//  什么值得买
//
//  Created by Wang_ruzhou on 16/8/30.
//  Copyright © 2016年 Wang_ruzhou. All rights reserved.
//

#import "ZZDetailArticleViewController.h"
#import <WebKit/WebKit.h>
#import "ZZChannelID.h"
#import "ZZCircleView.h"
#import "ZZDetailBaseBottomBar.h"
#import "YYTextExampleHelper.h"
#import "ZZDetailModel.h"
#import "ZZDetailHeaderView.h"
#import "UINavigationItem+Margin.h"
#import "什么值得买-Swift.h"
#import <WebViewJavascriptBridge/WKWebViewJavascriptBridge.h>

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>

#define kBottomBarHeight 44
#define NAVBAR_CHANGE_POINT 50


NSString *const WKWebViewKeyPathContentSize = @"contentSize";

@interface ZZDetailArticleViewController ()<WKUIDelegate, WKNavigationDelegate, UIScrollViewDelegate, ZZDetailBaseBottomBarDelegate>
@property (nonatomic, strong) ZZChannelID *channel;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) ZZCircleView *circleView;
@property (nonatomic, strong) UIView *bottomToolBar;
@property (nonatomic, strong) UIScrollView *containerScrollView;        /**< 放置headerView +  WKWebView*/
@property (nonatomic, strong) ZZDetailHeaderLayout *headerLayout;
@property (nonatomic, strong) ZZDetailHeaderView *headerView;
@property (nonatomic, strong) ZZDetailModel *detailModel;
@property (nonatomic, strong) WKWebViewJavascriptBridge *bridge;

@end

@implementation ZZDetailArticleViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    //初始化底部工具栏
    [self initialBottomToolBar];
    
    _containerScrollView = [[UIScrollView alloc] init];
    _containerScrollView.delegate = self;
    _containerScrollView.scrollsToTop = YES;
    [self.view addSubview:_containerScrollView];
    _containerScrollView.frame = CGRectMake(0, kStatusH, self.view.width, self.view.height - kStatusH - kTabBarH);
    _containerScrollView.decelerationRate = UIScrollViewDecelerationRateFast;

    
    ZZDetailHeaderView *headerView = [[ZZDetailHeaderView alloc] init];
    [self.containerScrollView addSubview:headerView];
    self.headerView = headerView;
    
    //初始化webView
    [self initialWebView];
    //加载数据
    [self loadWebViewData];
    //初始化预加载动画, 有顺序要求
    [self initialCustomIndicatorView];

}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self scrollViewDidScroll:_containerScrollView];
    
    [self registerHandler];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.containerScrollView.delegate = nil;
    [self.navigationController.navigationBar lt_reset];
    
}

- (void)dealloc{
    
    [self.webView.scrollView removeObserver:self forKeyPath:WKWebViewKeyPathContentSize];
    self.containerScrollView.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - 初始化控件
- (void)initialBottomToolBar{

    ZZDetailBaseBottomBar *bottomToolBar = [ZZDetailBaseBottomBar barWithStyle:DetailBottomBarStyleHaiTao];
    bottomToolBar.delegate = self;
    [self.view addSubview:bottomToolBar];
    [bottomToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.offset(0);
        make.height.mas_equalTo(kTabBarH);
    }];
    self.bottomToolBar = bottomToolBar;
}

- (void)initialWebView{
    //解决wkwebView 加载的网页存在缩放的问题666
//    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
//    
//    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
//    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
//    [wkUController addUserScript:wkUScript];
////    [wkUController addScriptMessageHandler:self name:@"sizeNotification"];
//    
//    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
//    wkWebConfig.userContentController = wkUController;
    
    _webView = [[WKWebView alloc] init];
    _webView.frame = _containerScrollView.bounds;
    
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;

    [_webView.scrollView addObserver:self forKeyPath:WKWebViewKeyPathContentSize options:NSKeyValueObservingOptionNew context:nil];
//    _webView.scrollView.delegate = self;
    
    _webView.scrollView.scrollEnabled = NO;
    _webView.backgroundColor = [UIColor zz_randomColor];
    [_containerScrollView addSubview:_webView];
}

- (void)registerHandler {
    
    _bridge = [WKWebViewJavascriptBridge bridgeForWebView:self.webView];
    [_bridge registerHandler:@"lianjie" handler:^(id data, WVJBResponseCallback responseCallback) {
        
    }];
}

- (void)initialCustomIndicatorView {
    ZZCircleView *circleView = [[ZZCircleView alloc] init];
    circleView.center = self.view.center;
    circleView.width = 30;
    circleView.height = 30;
    [circleView startAnimating];
    [self.view addSubview:circleView];
    self.circleView = circleView;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleDefault;
}

- (void)configureLeftBarButtonItemWithImage:(UIImage *)leftImage rightBarButtonItemWithImage:(UIImage *)rightImage titleColor:(UIColor *)titleColor {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[leftImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(detailLeftBtnDidClick)];
    // 后退按钮距离图片距离左边边距
    self.navigationItem.leftBarButtonItem = backItem;
    self.navigationItem.leftMargin = -12;
    

    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[rightImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(detailRightBtnDidClick1)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    self.navigationItem.rightMargin = -12;

    NSDictionary *attributes = @{NSForegroundColorAttributeName : titleColor};
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];

}

#pragma mark - loadData
- (void)loadWebViewData {
    
    NSInteger ID = self.channelID.integerValue;
    ZZChannelID *channel = [ZZChannelID channelWithID:ID];
    self.channel = channel;
    NSString *URLStr = [NSString stringWithFormat:@"%@/%@", channel.URLString, _article_id];
    [ZZAPPDotNetAPIClient Get:URLStr parameters:[self configureParameters] completionBlock:^(NSDictionary *responseObject, NSError *error) {
        
        if (error) { return;}
        
        _detailModel = [ZZDetailModel modelWithDictionary:responseObject];
        _headerLayout = [[ZZDetailHeaderLayout alloc] initWithHeaderDetailModel:_detailModel];
        
        NSString *html5Content = nil;
        if (ID == 6 || ID == 11) {
            html5Content = _detailModel.article_filter_content;
        }else{
            html5Content = _detailModel.html5_content;
        }
        if (html5Content.length > 0) {
            
            [_webView loadHTMLString:html5Content baseURL:nil];
            
            [self.circleView stopAnimating];
            [self.circleView removeFromSuperview];
            
            self.headerView.headerLayout = _headerLayout;
            _webView.top = self.headerView.bottom;
        }
        
    }];
}

- (NSMutableDictionary *)configureParameters {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    NSInteger channelID = [self.channelID integerValue];
    
    if (channelID != 14) {
        [parameters setValue:@"0" forKey:@"imgmode"];
        [parameters setValue:@"1" forKey:@"filtervideo"];
        [parameters setValue:@"1" forKey:@"show_dingyue"];
        [parameters setValue:@"1" forKey:@"show_wiki"];
        
    }
    
    switch (channelID) {
        case 1:
        case 2:
        case 5:
            [parameters setValue:[NSString stringWithFormat:@"%@",self.channelID] forKey:@"channel_id"];
            break;
        case 6:
        case 8:
            break;
        case 11:
            [parameters setValue:@"1" forKey:@"no_html_series"];
            [parameters setValue:@"1" forKey:@"show_share"];
            break;
        case 14:
            
            break;
            
        default:
            break;
    }
    
    return parameters;
}


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    // object为WKScrollView
    CGSize size = [object contentSize];
    [self configureWebViewContentSizeWithScrollViewHeight:size.height];
    
}

- (void)configureWebViewContentSizeWithScrollViewHeight:(CGFloat)height {
    self.webView.height = height;
    self.containerScrollView.contentSize = CGSizeMake(self.view.width, height + _headerLayout.height);
}

#pragma mark - 事件监听
- (void)detailLeftBtnDidClick {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)detailRightBtnDidClick1 {
    NSArray* imageArray = @[_detailModel.share_pic];
    
    NSURL *url = [NSURL URLWithString:_detailModel.article_url];
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    //1、创建分享参数
    [shareParams SSDKSetupShareParamsByText:nil images:imageArray url:url title:_detailModel.share_title_other type:SSDKContentTypeAuto];
    
    [self jumpToShareViewControllerWithParameters:shareParams];
}

/** 分享 */
- (void)detailRightBtnDidClick {
    
//    [self jumpToShareViewController];
    
    //1、创建分享参数

    //（注意：图片必须要在Xcode左边目录里面，名称必须要传正确 (Bundle中的图片)
    // 如果要分享网络图片，可以这样传iamge参数 images:@[@"http://mob.com/Assets/images/logo.png?v=20150320"]）(网络图片直接给URL地址)
    NSArray* imageArray = @[_detailModel.share_pic];
    
    NSURL *url = [NSURL URLWithString:_detailModel.article_url];
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    //1、创建分享参数
    [shareParams SSDKSetupShareParamsByText:nil images:imageArray url:url title:_detailModel.share_title_other type:SSDKContentTypeAuto];
    
    // 分享结果的回调方法
    SSUIShareStateChangedHandler handler = ^ (SSDKResponseState state,SSDKPlatformType platformType, NSDictionary *userData,SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
        
        // SSDKResponseState 分享结果的状态
        switch (state) {
            case SSDKResponseStateSuccess:
                NSLog(@"分享成功");
                break;
            case SSDKResponseStateFail:
                NSLog(@"分享失败");
                break;
            default:
                break;
        }
    };
    
    /**
     *  显示分享菜单
     *
     *  @param view                     要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图, iPhone可以传nil不会影响
     *  @param items                    菜单项，如果传入nil，则显示已集成的平台列表
     *  @param shareParams              分享内容参数
     *  @param shareStateChangedHandler 分享状态变更事件
     *
     *  @return 分享菜单控制器
     */
    [ShareSDK showShareActionSheet:nil items:nil shareParams:shareParams onShareStateChanged:handler];
}

#pragma mark - ZZDetailBaseBottomBarDelegate
- (void)bottomBarLinkBtnDidClick:(ZZDetailBaseBottomBar *)bottomBar{
    
    ZZAllCommentController *commentController = [[ZZAllCommentController alloc] initWithStyle:UITableViewStyleGrouped];
    
    commentController.articleID = self.article_id;
    [self.navigationController pushViewController:commentController animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self configureLeftBarButtonItemWithImage:[UIImage imageNamed:@"SM_Detail_Back"] rightBarButtonItemWithImage:[UIImage imageNamed:@"SM_Detail_Right"] titleColor:[UIColor clearColor]];
    
    CGFloat offsetY = scrollView.contentOffset.y;
    
    
    if (offsetY > NAVBAR_CHANGE_POINT) {
        CGFloat alpha = MIN(1, 1 - (NAVBAR_CHANGE_POINT + 64 - offsetY) / 64);
        
        [self.navigationController.navigationBar lt_setBackgroundColor:[kGlobalLightGrayColor colorWithAlphaComponent:alpha]];
        
        if (alpha == 1) {
            [self configureLeftBarButtonItemWithImage:[UIImage imageNamed:@"SM_Detail_BackSecond"] rightBarButtonItemWithImage:[UIImage imageNamed:@"SM_Detail_RightSecond"] titleColor:[UIColor blackColor]];
        }
        
    }else{
        [self.navigationController.navigationBar lt_setBackgroundColor:[kGlobalLightGrayColor colorWithAlphaComponent:0]];
    }
    
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return nil;
}

#pragma mark - WKNavigationDelegate

/** 页面开始加载时调用 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    

    
//    LxDBAnyVar(@"页面开始加载时调用");
}

/** 当内容开始返回时调用 */
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
//    LxDBAnyVar(@"当内容开始返回时调用");
    
}

/** 页面加载完成时调用 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    
}

/** 页面加载失败时调用 */
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
//    LxDBAnyVar(@"页面加载失败时调用");
}

/** 接收到服务器跳转请求之后调用 */
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
//    LxDBAnyVar(@"接收到服务器跳转请求之后调用");
}

/** 在发送请求之前决定是否跳转 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
//    LxDBAnyVar(@"Decides whether to allow or cancel a navigation.");
    
    NSURL *URL = navigationAction.request.URL;
    NSString *scheme = [URL scheme];
    
    //详情: "about"
    
    LxDBAnyVar(scheme);
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

/** 在收到响应之后决定是否跳转 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
//    LxDBAnyVar(@"Decides whether to allow or cancel a navigation after its response is known.");
    
    decisionHandler(WKNavigationResponsePolicyAllow);
}

#pragma mark - WKUIDelegate
/**
 *  页面可以正常显示,但是里面的按钮全部失效了
 
    解决办法:
    只要在原来的基础上实现一个代理方法就可以了,设置WKWebView的UIDelegate,实现下面的方法就好了:
 */
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    
    if (navigationAction.targetFrame.isMainFrame) {
        
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

@end
