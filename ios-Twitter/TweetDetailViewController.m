//
//  TweetDetailViewController.m
//  ios-Twitter
//
//  Created by Carter Chang on 6/30/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import "TweetDetailViewController.h"
#import "TwitterClient.h"
#import "ComposeTweetViewController.h"

@interface TweetDetailViewController () <ComposeTweetViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *screenname;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UILabel *createAtLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoritesNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetsNumLabel;
@property (weak, nonatomic) IBOutlet UIImageView *replyBtn;
@property (weak, nonatomic) IBOutlet UIImageView *retweetBtn;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteBtn;
@property(strong, nonatomic) Tweet *tweet;
@property(strong, nonatomic) User *loginUser;
@property (strong, nonatomic) UIImage *retweetImage;
@property (strong, nonatomic) UIImage *retweetActiveImage;
@property (strong, nonatomic) UIImage *favoriteImage;
@property (weak, nonatomic) IBOutlet UIImageView *removeBtn;
@property (strong, nonatomic) UIImage *favoriteActiveImage;
@end

@implementation TweetDetailViewController

-(id) initWithUser:(User *)user andTweet:(Tweet *)tweet{
    self = [super init];
    if (self) {
        self.tweet = tweet;
        self.loginUser = user;
    }
    return self;
}

-(void) updateImages{
    if ([self.tweet.favorited integerValue] == 1) {
        self.favoriteBtn.image = self.favoriteActiveImage;
    }else {
        self.favoriteBtn.image = self.favoriteImage;
    }
    
    if ([self.tweet.retweeted integerValue] == 1) {
        self.retweetBtn.image = self.retweetActiveImage;
    }else {
        self.retweetBtn.image = self.retweetImage;
    }
    
    if ([self.loginUser.idStr isEqualToString:self.tweet.user.idStr]) {
        [self.retweetBtn setAlpha:0.3];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    Tweet *t = self.tweet;
    self.name.text = t.user.name;
    self.screenname.text = [NSString stringWithFormat:@"@%@",t.user.screenname ];
    self.tweetLabel.text = t.text;
    self.favoritesNumLabel.text = [@(t.favoriteCount) stringValue];
    self.retweetsNumLabel.text = [@(t.retweetCount) stringValue];
    
    NSString *dateString = [NSDateFormatter localizedStringFromDate:t.createdAt
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterShortStyle];
    self.createAtLabel.text = dateString;
    
    self.retweetImage = [Define fontImage:NIKFontAwesomeIconRetweet rgbaValue:0xaaaaaa];
    self.retweetActiveImage = [Define fontImage:NIKFontAwesomeIconRetweet rgbaValue:0x77b255];
    self.favoriteImage = [Define fontImage:NIKFontAwesomeIconStarO rgbaValue:0xaaaaaa];
    self.favoriteActiveImage = [Define fontImage:NIKFontAwesomeIconStar rgbaValue:0xffac33];

    self.replyBtn.image = [Define fontImage:NIKFontAwesomeIconReply rgbaValue:0xaaaaaa];
    self.removeBtn.image = [Define fontImage:NIKFontAwesomeIconTrashO rgbaValue:0xaaaaaa];
    
    [self updateImages];
    
    // Profile image
    NSString *profileImageUrl = t.user.profileImageUrl;
    [self.profileImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileImageUrl] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:3] placeholderImage:nil success: nil failure:nil];
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    self.profileImage.layer.borderWidth = 1.0f;
    self.profileImage.layer.borderColor = CGColorRetain([UIColor colorWithRed:0.335 green:0.632 blue:0.916 alpha:1.000].CGColor);
    
    
    // Custom back button
    UIImage *backImg = [Define fontImage:NIKFontAwesomeIconArrowCircleOLeft rgbaValue:0xffffff];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithImage:backImg style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    
    self.navigationItem.leftBarButtonItem = backBtn;
    //self.navigationItem.rightBarButtonItem = self.tweetBtn;
    [self.navigationController.navigationBar setBarTintColor:[[UIColor alloc] initWithRed:0.298 green:0.646 blue:0.920 alpha:1.000]];
    
    // Action Buttons
    self.replyBtn.userInteractionEnabled = YES;
    self.retweetBtn.userInteractionEnabled = YES;
    self.favoriteBtn.userInteractionEnabled = YES;
    self.removeBtn.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onReply)];
    tapped.numberOfTapsRequired = 1;
    [self.replyBtn addGestureRecognizer:tapped];
    
    tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onRetweet)];
    tapped.numberOfTapsRequired = 1;
    [self.retweetBtn addGestureRecognizer:tapped];
    
    tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onFavorite)];
    tapped.numberOfTapsRequired = 1;
    [self.favoriteBtn addGestureRecognizer:tapped];
    
    tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onRemoveTweet)];
    tapped.numberOfTapsRequired = 1;
    [self.removeBtn addGestureRecognizer:tapped];
}

-(void) onRemoveTweet{
    [[TwitterClient sharedInstance] postDestroy:self.tweet.idStr completion:^(Tweet *tweet, NSError *error) {
        if (tweet != nil) {
            NSLog(@"postDestroy success");
           [self.delegate didPostTweet:tweet];
           [self onBack];
        }
    }];
}

- (void)didPostTweet:(Tweet *)tweet
{
    [self.delegate didPostTweet:tweet];
}

-(void) onReply {
    ComposeTweetViewController *vc = [[ComposeTweetViewController alloc]initWithUser:self.loginUser andTweet:self.tweet];
    vc.delegate = self;
    UINavigationController *nvController = [[UINavigationController alloc]
                                            initWithRootViewController: vc];
    // nvController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:nvController animated:YES completion:nil];
}

-(void) onRetweet {
    NSLog(@"onRetweet");
    [[TwitterClient sharedInstance] postRetweet:self.tweet.idStr completion:^(Tweet *tweet, NSError *error) {
        if (tweet != nil) {
            [self.tweet setRetweet:1];
            [self updateImages];
        }
        NSLog(@"retweet success");
       [self.delegate didPostTweet:tweet];
    }];
}

-(void) onFavorite {
    NSLog(@"onFavorite");
    if([self.tweet.favorited integerValue] == 1){
        [[TwitterClient sharedInstance] postFavoriteDestroy:self.tweet.idStr completion:^(Tweet *tweet, NSError *error) {
            if (tweet != nil) {
                [self.tweet setFavorite:0];
                [self updateImages];
            }
            NSLog(@"favorite success");
            [self.delegate didPostTweet:tweet];
        }];
    }else{
        [[TwitterClient sharedInstance] postFavoriteCreate:self.tweet.idStr completion:^(Tweet *tweet, NSError *error) {
            if (tweet != nil) {
                [self.tweet setFavorite:1];
                [self updateImages];
            }
            NSLog(@"remove favorite success");
            [self.delegate didPostTweet:tweet];
        }];
    }
}

- (void) onBack {
    // [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
