//
//  ZZTableViewController.m
//  什么值得买
//
//  Created by Wang_ruzhou on 16/8/12.
//  Copyright © 2016年 Wang_ruzhou. All rights reserved.
//

#import "ZZFirstTableViewController.h"
#import "ZZDIYHeader.h"
#import "ZZDIYBackFooter.h"


@interface ZZFirstTableViewController ()

@end

@implementation ZZFirstTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)initUI {
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.scrollsToTop = YES;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    self.tableView.mj_header = [ZZDIYHeader headerWithRefreshingTarget:self
                                                      refreshingAction:@selector(loadData)];
    self.tableView.mj_footer = [ZZDIYBackFooter footerWithRefreshingTarget:self
                                                          refreshingAction:@selector(loadMoreData)];
    [self.tableView.mj_header beginRefreshing];
}

- (void)loadData {}

- (void)loadMoreData {}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

#pragma mark - getter && setter

- (NSMutableArray *)dataSource{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)setTableViewColor:(UIColor *)tableViewColor{
    
    _tableViewColor = tableViewColor;
    
    self.tableView.backgroundColor = tableViewColor;
    self.tableView.mj_footer.backgroundColor = tableViewColor;
    self.tableView.mj_header.backgroundColor = tableViewColor;
}


@end
