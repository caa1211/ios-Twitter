//
//  TweetDetailViewController.h
//  ios-Twitter
//
//  Created by Carter Chang on 6/30/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Define.h"
#import "Tweet.h"
#import <UIImageView+AFNetworking.h>


@protocol TweetDetailViewControllerDelegate <NSObject>
- (void) didPostTweet:(Tweet*)tweet;
@end

@interface TweetDetailViewController : UIViewController
-(id) initWithUser:(User *)user andTweet:(Tweet *)tweet;
@property (nonatomic, weak) id <TweetDetailViewControllerDelegate> delegate;
@end
