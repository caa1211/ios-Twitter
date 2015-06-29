//
//  ComposeTweetViewController.m
//  ios-Twitter
//
//  Created by Carter Chang on 6/30/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import "ComposeTweetViewController.h"
#import <UIImageView+AFNetworking.h>
#import "Define.h"
#import "TwitterClient.h"
#import <TSMessage.h>

NSInteger const kMaxTextCount = 140;

@interface ComposeTweetViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *textCount;
@property (weak, nonatomic) IBOutlet UILabel *screenname;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) User *loginUser;
@property (strong, nonatomic) UIBarButtonItem *tweetBtn;

@property (strong, nonatomic) UIImage *tweetEnableImg;
@property (strong, nonatomic) UIImage *tweetDisableImg;
@end

@implementation ComposeTweetViewController

- (id) initWithUser: (User *)user{
    self = [super init];
    if (self) {
        self.loginUser = user;
           }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    User *user = self.loginUser;
    self.screenname.text = user.screenname;
    self.name.text = user.name;
    self.tweetTextView.text = @"";
    self.tweetTextView.delegate = self;
    self.textCount.text = [@(kMaxTextCount) stringValue];
    
    NSString *profileImageUrl = user.profileImageUrl;
    [self.profileImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileImageUrl] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:3]
                             placeholderImage:nil success: nil failure:nil];
 
    // Custom back button
    UIImage *backImg = [Define fontImage:NIKFontAwesomeIconTimesCircle rgbaValue:0xffffff];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithImage:backImg style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    
    self.tweetEnableImg = [Define fontImage:NIKFontAwesomeIconPaperPlane rgbaValue:0xffffff];
    
    self.tweetDisableImg = [Define fontImage:NIKFontAwesomeIconPaperPlane rgbaValue:0xa6cfe3];
    self.tweetBtn = [[UIBarButtonItem alloc] initWithImage:self.tweetEnableImg style:UIBarButtonItemStylePlain target:self action:@selector(onTweet)];

    [self.tweetBtn setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor] } forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem = backBtn;
    self.navigationItem.rightBarButtonItem = self.tweetBtn;
    [self.navigationController.navigationBar setBarTintColor:[[UIColor alloc] initWithRed:0.298 green:0.646 blue:0.920 alpha:1.000]];
    
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    self.profileImage.layer.borderWidth = 1.0f;
    self.profileImage.layer.borderColor = CGColorRetain([UIColor colorWithRed:0.335 green:0.632 blue:0.916 alpha:1.000].CGColor);
    
    // Default keyboard on
    [self.tweetTextView becomeFirstResponder];
}

-(void) onBack {
  [self.view endEditing:YES];
  [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) onTweet {
    NSString *text = self.tweetTextView.text;
    void (^completion) (Tweet *tweet, NSError *error) = ^(Tweet *tweet, NSError *error){
        if(tweet != nil) {
            [self.delegate didPostTweet:tweet];
        }else {
            [TSMessage showNotificationWithTitle:@"Tweet failed"
                                        subtitle:@"Please try later"
                                            type:TSMessageNotificationTypeWarning];
        }
        [self.view endEditing:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    
    [[TwitterClient sharedInstance] postTweet:text completion:completion];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateTweetBtnState{
    if (self.tweetBtn.enabled && self.tweetBtn.image == self.tweetDisableImg) {
        self.tweetBtn.image = self.tweetEnableImg;
    }else if (!self.tweetBtn.enabled && self.tweetBtn.image == self.tweetEnableImg){
        self.tweetBtn.image = self.tweetDisableImg;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    NSInteger textLeft = kMaxTextCount - textView.text.length;
    self.textCount.text = [@(textLeft) stringValue];
    self.tweetBtn.enabled = (textLeft >= 0) && (textLeft < kMaxTextCount);
    self.textCount.textColor = (textLeft >= 20) ? [UIColor colorWithWhite:0.629 alpha:1.000] : [UIColor redColor];
    
    [self updateTweetBtnState];
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
