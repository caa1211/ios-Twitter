//
//  TweetCell.m
//  ios-Twitter
//
//  Created by Carter Chang on 6/29/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import "TweetCell.h"
#import <UIImageView+AFNetworking.h>


@interface TweetCell()
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *tweetText;
@property (weak, nonatomic) IBOutlet UILabel *createAt;
@property (weak, nonatomic) IBOutlet UIImageView *retweetBtn;
@property (weak, nonatomic) IBOutlet UIImageView *replyBtn;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteBtn;
@property (weak, nonatomic) IBOutlet UIImageView *globalIcon;
@property (weak, nonatomic) IBOutlet UILabel *screenName;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@end


@implementation TweetCell

- (void)awakeFromNib {
    
    NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];
    [factory setColors:@[ UIColorFromRGB(0xcdd8de)]];
    self.globalIcon.image = [factory createImageForIcon:NIKFontAwesomeIconGlobe];

    
    // Initialization code
    self.replyBtn.image = [UIImage imageNamed:@"reply.png" ];
    self.favoriteBtn.image = [UIImage imageNamed:@"favorite.png" ];
    self.retweetBtn.image = [UIImage imageNamed:@"retweet.png" ];
    
    self.name.text = @"";
    self.clipsToBounds = YES;
    
}


-(void) setTweet:(Tweet *) tweet {
    User *user = tweet.user;
    self.name.text = user.name;
    self.createAt.text = tweet.timestamp;
    self.tweetText.text = tweet.text;
    self.screenName.text = [NSString stringWithFormat:@"@%@", user.screenname ];
    
    NSString *profileImageUrl = user.profileImageUrl;
    
    [self.profileImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileImageUrl] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:3]
                             placeholderImage:nil success: ^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
                                 self.profileImage.image = image;
                                 CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
                                 fade.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                                 fade.fromValue = [NSNumber numberWithFloat:0.0f];
                                 fade.toValue = [NSNumber numberWithFloat:1.0f];
                                 fade.duration = 0.5f;
                                 [self.profileImage.layer addAnimation:fade forKey:@"fade"];
                                 
                             } failure:nil];

    // Circle Image Style
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    self.profileImage.layer.borderWidth = 1.0f;
    self.profileImage.layer.borderColor = CGColorRetain([UIColor colorWithRed:0.335 green:0.632 blue:0.916 alpha:1.000].CGColor);
    

    // TODO: media preview
//    if(tweet.mediaUrl != nil){
//        [mv setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:tweet.mediaUrl] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:3] placeholderImage:nil success: ^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
//           // mv.image = image;
//        } failure:nil];
//    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.profileImage = nil;
}

@end
