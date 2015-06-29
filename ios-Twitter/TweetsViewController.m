//
//  TweetsViewController.m
//  ios-Twitter
//
//  Created by Carter Chang on 6/29/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import "TweetsViewController.h"
#import "User.h"
#import "Tweet.h"
#import "TwitterClient.h"
#import "TweetCell.h"
#import <UIScrollView+InfiniteScroll.h>
#import <TSMessage.h>
#import "ComposeTweetViewController.h"

@interface TweetsViewController () <UITableViewDataSource, UITableViewDelegate, ComposeTweetViewControllerDelegate>
//@property (nonatomic, strong) UINavigationController *naviController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *tweets;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) User *loginUser;
@end

enum {
    TimelineSection = 0
};

@implementation TweetsViewController

- (void)viewWillAppear:(BOOL)animated {
    // Fix height of cell be strange after filter view closing
    [super viewWillAppear:animated];
    self.tableView.estimatedRowHeight = 100.0; // for example. Set your average height
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (id) initWithUser: (User *)user{
    self = [super init];
    if (self) {
        self.loginUser = user;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[TwitterClient sharedInstance] homeTimelineWithParams:nil completion:^(NSArray *tweets, NSError *error) {
        if (tweets == nil){
            // NSString *errorMsg =  error.userInfo[@"NSLocalizedDescription"];
            [TSMessage showNotificationWithTitle:@"Newtork Error"
                                        subtitle:@"Please check your connection and try again later"
                                        type:TSMessageNotificationTypeWarning];
        }else{
            self.tweets = [[NSMutableArray alloc] initWithArray: tweets];
            [self.tableView reloadData];
        }
    }];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.title = @"Home";

    
//    UIBarButtonItem *logoutBtn = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(onLogout)];
//    [logoutBtn setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor] } forState:UIControlStateNormal];
//    
//    UIBarButtonItem *newBtn = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(onNew)];
//    [newBtn setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor] } forState:UIControlStateNormal];
    
    UIImage *logoutImg = [Define fontImage:NIKFontAwesomeIconUserTimes rgbaValue:0xffffff];
    UIBarButtonItem *logoutBtn = [[UIBarButtonItem alloc] initWithImage:logoutImg style:UIBarButtonItemStylePlain target:self action:@selector(onLogout)];
    
    UIImage *newImg = [Define fontImage:NIKFontAwesomeIconPencilSquareO rgbaValue:0xffffff];
    UIBarButtonItem *newBtn = [[UIBarButtonItem alloc] initWithImage:newImg style:UIBarButtonItemStylePlain target:self action:@selector(onNew)];
    
    self.navigationItem.leftBarButtonItem = logoutBtn;
    self.navigationItem.rightBarButtonItem = newBtn;
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    [self.navigationController.navigationBar setBarTintColor:[[UIColor alloc] initWithRed:0.298 green:0.646 blue:0.920 alpha:1.000]];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"TweetCell"];
    [self initRefreshControl];
    [self initInfiniteScroll];
}

- (void) initInfiniteScroll {
    [self.tableView addInfiniteScrollWithHandler:^(UITableView* tableView) {
        [self loadMoreTweetsWithCompletionHandler:^{
             [self.tableView finishInfiniteScroll];
        }];
    }];
}

- (void)loadMoreTweetsWithCompletionHandler:(void (^)(void))completionHandler {
    NSString *lastTweetIdStr = ((Tweet *)[self.tweets lastObject]).idStr;
    long long maxIdToLoad = [lastTweetIdStr longLongValue] - 1;
    
    [[TwitterClient sharedInstance] homeTimelineWithParams:@{@"max_id": [@(maxIdToLoad) stringValue]} completion:^(NSArray *tweets, NSError *error) {

        if (tweets.count > 0) {
            NSInteger cNumTweets = self.tweets.count;
            //self.tweets = [self.tweets arrayByAddingObjectsFromArray:tweets];
            [self.tweets addObjectsFromArray:tweets];
            NSMutableArray *newIndexPaths = [NSMutableArray array];
            for (NSInteger i = cNumTweets; i < self.tweets.count; i++) {
                [newIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            [self.tableView insertRowsAtIndexPaths:newIndexPaths withRowAnimation:UITableViewRowAnimationNone];
        }
        completionHandler();
    }];
    
}


- (void) initRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor colorWithRed:0.85 green:0.49 blue:0.47 alpha:1.0];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action: @selector(refreshData)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex: 0];
}

- (void)refreshData{
    [[TwitterClient sharedInstance] homeTimelineWithParams:nil completion:^(NSArray *tweets, NSError *error) {
        if (tweets!=nil) {
            [self.tweets removeAllObjects];
            [self.tweets addObjectsFromArray:tweets];
            [self.tableView reloadData];
        }
        
        //End the refreshing
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;

        [self.refreshControl endRefreshing];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onLogout {
    [User logout];
}

- (void)onNew {
    ComposeTweetViewController *vc = [[ComposeTweetViewController alloc]initWithUser:self.loginUser];
    vc.delegate = self;
    
    UINavigationController *nvController = [[UINavigationController alloc]
                              initWithRootViewController: vc];
    // nvController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:nvController animated:YES completion:nil];
}


#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    switch (section) {
        case TimelineSection:
        default:
            num = self.tweets.count;
            break;
    }
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];

    [cell setTweet:self.tweets[indexPath.row]];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    [view setBackgroundColor:[UIColor colorWithRed:0.951 green:0.965 blue:0.975 alpha:1.000]];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 50)];
    [lbl setFont:[UIFont boldSystemFontOfSize:15]];
    [lbl setTextColor:[UIColor grayColor]];
    [view addSubview:lbl];
    [lbl setText:[NSString stringWithFormat:@"%@", [self tableView:self.tableView titleForHeaderInSection:section]]];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 49, self.view.bounds.size.width, 1)] ;
    lineView.backgroundColor = [UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1.0];
    [view addSubview:lineView];

    return view;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case TimelineSection:
        default:
            return @"Timeline";
            break;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)didPostTweet:(Tweet *)tweet
{
    if (tweet !=nil) {
        [self refreshData];
    }
}


@end
